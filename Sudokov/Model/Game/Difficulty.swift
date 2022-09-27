//
//  Difficulty.swift
//  Sudokov
//
//  Created by furrki on 24.07.2022.
//

import Foundation

enum Difficulty: CaseIterable, Codable {
    case easy
    case medium
    case hard

    var name: String {
        switch self {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
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
        }
    }
}
