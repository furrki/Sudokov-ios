//
//  Move.swift
//  Sudokov
//
//  Created by furrki on 16.07.2022.
//

import Foundation

struct Move: Codable {
    enum MoveType: Codable {
        case text
        case draft
        case draftProgramatically
    }

    let row: Int
    let col: Int
    let moveType: MoveType
    let content: [Int]
}
