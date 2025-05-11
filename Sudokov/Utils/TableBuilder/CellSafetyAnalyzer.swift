//
//  CellSafetyAnalyzer.swift
//  Sudokov
//
//  Created by Furkan Kaynar on 9.05.25.
//
import Foundation

/// Analyzes cells to determine their safety for removal while maintaining a unique solution
class CellSafetyAnalyzer {
    private let table: TableMatrix
    private let cellsToRemove: Set<Coordinate>
    private let dangerousPairs: [[Coordinate]]
    
    init(table: TableMatrix, cellsToRemove: Set<Coordinate>, dangerousPairs: [[Coordinate]] = []) {
        self.table = table
        self.cellsToRemove = cellsToRemove
        self.dangerousPairs = dangerousPairs
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
    func calculateRiskScore(for cell: Coordinate) -> Int {
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
    
    /// Check if a cell is part of a dangerous pair with already removed cells
    func isPartOfDangerousPair(_ cell: Coordinate) -> Bool {
        for pair in dangerousPairs {
            if pair.contains(cell) && pair.contains(where: { cellsToRemove.contains($0) }) {
                return true
            }
        }
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
    func getAllAvailableCells() -> [Coordinate] {
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