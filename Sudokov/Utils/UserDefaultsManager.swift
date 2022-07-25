//
//  UserDefaultsManager.swift
//  Sudokov
//
//  Created by furrki on 24.07.2022.
//

import Foundation

class UserDefaultsManager {
    // MARK: - Constants
    private enum Keys {
//        static let currentLevelInfo = "CurrentLevelInfo"
    }

    // MARK: - Properties
    let userDefaults: UserDefaults
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    // MARK: - Computed Properties

    // MARK: - Methods
    /*
    func encodeSet<E: Encodable>(key: String, encodableObject: E) {
        if let encoded = try? encoder.encode(encodableObject) {
            userDefaults.set(encoded, forKey: key)
        }
    }

    func decodeGet<D: Decodable>(key: String) -> D? {
        if let savedObject = userDefaults.data(forKey: key) {
            if let loadedObject = try? decoder.decode(D.self, from: savedObject) {
                return loadedObject
            }
        }

        return nil
    }
     */
}
