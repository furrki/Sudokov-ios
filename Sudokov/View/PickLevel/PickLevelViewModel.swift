//
//  PickLevelViewModel.swift
//  Sudokov
//
//  Created by furrki on 2.08.2022.
//

import Foundation

class PickLevelViewModel {
    let levelCount = 50
    let rowsCount = 10
    let colsCount = 5
    let difficulty: Difficulty
    let titleText: String
    let userFinishedLevels: [TemplateLevel]

    init(difficulty: Difficulty, userFinishedLevels: [TemplateLevel]) {
        self.difficulty = difficulty
        self.userFinishedLevels = userFinishedLevels

        titleText = "Select Level - \(difficulty.name)"
    }

    func getContent(row: Int, col: Int) -> Int {
        (row - 1) * colsCount + col
    }

    func getLevel(row: Int, col: Int) -> Int {
        getContent(row: row, col: col) - 1
    }

    func isFinished(row: Int, col: Int) -> Bool {
        return userFinishedLevels.contains { level in
            level.difficulty == difficulty && getLevel(row: row, col: col) == level.visualLevel - 1
        }
    }
}
