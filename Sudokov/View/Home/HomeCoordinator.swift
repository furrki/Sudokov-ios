//
//  HomeCoordinator.swift
//  Sudokov
//
//  Created by furrki on 24.07.2022.
//

import Foundation
import Combine

class HomeCoordinator: Coordinator, ObservableObject {
    @Published var currentScreen: Screen?
    @Published var generatingTableBuilder: TableBuilder?
    @Published var selectedDifficulty: Int?

    enum Screen: String, Hashable, CaseIterable {
        case game
        case selectLevel
        case selectGenerateDifficulty
        case generating
    }
}
