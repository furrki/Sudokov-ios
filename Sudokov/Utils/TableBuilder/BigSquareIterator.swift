//
//  BigSquareIterator.swift
//  Sudokov
//
//  Created by Furkan Kaynar on 14.09.24.
//

import Foundation

protocol BigSquareIterator {
    var table: TableMatrix { get }

    func getRowIndex(tableState: TableMatrix, col: Int, of value: Int) -> Int
    func getColIndex(tableState: TableMatrix, row: Int, of value: Int) -> Int
    func indexesOfCell(coordinate: Coordinate) -> [Coordinate]
    func getBigSquareState(baseCoordiate: Coordinate, relevantCoordinate: Coordinate) -> BigSquareRelation
    func getHorizontalPairs(baseCoordinate: Coordinate, relevantCoordinate: Coordinate) -> [Coordinate]
    func getVerticalPairs(baseCoordinate: Coordinate, relevantCoordinate: Coordinate) -> [Coordinate]
}

extension BigSquareIterator {
    func getRowIndex(tableState: TableMatrix, col: Int, of value: Int) -> Int {
        for i in 0...8 {
            if tableState[i][col] == value {
                return i
            }
        }
        return -1
    }
    
    func getColIndex(tableState: TableMatrix, row: Int, of value: Int) -> Int {
        for i in 0...8 {
            if tableState[row][i] == value {
                return i
            }
        }
        return -1
    }
    
    func indexesOfCell(coordinate: Coordinate) -> [Coordinate] {
        var coordinates = [Coordinate]()
        
        for i in (coordinate.row * 3)...(coordinate.row * 3 + 2) {
            for j in (coordinate.col * 3)...(coordinate.col * 3 + 2) {
                coordinates.append(Coordinate(row: i, col: j))
            }
        }
        
        return coordinates
    }

    func getBigSquareState(baseCoordiate: Coordinate, relevantCoordinate: Coordinate) -> BigSquareRelation {
        if baseCoordiate.col == relevantCoordinate.col {
            return .vertical
        } else if baseCoordiate.row == relevantCoordinate.row {
            return .horizontal
        }
        return .irrelevant
    }

    func getHorizontalPairs(baseCoordinate: Coordinate, relevantCoordinate: Coordinate) -> [Coordinate] {
        let baseValue = table[baseCoordinate.row][baseCoordinate.col]
        let relevantValue = table[relevantCoordinate.row][relevantCoordinate.col]
        
        let rowIndexOfRelevantOnBaseCol = getRowIndex(tableState: table,
                                                      col: baseCoordinate.col,
                                                      of: relevantValue)
    
        let rowIndexOfBaseOnRelevantCol = getRowIndex(tableState: table,
                                                      col: relevantCoordinate.col,
                                                      of: baseValue)
        
        return [
            Coordinate(row: rowIndexOfRelevantOnBaseCol, col: baseCoordinate.col),
            Coordinate(row: rowIndexOfBaseOnRelevantCol, col: relevantCoordinate.col)
        ]
    }
    
    func getVerticalPairs(baseCoordinate: Coordinate, relevantCoordinate: Coordinate) -> [Coordinate] {
        let baseValue = table[baseCoordinate.row][baseCoordinate.col]
        let relevantValue = table[relevantCoordinate.row][relevantCoordinate.col]
        
        let colIndexOfRelevantOnBaseRow = getColIndex(tableState: table,
                                                      row: baseCoordinate.row,
                                                      of: relevantValue)
        
        let colIndexOfBaseOnRelevantRow = getColIndex(tableState: table,
                                                      row: relevantCoordinate.row,
                                                      of: baseValue)
        
        return [
            Coordinate(row: baseCoordinate.row, col: colIndexOfRelevantOnBaseRow),
            Coordinate(row: relevantCoordinate.row, col: colIndexOfBaseOnRelevantRow)
        ]
    }
}
