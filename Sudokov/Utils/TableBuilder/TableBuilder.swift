//
//  GameManager.swift
//  Sudokov
//
//  Created by furrki on 13.07.2022.
//

import Foundation

enum BigSquareRelation {
    case horizontal
    case vertical
    case irrelevant
}

class TableBuilder: ObservableObject {
    // MARK: - Properties
    var table: TableMatrix {
        return tableState
    }
    
    @Published private(set) var tableState: TableMatrix
    @Published var index = 0
    
    private(set) var depth: Int?
    private(set) var cellsToHide = [Coordinate]()
    private(set) var riskyCellGroups = [[Coordinate]]()
    
    private let asymmetryAvoider: AsymmetryAvoider = AsymmetryAvoider()
    
    // MARK: - Methods
    init(tableState: TableMatrix? = nil, depth: Int? = nil) {
        self.depth = depth
        
        if let tableState = tableState {
            self.tableState = tableState
        } else {
            self.tableState = Array(repeating: Array(repeating: 0, count: 9), count: 9)
            
            makeLevel()
        }
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
        let nakedPairs = NakedPairsFinder(table: tableState).getAllNakedPairs()

        return Array(nakedPairs.map {
            Array($0)
        })
    }
    
    func makeLevel() {
        generateLevel()
        riskyCellGroups = getConflictableCellGroups(tableState: tableState)
        makeCellsToRemove()
        var hasSwordfish = iterateSwordFishCheck()
        
        while hasSwordfish {
            hasSwordfish = iterateSwordFishCheck()
            makeCellsToRemove()
        }
    }
                                                                
    private func makeCellsToRemove() {
        guard let depth = depth else {
            return
        }
        
        var cellsToHide = Set<Coordinate>()
        let triesTreshold = 5000
        var tries = 0
        
        while cellsToHide.count < (81 - depth) {
            if let cell = RandomCellPicker(table: tableState, cellsPlannedForRemoval: Array(cellsToHide)).pickCell() {
                if asymmetryAvoider.canRemoveSymmetrically(cell, cellsToHide: cellsToHide, isRiskyToRemove: isRiskyToRemove) {
                    tries = 0
                    asymmetryAvoider.removeSymmetrically(cell, cellsToHide: &cellsToHide, removeFromRiskyCellGroups: removeFromRiskyCellGroups)
                } else {
                    tries += 1
                }
            } else {
                tries += 1
            }
            
            if tries >= triesTreshold {
                generateLevel()
                riskyCellGroups = getConflictableCellGroups(tableState: tableState)
                cellsToHide = Set<Coordinate>()
                tries = 0
            }
        }
        
        self.cellsToHide = Array(cellsToHide)
    }
    
    private func isRiskyToRemove(cell: Coordinate) -> Bool {
        riskyCellGroups.contains { $0 == [cell] }
    }
    
    private func removeFromRiskyCellGroups(cell: Coordinate) {
        riskyCellGroups = riskyCellGroups.map { group in
            group.filter { $0 != cell }
        }
    }
    
    private func iterateSwordFishCheck() -> Bool {
        var hasSwordFish = false
        let swordfishCoordinates = SwordFishFinder(table: table, cellsPlannedForRemoval: self.cellsToHide).findAll()
        for swordfishCoordinate in swordfishCoordinates {
            if !riskyCellGroups.contains(swordfishCoordinate) {
                riskyCellGroups.append(swordfishCoordinate)
                hasSwordFish = true
                cellsToHide.removeAll {
                    $0 == swordfishCoordinate.first!
                }
            }
        }
        
        return hasSwordFish
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
}
