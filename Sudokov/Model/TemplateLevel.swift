//
//  SolvedLevel.swift
//  Sudokov
//
//  Created by furrki on 30.07.2022.
//

import Foundation

struct TemplateLevel: Codable, Equatable {
    let difficulty: Difficulty
    let visualLevel: Int // [1-50]
}
