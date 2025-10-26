//
//  LoadingGameInfoView.swift
//  Sudokov
//

import SwiftUI

struct LoadingGameInfoView: View {
    @EnvironmentObject var coordinator: HomeCoordinator
    @State private var isAbandoning = false

    var body: some View {
        HStack(spacing: 15) {
            Button {
                isAbandoning = true
            } label: {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor(Color(R.color.button.name))
            }
            .alert(isPresented: $isAbandoning) {
                Alert(
                    title: Text("Cancel generation?"),
                    message: nil,
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Cancel")) {
                        coordinator.currentScreen = .none
                    }
                )
            }

            if let difficulty = coordinator.selectedDifficulty {
                Text("\(difficulty) - \(Difficulty.getDifficulty(depth: difficulty).name)")
                    .font(.system(size: 14.0))
            } else {
                Text("Generating...")
                    .font(.system(size: 14.0))
            }

            Spacer()

            if DependencyManager.storageManager.featureFlagManager.lives {
                Text("❤️ 3")
                    .font(.system(size: 14.0))
            }

            if DependencyManager.storageManager.featureFlagManager.timer {
                Text("⏱️ 00:00")
                    .font(.system(size: 14.0))
            }
        }
        .padding(.horizontal, 20)
    }
}
