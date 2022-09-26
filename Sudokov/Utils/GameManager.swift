//
//  GameManager.swift
//  Sudokov
//
//  Created by furrki on 13.row7.2022.
//

import Foundation
import Combine

class GameManager: ObservableObject {
    // MARK: - Constants Enums
    private enum Constants {
        static let startingLives = 3
        static let perSecondSave = 5
    }

    enum FillContentMode {
        case draft
        case text
    }
    
    // MARK: - Properties
    let tableBuilder = TableBuilder()
    private let storageManager: StorageManager
    private let tableFirstState: TableMatrix
    private let solution: TableMatrix
    private let featureFlagManager: FeatureFlagManager
    private let analyticsManager: AnalyticsManager
    private var bag = Set<AnyCancellable>()
    private var timerCancellable: AnyCancellable?
    private var moves: [Move] = []
    private var conflicts: [Coordinate] = []
    private var unmatches: [Coordinate] = []
    private var secondsPast: Int {
        didSet {
            timerText = secondsPast.getFormattedCounter()
        }
    }

    let level: TemplateLevel?

    private(set) var lives: Int = Constants.startingLives {
        didSet {
            let livesToShow = lives >= 0 ? lives : 0
            livesText = "Lives: \(livesToShow)/\(Constants.startingLives)"
        }
    }

    @Published private(set) var isAbandoned: Bool = false
    @Published private(set) var livesText: String
    @Published private(set) var timerText: String
    @Published private(set) var options: [Int] = []
    @Published private(set) var tableState: TableMatrix
    @Published private(set) var drafts: Dictionary<Coordinate, [Int]> = [:]
    @Published private(set) var fillContentMode: FillContentMode = .text
    @Published var selectedCell: Coordinate?
    @Published var levelState: LevelState

    // MARK: - Computed Properties
    var isGameActive: Bool {
        levelState == .solving
    }

    private var levelAnalytics: LevelAnalytics {
        if let level = level {
            return LevelAnalytics(level: level.visualLevel, difficulty: level.difficulty)
        }

        return LevelAnalytics(level: -1, difficulty: level?.difficulty ?? .normal)
    }

    // MARK: - Methods
    init(level: Level,
         templateLevel: TemplateLevel?,
         storageManager: StorageManager = DependencyManager.storageManager,
         analyticsManager: AnalyticsManager = DependencyManager.analyticsManager) {
        solution = level.table

        let builtTable = level.table.enumerated().compactMap { rowIndex, row in
            row.enumerated().compactMap { colIndex, value -> Int in
                if level.cellsToHide.contains(Coordinate(row: rowIndex, col: colIndex)) {
                    return 0
                } else {
                    return value
                }
            }
        }

        tableState = builtTable
        tableFirstState = builtTable
        self.featureFlagManager = storageManager.featureFlagManager
        self.analyticsManager = analyticsManager
        self.storageManager = storageManager
        self.level = templateLevel
        self.secondsPast = 0
        self.timerText = 0.getFormattedCounter()

        let livesToShow = lives >= 0 ? lives : 0
        self.livesText = "Lives: \(livesToShow)/\(Constants.startingLives)"
        self.levelState = .solving
        addBinders()
    }

    init(levelInfo: LevelInfo,
         storageManager: StorageManager = DependencyManager.storageManager,
         analyticsManager: AnalyticsManager = DependencyManager.analyticsManager) {
        self.tableFirstState = levelInfo.tableFirstState
        self.solution = levelInfo.solution
        self.drafts = levelInfo.drafts
        self.moves = levelInfo.moves
        self.conflicts = levelInfo.conflicts
        self.unmatches = levelInfo.unmatches
        self.lives = levelInfo.lives
        self.options = levelInfo.options
        self.tableState = levelInfo.tableState
        self.featureFlagManager = storageManager.featureFlagManager
        self.analyticsManager = analyticsManager
        self.storageManager = storageManager
        self.secondsPast = levelInfo.secondsPast
        self.timerText = levelInfo.secondsPast.getFormattedCounter()

        let livesToShow = lives >= 0 ? lives : 0
        self.livesText = "Lives: \(livesToShow)/\(Constants.startingLives)"
        self.level = levelInfo.level
        self.levelState = levelInfo.levelState
        addBinders()
        objectWillChange.send()
    }

