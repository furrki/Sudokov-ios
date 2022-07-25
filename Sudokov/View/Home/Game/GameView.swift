//
//  GameView.swift
//  Sudokov
//
//  Created by furrki on 11.06.2022.
//

import SwiftUI
import Combine

struct GameView: View {
    @StateObject var gameManager: GameManager
    @EnvironmentObject var coordinator: HomeCoordinator

    var body: some View {
        ZStack {
            Color
                .white
                .ignoresSafeArea()

            GeometryReader { geometry in
                VStack(alignment: .center, spacing: 20) {
                    GameInfoView()
                        .environmentObject(gameManager)
                        .environmentObject(coordinator)
                        .padding(.top, 20)

                    TableView(geometry: geometry)
                        .environmentObject(gameManager)

                    ControlsView(configuration: GameConfiguration.shared)
                        .environmentObject(gameManager)
                        .padding(.horizontal, 20)

                    NumberPickerView(configuration: GameConfiguration.shared)
                        .environmentObject(gameManager)
                        .padding(.horizontal, 10)
                    Spacer()
                }
            }
        }
    }
}
