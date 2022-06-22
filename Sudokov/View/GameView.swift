//
//  GameView.swift
//  Sudokov
//
//  Created by furrki on 11.06.2022.
//

import SwiftUI
import Combine

struct GameView: View {
    var gameManager: GameManager = GameManager()

    var body: some View {
        TableView(gameManager: gameManager)
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(gameManager: GameManager())
    }
}

struct TableView: View {
    @ObservedObject var gameManager: GameManager

    var body: some View {
        ZStack {
            Color
                .gray
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ForEach((0..<gameManager.tableState.count), id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach((0..<gameManager.tableState[row].count), id: \.self) { col in
                            GameSquare(row: row, col: col, squareSize: gameManager.tableState.count, text: gameManager.squareText(row: row, col: col) ?? "")
                                .onTapGesture {
                                    if gameManager.tableState[row][col] != 0 {
                                        gameManager.generateLevel()
                                    }
                                    print(gameManager.availableNumbers(row: row, col: col))
                                }
                        }
                    }
                }
            }
        }
    }
}

struct GameSquare: View {
    let row: Int
    let col: Int
    let squareSize: Int
    let text: String

    var body: some View {
        Text(text)
            .frame(width: 30, height: 30)
            .background(Color.white)
            .foregroundColor(Color.black)
            .border(Color.black, width: 0.5)
            .border(width: col % 3 == 0 ? 3 : 0, edges: [.leading], color: .black)
            .border(width: row % 3 == 0 ? 3 : 0, edges: [.top], color: .black)
            .border(width: col == squareSize - 1 ? 3 : 0, edges: [.trailing], color: .black)
            .border(width: row == squareSize - 1 ? 3 : 0, edges: [.bottom], color: .black)
    }
}

class GameManager: ObservableObject {
    @Published private(set) var tableState: [[Int]]

    init() {
        tableState = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        generateLevel()
    }

    func squareText(row: Int, col: Int) -> String? {
        if (1...9).contains(tableState[row][col])  {
            return "\(tableState[row][col])"
        }

        return nil
    }

    func generateLevel() {
        tableState = Array(repeating: Array(repeating: 0, count: 9), count: 9)
        for i in 0...8 {
            for j in 0...8 {
                if tableState[i][j] == 0 {
                    let numbers = availableNumbers(row: i, col: j)
                    if numbers.isEmpty {
                        backTrace(row: i, col: j)
                        if tableState[i][j] == 0 {
                            return
                        }
                    } else {
                        tableState[i][j] = numbers.randomElement() ?? 0
                    }
                }
            }
        }
    }

    func backTrace(row: Int, col: Int) {
        tableState[row][col] = 0

        var i = row
        while i >= 0 {
            var j = col
            while j > 0 {
                j -= 1
                print(row, col, i, j)
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

    func hasConflict(row: Int,
                     col: Int,
                     i: Int,
                     j: Int) -> Bool {
        let tmp = tableState[i][j]
        tableState[i][j] = 0

        var container = availableNumbers(row: i, col: j)
        container.removeAll {
            $0 == tmp
        }
        if availableNumbers(row: row, col: col).contains(tmp) && container.count > 0 {
            tableState[i][j] = tmp
            return false
        } else {
            tableState[i][j] = tmp
            return true
        }
    }

    func availableNumbers(row: Int,
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
}
