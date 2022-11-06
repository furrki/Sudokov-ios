//
//  GameInfoView.swift
//  Sudokov
//
//  Created by furrki on 25.07.2022.
//

import SwiftUI

struct GameInfoView: View {
    @EnvironmentObject var gameManager: GameManager
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
                    title: Text("Abandon game?"),
                    message: nil,
                    primaryButton: .cancel(),
                    secondaryButton: .destructive(Text("Abandon")) {
                        gameManager.abandonGame()

                        withAnimation {
                            coordinator.popBack()
                        }
                    }
                )
            }

            Text(gameManager.levelText)
                .font(.system(size: 14.0))

            Spacer()

            if DependencyManager.storageManager.featureFlagManager.lives {
                Text(gameManager.livesText)
                    .font(.system(size: 14.0))
            }

            if DependencyManager.storageManager.featureFlagManager.timer {
                Text(gameManager.timerText)
                    .font(.system(size: 14.0))
            }
        }
        .padding(.horizontal, 20)
    }
}
