import Cocoa
import Combine
import PlaygroundSupport

typealias TableMatrix = [[Int]]

struct Level: Codable {
    let table: TableMatrix
    let cellsToHide: [Coordinate]
}

struct Coordinate: Codable, Hashable {
    let row: Int
    let col: Int
}

class TableBuilder: ObservableObject {
    // MARK: - Constants
    enum BigSquareDudeState {
        case horizontal
        case vertical
        case irrelevant
    }

    // MARK: - Properties
    var table: TableMatrix {
        return tableState
    }

    @Published private(set) var tableState: TableMatrix
    @Published var index = 0

    // MARK: - Methods
    init(tableState: TableMatrix? = nil) {
        if let tableState = tableState {
            self.tableState = tableState
        } else {
            self.tableState = Array(repeating: Array(repeating: 0, count: 9), count: 9)
            generateLevel()
        }
    }

    func generateLevel() {
        tableState = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        for i in 0...8 {
            for j in 0...8 {
                if tableState[i][j] == 0 {
                    let numbers = availableNumbers(row: i, col: j)
                    if numbers.isEmpty {
                        backTrace(row: i, col: j)
                    } else {
                        tableState[i][j] = numbers.randomElement() ?? 0
                    }
                }
            }
        }

        let hasZero = tableState.contains {
            $0.contains(0)
        }

        if hasZero {
            generateLevel()
            return
        }
    }

    func availableNumbers(tableState: TableMatrix,
                          row: Int,
                          col: Int,
                          shouldCheckRows: Bool = true,
                          shouldCheckCols: Bool = true,
                          shouldCheckSquares: Bool = true) -> [Int] {
        var available = Array(1...9)

        if shouldCheckRows {
            for i in 0...8 {
                let square = tableState[row][i]

                if i != col, square != 0, available.contains(square) {
                    available.removeAll {
                        $0 == square
                    }
                }
            }
        }

        if shouldCheckCols {
            for i in 0...8 {
                let square = tableState[i][col]

                if i != row, square != 0, available.contains(square) {
                    available.removeAll {
                        $0 == square
                    }
                }
            }
        }

        if shouldCheckSquares {
            let bigRow = row / 3
            let bigCol = col / 3

            for i in (bigRow * 3)...(bigRow * 3 + 2) {
                for j in (bigCol * 3)...(bigCol * 3 + 2) {
                    let square = tableState[i][j]

                    if i != row, j != col, square != 0, available.contains(square) {
                        available.removeAll {
                            $0 == square
                        }
                    }
                }
            }
        }
        return available
    }

    func getConflictableCellGroups(tableState: TableMatrix) -> [[Coordinate]] {
        let bigRowRange = 0...2
        var possibleConflicts = Set<Set<Coordinate>>()

        for i in bigRowRange {
            for j in bigRowRange {
                let res = iterateBigSquare(bigCoordinate: Coordinate(row: i, col: j))
                possibleConflicts = possibleConflicts.union(res)
            }
        }

        return Array(possibleConflicts.map {
            Array($0)
        })
    }

    func makeCellsToRemove(tableState: TableMatrix, depth: Int) -> [Coordinate] {
        var riskyCellGroups = getConflictableCellGroups(tableState: tableState)
        var cellsToHide = Set<Coordinate>()

        while cellsToHide.count < (81 - depth) {
            let cell = Coordinate(row: Int.random(in: 0...8), col: Int.random(in: 0...8))

            let isRiskyToRemove: Bool = riskyCellGroups.contains {
                $0 == [cell]
            }

            if !isRiskyToRemove {
                cellsToHide.insert(cell)
                riskyCellGroups = riskyCellGroups.map {
                    $0.compactMap { cellInRiskyGroup in
                        if cellInRiskyGroup == cell {
                            return nil
                        }

                        return cellInRiskyGroup
                    }
                }
            }
        }

        return Array(cellsToHide)
    }

    // MARK: - Private Methods
    private func backTrace(row: Int, col: Int) {
        tableState[row][col] = 0
        var i = row
        while i >= 0 {
            var j = col
            while j > 0 {
                j -= 1

                if !hasConflict(row: row, col: col, i: i, j: j) {
                    tableState[row][col] = tableState[i][j]
                    tableState[i][j] = availableNumbers(row: i, col: j).randomElement() ?? 0
                    j = 0
                    i = -1
                }
            }

            i -= 1
        }
    }

    private func hasConflict(row: Int,
                             col: Int,
                             i: Int,
                             j: Int) -> Bool {
        let tmp = tableState[i][j]
        tableState[i][j] = 0

        var available = availableNumbers(row: i, col: j)
        available.removeAll {
            $0 == tmp
        }
        if availableNumbers(row: row, col: col).contains(tmp) && available.count > 0 {
            tableState[i][j] = tmp
            return false
        } else {
            tableState[i][j] = tmp
            return true
        }
    }

    private func availableNumbers(row: Int,
                          col: Int,
                          shouldCheckRows: Bool = true,
                          shouldCheckCols: Bool = true,
                          shouldCheckSquares: Bool = true) -> [Int] {
        availableNumbers(tableState: tableState,
                         row: row,
                         col: col,
                         shouldCheckRows: shouldCheckRows,
                         shouldCheckCols: shouldCheckCols,
                         shouldCheckSquares: shouldCheckSquares)
    }

    private func getRowIndex(tableState: TableMatrix, col: Int, of value: Int) -> Int {
        for i in 0...8 {
            if tableState[i][col] == value {
                return i
            }
        }
        return -1
    }

