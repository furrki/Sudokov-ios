//
//  FeatureFlags.swift
//  Sudokov
//
//  Created by furrki on 17.07.2022.
//

import Foundation

class FeatureFlagManager {
    let hideNotNeededNumberButtons: Bool
    let backButton: Bool
    let tableHighlighting: Bool
    let alertConflict: Bool
    let alertNotMatch: Bool
    let lives: Bool

    init(hideNotNeededNumberButtons: Bool,
         revertButton: Bool,
         tableHighlighting: Bool,
         alertConflict: Bool,
         alertNotMatch: Bool) {
        self.hideNotNeededNumberButtons = hideNotNeededNumberButtons
        self.backButton = revertButton
        self.tableHighlighting = tableHighlighting
        self.alertConflict = alertConflict
        self.alertNotMatch = alertNotMatch
        self.lives = alertConflict || alertNotMatch
    }
}
