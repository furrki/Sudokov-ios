//
//  UniqueSolutionVerifier.swift
//  Sudokov
//
//  Created by Furkan Kaynar on 9.05.25.
//
import Foundation

/// Verifies if a Sudoku puzzle has a unique solution
class UniqueSolutionVerifier {
    var table: TableMatrix
    var cellsToRemove: Set<Coordinate> = []

    // Cache for cells that have been verified as unsafe in current state
    private var knownUnsafeCells = Set<Coordinate>()

    init(table: TableMatrix, cellsToRemove: Set<Coordinate> = []) {
        self.table = table
        self.cellsToRemove = cellsToRemove
    }
    
    /// Checks if the sudoku puzzle has a unique solution after removing cells
    /// - Returns: True if the puzzle has a unique solution, false otherwise
    func hasUniqueSolution() -> Bool {
        // Create a copy of the table with cells removed
        var puzzleWithRemovedCells = table
        for cell in cellsToRemove {
            puzzleWithRemovedCells[cell.row][cell.col] = 0
        }

        // Count solutions up to 2; unique if exactly 1
        let count = SolutionCounter.countSolutions(grid: puzzleWithRemovedCells, limit: 2)
        return count == 1
    }
    
    /// Finds a safe cell to remove that maintains unique solution
    /// - Returns: A coordinate that can be safely removed, or nil if none found
    func findSafeCellToRemove() -> Coordinate? {
        // Get all cells that are not already planned for removal
        let availableCells = getAllAvailableCells().filter { !knownUnsafeCells.contains($0) }

        // Try cells in order of their risk score (lowest risk first)
        let scoredCells = availableCells.map { ($0, calculateRiskScore(for: $0)) }
                                        .sorted { $0.1 < $1.1 }

        for (cell, _) in scoredCells {
            // Add this cell to the removal set
            let currentCellsToRemove = cellsToRemove
            cellsToRemove.insert(cell)

            // Check if the solution remains unique
            if hasUniqueSolution() {
                return cell
            }

            // Restore original removal set
            cellsToRemove = currentCellsToRemove

            // Remember this cell is unsafe in current state
            knownUnsafeCells.insert(cell)
        }

        return nil
    }

    /// Check if two cells are in the same unit (row, column, or box)
    private func isInSameUnitAs(_ cell1: Coordinate, other cell2: Coordinate) -> Bool {
        // Same row
        if cell1.row == cell2.row {
            return true
        }

        // Same column
        if cell1.col == cell2.col {
            return true
        }

        // Same box
        let box1Row = cell1.row / 3
        let box1Col = cell1.col / 3
        let box2Row = cell2.row / 3
        let box2Col = cell2.col / 3

        return box1Row == box2Row && box1Col == box2Col
    }
    
    /// Try to find safe cells in batches to speed up the process
    public func findSafeCellInBatches() -> Coordinate? {
        // Get cells not already planned for removal or known to be unsafe
        let availableCells = getAllAvailableCells().filter { !knownUnsafeCells.contains($0) }
        if availableCells.isEmpty {
            return nil
        }

        // Score cells by risk
        let scoredCells = availableCells.map { ($0, calculateRiskScore(for: $0)) }
                                        .sorted { $0.1 < $1.1 }

        // Take a batch of the lowest risk cells
        let batchSize = min(8, scoredCells.count)
        let batch = scoredCells.prefix(batchSize).map { $0.0 }

        // Try each cell in the batch
        for cell in batch {
            let currentCellsToRemove = cellsToRemove
            cellsToRemove.insert(cell)

            if hasUniqueSolution() {
                return cell
            }

            cellsToRemove = currentCellsToRemove
            knownUnsafeCells.insert(cell)
        }

        return nil
    }
    
    
    /// Selects a random cell to remove while ensuring the solution remains unique
    /// - Parameter preferredCells: Optional list of cells to prioritize for removal
    /// - Returns: A coordinate that can be safely removed, or nil if none found
    func selectRandomSafeCell(preferredCells: [Coordinate]? = nil) -> Coordinate? {
        // Try preferred cells first
        if let preferredCells = preferredCells {
            let randomizedPreferred = preferredCells.shuffled()
            
            for cell in randomizedPreferred {
                // Skip if already removed
                if cellsToRemove.contains(cell) {
                    continue
                }
                
                // Try removing this cell
                let currentCellsToRemove = cellsToRemove
                cellsToRemove.insert(cell)
                
                // Check if the solution remains unique
                if hasUniqueSolution() {
                    return cell
                }
                
                // Restore original removal set
                cellsToRemove = currentCellsToRemove
            }
        }
        
        // If no preferred cell works, try any available cell
        return findSafeCellToRemove()
    }
    
