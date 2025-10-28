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

    private var completedCount: Int {
        viewModel.userFinishedLevels.filter { $0.difficulty == viewModel.difficulty }.count
    }

    private var gradient: LinearGradient {
        switch viewModel.difficulty {
        case .easy, .basic:
            return LinearGradient(
                colors: [Color(red: 0.4, green: 0.85, blue: 0.6), Color(red: 0.3, green: 0.75, blue: 0.5)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .medium:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.7, blue: 0.3), Color(red: 0.9, green: 0.6, blue: 0.2)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .hard:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.4, blue: 0.4), Color(red: 0.85, green: 0.3, blue: 0.3)],
                startPoint: .leading,
                endPoint: .trailing
            )
        case .hardcore:
            return LinearGradient(
                colors: [Color(red: 0.5, green: 0.2, blue: 0.5), Color(red: 0.4, green: 0.1, blue: 0.4)],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    private var accentColor: Color {
        switch viewModel.difficulty {
        case .easy, .basic:
            return Color(red: 0.4, green: 0.85, blue: 0.6)
        case .medium:
            return Color(red: 0.95, green: 0.7, blue: 0.3)
        case .hard:
            return Color(red: 0.95, green: 0.4, blue: 0.4)
        case .hardcore:
            return Color(red: 0.5, green: 0.2, blue: 0.5)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            BackButton {
                withAnimation {
                    coordinator.popBack()
                }
            }

            ScrollView {
                VStack(spacing: 24) {
                    // Header Card
                    VStack(spacing: 16) {
                        Text(viewModel.difficulty.name)
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)

                        // Fancy Progress Bar
                        VStack(spacing: 8) {
                            HStack {
                                HStack(spacing: 8) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(gradient)

                                    Text("\(completedCount)/\(viewModel.levelCount)")
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundColor(.primary)
                                }

                                Spacer()

                                Text("\(Int((Double(completedCount) / Double(viewModel.levelCount)) * 100))%")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(gradient)
                            }

                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Background
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.15))
                                        .frame(height: 16)

                                    // Progress with gradient
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(gradient)
                                        .frame(width: geometry.size.width * CGFloat(completedCount) / CGFloat(viewModel.levelCount), height: 16)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.white.opacity(0.3), Color.clear],
                                                        startPoint: .top,
                                                        endPoint: .bottom
                                                    )
                                                )
                                        )
                                        .shadow(color: accentColor.opacity(0.4), radius: 4, x: 0, y: 2)
                                }
                            }
                            .frame(height: 16)
                        }
                    }
                    .padding(20)

                    // Levels Grid
                    VStack(spacing: 12) {
                        ForEach(1...viewModel.rowsCount, id: \.self) { row in
                            HStack(spacing: 12) {
                                ForEach(1...viewModel.colsCount, id: \.self) { col in
                                    levelButton(row: row, col: col)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.vertical, 24)
            }
        }
    }

    private func levelButton(row: Int, col: Int) -> some View {
        let isFinished = viewModel.isFinished(row: row, col: col)
        let isLocked = viewModel.isLocked(row: row, col: col)
        let levelNumber = viewModel.getContent(row: row, col: col)

        return Button {
            if !isLocked {
                onSelectLevel(viewModel.getLevel(row: row, col: col))
            }
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isFinished ? gradient :
                        isLocked ? LinearGradient(colors: [Color.gray.opacity(0.2)], startPoint: .leading, endPoint: .trailing) :
                        LinearGradient(colors: [Color(UIColor.secondarySystemGroupedBackground)], startPoint: .leading, endPoint: .trailing)
                    )
                    .frame(height: 56)

                if isLocked {
                    HStack(spacing: 8) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.gray.opacity(0.5))

                        Text("\(levelNumber)")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                } else if isFinished {
                    HStack(spacing: 8) {
                        Text("\(levelNumber)")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white.opacity(0.9))
                    }
                } else {
                    Text("\(levelNumber)")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }
        }
        .disabled(isLocked)
        .buttonStyle(PlainButtonStyle())
    }
}

struct PickLevelView_Previews: PreviewProvider {
    static var previews: some View {
        PickLevelView(viewModel: PickLevelViewModel(difficulty: .medium, userFinishedLevels: [TemplateLevel(difficulty: .medium, visualLevel: 1)])) { _ in

        }
    }
}
