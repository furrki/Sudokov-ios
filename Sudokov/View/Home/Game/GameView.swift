//
//  GameView.swift
//  Sudokov
//
//  Created by furrki on 11.06.2022.
//

import SwiftUI
import Combine

struct GameView: View {
    // MARK: - Constants
    private enum InternalAlert {
        case wonLevel(levelDescription: String)
        case wonPuzzle
        case lost
        
        var alert: Alert {
            switch self {
            case .wonLevel(let levelDescription):
                return Alert(title: Text("Congratulations!"),
                             message: Text("You've successfully completed \(levelDescription)"),
                             dismissButton: .default(Text("Okay!")))
            case .wonPuzzle:
                return Alert(title: Text("Congratulations!"),
                             message: Text("You've successfully completed the puzzle!"),
                             dismissButton: .default(Text("Okay!")))
            case .lost:
                return Alert(title: Text("No worries!"),
                             message: Text("You can restart the puzzle"),
                             dismissButton: .default(Text("Okay")))
            }
        }
    }
    
    // MARK: - Properties
    @StateObject var gameManager: GameManager
    @EnvironmentObject var coordinator: HomeCoordinator
    @State private var internalAlert: InternalAlert?
    @State private var shouldShowAlert = false
    
    // MARK: - Body
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
                        .alert(isPresented: $shouldShowAlert) {
                            if let alert = internalAlert?.alert {
                                return alert
                            } else {
                                return Alert(title: Text(""))
                            }
                        }
                        .onReceive(gameManager.$levelState) { levelState in
                            switch gameManager.levelState {
                            case .justWon:
                                if let level = gameManager.level {
                                    internalAlert = .wonLevel(levelDescription: "Level \(level.visualLevel), \(level.difficulty.name)")
                                } else {
                                    internalAlert = .wonPuzzle
                                }
                                gameManager.levelState = .ended
                            case .justLost:
                                internalAlert = .lost
                                gameManager.levelState = .ended
                            case .ended, .solving:
                                break
                            }

                            shouldShowAlert = internalAlert != nil
                        }
                    Spacer()
                }
                .onAppear {
                    gameManager.saveState()
                }
            }
        }
    }
}
