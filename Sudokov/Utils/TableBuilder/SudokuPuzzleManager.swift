//
//  SudokuPuzzleManager.swift
//  Sudokov
//
//  Created by Furkan Kaynar on 9.05.25.
//
import Foundation

/// Main facade for Sudoku puzzle generation and verification functionality
class SudokuPuzzleManager: BigSquareIterator {
    let table: TableMatrix
    private var cellsToRemove: Set<Coordinate> = []
    
    // Component instances
    private let verifier: UniqueSolutionVerifier
    private var safetyAnalyzer: CellSafetyAnalyzer
    private var puzzleGenerator: PuzzleGenerator
    private var dangerousCellFinder: DangerousCellFinder
    private var patternEliminator: PatternEliminator
    
    // Retry configuration
    private var stuckThreshold: Int = 200
    private var maxBacktrackSteps: Int = 5
    
    init(table: TableMatrix, cellsToRemove: Set<Coordinate> = []) {
        self.table = table
        self.cellsToRemove = cellsToRemove
        
        self.verifier = UniqueSolutionVerifier(table: table, cellsToRemove: cellsToRemove)
        self.safetyAnalyzer = CellSafetyAnalyzer(table: table, cellsToRemove: cellsToRemove)
        self.puzzleGenerator = PuzzleGenerator(table: table)
        self.dangerousCellFinder = DangerousCellFinder(table: table, cellsToRemove: cellsToRemove)
        self.patternEliminator = PatternEliminator(table: table, cellsToRemove: cellsToRemove)
    }
    
    /// Updates the cells to remove across all components
    func updateCellsToRemove(_ newCells: Set<Coordinate>) {
        self.cellsToRemove = newCells
        verifier.cellsToRemove = newCells
        safetyAnalyzer = CellSafetyAnalyzer(table: table, cellsToRemove: newCells)
        dangerousCellFinder = DangerousCellFinder(table: table, cellsToRemove: newCells)
        patternEliminator.updateCellsToRemove(newCells)
    }
    
    /// Configure retry mechanism parameters
    /// - Parameters:
    ///   - stuckThreshold: Number of attempts before considering the process stuck
    ///   - maxBacktrackSteps: Maximum number of cells to remove when backtracking
    func configureRetryMechanism(stuckThreshold: Int, maxBacktrackSteps: Int) {
        self.stuckThreshold = stuckThreshold
        self.maxBacktrackSteps = maxBacktrackSteps
        
        // Configure the puzzleGenerator with the new threshold
        puzzleGenerator.configureRetryMechanism(threshold: stuckThreshold)
    }
    
    // MARK: - Verification Methods
    
    /// Checks if the puzzle has a unique solution
    func hasUniqueSolution() -> Bool {
        return verifier.hasUniqueSolution()
    }
    
    /// Finds dangerous cell groups that would lead to multiple solutions
    func findDangerousCellGroups(maxGroupSize: Int = 3) -> [[Coordinate]] {
        return dangerousCellFinder.findDangerousCellGroups(maxGroupSize: maxGroupSize)
    }
    
    // MARK: - Analysis Methods
    
    /// Analyzes and returns cells sorted by their risk (lower is safer to remove)
    func analyzeCellSafetyScores() -> [(cell: Coordinate, riskScore: Int)] {
        return safetyAnalyzer.analyzeCellSafetyScores()
    }
    
    /// Calculates the risk score for a specific cell
    func calculateRiskScore(for cell: Coordinate) -> Int {
        return safetyAnalyzer.calculateRiskScore(for: cell)
    }
    
    /// Checks if a cell is part of a known dangerous pair
    func isPartOfDangerousPair(_ cell: Coordinate) -> Bool {
        let dangerousPairs = dangerousCellFinder.precomputeDangerousPairs()
        safetyAnalyzer = CellSafetyAnalyzer(table: table, cellsToRemove: cellsToRemove, dangerousPairs: dangerousPairs)
        return safetyAnalyzer.isPartOfDangerousPair(cell)
    }
    
    // MARK: - Generation Methods
    
    /// Generates a puzzle with specified difficulty
    func generatePuzzle(difficulty: Int, maxAttempts: Int = 10) -> Set<Coordinate>? {
        return puzzleGenerator.generatePuzzle(difficulty: difficulty, maxAttempts: maxAttempts)
    }
    
    /// Generates an extreme difficulty puzzle with minimal hints
    func generateExtremePuzzle(targetHints: Int = 22, maxIterations: Int = 50, timeLimit: TimeInterval = 60) -> Set<Coordinate>? {
        return puzzleGenerator.generateExtremePuzzle(targetHints: targetHints, maxIterations: maxIterations, timeLimit: timeLimit)
    }
    
    /// Handle a stuck situation by backtracking
    /// - Returns: true if backtracking was successful, false otherwise
    func handleStuckSituation() -> Bool {
        if cellsToRemove.isEmpty {
            return false
        }
        
        print("Handling stuck situation by backtracking...")
        
        // Remove a few cells to try a different path
        let backtrackAmount = min(maxBacktrackSteps, cellsToRemove.count / 10 + 1)
        let cellsToBacktrack = Array(cellsToRemove).shuffled().prefix(backtrackAmount)
        
        var newCellsToRemove = cellsToRemove
        for cell in cellsToBacktrack {
            newCellsToRemove.remove(cell)
        }
        
        updateCellsToRemove(newCellsToRemove)
        print("Backtracked from \(cellsToRemove.count + backtrackAmount) to \(cellsToRemove.count) cells")
        
        return true
    }
    
    // MARK: - Pattern Methods
    
    /// Tries to remove cells symmetrically
    func trySymmetricalElimination() -> Bool {
        let result = patternEliminator.trySymmetricalElimination()
        if result {
            // Get updated cells to remove
            updateCellsToRemove(patternEliminator.cellsToRemove)
        }
        return result
    }
    
    /// Tries pattern-based cell elimination
    func tryPatternBasedElimination() -> Bool {
        let result = patternEliminator.tryPatternBasedElimination()
        if result {
            // Get updated cells to remove
            updateCellsToRemove(patternEliminator.cellsToRemove)
        }
        return result
    }
    
    // MARK: - Utility Methods
    
    /// Gets all available cells for removal
    func getAllAvailableCells() -> [Coordinate] {
        return safetyAnalyzer.getAllAvailableCells()
    }
} 
