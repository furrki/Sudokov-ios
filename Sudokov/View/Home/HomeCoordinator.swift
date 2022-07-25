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

    enum Screen: String, Hashable, CaseIterable {
        case game
    }
}
