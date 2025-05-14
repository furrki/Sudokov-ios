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
    
    // Added to track progress and detect when we're stuck
    private var lastProgressCount = 0
    private var stuckCounter = 0
    private var maxStuckThreshold = 500
    
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
    
    /// Configure the retry mechanism parameters
    /// - Parameters:
    ///   - threshold: Number of attempts before considering the process stuck
    func configureRetryMechanism(threshold: Int) {
        self.maxStuckThreshold = threshold
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
        
        // Number of cells to remain visible
        let visibleCells = depth
        // Number of cells to hide
        let cellsToHideCount = 81 - visibleCells
        
        // If requesting a very hard puzzle (20-24 hints), use the extreme generator
        if visibleCells <= 24 {
            let uniqueSolutionVerifier = UniqueSolutionVerifier(table: tableState)
            
            // Try to generate an extreme puzzle with the requested number of hints
            if let cellsToHideSet = uniqueSolutionVerifier.generateExtremePuzzle(
                targetHints: visibleCells, 
                maxIterations: 100,
                timeLimit: 120
            ) {
                self.cellsToHide = Array(cellsToHideSet)
                print("Generated extreme puzzle with \(visibleCells) hints")
                print("Unique solution: \(UniqueSolutionVerifier(table: tableState, cellsToRemove: cellsToHideSet).hasUniqueSolution())")
                return
            }
            
            // If extreme generation failed, fall back to the regular method with slightly more hints
            print("Extreme generation failed, falling back to standard method")
        }
        
        // Standard generation for easier puzzles or as fallback
        var cellsToHide = Set<Coordinate>()
        let triesTreshold = 5000
        var tries = 0
        
        // Reset progress tracking variables
        lastProgressCount = 0
        stuckCounter = 0
        
        while cellsToHide.count < cellsToHideCount {
            // Create verifier with current state
            let uniqueSolutionVerifier = UniqueSolutionVerifier(table: tableState, cellsToRemove: cellsToHide)
            
            // For harder puzzles (25-35 hints), use batch processing for efficiency
            if visibleCells <= 35 && cellsToHide.count > 40 {
                if let cell = uniqueSolutionVerifier.findSafeCellInBatches() {
                    cellsToHide.insert(cell)
                    tries = 0
                    stuckCounter = 0 // Reset stuck counter when making progress
                    lastProgressCount = cellsToHide.count
                    print("Cells to hide: \(cellsToHide.count)")
                    continue
                }
            }
            
            // For easier puzzles or if batch processing didn't find a cell
            if let cell = uniqueSolutionVerifier.selectRandomSafeCell() {
                cellsToHide.insert(cell)
                tries = 0
                stuckCounter = 0 // Reset stuck counter when making progress
                lastProgressCount = cellsToHide.count
                print("Cells to hide: \(cellsToHide.count)")
            } else {
                // If we can't find a safe cell, increment try counter
                tries += 1
                
                // Check if we're stuck at the same count for too long
                if lastProgressCount == cellsToHide.count {
                    stuckCounter += 1
                } else {
                    stuckCounter = 0
                    lastProgressCount = cellsToHide.count
                }
                
                // If we're stuck for too long, try backtracking
                if stuckCounter >= maxStuckThreshold && cellsToHide.count > 0 {
                    print("Stuck at \(cellsToHide.count) cells, backtracking...")
                    
                    // Remove a few cells from our set to try a different path
                    let backtrackAmount = min(5, cellsToHide.count / 10 + 1)
                    let cellsToRemove = Array(cellsToHide).shuffled().prefix(backtrackAmount)
                    for cell in cellsToRemove {
                        cellsToHide.remove(cell)
                    }
                    
                    stuckCounter = 0
                    print("Backtracked to \(cellsToHide.count) cells")
                }
            }
            
            // If we've tried too many times without success, start over
            if tries >= triesTreshold {
                print("Regenerating puzzle after \(tries) failed attempts")
                generateLevel()
                riskyCellGroups = getConflictableCellGroups(tableState: tableState)
                cellsToHide = Set<Coordinate>()
                tries = 0
                stuckCounter = 0
                lastProgressCount = 0
            }
        }
        
        self.cellsToHide = Array(cellsToHide)
        print("Generated puzzle with \(visibleCells) hints")
        print("Unique solution: \(UniqueSolutionVerifier(table: tableState, cellsToRemove: cellsToHide).hasUniqueSolution())")
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