    /// Analyzes cells and returns them sorted by "safety" (likelihood of preserving unique solution)
    /// - Returns: An array of cells with their risk scores (lower score is safer)
    func analyzeCellSafetyScores() -> [(cell: Coordinate, riskScore: Int)] {
        let availableCells = getAllAvailableCells()
        var cellRiskScores = [(cell: Coordinate, riskScore: Int)]()
        
        for cell in availableCells {
            let score = calculateRiskScore(for: cell)
            cellRiskScores.append((cell: cell, riskScore: score))
        }
        
        // Sort by risk score (lower is safer)
        return cellRiskScores.sorted { $0.riskScore < $1.riskScore }
    }
    
    /// Calculates a risk score for removing a specific cell
    /// Higher score means higher risk of creating multiple solutions
    private func calculateRiskScore(for cell: Coordinate) -> Int {
        let row = cell.row
        let col = cell.col
        let value = table[row][col]

        // Create test puzzle with this cell removed
        var testPuzzle = table
        for c in cellsToRemove {
            testPuzzle[c.row][c.col] = 0
        }
        testPuzzle[row][col] = 0

        // Count constraint strength: how many ways can this cell be filled?
        var constraintCount = 0

        // Check row constraints
        let rowValues = Set(testPuzzle[row].filter { $0 != 0 })
        constraintCount += rowValues.count

        // Check column constraints
        var colValues = Set<Int>()
        for r in 0..<9 {
            if testPuzzle[r][col] != 0 {
                colValues.insert(testPuzzle[r][col])
            }
        }
        constraintCount += colValues.count

        // Check box constraints
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        var boxValues = Set<Int>()
        for r in boxRow..<boxRow+3 {
            for c in boxCol..<boxCol+3 {
                if testPuzzle[r][c] != 0 {
                    boxValues.insert(testPuzzle[r][c])
                }
            }
        }
        constraintCount += boxValues.count

        // Calculate available candidates for this cell
        let allConstraints = rowValues.union(colValues).union(boxValues)
        let candidateCount = 9 - allConstraints.count

        // Risk factors:
        // 1. More candidates = higher risk (less constrained)
        let candidateRisk = candidateCount * 10

        // 2. Weaker constraints = higher risk
        let constraintRisk = (27 - constraintCount) * 3

        // 3. If this is the only occurrence of this value in a unit, very risky
        let uniquenessRisk = isOnlyOccurrenceInAnyUnit(cell: cell) ? 50 : 0

        return candidateRisk + constraintRisk + uniquenessRisk
    }

    /// Check if this cell contains a value that appears only once in any of its units
    private func isOnlyOccurrenceInAnyUnit(cell: Coordinate) -> Bool {
        let value = table[cell.row][cell.col]

        // Check row
        var rowCount = 0
        for c in 0..<9 {
            if table[cell.row][c] == value && !cellsToRemove.contains(Coordinate(row: cell.row, col: c)) {
                rowCount += 1
            }
        }
        if rowCount == 1 { return true }

        // Check column
        var colCount = 0
        for r in 0..<9 {
            if table[r][cell.col] == value && !cellsToRemove.contains(Coordinate(row: r, col: cell.col)) {
                colCount += 1
            }
        }
        if colCount == 1 { return true }

        // Check box
        let boxRow = (cell.row / 3) * 3
        let boxCol = (cell.col / 3) * 3
        var boxCount = 0
        for r in boxRow..<boxRow+3 {
            for c in boxCol..<boxCol+3 {
                if table[r][c] == value && !cellsToRemove.contains(Coordinate(row: r, col: c)) {
                    boxCount += 1
                }
            }
        }
        if boxCount == 1 { return true }

        return false
    }
    
