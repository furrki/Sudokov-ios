//
//  SelectDifficultyView.swift
//  Sudokov
//
//  Created by furrki on 16.10.2022.
//

import SwiftUI

struct SelectDifficultyView: View {
    // MARK: - Properties
    @EnvironmentObject private var coordinator: HomeCoordinator
    @State private var difficulty: Double = Double(GameConfiguration.defaultPickDepth)
    private let storageManager = DependencyManager.storageManager
    private let difficultyRange = Double(GameConfiguration.minimumDepth)...Double(GameConfiguration.maximumDepth)

    let onSelectDifficulty: ((Int) -> Void)

    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            BackButton {
                withAnimation {
                    coordinator.popBack()
                }
            }

            Spacer()

            VStack(spacing: 30) {
                VStack(spacing: 12) {
                    Text("Custom Difficulty")
                        .font(.system(size: 32, weight: .bold))

                    Text("Choose your challenge")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.gray)
                }

                VStack(spacing: 24) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.95, green: 0.95, blue: 0.97),
                                        Color(red: 0.88, green: 0.88, blue: 0.92)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)

                        VStack(spacing: 20) {
                            Text(getDifficultyDescription())
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(getDifficultyColor())

                            HStack(spacing: 8) {
                                Image(systemName: "square.grid.3x3.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)

                                Text("\(Int(difficulty)) cells")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.black)
                            }
                        }
                        .padding(.vertical, 32)
                    }
                    .padding(.horizontal, 24)

                    VStack(spacing: 12) {
                        HStack {
                            Text("Easy")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)

                            Spacer()

                            Text("Extreme")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.gray)
                        }

                        LinearGradientSlider(value: $difficulty, range: difficultyRange, step: 1)
                            .frame(height: 40)
                    }
                    .padding(.horizontal, 24)
                }
            }

            Spacer()

            Button("Start the Game") {
                let selectedDifficulty = Int(difficulty)
                storageManager.preferredDepth = selectedDifficulty
                onSelectDifficulty(selectedDifficulty)
            }
            .buttonStyle(MenuButton())
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
        .onAppear {
            difficulty = Double(storageManager.preferredDepth)
        }
    }

    private func getDifficultyColor() -> Color {
        let level = Difficulty.getDifficulty(depth: Int(difficulty))
        switch level {
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

    // MARK: - Methods
    private func getDifficultyDescription() -> String {
        Difficulty.getDifficulty(depth: Int(difficulty)).name
    }
}

struct SelectDifficultyView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDifficultyView { _ in

        }
    }
}
