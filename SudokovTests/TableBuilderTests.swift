//
//  TableBuilderTests.swift
//  SudokovTests
//
//  Created by Furkan Kaynar on 3.06.24.
//

import XCTest
@testable import Sudokov

final class TableBuilderTests: XCTestCase {

    var tableBuilder: TableBuilder!
    
    override func setUp() async throws {
        tableBuilder = TableBuilder()
    }
    
    func testNakedPair() {
        let matrix = [
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
        tableBuilder = TableBuilder(tableState: matrix)
        
        let result = tableBuilder.getConflictableCellGroups(tableState: matrix)
        let filteredResult = result
        XCTAssertEqual(filteredResult.count, 27)
    }
    
    func testSingleNakedPair() {
        let matrix = [
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 1, 0, 0, 0, 3, 0, 0, 0],
            [0, 3, 0, 0, 0, 1, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 5, 0, 0, 0, 3, 0, 0, 1],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 2, 1, 0, 0, 0, 0, 0, 0],
            [0, 4, 0, 0, 0, 0, 0, 0, 0]
        ]
        tableBuilder = TableBuilder(tableState: matrix)
        
        let result = tableBuilder.getConflictableCellGroups(tableState: matrix)
        let filteredResult = result.filter { coordinate in
            !coordinate.contains {
                if $0.row >= 0 && $0.col >= 0 {
                    return matrix[$0.row][$0.col] == 0
                } else {
                    return true
                }
            }
        }
        XCTAssertEqual(filteredResult.count, 1)
    }
    
    func testSwordfish() {
        let matrix = [
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 1, 0, 0, 0, 5, 0, 0, 3],
            [0, 3, 0, 0, 0, 1, 0, 0, 5],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 5, 0, 0, 0, 3, 0, 0, 1],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 2, 1, 0, 0, 0, 0, 0, 0],
            [0, 4, 0, 0, 0, 0, 0, 0, 0]
        ]
        
        let finder = SwordFishFinder(table: matrix,
                                     cellsPlannedForRemoval: [
                                        Coordinate(row: 1, col: 1),
                                        Coordinate(row: 1, col: 5),
                                        Coordinate(row: 1, col: 8),
                                        Coordinate(row: 2, col: 1),
                                        Coordinate(row: 2, col: 5),
                                        Coordinate(row: 2, col: 8),
                                        Coordinate(row: 5, col: 1),
                                        Coordinate(row: 5, col: 5),
                                        Coordinate(row: 5, col: 8),
                                        Coordinate(row: 8, col: 1),
                                     ])
        
        let confictingCells = finder.findAll()
        XCTAssertEqual(confictingCells.first!.count, 9)
    }
    
    func testSwordfishes() {
        let matrix = [
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [7, 1, 0, 0, 8, 5, 0, 6, 3],
            [0, 3, 0, 0, 0, 1, 0, 0, 5],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [6, 5, 0, 0, 7, 3, 0, 8, 1],
            [0, 0, 0, 0, 0, 0, 0, 0, 0],
            [0, 2, 1, 0, 0, 0, 0, 0, 0],
            [8, 4, 0, 0, 6, 0, 0, 7, 0]
        ]
        
        let finder = SwordFishFinder(table: matrix,
                                     cellsPlannedForRemoval: [
                                        Coordinate(row: 1, col: 1),
                                        Coordinate(row: 1, col: 5),
                                        Coordinate(row: 1, col: 8),
                                        Coordinate(row: 2, col: 1),
                                        Coordinate(row: 2, col: 5),
                                        Coordinate(row: 2, col: 8),
                                        Coordinate(row: 5, col: 1),
                                        Coordinate(row: 5, col: 5),
                                        Coordinate(row: 5, col: 8),
                                        Coordinate(row: 8, col: 1),

                                        Coordinate(row: 1, col: 0),
                                        Coordinate(row: 5, col: 0),
                                        Coordinate(row: 8, col: 0),
                                        Coordinate(row: 1, col: 4),
                                        Coordinate(row: 5, col: 4),
                                        Coordinate(row: 8, col: 4),
                                        Coordinate(row: 1, col: 7),
                                        Coordinate(row: 5, col: 7),
                                        Coordinate(row: 8, col: 7),

                                     ])
        
        let confictingCells = finder.findAll()
        XCTAssertEqual(confictingCells.count, 2)
        XCTAssertEqual(confictingCells.first!.count, 9)
        XCTAssertEqual(confictingCells.last!.count, 9)
    }
}
