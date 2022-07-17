//
//  GameView.swift
//  Sudokov
//
//  Created by furrki on 11.06.2022.
//

import SwiftUI
import Combine

struct GameView: View {
    @StateObject var gameManager: GameManager = GameManager()

    var body: some View {
        ZStack {
            Color
                .white
                .ignoresSafeArea()

            GeometryReader { geometry in
                VStack(alignment: .center, spacing: 20) {
                    Spacer()

                    GameInfoView()
                        .environmentObject(gameManager)

                    TableView(geometry: geometry)
                        .environmentObject(gameManager)

                    ControlsView(configuration: GameConfiguration.shared)
                        .environmentObject(gameManager)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)

                    NumberPickerView(configuration: GameConfiguration.shared)
                        .environmentObject(gameManager)
                        .padding(.top, 10)
                        .padding(.horizontal, 20)
                    Spacer()
                }
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(gameManager: GameManager())
    }
}

struct GameInfoView: View {
    @EnvironmentObject var gameManager: GameManager

    var body: some View {
        HStack {
            if GameConfiguration.shared.featureFlags.lives {
                Text(gameManager.livesText)
                    .font(.system(size: 14.0))
            }
        }
    }
}
