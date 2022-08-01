//
//  PickLevelView.swift
//  Sudokov
//
//  Created by furrki on 27.07.2022.
//

import SwiftUI

struct PickLevelView: View {
    // MARK: - Properties
    let viewModel: PickLevelViewModel

    let onSelectLevel: ((Int) -> Void)

    var body: some View {
        ScrollView {
            VStack {
                Text(viewModel.titleText)
                    .font(.system(size: 25, weight: .bold))
                    .padding(.top, 60)

                VStack(spacing: 15) {
                    ForEach(1...viewModel.rowsCount, id: \.self) { row in
                        HStack(spacing: 15) {
                            ForEach(1...viewModel.colsCount, id: \.self) { col in
                                Button {
                                    onSelectLevel(viewModel.getLevel(row: row, col: col))
                                } label: {
                                    Text("\(viewModel.getContent(row: row, col: col))")
                                        .frame(height: 40)
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(NumberPickerButtonStyle())
                            }
                        }
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 40)
            }
        }
    }
}

struct PickLevelView_Previews: PreviewProvider {
    static var previews: some View {
        PickLevelView(viewModel: PickLevelViewModel(difficulty: .hard)) { _ in

        }
    }
}

class PickLevelViewModel {
    let levelCount = 50
    let rowsCount = 10
    let colsCount = 5
    let difficulty: Difficulty
    let titleText: String

    init(difficulty: Difficulty) {
        self.difficulty = difficulty

        titleText = "Select Level - \(difficulty.name)"
    }

    func getContent(row: Int, col: Int) -> Int {
        (row - 1) * colsCount + col
    }

    func getLevel(row: Int, col: Int) -> Int {
        getContent(row: row, col: col) - 1
    }
}
