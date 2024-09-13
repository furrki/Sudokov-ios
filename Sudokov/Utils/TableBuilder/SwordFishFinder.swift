//
//  SwordFishFinder.swift
//  Sudokov
//
//  Created by Furkan Kaynar on 14.09.24.
//

import Foundation

class SwordFishFinder: BigSquareIterator {
    let table: TableMatrix
    let cellsPlannedForRemoval: [Coordinate]

    init(table: TableMatrix,
         cellsPlannedForRemoval: [Coordinate]) {
        self.table = table
        self.cellsPlannedForRemoval = cellsPlannedForRemoval
    }

    func findAll() -> [[Coordinate]] {
        var possibleConflicts = Set<Set<Coordinate>>()
        for i in 1...9 {
            for j in 1...9 {
                for k in 1...9 {
                    let plannedCells = cellsPlannedForRemoval.filter {
                        [i, j, k].contains(table[$0.row][$0.col])
                    }
                    
                    let swordfish = iterate(subjectCoordinates: plannedCells)
                    if !swordfish.isEmpty {
                        possibleConflicts.insert(Set(swordfish))
                    }
                }
            }
        }
        
        return Array(possibleConflicts.map { Array($0) })
    }
    
    func iterate(subjectCoordinates: [Coordinate]) -> [Coordinate] {
        var rowSet = Set<Int>()
        var colSet = Set<Int>()

        for cell in subjectCoordinates {
            rowSet.insert(cell.row)
            colSet.insert(cell.col)
        }

        var coordinates = [Coordinate]()

        if rowSet.count == 3, colSet.count == 3 {
            for row in rowSet {
                for col in colSet {
                    coordinates.append(Coordinate(row: row, col: col))
                }
            }
        }
        
        return coordinates
    }
}
