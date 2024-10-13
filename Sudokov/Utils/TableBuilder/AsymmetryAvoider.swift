//
//  AsymmetryAvoider.swift
//  Sudokov
//
//  Created by Furkan Kaynar on 14.10.24.
//

import Foundation

class AsymmetryAvoider {
    private let tableSize: Int
    
    init(tableSize: Int = 9) {
        self.tableSize = tableSize
    }
    
    func getSymmetricCell(_ cell: Coordinate) -> Coordinate {
        return Coordinate(row: tableSize - 1 - cell.row, col: tableSize - 1 - cell.col)
    }

    func canRemoveSymmetrically(_ cell: Coordinate, cellsToHide: Set<Coordinate>, isRiskyToRemove: (Coordinate) -> Bool) -> Bool {
        let symmetricCell = getSymmetricCell(cell)
        return !isRiskyToRemove(cell) &&
               !isRiskyToRemove(symmetricCell) &&
               !cellsToHide.contains(cell) &&
               !cellsToHide.contains(symmetricCell)
    }

    func removeSymmetrically(_ cell: Coordinate, cellsToHide: inout Set<Coordinate>, removeFromRiskyCellGroups: (Coordinate) -> Void) {
        let symmetricCell = getSymmetricCell(cell)
        cellsToHide.insert(cell)
        cellsToHide.insert(symmetricCell)
        removeFromRiskyCellGroups(cell)
        removeFromRiskyCellGroups(symmetricCell)
    }
}
