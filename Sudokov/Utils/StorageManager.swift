//
//  StorageManager.swift
//  Sudokov
//
//  Created by furrki on 25.07.2022.
//

import Foundation

class StorageManager {
    // MARK: - Constants
    private enum Keys {
        static let levelInfo = "LevelInfo"
        static let solvedLevels = "SolvedLevels"
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

    private func fetchFromFile<D: Decodable>(key: String) -> D? {
        do {
            let data: D = try storage.fetch(for: key)
            return data
        } catch {
            return nil
        }
    }
}
