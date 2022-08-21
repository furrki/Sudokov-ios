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
    private let storageManager = DependencyManager.storageManager
    private let analyticsManager = DependencyManager.analyticsManager

    var body: some View {
        NavigationView {
            List {
                Section {
                    Toggle(isOn: $viewModel.hideNotNeededNumberButtons) {
                        Text("Hide found numbers")
                    }
                    .onChange(of: viewModel.hideNotNeededNumberButtons) { value in
                        analyticsManager.logEvent(.settingsUpdate, parameters: SettingsAnalytics(setting: .hideNotNeededNumberButtons, isOn: value))
                    }

                    Toggle(isOn: $viewModel.revertButton) {
                        Text("Revert button")
                    }
                    .onChange(of: viewModel.revertButton) { value in
                        analyticsManager.logEvent(.settingsUpdate, parameters: SettingsAnalytics(setting: .revertButton, isOn: value))
                    }

                    Toggle(isOn: $viewModel.tableHighlighting) {
                        Text("Highlighting table")
                    }
                    .onChange(of: viewModel.tableHighlighting) { value in
                        analyticsManager.logEvent(.settingsUpdate, parameters: SettingsAnalytics(setting: .tableHighlighting, isOn: value))
                    }

                    Toggle(isOn: $viewModel.alertConflict) {
                        Text("Check for conflicts")
                    }
                    .onChange(of: viewModel.alertConflict) { value in
                        analyticsManager.logEvent(.settingsUpdate, parameters: SettingsAnalytics(setting: .alertConflict, isOn: value))
                    }

                    Toggle(isOn: $viewModel.alertNotMatch) {
                        Text("Check for wrong number")
                    }
                    .onChange(of: viewModel.alertNotMatch) { value in
                        analyticsManager.logEvent(.settingsUpdate, parameters: SettingsAnalytics(setting: .alertNotMatch, isOn: value))
                    }

                    Toggle(isOn: $viewModel.timer) {
                        Text("Timer")
                    }
                    .onChange(of: viewModel.timer) { value in
                        analyticsManager.logEvent(.settingsUpdate, parameters: SettingsAnalytics(setting: .timer, isOn: value))
                    }
                }

                Button("Select a play set") {
                    isSelectingPlaySet = true
                }
            }
            .navigationTitle("Settings")
            .confirmationDialog("Select a play set", isPresented: $isSelectingPlaySet, titleVisibility: .visible) {
                ForEach(PlaySet.allCases, id: \.self) { playSet in
                    Button(playSet.rawValue) {
                        storageManager.preferredPlaySet = playSet
                        storageManager.featureFlagManager = FeatureFlagManager(playSet: playSet)
                        analyticsManager.logEvent(.settingsPlaySet, parameters: PlaySetAnalytics(playSet: playSet))
                        
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
