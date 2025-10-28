//
//  PickLevelViewModel.swift
//  Sudokov
//
//  Created by furrki on 2.08.2022.
//

import Foundation

class PickLevelViewModel {
    let levelCount = 100
    let rowsCount = 20
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

    func isLocked(row: Int, col: Int) -> Bool {
        let currentLevel = getLevel(row: row, col: col)

        // First level (0) is always unlocked
        if currentLevel == 0 {
            return false
        }

        // Check if previous level is completed
        let previousLevel = currentLevel - 1
        let isPreviousCompleted = userFinishedLevels.contains { level in
            level.difficulty == difficulty && previousLevel == level.visualLevel - 1
        }

        return !isPreviousCompleted
    }
}
