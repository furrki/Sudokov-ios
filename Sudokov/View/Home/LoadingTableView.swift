//
//  LoadingTableView.swift
//  Sudokov
//

import SwiftUI

class LoadingTableManager: ObservableObject {
    @Published var tableState: [[Int]] = Array(repeating: Array(repeating: 0, count: 9), count: 9)
    private var timer: Timer?

    init() {
        startAnimation()
    }

    deinit {
        timer?.invalidate()
    }

    private func startAnimation() {
        // Initial random population
        for row in 0..<9 {
            for col in 0..<9 {
                if Bool.random() {
                    tableState[row][col] = Int.random(in: 1...9)
                }
            }
        }

        // Animate changes
        timer = Timer.scheduledTimer(withTimeInterval: 0.12, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Randomly change 8-12 cells
            for _ in 0..<Int.random(in: 8...12) {
                let row = Int.random(in: 0..<9)
                let col = Int.random(in: 0..<9)

                if self.tableState[row][col] == 0 {
                    // Empty cell - add a number
                    self.tableState[row][col] = Int.random(in: 1...9)
                } else if Bool.random() {
                    // Has number - maybe remove it or change it
                    self.tableState[row][col] = Bool.random() ? 0 : Int.random(in: 1...9)
                }
            }
        }
    }

    func getGameSquare(i: Int, j: Int) -> GameSquareViewModel {
        let content = tableState[i][j]
        return GameSquareViewModel(
            selectionType: .none,
            contentType: .levelGeneratedValue,
            isAlerting: false,
            content: content,
            drafts: [],
            row: i,
            col: j,
            squareSize: 9
        )
    }
}

struct LoadingTableView: View {
    let geometry: GeometryProxy
    @StateObject private var loadingManager = LoadingTableManager()

    var body: some View {
        VStack(spacing: 0) {
            ForEach((0..<9), id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach((0..<9), id: \.self) { col in
                        GameSquareView(
                            viewModel: loadingManager.getGameSquare(i: row, j: col),
                            tableWidth: geometry.size.width
                        )
                        .animation(.easeInOut(duration: 0.15), value: loadingManager.tableState[row][col])
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fixedSize()
    }
}