    private func getColIndex(tableState: TableMatrix, row: Int, of value: Int) -> Int {
        for i in 0...8 {
            if tableState[row][i] == value {
                return i
            }
        }
        return -1
    }

    private func indexesOfCell(coordinate: Coordinate) -> [Coordinate] {
        var coordinates = [Coordinate]()

        for i in (coordinate.row * 3)...(coordinate.row * 3 + 2) {
            for j in (coordinate.col * 3)...(coordinate.col * 3 + 2) {
                coordinates.append(Coordinate(row: i, col: j))
            }
        }

        return coordinates
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

    private func getHorizontalDudes(baseCoordinate: Coordinate, relevantCoordinate: Coordinate) -> [Coordinate] {
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

    private func getVerticalDudes(baseCoordinate: Coordinate, relevantCoordinate: Coordinate) -> [Coordinate] {
        let baseValue = table[baseCoordinate.row][baseCoordinate.col]
        let relevantValue = table[relevantCoordinate.row][relevantCoordinate.col]

        let rowIndexOfRelevantOnBaseCol = getRowIndex(tableState: table, col: baseCoordinate.col, of: relevantValue)
        let rowIndexOfBaseOnRelevantCol = getRowIndex(tableState: table, col: relevantCoordinate.col, of: baseValue)

        return [
            Coordinate(row: rowIndexOfRelevantOnBaseCol, col: baseCoordinate.col),
            Coordinate(row: rowIndexOfBaseOnRelevantCol, col: relevantCoordinate.col)
        ]
    }

    private func iterateBigSquare(bigCoordinate: Coordinate) -> Set<Set<Coordinate>> {
        var coordinates = Set<Set<Coordinate>>()
        let indexes = indexesOfCell(coordinate: bigCoordinate)
        for (i, baseCoordinate) in indexes.dropLast().enumerated() {
            for (_ , relevantCoordinate) in indexes.dropFirst(i + 1).enumerated() {
                let bigSquareState = getBigSquareState(baseCoordiate: baseCoordinate, relevantCoordinate: relevantCoordinate)
                switch bigSquareState {
                case .horizontal:

                    if !isHorizontallySecure(baseCoordinate: baseCoordinate, relevantCoordinate: relevantCoordinate) {
                        var coordinatesToAppend = [Coordinate]()
                        coordinatesToAppend.append(contentsOf: getHorizontalDudes(baseCoordinate: baseCoordinate,
                                                                      relevantCoordinate: relevantCoordinate))
                        coordinatesToAppend.append(baseCoordinate)
                        coordinatesToAppend.append(relevantCoordinate)
                        coordinates.insert(Set(coordinatesToAppend))
                    }
                case .vertical:

                    if !isVerticallySecure(baseCoordinate: baseCoordinate, relevantCoordinate: relevantCoordinate) {
                        var coordinatesToAppend = [Coordinate]()
                        coordinatesToAppend.append(contentsOf: getVerticalDudes(baseCoordinate: baseCoordinate,
                                                                      relevantCoordinate: relevantCoordinate))
                        coordinatesToAppend.append(baseCoordinate)
                        coordinatesToAppend.append(relevantCoordinate)
                        coordinates.insert(Set(coordinatesToAppend))
                    }
                case .irrelevant:
                    if !isVerticallySecure(baseCoordinate: baseCoordinate, relevantCoordinate: relevantCoordinate) &&
                        !isHorizontallySecure(baseCoordinate: baseCoordinate, relevantCoordinate: relevantCoordinate) {
                        var coordinatesToAppend = [Coordinate]()
                        coordinatesToAppend.append(contentsOf: getHorizontalDudes(baseCoordinate: baseCoordinate,
                                                                      relevantCoordinate: relevantCoordinate))
                        coordinatesToAppend.append(contentsOf: getVerticalDudes(baseCoordinate: baseCoordinate,
                                                                      relevantCoordinate: relevantCoordinate))
                        coordinatesToAppend.append(baseCoordinate)
                        coordinatesToAppend.append(relevantCoordinate)
                        coordinates.insert(Set(coordinatesToAppend))
                    }
                }
            }
        }
        return coordinates
    }

    private func getBigSquareState(baseCoordiate: Coordinate, relevantCoordinate: Coordinate) -> BigSquareDudeState {

        if baseCoordiate.col == relevantCoordinate.col {
            return .vertical
        } else if baseCoordiate.row == relevantCoordinate.row {
            return .horizontal
        }
        return .irrelevant
    }
}

let easyDepth = 45
let mediumDepth = 35
let hardDepth = 26

func writeToFile(name: String, levels: [Level]) {
    let fileURL = playgroundSharedDataDirectory.appendingPathComponent(name)
    let data = try? JSONEncoder().encode(levels)
    let dataString = data?.base64EncodedString()
    do {
        try dataString!.write(to: fileURL, atomically: false, encoding: .utf8)
    }
    catch {/* error handling here */}
}

var levels: [Level] = []
var tableBuilder = TableBuilder()

for i in 0...49 {
    tableBuilder = TableBuilder()

    let cellsToHide = tableBuilder.makeCellsToRemove(tableState: tableBuilder.tableState, depth: hardDepth)
    levels.append(Level(table: tableBuilder.tableState, cellsToHide: cellsToHide))
}
writeToFile(name: "hard.data", levels: levels)

levels = []