    /// Counts how many times a value appears in the puzzle
    private func countValueFrequency(_ value: Int) -> Int {
        var count = 0
        for row in 0..<9 {
            for col in 0..<9 {
                if table[row][col] == value {
                    count += 1
                }
            }
        }
        return count
    }
    
    /// Gets all cells that are not already planned for removal
    private func getAllAvailableCells() -> [Coordinate] {
        var availableCells = [Coordinate]()
        for row in 0..<9 {
            for col in 0..<9 {
                let coord = Coordinate(row: row, col: col)
                if !cellsToRemove.contains(coord) {
                    availableCells.append(coord)
                }
            }
        }
        return availableCells
    }
    
    
    /// Generates an extreme difficulty puzzle with minimal hints (17-24 hints)
    /// - Parameters:
    ///   - targetHints: Target number of hints to keep visible (61-64 cells to hide)
    ///   - maxIterations: Maximum iterations before giving up
    ///   - timeLimit: Maximum time in seconds to spend trying
    /// - Returns: Set of coordinates to hide, or nil if failed
    func generateExtremePuzzle(targetHints: Int = 22, maxIterations: Int = 50, timeLimit: TimeInterval = 60) -> Set<Coordinate>? {
        // Validate input
        guard targetHints >= 17 && targetHints <= 30 else {
            // 17 is theoretical minimum for valid sudoku
            return nil
        }
        
        // Reset state
        cellsToRemove.removeAll()
        knownUnsafeCells.removeAll()
        
        // Start with a simpler puzzle
        let initialHints = 30
        let targetCellsToHide = 81 - targetHints
        let initialCellsToHide = 81 - initialHints
        
        // Start with a simple seed by removing some cells randomly
        cellsToRemove.removeAll()
        let availableCells = getAllAvailableCells()
        
        // Add initial cells to remove (safer approach)
        let shuffledCells = availableCells.shuffled()
        for cell in shuffledCells.prefix(min(initialCellsToHide, shuffledCells.count)) {
            cellsToRemove.insert(cell)
            if !hasUniqueSolution() {
                cellsToRemove.remove(cell) // Remove if it breaks uniqueness
            }
        }
        
        // Save best result so far
        var bestResult = cellsToRemove
        
        // Record start time
        let startTime = Date()
        var iterations = 0
        
        // Progressive elimination with backtracking
        while cellsToRemove.count < targetCellsToHide && 
              iterations < maxIterations &&
              Date().timeIntervalSince(startTime) < timeLimit {
            
            iterations += 1
            
            // Try symmetrical elimination for aesthetic appeal
            if trySymmetricalElimination() {
                if cellsToRemove.count > bestResult.count {
                    bestResult = cellsToRemove
                }
                continue
            }
            
            // Try progressive elimination of low-risk candidates
            if tryProgressiveElimination() {
                if cellsToRemove.count > bestResult.count {
                    bestResult = cellsToRemove
                }
                continue
            }
            
            // Try the advanced elimination technique
            if tryAdvancedElimination() {
                if cellsToRemove.count > bestResult.count {
                    bestResult = cellsToRemove
                }
                continue
            }
            
            // If we're stuck, remove a cell and try a different path
            if cellsToRemove.count < targetCellsToHide {
                let backtrackAmount = Int.random(in: 1...3)
                backtrack(steps: backtrackAmount)
            }
        }
        
        // If we reached target, return the result
        if cellsToRemove.count >= targetCellsToHide {
            return cellsToRemove
        }
        
        // Otherwise return the best result we found
        return bestResult.count > initialCellsToHide ? bestResult : nil
    }
    
