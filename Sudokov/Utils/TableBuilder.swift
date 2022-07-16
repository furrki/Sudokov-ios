//
//  GameManager.swift
//  Sudokov
//
//  Created by furrki on 13.07.2022.
//

import Foundation

class TableBuilder: ObservableObject {
    // MARK: - Constants and Structures
    struct Cell: Hashable {
        let row: Int
        let col: Int
    }

    // MARK: - Properties
    var table: TableMatrix {
        return tableState
//        if tableStates.isEmpty || index < 0 || index >= tableStates.count {
//            return tableState
//        } else {
//            return tableStates[index]
//        }
    }

    @Published private(set) var tableState: TableMatrix
    @Published private(set) var tableStates: [TableMatrix] = []
    @Published var index = 0

    // MARK: - Methods
    init() {
        tableState = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        generateLevel()
    }

    func generateLevel() {
        tableStates.removeAll()
        tableState = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        for i in 0...8 {
            for j in 0...8 {
                if tableState[i][j] == 0 {
                    let numbers = availableNumbers(row: i, col: j)
                    if numbers.isEmpty {
                        tableStates.append(tableState)
                        backTrace(row: i, col: j)
                        tableStates.append(tableState)

                    } else {
                        tableState[i][j] = numbers.randomElement() ?? 0
                    }
                }
            }
        }

        let hasZero = tableState.contains {
            $0.contains(0)
        }

        if hasZero {
            generateLevel()
            return
        }
    }

    func availableNumbers(tableState: TableMatrix,
                          row: Int,
                          col: Int,
                          shouldCheckRows: Bool = true,
                          shouldCheckCols: Bool = true,
                          shouldCheckSquares: Bool = true) -> [Int] {
        var available = Array(1...9)

        if shouldCheckRows {
            for i in 0...8 {
                let square = tableState[row][i]

                if i != col, square != 0, available.contains(square) {
                    available.removeAll {
                        $0 == square
                    }
                }
            }
        }

        if shouldCheckCols {
            for i in 0...8 {
                let square = tableState[i][col]

                if i != row, square != 0, available.contains(square) {
                    available.removeAll {
                        $0 == square
                    }
                }
            }
        }

        if shouldCheckSquares {
            let bigRow = row / 3
            let bigCol = col / 3

            for i in (bigRow * 3)...(bigRow * 3 + 2) {
                for j in (bigCol * 3)...(bigCol * 3 + 2) {
                    let square = tableState[i][j]

                    if i != row, j != col, square != 0, available.contains(square) {
                        available.removeAll {
                            $0 == square
                        }
                    }
                }
            }
        }
        return available
    }

    func removeCells(tableState: TableMatrix,
                     depth: Int) -> TableMatrix {
        var cellsToHide = Set<Cell>()
        var newTableState = tableState

        while cellsToHide.count < (81 - depth) {
            cellsToHide.insert(Cell(row: Int.random(in: 0...8), col: Int.random(in: 0...8)))
        }

        for cell in cellsToHide {
            newTableState[cell.row][cell.col] = 0
        }

        return newTableState
    }

    // MARK: - Private Methods
    private func backTrace(row: Int, col: Int) {
        tableState[row][col] = 0
        tableStates.append(tableState)
        var i = row
        while i >= 0 {
            var j = col
            while j > 0 {
                j -= 1

                if !hasConflict(row: row, col: col, i: i, j: j) {
                    tableState[row][col] = tableState[i][j]
                    tableStates.append(tableState)
                    tableState[i][j] = availableNumbers(row: i, col: j).randomElement() ?? 0
                    tableStates.append(tableState)
                    j = 0
                    i = -1
                }
            }

            i -= 1
        }
    }

    private func hasConflict(row: Int,
                             col: Int,
                             i: Int,
                             j: Int) -> Bool {
        let tmp = tableState[i][j]
        tableState[i][j] = 0

        var available = availableNumbers(row: i, col: j)
        available.removeAll {
            $0 == tmp
        }
        if availableNumbers(row: row, col: col).contains(tmp) && available.count > 0 {
            tableState[i][j] = tmp
            return false
        } else {
            tableState[i][j] = tmp
            return true
        }
    }

    private func availableNumbers(row: Int,
                          col: Int,
                          shouldCheckRows: Bool = true,
                          shouldCheckCols: Bool = true,
                          shouldCheckSquares: Bool = true) -> [Int] {
        availableNumbers(tableState: tableState,
                         row: row,
                         col: col,
                         shouldCheckRows: shouldCheckRows,
                         shouldCheckCols: shouldCheckCols,
                         shouldCheckSquares: shouldCheckSquares)
    }
}
