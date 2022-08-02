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
    @EnvironmentObject var coordinator: HomeCoordinator

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Button {
                        withAnimation {
                            coordinator.popBack()
                        }
                    } label: {
                        Image(systemName: "arrow.uturn.backward.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                    }

                    Spacer()
                }
                .padding(.horizontal, 30)
                .padding(.top, 10)

                Text(viewModel.titleText)
                    .font(.system(size: 25, weight: .bold))
                    .padding(.top, 30)

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
                                .buttonStyle(NumberPickerButtonStyle(isSelected: viewModel.isFinished(row: row, col: col)))
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
        PickLevelView(viewModel: PickLevelViewModel(difficulty: .hard, userFinishedLevels: [TemplateLevel(difficulty: .hard, visualLevel: 1)])) { _ in

        }
    }
}
