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
    // MARK: - Properties
    var table: TableMatrix {
        return tableState
    }

    @Published private(set) var tableState: TableMatrix
    @Published var index = 0

    // MARK: - Methods
    init() {
        tableState = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        generateLevel()
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

    func removeCells(tableState: TableMatrix,
                     depth: Int) -> [Coordinate] {
        var cellsToHide = Set<Coordinate>()

        while cellsToHide.count < (81 - depth) {
            cellsToHide.insert(Coordinate(row: Int.random(in: 0...8), col: Int.random(in: 0...8)))
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
}
let veryEasyDepth = 50
let easyDepth = 40
let mediumDepth = 30
let hardDepth = 25
let extremeDepth = 22




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

    let cellsToHide = tableBuilder.removeCells(tableState: tableBuilder.tableState, depth: hardDepth)
    levels.append(Level(table: tableBuilder.tableState, cellsToHide: cellsToHide))
}
writeToFile(name: "normal.data", levels: levels)

levels = []
