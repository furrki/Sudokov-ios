//
//  Level.swift
//  Sudokov
//
//  Created by furrki on 24.07.2022.
//

import Foundation

struct Level: Codable, Hashable {
    let table: TableMatrix
    let cellsToHide: [Coordinate]
}
