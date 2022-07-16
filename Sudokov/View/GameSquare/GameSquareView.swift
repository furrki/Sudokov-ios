//
//  GameSquareView.swift
//  Sudokov
//
//  Created by furrki on 14.07.2022.
//

import SwiftUI

struct GameSquareView: View {
    let viewModel: GameSquareViewModel
    let tableWidth: CGFloat

    var body: some View {
        VStack {
            switch viewModel.contentType {
            case .draft:
                GameSquareDraftView(drafts: viewModel.drafts,
                                    boldNumber: viewModel.boldNumber,
                                    superBackgroundColor: viewModel.backgroundColor)
            case .userAddedValue, .levelGeneratedValue:
                Text(viewModel.squareText)
                    .font(.system(size: 20, weight: .semibold))
            }
        }
        .frame(width: tableWidth/9.3, height: tableWidth/9.3)
        .background(viewModel.backgroundColor)
        .foregroundColor(viewModel.foregroundColor)
        .border(Color(R.color.greatBorder.name).opacity(0.3), width: 0.5)
        .border(width: viewModel.leadingBorderWidth, edges: [.leading], color: viewModel.leadingBorderColor)
        .border(width: viewModel.topBorderWidth, edges: [.top], color: viewModel.topBorderColor)
        .border(width: viewModel.trailingBorderWidth, edges: [.trailing], color: viewModel.trailingBorderColor)
        .border(width: viewModel.bottomBorderWidth, edges: [.bottom], color: viewModel.bottomBorderColor)
    }
}

struct GameSquareDraftView: View {
    let drafts: [Int]
    let boldNumber: Int?
    let superBackgroundColor: Color

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            ForEach((1...3), id: \.self) { row in
                HStack(alignment: .center, spacing: 0) {
                    ForEach((1...3), id: \.self) { col in
                        Text("\(getIndex(row: row, col: col))")
                            .font(shouldHighlight(row: row, col: col) ? .system(size: 11, weight: .bold) : .system(size: 9))
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.black)
                            .opacity(drafts.contains(getIndex(row: row, col: col)) ? 1 : 0)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func shouldHighlight(row: Int, col: Int) -> Bool {
        getIndex(row: row, col: col) == boldNumber
    }

    private func getIndex(row: Int, col: Int) -> Int {
        (row - 1) * 3 + col
    }
}
