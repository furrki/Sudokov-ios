//
//  GameView.swift
//  Sudokov
//
//  Created by furrki on 11.06.2022.
//

import SwiftUI
import Combine

struct GameView: View {
    @StateObject var gameManager: GameManager = GameManager()

    var body: some View {
        ZStack {
            Color
                .white
                .ignoresSafeArea()

            GeometryReader { geometry in
                VStack(alignment: .center, spacing: 20) {
                    Spacer()
                    TableView(geometry: geometry)
                        .environmentObject(gameManager)

                    ControlsView()
                        .environmentObject(gameManager)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                    NumberPickerView()
                        .environmentObject(gameManager)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                    Spacer()
                }
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(gameManager: GameManager())
    }
}

struct TableView: View {
    let geometry: GeometryProxy
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        VStack(spacing: 0) {
            ForEach((0..<self.gameManager.tableState.count), id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach((0..<self.gameManager.tableState[row].count), id: \.self) { col in
                        GameSquareView(viewModel: self.gameManager.getGameSquare(i: row, j: col), tableWidth: geometry.size.width)
                            .onTapGesture {
                                self.gameManager.selectedCell = GameManager.Coordinate(row: row, col: col)
                            }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fixedSize()
    }
}
