//
//  RandomCellPicker.swift
//  Sudokov
//
//  Created by Furkan Kaynar on 9.05.25.
//

class RandomCellPicker: BigSquareIterator {
    let table: TableMatrix
    let cellsPlannedForRemoval: [Coordinate]
    
    init(table: TableMatrix, cellsPlannedForRemoval: [Coordinate]) {
        self.table = table
        self.cellsPlannedForRemoval = cellsPlannedForRemoval
    }
    
    func pickCell() -> Coordinate? {
        let randomCells = (0..<9).flatMap { row in
            (0..<9).compactMap { col in
                let coordinate = Coordinate(row: row, col: col)
                return cellsPlannedForRemoval.contains(coordinate) ? nil : coordinate
            }
        }.shuffled().prefix(14)

        let cellsWithRisk = randomCells.map { cell in
            (cell, calculateRisk(cell: cell))
        }

        return cellsWithRisk.sorted { $0.1 < $1.1 }.first?.0
    }

    private func calculateRisk(cell: Coordinate) -> Int {
        let horizontallyRemovedCount = cellsPlannedForRemoval.count { $0.row == cell.row }
        let verticallyRemovedCount = cellsPlannedForRemoval.count { $0.col == cell.col }
        let bigSquareRemovedCount = cellsPlannedForRemoval.count {
            let bigSquare = cell.row / 3 * 3 + cell.col / 3
            return $0.row / 3 == bigSquare / 3 && $0.col / 3 == bigSquare % 3
        }
        
        let numberCounts = (1...9).map { value in
            cellsPlannedForRemoval.count { coord in
                table[coord.row][coord.col] == value
            }
        }
        let averageRemovedCountOfNumbers = Double(numberCounts.reduce(0, +)) / 9.0
        let averageScoreMultiplier = 3
        let risk = horizontallyRemovedCount + verticallyRemovedCount + bigSquareRemovedCount + Int(averageRemovedCountOfNumbers) * averageScoreMultiplier
        return risk
    }
}
