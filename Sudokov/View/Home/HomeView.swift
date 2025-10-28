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

    @State var gameManager: GameManager?
    @State var shouldShowPickDifficulty = false
    @State private var isShowingSetting = false
    @State private var isShowingStatistics = false
    @State private var isSelectingPlaySet = false
    @State private var difficulty: Difficulty?
    @ObservedObject var coordinator = HomeCoordinator()

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

                    VStack(spacing: 8) {
                        Text("Sudokov")
                            .font(.system(size: 50, weight: .bold))

                        Text("Master the grid, one number at a time")
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.gray)
                    }
                    .padding(.bottom, 50)

                    VStack(spacing: 20) {
                        HomeMenuCard(
                            icon: "gamecontroller.fill",
                            title: "Start Game",
                            subtitle: "Pick a level and play",
                            action: {
                                withAnimation {
                                    shouldShowPickDifficulty = true
                                }
                            },
                            gradient: LinearGradient(
                                colors: [Color(red: 0.98, green: 0.5, blue: 0.3), Color(red: 0.95, green: 0.3, blue: 0.4)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .sheet(isPresented: $isShowingSetting) {
                            SettingsView()
                        }

                        HomeMenuCard(
                            icon: "sparkles",
                            title: "Generate Level",
                            subtitle: "Create a random puzzle",
                            action: {
                                coordinator.currentScreen = .selectGenerateDifficulty
                            },
                            gradient: LinearGradient(
                                colors: [Color(red: 0.3, green: 0.6, blue: 0.98), Color(red: 0.2, green: 0.4, blue: 0.95)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .sheet(isPresented: $isShowingStatistics) {
                            StatisticsView()
                        }
                    }
                    .padding(.horizontal, 24)
                    .sheet(isPresented: $shouldShowPickDifficulty) {
                        DifficultyPickerView(
                            onDifficultySelected: { selectedDifficulty in
                                self.difficulty = selectedDifficulty
                                withAnimation {
                                    coordinator.currentScreen = .selectLevel
                                    shouldShowPickDifficulty = false
                                }
                            },
                            onDismiss: {
                                withAnimation {
                                    shouldShowPickDifficulty = false
                                }
                            }
                        )
                    }

                    Spacer()
                }
                .confirmationDialog("How do you want to play?", isPresented: $isSelectingPlaySet, titleVisibility: .visible) {
                    ForEach(PlaySet.allCases, id: \.self) { playSet in
                        Button(playSet.rawValue) {
                            storageManager.preferredPlaySet = playSet
                            storageManager.featureFlagManager = FeatureFlagManager(playSet: playSet)

                            analyticsManager.logEvent(.homePlaySet, parameters: PlaySetAnalytics(playSet: playSet))
                        }
                    }
                }
            case .selectGenerateDifficulty:
                SelectDifficultyView { difficulty in
                    // Show loading immediately
                    coordinator.currentScreen = .generating

                    // Start generation on background thread
                    DispatchQueue.global(qos: .userInitiated).async {
                        let tableBuilder = TableBuilder(depth: difficulty)

                        // Store tableBuilder for progress tracking
                        DispatchQueue.main.async {
                            coordinator.generatingTableBuilder = tableBuilder
                        }

                        // Create game as soon as generation completes
                        let level = Level(
                            table: tableBuilder.table,
                            cellsToHide: Array(tableBuilder.cellsToHide)
                        )

                        let newGameManager = GameManager(level: level, templateLevel: nil)

                        analyticsManager.logEvent(.customGameGenerate,
                                                  parameters: CustomGameAnalytics(difficulty: difficulty))

                        // Transition to game on main thread
                        DispatchQueue.main.async {
                            gameManager = newGameManager
                            coordinator.currentScreen = .game
                        }
                    }
                }
                .environmentObject(coordinator)
            case .generating:
                GeometryReader { geometry in
                    VStack(alignment: .center, spacing: 20) {
                        LoadingGameInfoView()
                            .environmentObject(coordinator)
                            .padding(.top, 20)

                        LoadingTableView(geometry: geometry)

                        // Progress info in place of controls
                        VStack(spacing: 12) {
                            if let tableBuilder = coordinator.generatingTableBuilder {
                                Text(tableBuilder.generationMessage)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(R.color.levelSquareText.name))
                                    .multilineTextAlignment(.center)

                                ProgressView(value: tableBuilder.generationProgress)
                                    .tint(Color(R.color.button.name))
                                    .frame(width: 280)
                            } else {
                                ProgressView()
                                    .tint(Color(R.color.button.name))
                            }
                        }
                        .padding(.horizontal, 20)

                        // Empty space for NumberPickerView
                        Color.clear
                            .frame(height: 60)

                        Spacer()

                        AdView()
                    }
                }
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
