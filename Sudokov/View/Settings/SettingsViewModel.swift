//
//  SettingsViewModel.swift
//  Sudokov
//
//  Created by furrki on 21.08.2022.
//

import Foundation

class SettingsViewModel: ObservableObject {
    @Published var hideNotNeededNumberButtons: Bool
    @Published var revertButton: Bool
    @Published var tableHighlighting: Bool
    @Published var alertConflict: Bool
    @Published var alertNotMatch: Bool
    @Published var timer: Bool

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
        self.timer = timer
    }

    init(featureFlagManager: FeatureFlagManager) {
        self.hideNotNeededNumberButtons = featureFlagManager.hideNotNeededNumberButtons
        self.revertButton = featureFlagManager.revertButton
        self.tableHighlighting = featureFlagManager.tableHighlighting
        self.alertConflict = featureFlagManager.alertConflict
        self.alertNotMatch = featureFlagManager.alertNotMatch
        self.timer = featureFlagManager.timer
    }

    func saveFeatureFlagManager() {
        let featureFlagManager = FeatureFlagManager(hideNotNeededNumberButtons: hideNotNeededNumberButtons,
                                                    revertButton: revertButton,
                                                    tableHighlighting: tableHighlighting,
                                                    alertConflict: alertConflict,
                                                    alertNotMatch: alertNotMatch,
                                                    timer: timer)
        DependencyManager.storageManager.featureFlagManager = featureFlagManager
    }

    func load(featureFlagManager: FeatureFlagManager) {
        self.hideNotNeededNumberButtons = featureFlagManager.hideNotNeededNumberButtons
        self.revertButton = featureFlagManager.revertButton
        self.tableHighlighting = featureFlagManager.tableHighlighting
        self.alertConflict = featureFlagManager.alertConflict
        self.alertNotMatch = featureFlagManager.alertNotMatch
        self.timer = featureFlagManager.timer
    }
}
