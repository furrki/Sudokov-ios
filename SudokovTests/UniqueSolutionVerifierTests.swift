//
//  UniqueSolutionVerifierTests.swift
//  SudokovTests
//
//  Created by Codex on 2025-09-04.
//

import XCTest
@testable import Sudokov

final class UniqueSolutionVerifierTests: XCTestCase {
    // A known valid solved Sudoku grid
    private let solved: TableMatrix = [
        [8, 3, 7, 5, 9, 2, 1, 4, 6],
        [2, 9, 6, 1, 4, 3, 7, 5, 8],
        [5, 4, 1, 8, 6, 7, 2, 3, 9],
        [7, 5, 8, 9, 3, 1, 4, 6, 2],
        [3, 2, 9, 4, 5, 6, 8, 1, 7],
        [6, 1, 4, 7, 2, 8, 3, 9, 5],
        [9, 7, 2, 3, 1, 5, 6, 8, 4],
        [4, 8, 3, 6, 7, 9, 5, 2, 1],
        [1, 6, 5, 2, 8, 4, 9, 7, 3]
    ]

    func testSolvedGridHasExactlyOneSolution() {
        let count = SolutionCounter.countSolutions(grid: solved, limit: 2)
        XCTAssertEqual(count, 1)

        let verifier = UniqueSolutionVerifier(table: solved)
        XCTAssertTrue(verifier.hasUniqueSolution())
    }

    func testInvalidGridHasNoSolution() {
        var invalid = solved
        // Introduce a conflict: duplicate in first row
        invalid[0][0] = 1
        invalid[0][1] = 1

        let count = SolutionCounter.countSolutions(grid: invalid, limit: 2)
        XCTAssertEqual(count, 0)
    }
}

