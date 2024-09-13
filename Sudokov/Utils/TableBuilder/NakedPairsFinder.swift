//
//  NakedPairsFinder.swift
//  Sudokov
//
//  Created by Furkan Kaynar on 14.09.24.
//

import Foundation

class NakedPairsFinder: BigSquareIterator {
    let table: TableMatrix
    
    init(table: TableMatrix) {
        self.table = table
    }
    
    func getAllNakedPairs() -> [[Coordinate]] {
        let bigRowRange = 0...2
        var possibleConflicts = [[Coordinate]]()
        
        for i in bigRowRange {
            for j in bigRowRange {
                let res = iterateBigSquare(bigCoordinate: Coordinate(row: i, col: j))
                possibleConflicts.append(contentsOf: res)
            }
        }
        
        return Array(Set(possibleConflicts.map {
            Array(Set($0))
        }))
    }
    
    private func isHorizontallySecure(baseCoordinate: Coordinate, relevantCoordinate: Coordinate) -> Bool {
        let baseValue = table[baseCoordinate.row][baseCoordinate.col]
        let relevantValue = table[relevantCoordinate.row][relevantCoordinate.col]
        
        let rowIndexOfRelevantOnBaseCol = getRowIndex(tableState: table, col: baseCoordinate.col, of: relevantValue)
        let rowIndexOfBaseOnRelevantCol = getRowIndex(tableState: table, col: relevantCoordinate.col, of: baseValue)
        
        return rowIndexOfBaseOnRelevantCol != rowIndexOfRelevantOnBaseCol
    }
    
    private func isVerticallySecure(baseCoordinate: Coordinate, relevantCoordinate: Coordinate) -> Bool {
        let baseValue = table[baseCoordinate.row][baseCoordinate.col]
        let relevantValue = table[relevantCoordinate.row][relevantCoordinate.col]
        
        let colIndexOfRelevantOnBaseRow = getColIndex(tableState: table,
                                                      row: baseCoordinate.row,
                                                      of: relevantValue)
        
        let colIndexOfBaseOnRelevantRow = getColIndex(tableState: table,
                                                      row: relevantCoordinate.row,
                                                      of: baseValue)
        
        return colIndexOfRelevantOnBaseRow != colIndexOfBaseOnRelevantRow
    }
    
    private func iterateBigSquare(bigCoordinate: Coordinate) -> [[Coordinate]] {
        var coordinates = [[Coordinate]]()
        let indexes = indexesOfCell(coordinate: bigCoordinate)
        for (i, baseCoordinate) in indexes.dropLast().enumerated() {
            for (_ , relevantCoordinate) in indexes.dropFirst(i + 1).enumerated() {
                let bigSquareState = getBigSquareState(baseCoordiate: baseCoordinate,
                                                       relevantCoordinate: relevantCoordinate)
                switch bigSquareState {
                case .horizontal:
                    if !isHorizontallySecure(baseCoordinate: baseCoordinate, relevantCoordinate: relevantCoordinate) {
                        var coordinatesToAppend = [Coordinate]()
                        coordinatesToAppend.append(contentsOf: getHorizontalPairs(baseCoordinate: baseCoordinate,
                                                                                  relevantCoordinate: relevantCoordinate))
                        coordinatesToAppend.append(baseCoordinate)
                        coordinatesToAppend.append(relevantCoordinate)
                        coordinates.append(coordinatesToAppend)
                    }
                case .vertical:
                    if !isVerticallySecure(baseCoordinate: baseCoordinate, relevantCoordinate: relevantCoordinate) {
                        var coordinatesToAppend = [Coordinate]()
                        coordinatesToAppend.append(contentsOf: getVerticalPairs(baseCoordinate: baseCoordinate,
                                                                                relevantCoordinate: relevantCoordinate))
                        coordinatesToAppend.append(baseCoordinate)
                        coordinatesToAppend.append(relevantCoordinate)
                        coordinates.append(coordinatesToAppend)
                    }
                case .irrelevant:
                    if !isVerticallySecure(baseCoordinate: baseCoordinate, relevantCoordinate: relevantCoordinate) &&
                        !isHorizontallySecure(baseCoordinate: baseCoordinate, relevantCoordinate: relevantCoordinate) {
                        var coordinatesToAppend = [Coordinate]()
                        coordinatesToAppend.append(contentsOf: getHorizontalPairs(baseCoordinate: baseCoordinate,
                                                                                  relevantCoordinate: relevantCoordinate))
                        coordinatesToAppend.append(contentsOf: getVerticalPairs(baseCoordinate: baseCoordinate,
                                                                                relevantCoordinate: relevantCoordinate))
                        coordinatesToAppend.append(baseCoordinate)
                        coordinatesToAppend.append(relevantCoordinate)
                        coordinates.append(coordinatesToAppend)
                    }
                }
            }
        }

        return coordinates
    }
}
