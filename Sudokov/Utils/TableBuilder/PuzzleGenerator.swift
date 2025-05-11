//
//  PuzzleGenerator.swift
//  Sudokov
//
//  Created by Furkan Kaynar on 9.05.25.
//
import Foundation

/// Generates Sudoku puzzles of varying difficulty levels
class PuzzleGenerator: BigSquareIterator {
    let table: TableMatrix
    private var cellsToRemove: Set<Coordinate> = []
    private var knownSafeCells = Set<Coordinate>()
    private var knownUnsafeCells = Set<Coordinate>()
    private var dangerousPairs = [[Coordinate]]()
    private let verifier: UniqueSolutionVerifier
    private var safetyAnalyzer: CellSafetyAnalyzer
    
    init(table: TableMatrix) {
        self.table = table
        self.verifier = UniqueSolutionVerifier(table: table)
        self.safetyAnalyzer = CellSafetyAnalyzer(table: table, cellsToRemove: cellsToRemove)
    }
    
    /// Generate a puzzle with specified difficulty (number of cells to hide)
    /// - Parameters:
    ///   - difficulty: Number of cells to hide (higher = harder)
    ///   - maxAttempts: Maximum attempts before giving up
    /// - Returns: Set of coordinates to hide, or nil if failed
    func generatePuzzle(difficulty: Int, maxAttempts: Int = 10) -> Set<Coordinate>? {
        // Reset state
        cellsToRemove.removeAll()
        knownSafeCells.removeAll()
        knownUnsafeCells.removeAll()
        
        // Precompute dangerous pairs to avoid them
        precomputeDangerousPairs()
        
        // Update the safety analyzer with the new state
        updateSafetyAnalyzer()
        
        // Keep track of attempts
        var attempts = 0
        
        while cellsToRemove.count < difficulty {
            if let cell = findSafeCellInBatches() {
                cellsToRemove.insert(cell)
                updateSafetyAnalyzer()
                
                // Reset unsafe cells periodically to avoid getting stuck
                if cellsToRemove.count % 10 == 0 {
                    knownUnsafeCells.removeAll()
                }
            } else {
                // If we can't find a safe cell, start over
                attempts += 1
                if attempts >= maxAttempts {
                    return nil
                }
                
                // Start with a smaller set of removed cells
                let currentCount = cellsToRemove.count
                let keepCount = max(currentCount - 5, 0)
                if keepCount < currentCount {
                    let cellsToKeep = Array(cellsToRemove).shuffled().prefix(keepCount)
                    cellsToRemove = Set(cellsToKeep)
                }
                
                knownSafeCells.removeAll()
                knownUnsafeCells.removeAll()
                updateSafetyAnalyzer()
            }
        }
        
        return cellsToRemove
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
        
        // Generate a valid puzzle with more hints as a starting point
        if let initialCells = generatePuzzle(difficulty: initialCellsToHide) {
            cellsToRemove = initialCells
            updateSafetyAnalyzer()
        } else {
            return nil
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
                updateSafetyAnalyzer()
            }
        }
        
        // If we reached target, return the result
        if cellsToRemove.count >= targetCellsToHide {
            return cellsToRemove
        }
        
