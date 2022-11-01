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
    private let analyticsManager = DependencyManager.analyticsManager
    private let tableBuilder = DependencyManager.tableBuilder

    @State var gameManager: GameManager?
    @State var shouldShowPickDifficulty: Bool = false
    @State private var isShowingSetting = false
    @State private var isShowingStatistics = false
    @State private var isSelectingPlaySet = false
    @State private var difficulty: Difficulty?
    @ObservedObject var coordinator = HomeCoordinator()

    private var bag = Set<AnyCancellable>()

    // MARK: - Content

    private var topBar: some View {
        HStack(alignment: .top, spacing: 20.0) {
            Spacer()

            Button {
                isShowingStatistics = true
                analyticsManager.logEvent(.customGameStatistics)
            } label: {
                Image(systemName: "line.3.horizontal.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(R.color.button.name))
            }

            Button {
                isShowingSetting = true
                analyticsManager.logEvent(.homeSettings)
            } label: {
                Image(systemName: "gear")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(R.color.button.name))
            }
        }
        .padding(.horizontal, 20)
    }

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
                    PickLevelView(viewModel: PickLevelViewModel(difficulty: difficulty, userFinishedLevels: storageManager.solvedLevels)) { levelNumber in
                        if let level = localLevelManager.getLevel(difficulty: difficulty, level: levelNumber) {
                            gameManager = GameManager(level: level,
                                                      templateLevel: TemplateLevel(difficulty: difficulty, visualLevel: levelNumber + 1))

                            withAnimation {
                                coordinator.currentScreen = .game
                            }
                        }
                    }
                    .transition(.move(edge: .trailing))
                    .environmentObject(coordinator)
                }
            case .none:
                VStack {
                    topBar
                        .frame(height: 30, alignment: .trailing)
                        .padding(.top, 20)

                    Spacer()

                    Text("Sudokov")
                        .font(.system(size: 45, weight: .semibold))
                        .confirmationDialog("How do you want to play?", isPresented: $isSelectingPlaySet, titleVisibility: .visible) {
                            ForEach(PlaySet.allCases, id: \.self) { playSet in
                                Button(playSet.rawValue) {
                                    storageManager.preferredPlaySet = playSet
                                    storageManager.featureFlagManager = FeatureFlagManager(playSet: playSet)

                                    analyticsManager.logEvent(.homePlaySet, parameters: PlaySetAnalytics(playSet: playSet))
                                }
                            }
                        }
                    VStack {
                        Button("Start game") {
                            shouldShowPickDifficulty = true
                        }
                        .buttonStyle(MenuButton())
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.top, 30)
                        .sheet(isPresented: $isShowingSetting) {
                            SettingsView()
                        }

                        Button("Generate a level") {
                            coordinator.currentScreen = .selectGenerateDifficulty
                        }
                        .buttonStyle(MenuButton())
                        .font(.system(size: 15, weight: .semibold))
                        .padding(.top, 20)
                        .sheet(isPresented: $isShowingStatistics) {
                            StatisticsView()
                        }
                    }

                    Spacer()
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
            case .selectGenerateDifficulty:
                SelectDifficultyView { difficulty in
                    let level = Level(
                        table: tableBuilder.table,
                        cellsToHide: tableBuilder.makeCellsToRemove(
                            tableState: tableBuilder.tableState,
                            depth: difficulty
                        )
                    )

                    gameManager = GameManager(level: level,
                                              templateLevel: nil)

                    analyticsManager.logEvent(.customGameGenerate,
                                              parameters: CustomGameAnalytics(difficulty: difficulty))
                    coordinator.currentScreen = .game
                }
                .environmentObject(coordinator)
            }
        }
        .onAppear {
            if let currentLevel = storageManager.currentLevelInfo {
                gameManager = GameManager(levelInfo: currentLevel)
                coordinator.currentScreen = .game
                return
            }

            if storageManager.preferredPlaySet == nil {
                isSelectingPlaySet = true
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