    func saveState() {
        let levelInfo = LevelInfo(tableFirstState: tableFirstState,
                                  solution: solution,
                                  drafts: drafts,
                                  moves: moves,
                                  conflicts: conflicts,
                                  unmatches: unmatches,
                                  lives: lives,
                                  options: options,
                                  tableState: tableState,
                                  level: level,
                                  levelState: levelState,
                                  secondsPast: secondsPast)
        storageManager.currentLevelInfo = levelInfo
    }

    private func saveToSolvedLevels() {
        if let templateLevel = level, !storageManager.solvedLevels.contains(templateLevel) {
            storageManager.solvedLevels.append(templateLevel)
        }
    }

    private func addBinders() {
        if featureFlagManager.hideNotNeededNumberButtons {
            $tableState
                .map { rows in
                    var options: [Int] = (0...8).map { _ in 0 }

                    rows.forEach { row in
                        row.forEach { col in
                            guard col != 0 else {
                                return
                            }

                            options[col - 1] += 1
                        }
                    }

                    return options
                        .enumerated()
                        .compactMap { index, value in
                            if value < 9 {
                                return index + 1
                            }

                            return nil
                        }

                }
                .assign(to: \.options, on: self)
                .store(in: &bag)
        }

        if featureFlagManager.timer {
            timerCancellable = Timer.publish(every: 1.0, on: .main, in: .default)
                .autoconnect()
                .sink { [weak self] seconds in
                    self?.tickSecond()
                }
        }
    }

    func getGameSquare(i: Int, j: Int) -> GameSquareViewModel {
        let selectedNumber: Int?

        if let selectedCell = selectedCell,
           tableState[selectedCell.row][selectedCell.col] != 0 {
            selectedNumber = tableState[selectedCell.row][selectedCell.col]
        } else {
            selectedNumber = nil
        }

        let isAlerting = conflicts.contains(Coordinate(row: i, col: j)) || unmatches.contains(Coordinate(row: i, col: j))
        return GameSquareViewModel(selectionType: self.selectionType(row: i, col: j),
                                   contentType: self.contentType(row: i, col: j),
                                   isAlerting: isAlerting,
                                   content: self.tableState[i][j],
                                   drafts: drafts[Coordinate(row: i, col: j)] ?? [],
                                   row: i,
                                   col: j,
                                   squareSize: self.tableState.count,
                                   boldNumber: selectedNumber)
    }

    func switchFillContentMode() {
        guard isGameActive else {
            return
        }

        switch fillContentMode {
        case .draft:
            fillContentMode = .text
            analyticsManager.logEvent(.gameTurnOffDraft)
        case .text:
            fillContentMode = .draft
            analyticsManager.logEvent(.gameTurnOnDraft)
        }
    }

    func abandonGame() {
        storageManager.currentLevelInfo = nil
        analyticsManager.logEvent(.gameAbandon, parameters: levelAnalytics)
        timerCancellable?.cancel()
        isAbandoned = true
    }

