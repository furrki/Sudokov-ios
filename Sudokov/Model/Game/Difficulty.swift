//
//  Difficulty.swift
//  Sudokov
//
//  Created by furrki on 24.07.2022.
//

import Foundation

enum Difficulty: CaseIterable, Codable {
    case basic
    case easy
    case medium
    case hard
    case hardcore

    var name: String {
        switch self {
        case .basic:
            return "Basic 🌞"
        case .easy:
            return "Easy ☀️"
        case .medium:
            return "Medium 👊"
        case .hard:
            return "Hard ❤️‍🔥"
        case .hardcore:
            return "Hardcore 🔥"
        }
    }

    var fileName: String {
        switch self {
        case .easy:
            return "easy"
        case .medium:
            return "medium"
        case .hard:
            return "hard"
        default:
            return ""
        }
    }

    static let preparedLevels: [Difficulty] = [.easy, .medium, .hard]

    static func getDifficulty(depth: Int) -> Difficulty {
        switch depth {
        case GameConfiguration.minimumDepth...GameConfiguration.hardDepth:
            return .hardcore
        case (GameConfiguration.hardDepth + 1)...GameConfiguration.mediumDepth:
            return .hard
        case (GameConfiguration.mediumDepth + 1)...GameConfiguration.easyDepth:
            return .medium
        case (GameConfiguration.easyDepth + 1)...GameConfiguration.veryEasyDepth:
            return .easy
        case (GameConfiguration.veryEasyDepth + 1)...GameConfiguration.maximumDepth:
            return .basic
        default:
            return .basic
        }
    }
}
