//
//  LocalLevelManager.swift
//  Sudokov
//
//  Created by furrki on 24.07.2022.
//

import Foundation

class LocalLevelManager {
    func getLevel(difficulty: Difficulty, level: Int) -> Level? {
        guard let path = Bundle.main.path(forResource: difficulty.fileName, ofType: "data") else {
            return nil
        }

        do {
            let string = try String(contentsOfFile: path, encoding: String.Encoding.utf8)

            if let data = Data(base64Encoded: string),
               let decodedData = try JSONDecoder().decode([Level]?.self, from: data) {
                return decodedData[level]
            } else {
                return nil
            }
        } catch let error {
            print(error)
            return nil
        }
    }
}