    func setValue(_ value: Int) {
        guard let selectedCell = selectedCell,
              tableFirstState[selectedCell.row][selectedCell.col] == 0,
              isGameActive else {
            return
        }

        switch fillContentMode {
        case .draft:
            let element = tableState[selectedCell.row][selectedCell.col]
            guard element == 0 else {
                return
            }

            if drafts[selectedCell]?.contains(value) ?? false {
                moves.append(Move(row: selectedCell.row,
                                  col: selectedCell.col,
                                  moveType: .draft,
                                  content: drafts[selectedCell] ?? []))
                drafts[selectedCell]?.removeAll {
                    $0 == value
                }
            } else {
                moves.append(Move(row: selectedCell.row,
                                  col: selectedCell.col,
                                  moveType: .draft,
                                  content: drafts[selectedCell] ?? []))

                if drafts[selectedCell] != nil {
                    drafts[selectedCell]?.append(value)
                } else {
                    drafts[selectedCell] = [value]
                }
            }

        case .text:
            if let drafts = drafts[selectedCell] {
                moves.append(Move(row: selectedCell.row,
                                  col: selectedCell.col,
                                  moveType: .draftProgramatically,
                                  content: drafts))
                self.drafts[selectedCell]?.removeAll()
            }

            removeConcerningDrafts(coordinate: selectedCell, value: value)

            if value != tableState[selectedCell.row][selectedCell.col] {
                moves.append(Move(row: selectedCell.row,
                                  col: selectedCell.col,
                                  moveType: .text,
                                  content: [tableState[selectedCell.row][selectedCell.col]]))
                updateLives(coordinate: selectedCell, value: value)
                tableState[selectedCell.row][selectedCell.col] = value
                updateConflicts(coordinate: selectedCell)
            }

            checkWin()
        }

        objectWillChange.send()
        saveState()
    }

    func removeValue() {
        guard let selectedCell = selectedCell,
              isGameActive,
              tableFirstState[selectedCell.row][selectedCell.col] == 0 else {
            return
        }

        if let drafts = drafts[selectedCell] {
            moves.append(Move(row: selectedCell.row,
                              col: selectedCell.col,
                              moveType: .draft,
                              content: drafts))
            self.drafts[selectedCell]?.removeAll()
        }

        if tableState[selectedCell.row][selectedCell.col] != 0 {
            moves.append(Move(row: selectedCell.row,
                              col: selectedCell.col,
                              moveType: .text,
                              content: [tableState[selectedCell.row][selectedCell.col]]))
        }

        analyticsManager.logEvent(.gameRemove, parameters: CellLevelAnalytics(cellAnalytics: CellAnalytics(coordinate: selectedCell, currentValue: tableState[selectedCell.row][selectedCell.col]),
                                                                              levelAnalytics: levelAnalytics))
        tableState[selectedCell.row][selectedCell.col] = 0
        updateConflicts(coordinate: selectedCell)
        saveState()
    }

    func availableNumbers(row: Int, col: Int) -> [Int] {
        tableBuilder.availableNumbers(tableState: tableState, row: row, col: col)
    }

    func revertMove() {
        guard let lastMove = moves.last,
              isGameActive else {
            return
        }

        switch lastMove.moveType {
        case .text:
            if let number = lastMove.content.first {
                tableState[lastMove.row][lastMove.col] = number
            }
        case .draft, .draftProgramatically:
            drafts[Coordinate(row: lastMove.row, col: lastMove.col)] = lastMove.content
        }

        moves.removeLast()

        selectedCell = Coordinate(row: lastMove.row, col: lastMove.col)

        if moves.last?.moveType == .draftProgramatically {
            revertMove()
        }

        updateConflicts(coordinate: Coordinate(row: lastMove.row, col: lastMove.col))
        saveState()
        analyticsManager.logEvent(.gameRevert, parameters: levelAnalytics)
    }

    private func tickSecond() {
        if featureFlagManager.timer {
            secondsPast += 1

            if secondsPast % Constants.perSecondSave == 0 {
                saveState()
            }
        }
    }

    private func checkWin() {
        if tableState.allSatisfy({ row in
            row.allSatisfy { col in
                col != 0
            }
        }) && conflicts.isEmpty {
            timerCancellable?.cancel()
            analyticsManager.logEvent(.gameFinish, parameters: levelAnalytics)
            levelState = .justWon
            saveToSolvedLevels()
            selectedCell = nil
        }
    }

    private func checkLose() {
        guard featureFlagManager.lives, lives < 0 else {
            return
        }
        
        analyticsManager.logEvent(.gameLost, parameters: levelAnalytics)
        timerCancellable?.cancel()
        self.levelState = .justLost
        selectedCell = nil
    }

