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
    private let tableBuilder = DependencyManager.tableBuilder
    private let storageManager = DependencyManager.storageManager
    private let difficultyRange = Double(GameConfiguration.minimumDepth)...Double(GameConfiguration.maximumDepth)

    let onSelectDifficulty: ((Int) -> Void)

    // MARK: - Body
    var body: some View {
        VStack {
            BackButton {
                withAnimation {
                    coordinator.popBack()
                }
            }

            Spacer()

            VStack(alignment: .center, spacing: 15.0) {
                Text("\(getDifficultyDescription())")

                Text("Cells to erase: \(Int(difficulty))")

                LinearGradientSlider(value: $difficulty, range: difficultyRange, step: 1)
                    .frame(height: 30)
                    .padding(.horizontal, 40)

                Button("Start the game") {
                    let selectedDifficulty = Int(difficulty)
                    storageManager.preferredDepth = selectedDifficulty
                    onSelectDifficulty(selectedDifficulty)
                }
                .buttonStyle(MenuButton())
                .font(.system(size: 15, weight: .semibold))
                .padding(.top, 30)
            }

            Spacer()
        }
        .onAppear {
            difficulty = Double(storageManager.preferredDepth)
        }
    }

    // MARK: - Methods
    private func getDifficultyDescription() -> String {
        switch Int(difficulty) {
        case GameConfiguration.minimumDepth...GameConfiguration.hardDepth:
            return "Hardcore 🔥"
        case (GameConfiguration.hardDepth + 1)...GameConfiguration.mediumDepth:
            return "Hard ❤️‍🔥"
        case (GameConfiguration.mediumDepth + 1)...GameConfiguration.easyDepth:
            return "Medium 👊"
        case (GameConfiguration.easyDepth + 1)...GameConfiguration.veryEasyDepth:
            return "Easy 🌞"
        case (GameConfiguration.veryEasyDepth + 1)...GameConfiguration.maximumDepth:
            return "Basic ☀️"
        default:
            return "Simple ☀️"
        }
    }
}

struct SelectDifficultyView_Previews: PreviewProvider {
    static var previews: some View {
        SelectDifficultyView { _ in

        }
    }
}
