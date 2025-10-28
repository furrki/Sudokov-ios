//
//  StorageManager.swift
//  Sudokov
//
//  Created by furrki on 25.07.2022.
//

import Foundation
import SwiftUI

class StorageManager {
    // MARK: - Constants
    private enum Keys {
        static let levelInfo = "LevelInfo"
        static let solvedLevels = "SolvedLevels"
        static let featureFlags = "FeatureFlags"
        static let preferredPlaySet = "PreferredPlaySet"
        static let preferredDepth = "PreferredDepth"
        static let preferredDifficulty = "PreferredDifficulty"
        static let levelStatistics = "LevelStatistics"
        static let preferredColorScheme = "PreferredColorScheme"
    }

    // MARK: - Properties
    private let storage: CodableStorage

    // MARK: - Methods
    init(storage: CodableStorage = DependencyManager.storage) {
        self.storage = storage
    }

    // MARK: - Computed Properties
    var currentLevelInfo: LevelInfo? {
        get {
            fetchFromFile(key: Keys.levelInfo)
        }

        set {
            try? storage.save(newValue, for: Keys.levelInfo)
        }
    }

    var solvedLevels: [TemplateLevel] {
        get {
            fetchFromFile(key: Keys.solvedLevels) ?? []
        }

        set {
            try? storage.save(newValue, for: Keys.solvedLevels)
        }
    }

    var preferredPlaySet: PlaySet? {
        get {
            fetchFromFile(key: Keys.preferredPlaySet)
        }

        set {
            try? storage.save(newValue, for: Keys.preferredPlaySet)
        }
    }

    var preferredColorScheme: ColorScheme? {
        get {
            .dark
        }
    }

    var preferredDepth: Int {
        get {
            fetchFromFile(key: Keys.preferredDepth) ?? GameConfiguration.defaultPickDepth
        }

        set {
            try? storage.save(newValue, for: Keys.preferredDepth)
        }
    }

    var preferredDifficulty: Difficulty? {
        get {
            fetchFromFile(key: Keys.preferredDifficulty)
        }

        set {
            try? storage.save(newValue, for: Keys.preferredDifficulty)
        }
    }

    var levelStatistics: [LevelStatistics] {
        get {
            fetchFromFile(key: Keys.levelStatistics) ?? []
        }

        set {
            try? storage.save(newValue, for: Keys.levelStatistics)
        }
    }

    var featureFlagManager: FeatureFlagManager {
        get {
            fetchFromFile(key: Keys.featureFlags) ?? FeatureFlagManager(playSet: .arcade)
        }

        set {
            try? storage.save(newValue, for: Keys.featureFlags)
        }
    }

    private func fetchFromFile<D: Decodable>(key: String) -> D? {
        do {
            let data: D = try storage.fetch(for: key)
            return data
        } catch {
            return nil
        }
    }
}