    private func contentType(row: Int, col: Int) -> GameSquareViewModel.ContentType {
        if tableFirstState[row][col] != 0 {
            return .levelGeneratedValue
        }

        if tableState[row][col] != 0 {
            return .userAddedValue
        }

        if !(drafts[Coordinate(row: row, col: col)]?.isEmpty ?? true) {
            return .draft
        }

        return .userAddedValue
    }

    private func selectionType(row: Int,
                               col: Int) -> GameSquareViewModel.SelectionType {
        guard let selectedCell = selectedCell else {
            return .none
        }

        if selectedCell.row == row && selectedCell.col == col {
            return .selection
        } else if selectedCell.row == row || selectedCell.col == col {
            return .secondary
        }

        let content = tableState[row][col]
        if content != 0 && content == tableState[selectedCell.row][selectedCell.col] {
            return .primary
        }

        let selectedBigRow = selectedCell.row / 3
        let selectedBigCol = selectedCell.col / 3

        let bigRow = row / 3
        let bigCol = col / 3

        if bigRow == selectedBigRow && bigCol == selectedBigCol {
            return .secondary
        }

        return .none
    }

    private func removeConcerningDrafts(coordinate: Coordinate, value: Int) {
        drafts
            .filter { draft in
                draft.value.contains(value) && (draft.key.row == coordinate.row || draft.key.col == coordinate.col ||
                    (coordinate.row / 3 == draft.key.row / 3 && coordinate.col / 3 == draft.key.col / 3))
            }
            .forEach { draft in
                moves.append(Move(row: draft.key.row, col: draft.key.col, moveType: .draftProgramatically, content: drafts[draft.key] ?? []))
                drafts[draft.key]?.removeAll {
                    $0 == value
                }
            }
    }

    private func updateLives(coordinate: Coordinate, value: Int) {
        if featureFlagManager.lives {
            let shouldLoseLifeByConflict = featureFlagManager.alertConflict && !tableBuilder.availableNumbers(tableState: tableState, row: coordinate.row, col: coordinate.col).contains(value)
            let shouldLoseLifeByUnmatch = featureFlagManager.alertNotMatch && solution[coordinate.row][coordinate.col] != value

            if shouldLoseLifeByConflict || shouldLoseLifeByUnmatch {
                lives -= 1
                checkLose()
            }
        }
    }

    private func updateConflicts(coordinate: Coordinate) {
        if featureFlagManager.alertConflict {
            conflicts.removeAll {
                tableBuilder.availableNumbers(tableState: tableState, row: $0.row, col: $0.col).contains(tableState[$0.row][$0.col])
            }

            for i in 0...8 {
                if !tableBuilder.availableNumbers(tableState: tableState, row: i, col: coordinate.col).contains(tableState[i][coordinate.col]) {
                    conflicts.append(Coordinate(row: i, col: coordinate.col))
                }

                if !tableBuilder.availableNumbers(tableState: tableState, row: coordinate.row, col: i).contains(tableState[coordinate.row][i]) {
                    conflicts.append(Coordinate(row: coordinate.row, col: i))
                }
            }

            let bigRow = coordinate.row / 3
            let bigCol = coordinate.col / 3

            for i in (bigRow * 3)...(bigRow * 3 + 2) {
                for j in (bigCol * 3)...(bigCol * 3 + 2) {
                    if !tableBuilder.availableNumbers(tableState: tableState, row: i, col: j).contains(tableState[i][j]) {
                        conflicts.append(Coordinate(row: i, col: j))
                    }
                }
            }
        }

        if featureFlagManager.alertNotMatch {
            unmatches.removeAll { _ in
                self.solution[coordinate.row][coordinate.col] == self.tableState[coordinate.row][coordinate.col] || self.tableState[coordinate.row][coordinate.col] == 0
            }

            if self.solution[coordinate.row][coordinate.col] != self.tableState[coordinate.row][coordinate.col] {
                unmatches.append(coordinate)
            }
        }
    }
}
