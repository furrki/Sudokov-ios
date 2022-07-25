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
        HStack {
            Button {
                isAbandoning = true
            } label: {
                Image(systemName: "xmark.circle")
                    .resizable()
                    .frame(width: 25, height: 25)
            }

            Spacer()

            if GameConfiguration.shared.featureFlags.lives {
                Text(gameManager.livesText)
                    .font(.system(size: 14.0))
            }
        }
        .padding(.horizontal, 20)
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
    }
}
