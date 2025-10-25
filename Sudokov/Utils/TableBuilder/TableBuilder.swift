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
    
    
    func generateLevel() {
        tableState = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        
        // Use more efficient backtracking with proper recursion
        if !fillBoardBacktrack() {
            // If generation fails, try again with different seed
            generateLevel()
        }
    }
    
    private func fillBoardBacktrack() -> Bool {
        // Find next empty cell
        guard let emptyCell = findNextEmptyCell() else {
            // Board is complete
            return true
        }
        
        let row = emptyCell.row
        let col = emptyCell.col
        let numbers = availableNumbers(row: row, col: col).shuffled()
        
        for number in numbers {
            tableState[row][col] = number
            
            if fillBoardBacktrack() {
                return true
            }
            
            // Backtrack
            tableState[row][col] = 0
        }
        
        return false
    }
    
    private func findNextEmptyCell() -> Coordinate? {
        for row in 0..<9 {
            for col in 0..<9 {
                if tableState[row][col] == 0 {
                    return Coordinate(row: row, col: col)
                }
            }
        }
        return nil
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
        var attempts = 0
        let maxAttempts = 5
        
        repeat {
            generateLevel()
            riskyCellGroups = getConflictableCellGroups(tableState: tableState)
            makeCellsToRemove()
            var hasSwordfish = iterateSwordFishCheck()
            
            while hasSwordfish {
                hasSwordfish = iterateSwordFishCheck()
                makeCellsToRemove()
            }
            
            attempts += 1
            
            // Validate puzzle quality
            if validatePuzzleQuality() {
                break
            } else if attempts < maxAttempts {
                print("Puzzle quality insufficient, regenerating... (attempt \(attempts + 1)/\(maxAttempts))")
            }
            
        } while attempts < maxAttempts
        
        if attempts >= maxAttempts {
            print("Warning: Generated puzzle may not meet quality standards after \(maxAttempts) attempts")
        }
    }
    
    private func validatePuzzleQuality() -> Bool {
        guard let targetDepth = depth else { return true }
        
        let actualHints = 81 - cellsToHide.count
        let hintDifference = abs(actualHints - targetDepth)
        
        // Accept puzzle if hints are within reasonable range
        let acceptableRange = targetDepth <= 25 ? 3 : 5
        if hintDifference > acceptableRange {
            return false
        }
        
        // Check for minimum puzzle complexity
        var puzzleToSolve = tableState
        for cell in cellsToHide {
            puzzleToSolve[cell.row][cell.col] = 0
        }
        
        let nakedSingles = countNakedSingles(in: puzzleToSolve)
        let totalEmptyCells = cellsToHide.count
        
        // Reject if puzzle has too many easy moves (naked singles) relative to difficulty
        let expectedDifficulty = Difficulty.getDifficulty(depth: targetDepth)
        switch expectedDifficulty {
        case .basic:
            return nakedSingles >= totalEmptyCells * 6 / 10 // 60%+ easy moves OK
        case .easy:
            return nakedSingles >= totalEmptyCells * 4 / 10 // 40%+ easy moves OK
        case .medium:
            return nakedSingles <= totalEmptyCells * 3 / 10 // Max 30% easy moves
        case .hard:
            return nakedSingles <= totalEmptyCells * 2 / 10 // Max 20% easy moves
        case .hardcore:
            return nakedSingles <= totalEmptyCells * 1 / 10 // Max 10% easy moves
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
        
        // For very hard puzzles (20-30 hints), use the extreme generator
        if visibleCells <= 30 {
            let uniqueSolutionVerifier = UniqueSolutionVerifier(table: tableState)
            
            // Try to generate an extreme puzzle with the requested number of hints
            if let cellsToHideSet = uniqueSolutionVerifier.generateExtremePuzzle(
                targetHints: visibleCells, 
                maxIterations: 200,
                timeLimit: 180
            ) {
                self.cellsToHide = Array(cellsToHideSet)
                print("Generated extreme puzzle with \(visibleCells) hints")
                print("Unique solution: \(UniqueSolutionVerifier(table: tableState, cellsToRemove: cellsToHideSet).hasUniqueSolution())")
                return
            }
            
            // If extreme generation failed, continue with standard method but with more attempts
            print("Extreme generation failed, continuing with enhanced standard method")
        }
        
        // Enhanced standard generation method
        var cellsToHide = Set<Coordinate>()
        let maxAttempts = visibleCells <= 30 ? 10000 : 5000 // More attempts for harder puzzles
        var attempts = 0
        
        // Reset progress tracking variables
        lastProgressCount = 0
        stuckCounter = 0
        
        while cellsToHide.count < cellsToHideCount && attempts < maxAttempts {
            // Create verifier with current state
            let uniqueSolutionVerifier = UniqueSolutionVerifier(table: tableState, cellsToRemove: cellsToHide)
            
            // Use batch processing for better efficiency
            if let cell = uniqueSolutionVerifier.findSafeCellInBatches() {
                cellsToHide.insert(cell)
                attempts = 0
                stuckCounter = 0
                lastProgressCount = cellsToHide.count
                
                // Print progress less frequently for performance
                if cellsToHide.count % 5 == 0 {
                    print("Cells to hide: \(cellsToHide.count)/\(cellsToHideCount)")
                }
                continue
            }
            
            // If batch processing fails, try individual cell selection
            if let cell = uniqueSolutionVerifier.selectRandomSafeCell() {
                cellsToHide.insert(cell)
                attempts = 0
                stuckCounter = 0
                lastProgressCount = cellsToHide.count
                continue
            }
            
            // Handle being stuck
            attempts += 1
            
            if lastProgressCount == cellsToHide.count {
                stuckCounter += 1
            } else {
                stuckCounter = 0
                lastProgressCount = cellsToHide.count
            }
            
            // Progressive backtracking strategy
            if stuckCounter >= maxStuckThreshold && cellsToHide.count > 10 {
                print("Stuck at \(cellsToHide.count) cells, backtracking...")
                
                // More aggressive backtracking for harder puzzles
                let backtrackAmount = visibleCells <= 30 ? 
                    min(8, cellsToHide.count / 8 + 2) : 
                    min(5, cellsToHide.count / 10 + 1)
                
                let cellsToBacktrack = Array(cellsToHide).shuffled().prefix(backtrackAmount)
                for cell in cellsToBacktrack {
                    cellsToHide.remove(cell)
                }
                
                stuckCounter = 0
                attempts = 0 // Reset attempts after backtracking
                print("Backtracked to \(cellsToHide.count) cells")
            }
        }
        
        // If we couldn't reach the target, accept what we have if it's reasonable
        if cellsToHide.count < cellsToHideCount {
            let achievedHints = 81 - cellsToHide.count
            if achievedHints >= visibleCells - 5 { // Accept if within 5 hints of target
                print("Settling for \(achievedHints) hints (target was \(visibleCells))")
            } else {
                print("Failed to generate sufficient difficulty, regenerating...")
                generateLevel()
                riskyCellGroups = getConflictableCellGroups(tableState: tableState)
                makeCellsToRemove()
                return
            }
        }
        
        self.cellsToHide = Array(cellsToHide)
        let actualDifficulty = assessPuzzleDifficulty()
        print("Generated puzzle with \(visibleCells) hints (Actual difficulty: \(actualDifficulty))")
        print("Unique solution: \(UniqueSolutionVerifier(table: tableState, cellsToRemove: cellsToHide).hasUniqueSolution())")
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
    
    // MARK: - Difficulty Assessment
    
    private func assessPuzzleDifficulty() -> String {
        // Create puzzle for solving
        var puzzleToSolve = tableState
        for cell in cellsToHide {
            puzzleToSolve[cell.row][cell.col] = 0
        }
        
        return analyzeSolvingTechniques(puzzle: puzzleToSolve)
    }
    
    /// Analyzes what solving techniques are actually required to solve the puzzle
    private func analyzeSolvingTechniques(puzzle: TableMatrix) -> String {
        var workingPuzzle = puzzle
        var candidates = generateCandidates(for: workingPuzzle)
        
        var techniques = [String]()
        let maxIterations = 100
        var iterations = 0
        
        while !isPuzzleComplete(workingPuzzle) && iterations < maxIterations {
            iterations += 1
            var progressMade = false
            
            // Try basic techniques first
            if let (row, col, num) = findNakedSingle(puzzle: workingPuzzle, candidates: candidates) {
                workingPuzzle[row][col] = num
                candidates = generateCandidates(for: workingPuzzle)
                if !techniques.contains("Naked Single") { techniques.append("Naked Single") }
                progressMade = true
                continue
            }
            
            if let (row, col, num) = findHiddenSingle(puzzle: workingPuzzle, candidates: candidates) {
                workingPuzzle[row][col] = num
                candidates = generateCandidates(for: workingPuzzle)
                if !techniques.contains("Hidden Single") { techniques.append("Hidden Single") }
                progressMade = true
                continue
            }
            
            // Try intermediate techniques
            if eliminateNakedPairs(candidates: &candidates) {
                if !techniques.contains("Naked Pair") { techniques.append("Naked Pair") }
                progressMade = true
                continue
            }
            
            if eliminatePointingPairs(puzzle: workingPuzzle, candidates: &candidates) {
                if !techniques.contains("Pointing Pairs") { techniques.append("Pointing Pairs") }
                progressMade = true
                continue
            }
            
            // Try advanced techniques
            if eliminateXWing(candidates: &candidates) {
                if !techniques.contains("X-Wing") { techniques.append("X-Wing") }
                progressMade = true
                continue
            }
            
            if eliminateSwordfish(candidates: &candidates) {
                if !techniques.contains("Swordfish") { techniques.append("Swordfish") }
                progressMade = true
                continue
            }
            
            // If no progress, break to avoid infinite loop
            if !progressMade {
                break
            }
        }
        
        // Determine difficulty based on techniques required
        if techniques.contains("Swordfish") || techniques.contains("X-Wing") {
            return "Hard"
        } else if techniques.contains("Pointing Pairs") || techniques.contains("Naked Pair") {
            return "Medium"
        } else if techniques.contains("Hidden Single") {
            return "Easy"
        } else {
            return "Simple"
        }
    }
    
    // MARK: - Solving Technique Implementations
    
    private func generateCandidates(for puzzle: TableMatrix) -> [[[Int]]] {
        var candidates = Array(repeating: Array(repeating: [Int](), count: 9), count: 9)
        
        for row in 0..<9 {
            for col in 0..<9 {
                if puzzle[row][col] == 0 {
                    candidates[row][col] = availableNumbers(tableState: puzzle, row: row, col: col)
                }
            }
        }
        
        return candidates
    }
    
    private func isPuzzleComplete(_ puzzle: TableMatrix) -> Bool {
        return !puzzle.flatMap { $0 }.contains(0)
    }
    
    private func findNakedSingle(puzzle: TableMatrix, candidates: [[[Int]]]) -> (Int, Int, Int)? {
        for row in 0..<9 {
            for col in 0..<9 {
                if puzzle[row][col] == 0 && candidates[row][col].count == 1 {
                    return (row, col, candidates[row][col][0])
                }
            }
        }
        return nil
    }
    
    private func findHiddenSingle(puzzle: TableMatrix, candidates: [[[Int]]]) -> (Int, Int, Int)? {
        // Check rows
        for row in 0..<9 {
            for num in 1...9 {
                let positions = (0..<9).filter { col in
                    puzzle[row][col] == 0 && candidates[row][col].contains(num)
                }
                if positions.count == 1 {
                    return (row, positions[0], num)
                }
            }
        }
        
        // Check columns
        for col in 0..<9 {
            for num in 1...9 {
                let positions = (0..<9).filter { row in
                    puzzle[row][col] == 0 && candidates[row][col].contains(num)
                }
                if positions.count == 1 {
                    return (positions[0], col, num)
                }
            }
        }
        
        // Check 3x3 boxes
        for boxRow in 0..<3 {
            for boxCol in 0..<3 {
                for num in 1...9 {
                    var positions: [(Int, Int)] = []
                    
                    for r in boxRow*3..<(boxRow+1)*3 {
                        for c in boxCol*3..<(boxCol+1)*3 {
                            if puzzle[r][c] == 0 && candidates[r][c].contains(num) {
                                positions.append((r, c))
                            }
                        }
                    }
                    
                    if positions.count == 1 {
                        return (positions[0].0, positions[0].1, num)
                    }
                }
            }
        }
        
        return nil
    }
    
    private func eliminateNakedPairs(candidates: inout [[[Int]]]) -> Bool {
        var progressMade = false
        
        // Check rows for naked pairs
        for row in 0..<9 {
            let rowCandidates = candidates[row]
            for col1 in 0..<8 {
                for col2 in (col1+1)..<9 {
                    if rowCandidates[col1].count == 2 && 
                       rowCandidates[col1] == rowCandidates[col2] {
                        // Found naked pair, eliminate from other cells in row
                        for col in 0..<9 {
                            if col != col1 && col != col2 {
                                let beforeCount = candidates[row][col].count
                                candidates[row][col] = candidates[row][col].filter { 
                                    !rowCandidates[col1].contains($0) 
                                }
                                if candidates[row][col].count < beforeCount {
                                    progressMade = true
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return progressMade
    }
    
    private func eliminatePointingPairs(puzzle: TableMatrix, candidates: inout [[[Int]]]) -> Bool {
        var progressMade = false
        
        // Check each 3x3 box
        for boxRow in 0..<3 {
            for boxCol in 0..<3 {
                for num in 1...9 {
                    var positions: [(Int, Int)] = []
                    
                    // Find all positions where this number can go in the box
                    for r in boxRow*3..<(boxRow+1)*3 {
                        for c in boxCol*3..<(boxCol+1)*3 {
                            if puzzle[r][c] == 0 && candidates[r][c].contains(num) {
                                positions.append((r, c))
                            }
                        }
                    }
                    
                    // Check if all positions are in the same row
                    if positions.count >= 2 && positions.allSatisfy({ $0.0 == positions[0].0 }) {
                        let row = positions[0].0
                        // Eliminate this number from other cells in the same row
                        for col in 0..<9 {
                            if col < boxCol*3 || col >= (boxCol+1)*3 {
                                let beforeCount = candidates[row][col].count
                                candidates[row][col] = candidates[row][col].filter { $0 != num }
                                if candidates[row][col].count < beforeCount {
                                    progressMade = true
                                }
                            }
                        }
                    }
                    
                    // Check if all positions are in the same column
                    if positions.count >= 2 && positions.allSatisfy({ $0.1 == positions[0].1 }) {
                        let col = positions[0].1
                        // Eliminate this number from other cells in the same column
                        for row in 0..<9 {
                            if row < boxRow*3 || row >= (boxRow+1)*3 {
                                let beforeCount = candidates[row][col].count
                                candidates[row][col] = candidates[row][col].filter { $0 != num }
                                if candidates[row][col].count < beforeCount {
                                    progressMade = true
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return progressMade
    }
    
    private func eliminateXWing(candidates: inout [[[Int]]]) -> Bool {
        var progressMade = false
        
        for num in 1...9 {
            // Check for X-Wing in rows
            for row1 in 0..<8 {
                for row2 in (row1+1)..<9 {
                    let cols1 = (0..<9).filter { candidates[row1][$0].contains(num) }
                    let cols2 = (0..<9).filter { candidates[row2][$0].contains(num) }
                    
                    if cols1.count == 2 && cols1 == cols2 {
                        // Found X-Wing, eliminate from columns
                        for col in cols1 {
                            for row in 0..<9 {
                                if row != row1 && row != row2 {
                                    let beforeCount = candidates[row][col].count
                                    candidates[row][col] = candidates[row][col].filter { $0 != num }
                                    if candidates[row][col].count < beforeCount {
                                        progressMade = true
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return progressMade
    }
    
    private func eliminateSwordfish(candidates: inout [[[Int]]]) -> Bool {
        var progressMade = false
        
        for num in 1...9 {
            // Check for Swordfish in rows (3 rows, 3 columns pattern)
            for row1 in 0..<7 {
                for row2 in (row1+1)..<8 {
                    for row3 in (row2+1)..<9 {
                        let cols1 = (0..<9).filter { candidates[row1][$0].contains(num) }
                        let cols2 = (0..<9).filter { candidates[row2][$0].contains(num) }
                        let cols3 = (0..<9).filter { candidates[row3][$0].contains(num) }
                        
                        // Each row should have 2-3 possible positions
                        if cols1.count >= 2 && cols1.count <= 3 &&
                           cols2.count >= 2 && cols2.count <= 3 &&
                           cols3.count >= 2 && cols3.count <= 3 {
                            
                            let allCols = Set(cols1 + cols2 + cols3)
                            
                            // Should form exactly 3 columns
                            if allCols.count == 3 {
                                let colsArray = Array(allCols)
                                
                                // Eliminate from other rows in these columns
                                for col in colsArray {
                                    for row in 0..<9 {
                                        if row != row1 && row != row2 && row != row3 {
                                            let beforeCount = candidates[row][col].count
                                            candidates[row][col] = candidates[row][col].filter { $0 != num }
                                            if candidates[row][col].count < beforeCount {
                                                progressMade = true
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return progressMade
    }
    
    private func countNakedSingles(in puzzle: TableMatrix) -> Int {
        var count = 0
        for row in 0..<9 {
            for col in 0..<9 {
                if puzzle[row][col] == 0 {
                    let available = availableNumbers(tableState: puzzle, row: row, col: col)
                    if available.count == 1 {
                        count += 1
                    }
                }
            }
        }
        return count
    }
    
    private func countHiddenSingles(in puzzle: TableMatrix) -> Int {
        var count = 0
        
        // Check rows
        for row in 0..<9 {
            for num in 1...9 {
                let positions = (0..<9).filter { col in
                    puzzle[row][col] == 0 && availableNumbers(tableState: puzzle, row: row, col: col).contains(num)
                }
                if positions.count == 1 {
                    count += 1
                }
            }
        }
        
        return count
    }
    
    private func countBoxLineReductions(in puzzle: TableMatrix) -> Int {
        // Simple heuristic: count cells that require more complex analysis
        var complexCells = 0
        for row in 0..<9 {
            for col in 0..<9 {
                if puzzle[row][col] == 0 {
                    let available = availableNumbers(tableState: puzzle, row: row, col: col)
                    if available.count >= 4 { // Cells with many possibilities
                        complexCells += 1
                    }
                }
            }
        }
        return complexCells / 3 // Rough approximation
    }
    
    private func calculateCellDistribution() -> Int {
        // Analyze how well distributed the removed cells are
        var rowCounts = Array(repeating: 0, count: 9)
        var colCounts = Array(repeating: 0, count: 9)
        var boxCounts = Array(repeating: 0, count: 9)
        
        for cell in cellsToHide {
            rowCounts[cell.row] += 1
            colCounts[cell.col] += 1
            let boxIndex = (cell.row / 3) * 3 + (cell.col / 3)
            boxCounts[boxIndex] += 1
        }
        
        // Calculate variance - more even distribution = higher score
        let rowVariance = calculateVariance(rowCounts)
        let colVariance = calculateVariance(colCounts)
        let boxVariance = calculateVariance(boxCounts)
        
        let avgVariance = (rowVariance + colVariance + boxVariance) / 3
        return max(0, 20 - Int(avgVariance)) // Lower variance = higher score
    }
    
    private func calculateVariance(_ values: [Int]) -> Double {
        let mean = Double(values.reduce(0, +)) / Double(values.count)
        let variance = values.reduce(0.0) { acc, val in
            acc + pow(Double(val) - mean, 2)
        } / Double(values.count)
        return variance
    }

    // MARK: - Private Methods
    
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
