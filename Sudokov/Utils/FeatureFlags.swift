//
//  FeatureFlags.swift
//  Sudokov
//
//  Created by furrki on 17.07.2022.
//

import Foundation

class FeatureFlagManager: Codable {
    let hideNotNeededNumberButtons: Bool
    let revertButton: Bool
    let tableHighlighting: Bool
    let alertConflict: Bool
    let alertNotMatch: Bool
    let lives: Bool
    let timer: Bool

    init(hideNotNeededNumberButtons: Bool,
         revertButton: Bool,
         tableHighlighting: Bool,
         alertConflict: Bool,
         alertNotMatch: Bool,
         timer: Bool) {
        self.hideNotNeededNumberButtons = hideNotNeededNumberButtons
        self.revertButton = revertButton
        self.tableHighlighting = tableHighlighting
        self.alertConflict = alertConflict
        self.alertNotMatch = alertNotMatch
        self.lives = alertConflict || alertNotMatch
        self.timer = timer
    }

    init(playSet: PlaySet) {
        switch playSet {
        case .oldSchool:
            self.hideNotNeededNumberButtons = false
            self.revertButton = false
            self.tableHighlighting = false
            self.alertConflict = false
            self.alertNotMatch = false
            self.lives = false
            self.timer = true
        case .arcade:
            self.hideNotNeededNumberButtons = true
            self.revertButton = true
            self.tableHighlighting = true
            self.alertConflict = true
            self.alertNotMatch = false
            self.lives = true
            self.timer = true
        }
    }
}