        // Otherwise return the best result we found
        return bestResult.count > initialCellsToHide ? bestResult : nil
    }
    
    /// Find a safe cell to remove that maintains unique solution
    private func findSafeCellToRemove() -> Coordinate? {
        // First try cells that we already know are safe
        if let safeCell = knownSafeCells.first {
            knownSafeCells.remove(safeCell)
            return safeCell
        }
        
        // Get all cells that are not already planned for removal
        let availableCells = safetyAnalyzer.getAllAvailableCells().filter { !knownUnsafeCells.contains($0) }
        
        // Try cells in order of their risk score (lowest risk first)
        let scoredCells = availableCells.map { ($0, safetyAnalyzer.calculateRiskScore(for: $0)) }
                                        .sorted { $0.1 < $1.1 }
        
        for (cell, _) in scoredCells {
            // Skip cells that are part of known dangerous pairs with already removed cells
            if safetyAnalyzer.isPartOfDangerousPair(cell) {
                continue
            }
            
            // Add this cell to the removal set
            let currentCellsToRemove = cellsToRemove
            cellsToRemove.insert(cell)
            verifier.cellsToRemove = cellsToRemove
            
            // Check if the solution remains unique
            if verifier.hasUniqueSolution() {
                // Remember other low-risk cells as potentially safe
                if let potentialSafeCells = findPotentialSafeCells(basedOn: cell, maxCount: 5) {
                    knownSafeCells.formUnion(potentialSafeCells)
                }
                return cell
            }
            
            // Restore original removal set
            cellsToRemove = currentCellsToRemove
            verifier.cellsToRemove = cellsToRemove
            
            // Remember this cell is unsafe
            knownUnsafeCells.insert(cell)
        }
        
        return nil
    }
    
    /// Find cells that are likely to be safe based on a known safe cell
    private func findPotentialSafeCells(basedOn safeCell: Coordinate, maxCount: Int) -> Set<Coordinate>? {
        let value = table[safeCell.row][safeCell.col]
        let availableCells = safetyAnalyzer.getAllAvailableCells().filter { 
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
    
    /// Updates the safety analyzer with the current state
    private func updateSafetyAnalyzer() {
        safetyAnalyzer = CellSafetyAnalyzer(
            table: table, 
            cellsToRemove: cellsToRemove,
            dangerousPairs: dangerousPairs
        )
        verifier.cellsToRemove = cellsToRemove
    }
    
    /// Precompute some dangerous pairs to avoid them during generation
    private func precomputeDangerousPairs() {
        // Sample a subset of cells to find dangerous pairs
        let sampleSize = min(30, safetyAnalyzer.getAllAvailableCells().count)
        let sampleCells = safetyAnalyzer.getAllAvailableCells().shuffled().prefix(sampleSize)
        
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
                verifier.cellsToRemove = cellsToRemove
                
                if !verifier.hasUniqueSolution() {
                    dangerousPairs.append([cell1, cell2])
                }
                
                // Restore original removal set
                cellsToRemove = currentCellsToRemove
                verifier.cellsToRemove = cellsToRemove
            }
        }
        
        updateSafetyAnalyzer()
    }
    
    /// Try to find safe cells in batches to speed up the process
    private func findSafeCellInBatches() -> Coordinate? {
        // If we have known safe cells, use them
        if let safeCell = knownSafeCells.first {
            knownSafeCells.remove(safeCell)
            return safeCell
        }
        
        // Get cells not already planned for removal or known to be unsafe
        let availableCells = safetyAnalyzer.getAllAvailableCells().filter { !knownUnsafeCells.contains($0) }
        if availableCells.isEmpty {
            return nil
        }
        
        // Score cells by risk
        let scoredCells = availableCells.map { ($0, safetyAnalyzer.calculateRiskScore(for: $0)) }
                                        .sorted { $0.1 < $1.1 }
        
        // Take a batch of the lowest risk cells
        let batchSize = min(5, scoredCells.count)
        let batch = scoredCells.prefix(batchSize).map { $0.0 }
        
        // Try each cell in the batch
        for cell in batch {
            if safetyAnalyzer.isPartOfDangerousPair(cell) {
                continue
            }
            
            let currentCellsToRemove = cellsToRemove
            cellsToRemove.insert(cell)
            verifier.cellsToRemove = cellsToRemove
            
            if verifier.hasUniqueSolution() {
                return cell
            }
            
            cellsToRemove = currentCellsToRemove
            verifier.cellsToRemove = cellsToRemove
            knownUnsafeCells.insert(cell)
        }
        
        return nil
    }
    
    /// Attempts to remove cells symmetrically while maintaining a unique solution
    /// - Returns: true if successful in removing more cells
    private func trySymmetricalElimination() -> Bool {
        let availableCells = safetyAnalyzer.getAllAvailableCells().filter { !knownUnsafeCells.contains($0) }
        
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
            verifier.cellsToRemove = cellsToRemove
            
            if verifier.hasUniqueSolution() {
                return true
            }
            
            // Restore original state
            cellsToRemove = currentCellsToRemove
            verifier.cellsToRemove = cellsToRemove
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
        let availableCells = safetyAnalyzer.getAllAvailableCells().filter { !knownUnsafeCells.contains($0) }
        
        // Try cells in order of their risk score (lowest risk first)
        let scoredCells = availableCells.map { ($0, safetyAnalyzer.calculateRiskScore(for: $0)) }
                                         .sorted { $0.1 < $1.1 }
                                         .prefix(10) // Top candidates only
        
        for (cell, _) in scoredCells {
            // Try removing this cell
            let currentCellsToRemove = cellsToRemove
            cellsToRemove.insert(cell)
            verifier.cellsToRemove = cellsToRemove
            
            if verifier.hasUniqueSolution() {
                return true
            }
            
            // Restore original state
            cellsToRemove = currentCellsToRemove
            verifier.cellsToRemove = cellsToRemove
            knownUnsafeCells.insert(cell)
        }
        
        return false
    }
    
    /// Try advanced elimination techniques for extreme puzzles
    /// - Returns: true if successful in removing more cells
    private func tryAdvancedElimination() -> Bool {
        // Try patterns of cells that might work together
        if tryPatternBasedElimination() {
            return true
        }
        
        // Try temporarily removing groups of cells
        let availableCells = safetyAnalyzer.getAllAvailableCells().filter { !knownUnsafeCells.contains($0) }
        
        // Try various small groups (2-3 cells)
        if availableCells.count >= 3 {
            for _ in 0..<min(5, availableCells.count / 3) {
                let randomCells = Array(availableCells.shuffled().prefix(3))
                
                // Save current state
                let currentCellsToRemove = cellsToRemove
                
                // Add these cells
                cellsToRemove.formUnion(randomCells)
                verifier.cellsToRemove = cellsToRemove
                
                // Check if removing these cells works
                if verifier.hasUniqueSolution() {
                    return true
                }
                
                // If not, try each pair within the group
                for i in 0..<randomCells.count {
                    for j in (i+1)..<randomCells.count {
                        cellsToRemove = currentCellsToRemove
                        cellsToRemove.insert(randomCells[i])
                        cellsToRemove.insert(randomCells[j])
                        verifier.cellsToRemove = cellsToRemove
                        
                        if verifier.hasUniqueSolution() {
                            return true
                        }
                    }
                }
                
                // Restore original state
                cellsToRemove = currentCellsToRemove
                verifier.cellsToRemove = cellsToRemove
            }
        }
        
        return false
    }
    
    /// Try to eliminate cells based on common sudoku patterns
    private func tryPatternBasedElimination() -> Bool {
        // Try to isolate a region or line
        let regions = [
            // Try vertical regions (columns)
            getColumnCells(0, 1, 2),
            getColumnCells(3, 4, 5),
            getColumnCells(6, 7, 8),
            
            // Try horizontal regions (rows)
            getRowCells(0, 1, 2),
            getRowCells(3, 4, 5),
            getRowCells(6, 7, 8),
            
            // Try 3x3 boxes
            getBoxCells(0, 0),
            getBoxCells(0, 3),
            getBoxCells(0, 6),
            getBoxCells(3, 0),
            getBoxCells(3, 3),
            getBoxCells(3, 6),
            getBoxCells(6, 0),
            getBoxCells(6, 3),
            getBoxCells(6, 6)
        ]
        
        for region in regions {
            let availableCellsInRegion = region.filter { !cellsToRemove.contains($0) }
            if availableCellsInRegion.count > 0 && availableCellsInRegion.count <= 4 {
                // Try to remove all but one cell in this region
                let currentCellsToRemove = cellsToRemove
                
                for cell in availableCellsInRegion.dropLast(1) {
                    cellsToRemove.insert(cell)
                }
                verifier.cellsToRemove = cellsToRemove
                
                if verifier.hasUniqueSolution() {
                    return true
                }
                
                // Restore original state
                cellsToRemove = currentCellsToRemove
                verifier.cellsToRemove = cellsToRemove
            }
        }
        
        return false
    }
    
    /// Get cells in a column range
    private func getColumnCells(_ col1: Int, _ col2: Int, _ col3: Int) -> [Coordinate] {
        var cells = [Coordinate]()
        for row in 0..<9 {
            cells.append(Coordinate(row: row, col: col1))
            cells.append(Coordinate(row: row, col: col2))
            cells.append(Coordinate(row: row, col: col3))
        }
        return cells
    }
    
    /// Get cells in a row range
    private func getRowCells(_ row1: Int, _ row2: Int, _ row3: Int) -> [Coordinate] {
        var cells = [Coordinate]()
        for col in 0..<9 {
            cells.append(Coordinate(row: row1, col: col))
            cells.append(Coordinate(row: row2, col: col))
            cells.append(Coordinate(row: row3, col: col))
        }
        return cells
    }
    
    /// Get cells in a 3x3 box
    private func getBoxCells(_ startRow: Int, _ startCol: Int) -> [Coordinate] {
        var cells = [Coordinate]()
        for row in startRow..<(startRow + 3) {
            for col in startCol..<(startCol + 3) {
                cells.append(Coordinate(row: row, col: col))
            }
        }
        return cells
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
