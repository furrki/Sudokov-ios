//
//  Difficulty.swift
//  Sudokov
//
//  Created by furrki on 24.07.2022.
//

import Foundation

enum Difficulty: CaseIterable, Codable {
    case veryEasy
    case easy
    case normal

    var name: String {
        switch self {
        case .veryEasy:
            return "Very Easy"
        case .easy:
            return "Easy"
        case .normal:
            return "Normal"
        }
    }

    var fileName: String {
        switch self {
        case .veryEasy:
            return "veryEasy"
        case .easy:
            return "easy"
        case .normal:
            return "normal"
        }
    }
}
