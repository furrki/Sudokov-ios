//
//  BigSquareIteratorTests.swift
//  SudokovTests
//
//  Created by Furkan Kaynar on 25.08.24.
//

import XCTest
@testable import Sudokov

final class BigSquareIteratorTests: XCTestCase {
    func makeIterator() -> BigSquareIterator {
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
        
        return BigSquareIteratorHolder(table: matrix)
    }
    
    func testGetRowIndex() {
        let iterator = makeIterator()
        var rowIndex = iterator.getRowIndex(tableState: iterator.table, col: 1, of: 3)
        XCTAssertEqual(rowIndex, 0)

        rowIndex = iterator.getRowIndex(tableState: iterator.table, col: 4, of: 5)
        XCTAssertEqual(rowIndex, 4)
    }
    
    func testGetColIndex() {
        let iterator = makeIterator()
        var colIndex = iterator.getColIndex(tableState: iterator.table, row: 1, of: 3)
        XCTAssertEqual(colIndex, 5)

        colIndex = iterator.getColIndex(tableState: iterator.table, row: 4, of: 5)
        XCTAssertEqual(colIndex, 4)
    }
    
    func testGetHorizontalPairs() {
        let iterator = makeIterator()
        let coordinatePairs = iterator.getHorizontalPairs(baseCoordinate: .init(row: 0, col: 0),
                                                          relevantCoordinate: .init(row: 0, col: 2))
        
        XCTAssertEqual(coordinatePairs[0], .init(row: 3, col: 0))
        XCTAssertEqual(coordinatePairs[1], .init(row: 3, col: 2))
    }
    
    func testGetVerticalPairs() {
        let iterator = makeIterator()
        let coordinatePairs = iterator.getVerticalPairs(baseCoordinate: .init(row: 0, col: 0),
                                                        relevantCoordinate: .init(row: 3, col: 0))
        
        XCTAssertEqual(coordinatePairs[0], .init(row: 0, col: 2))
        XCTAssertEqual(coordinatePairs[1], .init(row: 3, col: 2))
    }
}

class BigSquareIteratorHolder: BigSquareIterator {
    var table: Sudokov.TableMatrix
    
    init(table: Sudokov.TableMatrix) {
        self.table = table
    }
}
