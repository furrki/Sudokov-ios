//
//  GameManager.swift
//  Sudokov
//
//  Created by furrki on 13.07.2022.
//

import Foundation

class TableBuilder: ObservableObject {
    // MARK: - Properties
    var table: TableMatrix {
        return tableState
    }

    @Published private(set) var tableState: TableMatrix
    @Published var index = 0

    // MARK: - Methods
    init() {
        tableState = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        generateLevel()
    }

    func generateLevel() {
        tableState = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        for i in 0...8 {
            for j in 0...8 {
                if tableState[i][j] == 0 {
                    let numbers = availableNumbers(row: i, col: j)
                    if numbers.isEmpty {
                        backTrace(row: i, col: j)
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

    func getConflictableCellGroups(tableState: TableMatrix) -> [[Coordinate]] {
        let tableSize = 8
        var possibleConflicts = Set<Set<Coordinate>>()

        for row in 0...tableSize {
            for i in 0...tableSize {
                // Matches for rows - rows or cols to cols
                if i < tableSize {
                    for j in ((i + 1)...tableSize) {
                        let iValue = tableState[row][i]
                        let jValue = tableState[row][j]

                        let iIndex = getRowIndex(tableState: tableState, col: i, of: jValue)
                        let jIndex = getRowIndex(tableState: tableState, col: j, of: iValue)

                        if iIndex == jIndex {
                            let coordinates: Set<Coordinate> = [
                                Coordinate(row: row, col: i),
                                Coordinate(row: row, col: j),
                                Coordinate(row: jIndex, col: i),
                                Coordinate(row: iIndex, col: j),
                            ]

                            possibleConflicts.insert(coordinates)
                        }
                    }
                }

                // cross checks for multiple puzzles
                if (row + 1) % 3 != 0 {
                    // \ cross
                    if (i + 1) % 3 != 0 {
                        let iValue = tableState[row][i]
                        let jValue = tableState[row + 1][i + 1]

                        let iRowIndex = getRowIndex(tableState: tableState, col: i, of: jValue)
                        let jRowIndex = getRowIndex(tableState: tableState, col: i + 1, of: iValue)

                        let iColIndex = getColIndex(tableState: tableState, row: row, of: jValue)
                        let jColIndex = getColIndex(tableState: tableState, row: row + 1, of: iValue)

                        if iRowIndex == jRowIndex && iColIndex == jColIndex {
                            let coordinates: Set<Coordinate> = [
                                Coordinate(row: row, col: i),
                                Coordinate(row: row + 1, col: i + 1),
                            ]
                            possibleConflicts.insert(coordinates)
                        }
                    }

                    // / cross
                    if i > 0 && (i - 1) % 3 != 0 {
                        let iValue = tableState[row][i]
                        let jValue = tableState[row + 1][i - 1]

                        let iRowIndex = getRowIndex(tableState: tableState, col: i, of: jValue)
                        let jRowIndex = getRowIndex(tableState: tableState, col: i - 1, of: iValue)

                        let iColIndex = getColIndex(tableState: tableState, row: row, of: jValue)
                        let jColIndex = getColIndex(tableState: tableState, row: row + 1, of: iValue)

                        if iRowIndex == jRowIndex && iColIndex == jColIndex {
                            let coordinates: Set<Coordinate> = [
                                Coordinate(row: row, col: i),
                                Coordinate(row: row + 1, col: i - 1),
                            ]
                            possibleConflicts.insert(coordinates)
                        }
                    }
                }
            }
        }

        return Array(possibleConflicts.map {
            Array($0)
        })
    }

    func makeCellsToRemove(tableState: TableMatrix, depth: Int) -> [Coordinate] {
        var riskyCellGroups = getConflictableCellGroups(tableState: tableState)
        var cellsToHide = Set<Coordinate>()

        while cellsToHide.count < (81 - depth) {
            let cell = Coordinate(row: Int.random(in: 0...8), col: Int.random(in: 0...8))

            let isRiskyToRemove: Bool = riskyCellGroups.contains {
                $0 == [cell]
            }

            if !isRiskyToRemove {
                cellsToHide.insert(cell)
                riskyCellGroups = riskyCellGroups.map {
                    $0.compactMap { cellInRiskyGroup in
                        if cellInRiskyGroup == cell {
                            return nil
                        }

                        return cellInRiskyGroup
                    }
                }
            }
        }

        return Array(cellsToHide)
    }

    // MARK: - Private Methods
    private func backTrace(row: Int, col: Int) {
        tableState[row][col] = 0
        var i = row
        while i >= 0 {
            var j = col
            while j > 0 {
                j -= 1

                if !hasConflict(row: row, col: col, i: i, j: j) {
                    tableState[row][col] = tableState[i][j]
                    tableState[i][j] = availableNumbers(row: i, col: j).randomElement() ?? 0
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

    private func getRowIndex(tableState: TableMatrix, col: Int, of value: Int) -> Int {
        for i in 0...8 {
            if tableState[i][col] == value {
                return i
            }
        }
        return -1
    }

    private func getColIndex(tableState: TableMatrix, row: Int, of value: Int) -> Int {
        for i in 0...8 {
            if tableState[row][i] == value {
                return i
            }
        }
        return -1
    }
}
