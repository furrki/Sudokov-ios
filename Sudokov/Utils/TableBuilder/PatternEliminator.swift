//
//  PatternEliminator.swift
//  Sudokov
//
//  Created by Furkan Kaynar on 9.05.25.
//
import Foundation

/// Implements pattern-based techniques for cell elimination
class PatternEliminator {
    private let table: TableMatrix
    private(set) var cellsToRemove: Set<Coordinate>
    private let verifier: UniqueSolutionVerifier
    
    init(table: TableMatrix, cellsToRemove: Set<Coordinate> = []) {
        self.table = table
        self.cellsToRemove = cellsToRemove
        self.verifier = UniqueSolutionVerifier(table: table, cellsToRemove: cellsToRemove)
    }
    
    /// Update the cells to remove and update the verifier
    func updateCellsToRemove(_ newCellsToRemove: Set<Coordinate>) {
        self.cellsToRemove = newCellsToRemove
        verifier.cellsToRemove = newCellsToRemove
    }
    
    /// Try symmetrical elimination of cells
    /// - Returns: true if successful in removing more cells
    func trySymmetricalElimination() -> Bool {
        let availableCells = getAllAvailableCells()
        
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
    
    /// Try pattern-based elimination techniques
    /// - Returns: true if successful in removing more cells
    func tryPatternBasedElimination() -> Bool {
        // Try to isolate a region or line
        let regions = getAllRegions()
        
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
    
    /// Returns all regions (rows, columns, boxes) in the puzzle
    private func getAllRegions() -> [[Coordinate]] {
        var regions = [[Coordinate]]()
        
        // Add columns
        regions.append(contentsOf: [
            getColumnCells(0, 1, 2),
            getColumnCells(3, 4, 5),
            getColumnCells(6, 7, 8)
        ])
        
        // Add rows
        regions.append(contentsOf: [
            getRowCells(0, 1, 2),
            getRowCells(3, 4, 5),
            getRowCells(6, 7, 8)
        ])
        
        // Add 3x3 boxes
        regions.append(contentsOf: [
            getBoxCells(0, 0),
            getBoxCells(0, 3),
            getBoxCells(0, 6),
            getBoxCells(3, 0),
            getBoxCells(3, 3),
            getBoxCells(3, 6),
            getBoxCells(6, 0),
            getBoxCells(6, 3),
            getBoxCells(6, 6)
        ])
        
        return regions
    }
    
    /// Gets the symmetrically opposite cell in the grid
    private func getSymmetricCell(for cell: Coordinate) -> Coordinate {
        return Coordinate(row: 8 - cell.row, col: 8 - cell.col)
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