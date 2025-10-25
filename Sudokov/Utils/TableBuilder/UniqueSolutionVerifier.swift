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
    
    // Cache for cells that have been verified as safe
    private var knownSafeCells = Set<Coordinate>()
    // Cache for cells that have been verified as unsafe
    private var knownUnsafeCells = Set<Coordinate>()
    // Cache for dangerous pairs
    private var dangerousPairs = [[Coordinate]]()
    
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
        // First try cells that we already know are safe
        if let safeCell = knownSafeCells.first {
            knownSafeCells.remove(safeCell)
            return safeCell
        }
        
        // Get all cells that are not already planned for removal
        let availableCells = getAllAvailableCells().filter { !knownUnsafeCells.contains($0) }
        
        // Try cells in order of their risk score (lowest risk first)
        let scoredCells = availableCells.map { ($0, calculateRiskScore(for: $0)) }
                                        .sorted { $0.1 < $1.1 }
        
        for (cell, _) in scoredCells {
            // Skip cells that are part of known dangerous pairs with already removed cells
            if isPartOfDangerousPair(cell) {
                continue
            }
            
            // Add this cell to the removal set
            let currentCellsToRemove = cellsToRemove
            cellsToRemove.insert(cell)
            
            // Check if the solution remains unique
            if hasUniqueSolution() {
                // Remember other low-risk cells as potentially safe
                if let potentialSafeCells = findPotentialSafeCells(basedOn: cell, maxCount: 5) {
                    knownSafeCells.formUnion(potentialSafeCells)
                }
                return cell
            }
            
            // Restore original removal set
            cellsToRemove = currentCellsToRemove
            
            // Remember this cell is unsafe
            knownUnsafeCells.insert(cell)
        }
        
        return nil
    }
    
    /// Check if a cell is part of a dangerous pair with already removed cells
    private func isPartOfDangerousPair(_ cell: Coordinate) -> Bool {
        for pair in dangerousPairs {
            if pair.contains(cell) && pair.contains(where: { cellsToRemove.contains($0) }) {
                return true
            }
        }
        return false
    }
    
    /// Find cells that are likely to be safe based on a known safe cell
    private func findPotentialSafeCells(basedOn safeCell: Coordinate, maxCount: Int) -> Set<Coordinate>? {
        let value = table[safeCell.row][safeCell.col]
        let availableCells = getAllAvailableCells().filter { 
            !knownUnsafeCells.contains($0) && 
            self.table[$0.row][$0.col] == value &&
            !isInSameUnitAs(safeCell, other: $0)
        }
        
        // Limit the number of potential safe cells
        if !availableCells.isEmpty {
            return Set(availableCells.shuffled().prefix(maxCount))
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
    
    
    /// Precompute some dangerous pairs to avoid them during generation
    private func precomputeDangerousPairs() {
        // Sample a subset of cells to find dangerous pairs
        let sampleSize = min(30, getAllAvailableCells().count)
        let sampleCells = getAllAvailableCells().shuffled().prefix(sampleSize)
        
        dangerousPairs = []
        
        // Check all pairs in the sample
        for i in sampleCells.indices {
            for j in sampleCells.indices.dropFirst(i + 1) {
                let cell1 = sampleCells[i]
                let cell2 = sampleCells[j]
                
                // Skip cells in the same unit as they're less likely to form dangerous pairs
                if isInSameUnitAs(cell1, other: cell2) {
                    continue
                }
                
                // Test if removing both cells creates multiple solutions
                let currentCellsToRemove = cellsToRemove
                cellsToRemove.insert(cell1)
                cellsToRemove.insert(cell2)
                
                if !hasUniqueSolution() {
                    dangerousPairs.append([cell1, cell2])
                }
                
                // Restore original removal set
                cellsToRemove = currentCellsToRemove
            }
        }
    }
    
    /// Try to find safe cells in batches to speed up the process
    public func findSafeCellInBatches() -> Coordinate? {
        // If we have known safe cells, use them
        if let safeCell = knownSafeCells.first {
            knownSafeCells.remove(safeCell)
            return safeCell
        }
        
        // Get cells not already planned for removal or known to be unsafe
        let availableCells = getAllAvailableCells().filter { !knownUnsafeCells.contains($0) }
        if availableCells.isEmpty {
            return nil
        }
        
        // Score cells by risk
        let scoredCells = availableCells.map { ($0, calculateRiskScore(for: $0)) }
                                        .sorted { $0.1 < $1.1 }
        
        // Take a batch of the lowest risk cells
        let batchSize = min(5, scoredCells.count)
        let batch = scoredCells.prefix(batchSize).map { $0.0 }
        
        // Try each cell in the batch
        for cell in batch {
            if isPartOfDangerousPair(cell) {
                continue
            }
            
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
        
        // Count how many times this value appears in the puzzle
        let valueFrequency = countValueFrequency(value)
        
        // Count cells already removed in same row, column and 3x3 box
        let rowRemovals = cellsToRemove.filter { $0.row == row }.count
        let colRemovals = cellsToRemove.filter { $0.col == col }.count
        
        let boxRow = (row / 3) * 3
        let boxCol = (col / 3) * 3
        let boxRemovals = cellsToRemove.filter { 
            $0.row >= boxRow && $0.row < boxRow + 3 && 
            $0.col >= boxCol && $0.col < boxCol + 3 
        }.count
        
        // Calculate risk based on these factors
        // Higher weights for factors that contribute more to non-uniqueness
        let valueWeight = 2
        let rowWeight = 3
        let colWeight = 3
        let boxWeight = 4
        
        // Add penalty for cells that are part of dangerous pairs
        let pairPenalty = isPartOfDangerousPair(cell) ? 15 : 0
        
        return (9 - valueFrequency) * valueWeight + 
               rowRemovals * rowWeight + 
               colRemovals * colWeight + 
               boxRemovals * boxWeight +
               pairPenalty
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
        knownSafeCells.removeAll()
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
