//
//  HomeView.swift
//  Sudokov
//
//  Created by furrki on 11.06.2022.
//

import SwiftUI
import Combine

struct HomeView: View {
    // MARK: - Properties
    private let localLevelManager = DependencyManager.localLevelManager
    private let storageManager = DependencyManager.storageManager
    @State var gameManager: GameManager?
    @ObservedObject var coordinator = HomeCoordinator()
    private var bag = Set<AnyCancellable>()

    // MARK: - Content
    var body: some View {
        ZStack {
            switch coordinator.currentScreen {
            case .game:
                if let gameManager = gameManager {
                    GameView(gameManager: gameManager)
                        .environmentObject(coordinator)
                }
            case .none:
                VStack {
                    Button("Start Game") {
                        if let level = localLevelManager.getLevel(difficulty: .easy, level: 1) {
                            gameManager = GameManager(level: level)
                            coordinator.currentScreen = .game
                        }
                    }
                    .buttonStyle(MenuButton())
                }
            }
        }
        .onAppear {
            if let currentLevel = storageManager.currentLevelInfo {
                gameManager = GameManager(levelInfo: currentLevel)
                coordinator.currentScreen = .game
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
