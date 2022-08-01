//
//  LevelState.swift
//  Sudokov
//
//  Created by Furkan Kaynar on 1.08.2022.
//

import Foundation

enum LevelState: Codable {
    case solving
    case justWon
    case justLost
    case ended
}