    /// Attempts to remove cells symmetrically while maintaining a unique solution
    /// - Returns: true if successful in removing more cells
    private func trySymmetricalElimination() -> Bool {
        let availableCells = getAllAvailableCells().filter { !knownUnsafeCells.contains($0) }
        
        // Try to remove cells in symmetric pairs
        for cell in availableCells {
            let symmetricCell = getSymmetricCell(for: cell)
            
            // Skip if symmetric cell is already removed
            if cellsToRemove.contains(symmetricCell) {
                continue
            }
            
            // Try removing both cells
            let currentCellsToRemove = cellsToRemove
            cellsToRemove.insert(cell)
            cellsToRemove.insert(symmetricCell)
            
            if hasUniqueSolution() {
                return true
            }
            
            // Restore original state
            cellsToRemove = currentCellsToRemove
        }
        
        return false
    }
    
    /// Gets the symmetrically opposite cell in the grid
    private func getSymmetricCell(for cell: Coordinate) -> Coordinate {
        return Coordinate(row: 8 - cell.row, col: 8 - cell.col)
    }
    
    /// Attempts to remove low-risk cells one by one
    /// - Returns: true if successful in removing more cells
    private func tryProgressiveElimination() -> Bool {
        let availableCells = getAllAvailableCells().filter { !knownUnsafeCells.contains($0) }
        
        // Try cells in order of their risk score (lowest risk first)
        let scoredCells = availableCells.map { ($0, calculateRiskScore(for: $0)) }
                                         .sorted { $0.1 < $1.1 }
                                         .prefix(10) // Top candidates only
        
        for (cell, _) in scoredCells {
            // Try removing this cell
            let currentCellsToRemove = cellsToRemove
            cellsToRemove.insert(cell)
            
            if hasUniqueSolution() {
                return true
            }
            
            // Restore original state
            cellsToRemove = currentCellsToRemove
            knownUnsafeCells.insert(cell)
        }
        
        return false
    }
    
    /// Try advanced elimination techniques for extreme puzzles
    /// - Returns: true if successful in removing more cells
    private func tryAdvancedElimination() -> Bool {
        
        // Try temporarily removing groups of cells
        let availableCells = getAllAvailableCells().filter { !knownUnsafeCells.contains($0) }
        
        // Try various small groups (2-3 cells)
        if availableCells.count >= 3 {
            for _ in 0..<min(5, availableCells.count / 3) {
                let randomCells = Array(availableCells.shuffled().prefix(3))
                
                // Save current state
                let currentCellsToRemove = cellsToRemove
                
                // Add these cells
                cellsToRemove.formUnion(randomCells)
                
                // Check if removing these cells works
                if hasUniqueSolution() {
                    return true
                }
                
                // If not, try each pair within the group
                for i in 0..<randomCells.count {
                    for j in (i+1)..<randomCells.count {
                        cellsToRemove = currentCellsToRemove
                        cellsToRemove.insert(randomCells[i])
                        cellsToRemove.insert(randomCells[j])
                        
                        if hasUniqueSolution() {
                            return true
                        }
                    }
                }
                
                // Restore original state
                cellsToRemove = currentCellsToRemove
            }
        }
        
        return false
    }
    
    
    /// Backtrack by removing a few cells from the set to try a different path
    private func backtrack(steps: Int) {
        if cellsToRemove.isEmpty {
            return
        }
        
        // Take a few random cells out of the set
        let cellsToRestore = Array(cellsToRemove).shuffled().prefix(steps)
        for cell in cellsToRestore {
            cellsToRemove.remove(cell)
        }
        
        // Also clear some of the unsafe cells cache to allow new paths
        knownUnsafeCells = Set(knownUnsafeCells.shuffled().prefix(knownUnsafeCells.count / 2))
    }
}
