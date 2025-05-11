//
//  DangerousCellFinder.swift
//  Sudokov
//
//  Created by Furkan Kaynar on 9.05.25.
//
import Foundation

/// Identifies groups of cells that when removed would lead to multiple solutions
class DangerousCellFinder {
    private let table: TableMatrix
    private var cellsToRemove: Set<Coordinate>
    private let verifier: UniqueSolutionVerifier
    
    init(table: TableMatrix, cellsToRemove: Set<Coordinate> = []) {
        self.table = table
        self.cellsToRemove = cellsToRemove
        self.verifier = UniqueSolutionVerifier(table: table, cellsToRemove: cellsToRemove)
    }
    
    /// Identifies dangerous cell groups that would create multiple solutions if removed together
    /// - Parameter maxGroupSize: Maximum size of cell groups to check (2 or 3)
    /// - Returns: Array of cell groups that would lead to multiple solutions
    func findDangerousCellGroups(maxGroupSize: Int = 3) -> [[Coordinate]] {
        var dangerousGroups = [[Coordinate]]()
        
        // Get all cells not already planned for removal
        let availableCells = getAllAvailableCells()
        
        // Check pairs of cells
        if maxGroupSize >= 2 {
            for i in 0..<availableCells.count {
                for j in (i+1)..<availableCells.count {
                    let pair = [availableCells[i], availableCells[j]]
                    
                    // Save current state
                    let currentCellsToRemove = cellsToRemove
                    
                    // Add this pair to removal set
                    cellsToRemove.formUnion(pair)
                    verifier.cellsToRemove = cellsToRemove
                    
                    // Check if removing these cells creates multiple solutions
                    if !verifier.hasUniqueSolution() {
                        dangerousGroups.append(pair)
                    }
                    
                    // Restore original removal set
                    cellsToRemove = currentCellsToRemove
                    verifier.cellsToRemove = cellsToRemove
                }
            }
        }
        
        // Check triplets of cells
        if maxGroupSize >= 3 {
            for i in 0..<availableCells.count {
                for j in (i+1)..<availableCells.count {
                    for k in (j+1)..<availableCells.count {
                        let triplet = [availableCells[i], availableCells[j], availableCells[k]]
                        
                        // Save current state
                        let currentCellsToRemove = cellsToRemove
                        
                        // Add this triplet to removal set
                        cellsToRemove.formUnion(triplet)
                        verifier.cellsToRemove = cellsToRemove
                        
                        // Check if removing these cells creates multiple solutions
                        if !verifier.hasUniqueSolution() {
                            dangerousGroups.append(triplet)
                        }
                        
                        // Restore original removal set
                        cellsToRemove = currentCellsToRemove
                        verifier.cellsToRemove = cellsToRemove
                    }
                }
            }
        }
        
        return dangerousGroups
    }
    
    /// Precomputes a sample of dangerous pairs
    /// - Parameter sampleSize: Number of cells to sample for pair testing
    /// - Returns: Array of dangerous cell pairs
    func precomputeDangerousPairs(sampleSize: Int = 30) -> [[Coordinate]] {
        // Sample a subset of cells to find dangerous pairs
        let availableCells = getAllAvailableCells()
        let actualSampleSize = min(sampleSize, availableCells.count)
        let sampleCells = availableCells.shuffled().prefix(actualSampleSize)
        
        var dangerousPairs = [[Coordinate]]()
        
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
        
        return dangerousPairs
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
} 