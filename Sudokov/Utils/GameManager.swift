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
    var moves: [Move] = []

    @Published private(set) var solution: TableMatrix
    @Published private(set) var tableState: TableMatrix
    @Published private(set) var drafts: Dictionary<Coordinate, [Int]> = [:]
    @Published private(set) var fillContentMode: FillContentMode = .text
    @Published var selectedCell: Coordinate?

    // MARK: - Methods
    init() {
        solution = tableBuilder.tableState
        let builtTable = tableBuilder.removeCells(tableState: tableBuilder.tableState, depth: 38)
        tableState = builtTable
        tableFirstState = builtTable
    }

    func getGameSquare(i: Int, j: Int) -> GameSquareViewModel {
        let selectedNumber: Int?

        if let selectedCell = selectedCell,
           tableState[selectedCell.row][selectedCell.col] != 0 {
            selectedNumber = tableState[selectedCell.row][selectedCell.col]
        } else {
            selectedNumber = nil
        }

        return GameSquareViewModel(selectionType: self.selectionType(row: i, col: j),
                            contentType: self.contentType(row: i, col: j),
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


            moves.append(Move(row: selectedCell.row,
                              col: selectedCell.col,
                              moveType: .text,
                              content: [tableState[selectedCell.row][selectedCell.col]]))
            tableState[selectedCell.row][selectedCell.col] = value
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
    }
}
