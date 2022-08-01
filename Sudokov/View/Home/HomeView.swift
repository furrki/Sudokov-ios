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
    @State var shouldShowPickDifficulty: Bool = false
    @State private var difficulty: Difficulty?
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
                        .transition(.moveAndScale)
                }
            case .selectLevel:
                if let difficulty = difficulty {
                    PickLevelView(viewModel: PickLevelViewModel(difficulty: difficulty)) { levelNumber in
                        if let level = localLevelManager.getLevel(difficulty: difficulty, level: levelNumber) {
                            gameManager = GameManager(level: level,
                                                      templateLevel: TemplateLevel(difficulty: difficulty, level: levelNumber))

                            withAnimation {
                                coordinator.currentScreen = .game
                            }
                        }
                    }
                    .transition(.move(edge: .trailing))
                }
            case .none:
                VStack {
                    Text("Sudokov")
                        .font(.system(size: 45, weight: .semibold))

                    Button("Start Game") {
                        shouldShowPickDifficulty = true
                    }
                    .buttonStyle(MenuButton())
                    .font(.system(size: 20, weight: .semibold))
                    .padding(.top, 30)
                }
                .confirmationDialog("Pick Difficulty", isPresented: $shouldShowPickDifficulty, titleVisibility: .visible) {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Button(difficulty.name) {
                            withAnimation {
                                self.difficulty = difficulty
                                coordinator.currentScreen = .selectLevel
                            }
                        }
                    }
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
