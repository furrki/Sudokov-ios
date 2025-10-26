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
    @Published var generationProgress: Double = 0.0
    @Published var generationMessage: String = ""

    private(set) var depth: Int?
    private(set) var cellsToHide = [Coordinate]()
    private(set) var riskyCellGroups = [[Coordinate]]()

    // Added to track progress and detect when we're stuck
    private var lastProgressCount = 0
    private var stuckCounter = 0
    private var maxStuckThreshold = 500

    // Progress callback
    var onProgress: ((Double, String) -> Void)?
    
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

        updateProgress(0.1, "Generating base puzzle...")

        // Use more efficient backtracking with proper recursion
        if !fillBoardBacktrack() {
            // If generation fails, try again with different seed
            generateLevel()
        }

        updateProgress(0.2, "Base puzzle ready")
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
        let maxAttempts = 3
        var bestPuzzle: (TableMatrix, [Coordinate], Double)?

        repeat {
            generateLevel()
            riskyCellGroups = getConflictableCellGroups(tableState: tableState)
            makeCellsToRemove()

            attempts += 1

            // Track best puzzle found so far
            if bestPuzzle == nil {
                bestPuzzle = (tableState, cellsToHide, calculatePuzzleScore())
            } else if let best = bestPuzzle {
                let currentScore = calculatePuzzleScore()
                if currentScore > best.2 {
                    bestPuzzle = (tableState, cellsToHide, currentScore)
                }
            }

            // Validate puzzle quality
            if validatePuzzleQuality() {
                updateProgress(1.0, "Quality check passed!")
                break
            } else if attempts < maxAttempts {
                updateProgress(0.15 + (0.05 * Double(attempts)), "Quality check failed, retrying...")
                print("Puzzle quality insufficient, regenerating... (attempt \(attempts + 1)/\(maxAttempts))")
            }

        } while attempts < maxAttempts

        // Fallback to best puzzle if all attempts failed
        if attempts >= maxAttempts {
            if let best = bestPuzzle {
                print("Using best puzzle found (score: \(best.2)) after \(maxAttempts) attempts")
                updateProgress(0.95, "Accepting best puzzle...")
                tableState = best.0
                cellsToHide = best.1
            } else {
                print("Warning: No valid puzzle generated, using last attempt")
            }
        }
    }

    /// Calculate a simple quality score (higher is better)
    private func calculatePuzzleScore() -> Double {
        guard let targetDepth = depth else { return 0 }

        let actualHints = 81 - cellsToHide.count
        let hintDifference = abs(actualHints - targetDepth)

        // Closer to target = higher score
        let hintScore = max(0, 10.0 - Double(hintDifference))

        // Check uniqueness
        let hasUnique = UniqueSolutionVerifier(table: tableState, cellsToRemove: Set(cellsToHide)).hasUniqueSolution()
        let uniqueScore = hasUnique ? 10.0 : 0.0

        return hintScore + uniqueScore
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

        // Check for minimum puzzle complexity by simulating solving
        var puzzleToSolve = tableState
        for cell in cellsToHide {
            puzzleToSolve[cell.row][cell.col] = 0
        }

        // Analyze solving path with technique counts
        let (techniques, techniqueCounts, totalMoves) = analyzeSolvingPathWithCounts(puzzle: puzzleToSolve)

        let expectedDifficulty = Difficulty.getDifficulty(depth: targetDepth)

        // Calculate percentage of trivial moves (naked singles)
        let nakedSingleCount = techniqueCounts["Naked Single"] ?? 0
        let trivialPercentage = totalMoves > 0 ? Double(nakedSingleCount) / Double(totalMoves) : 0

        switch expectedDifficulty {
        case .basic, .easy:
            // Easy puzzles: straightforward solving, can use basic techniques
            // Just ensure it's solvable with singles (don't force specific percentage)
            return techniques.contains("Naked Single") || techniques.contains("Hidden Single")
        case .medium:
            // Medium: max 40% naked singles, must have hidden singles or pairs
            return trivialPercentage <= 0.4 &&
                   (techniques.contains("Hidden Single") || techniques.contains("Naked Pair"))
        case .hard:
            // Hard: max 25% naked singles, requires intermediate techniques
            guard trivialPercentage <= 0.25 else { return false }
            return techniques.contains("Pointing Pairs") ||
                   techniques.contains("Naked Pair") ||
                   (techniqueCounts["Hidden Single"] ?? 0) >= 5
        case .hardcore:
            // Hardcore: max 30% naked singles, requires advanced techniques or variety
            guard trivialPercentage <= 0.30 else { return false }
            return techniques.contains("X-Wing") ||
                   techniques.contains("Swordfish") ||
                   techniques.contains("Pointing Pairs") ||
                   techniques.count >= 3
        }
    }

    /// Analyzes the actual solving path and counts technique usage
    /// Only counts a technique as "required" if no easier technique was available at that step
    private func analyzeSolvingPathWithCounts(puzzle: TableMatrix) -> (Set<String>, [String: Int], Int) {
        var workingPuzzle = puzzle
        var candidates = generateCandidates(for: workingPuzzle)
        var techniques = Set<String>()
        var techniqueCounts: [String: Int] = [:]
        var totalMoves = 0
        let maxIterations = 100
        var iterations = 0

        while !isPuzzleComplete(workingPuzzle) && iterations < maxIterations {
            iterations += 1
            var progressMade = false
            var techniqueUsed: String?

            // Try techniques in order, track which one is actually needed

            // Level 1: Naked single
            if let (row, col, num) = findNakedSingle(puzzle: workingPuzzle, candidates: candidates) {
                workingPuzzle[row][col] = num
                candidates = generateCandidates(for: workingPuzzle)
                techniqueUsed = "Naked Single"
                progressMade = true
            }
            // Level 2: Hidden single (only if no naked single)
            else if let (row, col, num) = findHiddenSingle(puzzle: workingPuzzle, candidates: candidates) {
                workingPuzzle[row][col] = num
                candidates = generateCandidates(for: workingPuzzle)
                techniqueUsed = "Hidden Single"
                progressMade = true
            }
            // Level 3: Naked pairs (only if no singles)
            else if eliminateNakedPairs(candidates: &candidates) {
                techniqueUsed = "Naked Pair"
                progressMade = true
            }
            // Level 4: Pointing pairs (only if no simpler technique)
            else if eliminatePointingPairs(puzzle: workingPuzzle, candidates: &candidates) {
                techniqueUsed = "Pointing Pairs"
                progressMade = true
            }
            // Level 5: X-Wing (only if nothing simpler works)
            else if eliminateXWing(candidates: &candidates) {
                techniqueUsed = "X-Wing"
                progressMade = true
            }
            // Level 6: Swordfish (only if nothing simpler works)
            else if eliminateSwordfish(candidates: &candidates) {
                techniqueUsed = "Swordfish"
                progressMade = true
            }

            // Record the technique that was actually needed
            if let technique = techniqueUsed {
                techniques.insert(technique)
                techniqueCounts[technique, default: 0] += 1
                totalMoves += 1
            }

            if !progressMade {
                break
            }
        }

        return (techniques, techniqueCounts, totalMoves)
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
                maxIterations: 150,
                timeLimit: 120
            ) {
                self.cellsToHide = Array(cellsToHideSet)
                print("Generated extreme puzzle with \(visibleCells) hints")
                return
            }

            // If extreme generation failed, continue with standard method but with more attempts
            print("Extreme generation failed, continuing with enhanced standard method")
        }

        // Simplified generation: progressive removal with smart backtracking
        var cellsToHide = Set<Coordinate>()
        var attemptsSinceProgress = 0
        let maxAttemptsWithoutProgress = 200

        updateProgress(0.3, "Removing cells: 0/\(cellsToHideCount)")

        while cellsToHide.count < cellsToHideCount && attemptsSinceProgress < maxAttemptsWithoutProgress {
            let uniqueSolutionVerifier = UniqueSolutionVerifier(table: tableState, cellsToRemove: cellsToHide)

            // Try to find safe cell
            if let cell = uniqueSolutionVerifier.findSafeCellInBatches() ?? uniqueSolutionVerifier.findSafeCellToRemove() {
                cellsToHide.insert(cell)
                attemptsSinceProgress = 0

                if cellsToHide.count % 5 == 0 {
                    let progress = 0.3 + (0.6 * Double(cellsToHide.count) / Double(cellsToHideCount))
                    updateProgress(progress, "Removing cells: \(cellsToHide.count)/\(cellsToHideCount)")
                }
                continue
            }

            attemptsSinceProgress += 1

            // Smart backtrack if stuck
            if attemptsSinceProgress >= 100 && cellsToHide.count > 10 {
                print("Stuck at \(cellsToHide.count) cells, smart backtracking...")

                var testPuzzle = tableState
                for c in cellsToHide {
                    testPuzzle[c.row][c.col] = 0
                }

                // Remove least-constrained cells (most candidates = causing problems)
                let cellsWithScores = cellsToHide.map { cell -> (Coordinate, Int) in
                    let available = availableNumbers(tableState: testPuzzle, row: cell.row, col: cell.col)
                    return (cell, available.count)
                }.sorted { $0.1 > $1.1 }

                let backtrackAmount = min(5, cellsToHide.count / 10)
                for i in 0..<backtrackAmount {
                    cellsToHide.remove(cellsWithScores[i].0)
                }

                print("Backtracked to \(cellsToHide.count) cells")
                attemptsSinceProgress = 0
            }
        }

        // Final acceptance logic
        if cellsToHide.count < cellsToHideCount {
            let achievedHints = 81 - cellsToHide.count
            let difference = visibleCells - achievedHints

            if difference <= 3 {
                print("Close enough: \(achievedHints) hints (target: \(visibleCells))")
            } else if cellsToHide.count < cellsToHideCount / 2 {
                print("Far from target, regenerating...")
                generateLevel()
                riskyCellGroups = getConflictableCellGroups(tableState: tableState)
                makeCellsToRemove()
                return
            } else {
                print("Accepting: \(achievedHints) hints (target: \(visibleCells))")
            }
        }

        self.cellsToHide = Array(cellsToHide)

        // Use the validation logic to get difficulty assessment
        var puzzleToSolve = tableState
        for cell in cellsToHide {
            puzzleToSolve[cell.row][cell.col] = 0
        }
        updateProgress(0.9, "Analyzing difficulty...")

        let (techniques, _, _) = analyzeSolvingPathWithCounts(puzzle: puzzleToSolve)
        let difficultyLabel = determineDifficultyLabel(from: techniques)

        updateProgress(1.0, "Complete!")

        print("Generated puzzle with \(81 - cellsToHide.count) hints (Difficulty: \(difficultyLabel), Techniques: \(techniques.sorted().joined(separator: ", ")))")
    }

    private func updateProgress(_ progress: Double, _ message: String) {
        DispatchQueue.main.async {
            self.generationProgress = progress
            self.generationMessage = message
            self.onProgress?(progress, message)
        }
    }

    /// Determines difficulty label based on techniques used
    private func determineDifficultyLabel(from techniques: Set<String>) -> String {
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
