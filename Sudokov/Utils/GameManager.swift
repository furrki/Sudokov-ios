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
        static let startingLives: Int = 3
    }

    enum FillContentMode {
        case draft
        case text
    }

    struct Coordinate: Hashable {
        let row: Int
        let col: Int
    }

    // MARK: - Properties
    let tableBuilder = TableBuilder()
    private let tableFirstState: TableMatrix
    private let solution: TableMatrix
    private let configuration: GameConfiguration
    private var bag = Set<AnyCancellable>()
    private var moves: [Move] = []
    private var conflicts: [Coordinate] = []
    private var unmatches: [Coordinate] = []
    private(set) var lives: Int = Constants.startingLives {
        didSet {
            livesText = "Lives: \(lives)/\(Constants.startingLives)"
        }
    }

    @Published private(set) var livesText = "Lives: \(Constants.startingLives)/\(Constants.startingLives)"
    @Published private(set) var options: [Int] = []
    @Published private(set) var tableState: TableMatrix
    @Published private(set) var drafts: Dictionary<Coordinate, [Int]> = [:]
    @Published private(set) var fillContentMode: FillContentMode = .text
    @Published var selectedCell: Coordinate?

    // MARK: - Methods
    init(configuration: GameConfiguration = GameConfiguration.shared) {
        solution = tableBuilder.tableState
        let builtTable = tableBuilder.removeCells(tableState: tableBuilder.tableState, depth: 38)
        tableState = builtTable
        tableFirstState = builtTable
        self.configuration = configuration
        addBinders()
    }

    func addBinders() {
        if configuration.featureFlags.hideNotNeededNumberButtons {
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
        switch fillContentMode {
        case .draft:
            fillContentMode = .text
        case .text:
            fillContentMode = .draft
        }
    }

    func setValue(_ value: Int) {
        guard let selectedCell = selectedCell,
              tableFirstState[selectedCell.row][selectedCell.col] == 0 else {
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
        }
        objectWillChange.send()
    }

    func removeValue() {
        guard let selectedCell = selectedCell,
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

        tableState[selectedCell.row][selectedCell.col] = 0
        updateConflicts(coordinate: selectedCell)
    }

    func availableNumbers(row: Int,
                          col: Int) -> [Int] {
        tableBuilder.availableNumbers(tableState: tableState, row: row, col: col)
    }

    func revertMove() {
        guard let lastMove = moves.last else {
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
                draft.value.contains(value) && (draft.key.row == coordinate.row || draft.key.col == coordinate.col)
            }
            .forEach { draft in
                moves.append(Move(row: draft.key.row, col: draft.key.col, moveType: .draftProgramatically, content: drafts[draft.key] ?? []))
                drafts[draft.key]?.removeAll {
                    $0 == value
                }
            }
    }

    private func updateLives(coordinate: Coordinate, value: Int) {
        if configuration.featureFlags.lives {
            let shouldLoseLifeByConflict = configuration.featureFlags.alertConflict && !tableBuilder.availableNumbers(tableState: tableState, row: coordinate.row, col: coordinate.col).contains(value)
            let shouldLoseLifeByUnmatch = configuration.featureFlags.alertNotMatch && solution[coordinate.row][coordinate.col] != value

            if shouldLoseLifeByConflict || shouldLoseLifeByUnmatch {
                lives -= 1
            }
        }
    }

    private func updateConflicts(coordinate: Coordinate) {
        if configuration.featureFlags.alertConflict {
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

        if configuration.featureFlags.alertNotMatch {
            unmatches.removeAll { _ in
                self.solution[coordinate.row][coordinate.col] == self.tableState[coordinate.row][coordinate.col] || self.tableState[coordinate.row][coordinate.col] == 0
            }

            if self.solution[coordinate.row][coordinate.col] != self.tableState[coordinate.row][coordinate.col] {
                unmatches.append(coordinate)
            }
        }
    }
}
