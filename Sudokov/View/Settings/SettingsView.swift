//
//  SettingsView.swift
//  Sudokov
//
//  Created by furrki on 4.08.2022.
//

import SwiftUI

struct SettingsView: View {
    @State private var isSelectingPlaySet = false
    @ObservedObject private var viewModel: SettingsViewModel = SettingsViewModel(featureFlagManager: DependencyManager.storageManager.featureFlagManager)
    private let storageManager: StorageManager = DependencyManager.storageManager

    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle(isOn: $viewModel.hideNotNeededNumberButtons) {
                        Text("Hide found numbers")
                    }

                    Toggle(isOn: $viewModel.revertButton) {
                        Text("Revert button")
                    }

                    Toggle(isOn: $viewModel.tableHighlighting) {
                        Text("Highlighting table")
                    }

                    Toggle(isOn: $viewModel.alertConflict) {
                        Text("Check for conflicts")
                    }

                    Toggle(isOn: $viewModel.alertNotMatch) {
                        Text("Check for wrong number")
                    }

                    Toggle(isOn: $viewModel.timer) {
                        Text("Timer")
                    }
                }

                Button("Select a play set") {
                    isSelectingPlaySet = true
                }

            }
            .navigationTitle("Settings")
            .confirmationDialog("Select a play set", isPresented: $isSelectingPlaySet, titleVisibility: .visible) {
                ForEach(FeatureFlagManager.PlaySet.allCases, id: \.self) { playSet in
                    Button(playSet.rawValue) {
                        storageManager.preferredPlaySet = playSet
                        storageManager.featureFlagManager = FeatureFlagManager(playSet: playSet)

                        withAnimation {
                            viewModel.load(featureFlagManager: storageManager.featureFlagManager)
                        }
                    }
                }
            }
        }
        .onDisappear {
            viewModel.saveFeatureFlagManager()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

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
