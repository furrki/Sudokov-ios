//
//  TableView.swift
//  Sudokov
//
//  Created by furrki on 17.07.2022.
//

import SwiftUI

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
                                guard gameManager.isGameActive else {
                                    return
                                }
                                
                                withAnimation(.easeOut.speed(2)) {
                                    self.gameManager.selectedCell = Coordinate(row: row, col: col)
                                }
                            }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .fixedSize()
    }
}
