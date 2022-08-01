//
//  LevelInfo.swift
//  Sudokov
//
//  Created by furrki on 18.07.2022.
//

import Foundation

struct LevelInfo: Codable {
    let tableFirstState: TableMatrix
    let solution: TableMatrix
    let drafts: Dictionary<Coordinate, [Int]>
    let moves: [Move]
    let conflicts: [Coordinate]
    let unmatches: [Coordinate]
    let lives: Int
    let options: [Int]
    let tableState: TableMatrix
    let level: TemplateLevel?
    let levelState: LevelState
}
