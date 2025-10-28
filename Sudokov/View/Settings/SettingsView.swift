//
//  SettingsView.swift
//  Sudokov
//
//  Created by furrki on 4.08.2022.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject private var viewModel: SettingsViewModel = SettingsViewModel(featureFlagManager: DependencyManager.storageManager.featureFlagManager)
    private let storageManager = DependencyManager.storageManager
    private let analyticsManager = DependencyManager.analyticsManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Play Mode Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Play Mode")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 12) {
                            ForEach(PlaySet.allCases, id: \.self) { playSet in
                                PlaySetCard(
                                    playSet: playSet,
                                    isSelected: storageManager.preferredPlaySet == playSet
                                ) {
                                    withAnimation {
                                        storageManager.preferredPlaySet = playSet
                                        storageManager.featureFlagManager = FeatureFlagManager(playSet: playSet)
                                        analyticsManager.logEvent(.settingsPlaySet, parameters: PlaySetAnalytics(playSet: playSet))
                                        viewModel.load(featureFlagManager: storageManager.featureFlagManager)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Interface Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Interface")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 10) {
                            SettingCard(
                                icon: "eye.slash.fill",
                                title: "Hide Found Numbers",
                                description: "Auto-hide buttons when all 9 are placed",
                                iconColor: Color(red: 0.3, green: 0.6, blue: 0.98),
                                isOn: $viewModel.hideNotNeededNumberButtons
                            )
                            .onChange(of: viewModel.hideNotNeededNumberButtons) { value in
                                analyticsManager.logEvent(.settingsUpdate, parameters: SettingsAnalytics(setting: .hideNotNeededNumberButtons, isOn: value))
                            }

                            SettingCard(
                                icon: "arrow.uturn.backward.circle.fill",
                                title: "Undo Button",
                                description: "Show undo button to revert moves",
                                iconColor: Color(red: 0.95, green: 0.7, blue: 0.3),
                                isOn: $viewModel.revertButton
                            )
                            .onChange(of: viewModel.revertButton) { value in
                                analyticsManager.logEvent(.settingsUpdate, parameters: SettingsAnalytics(setting: .revertButton, isOn: value))
                            }

                            SettingCard(
                                icon: "highlighter",
                                title: "Grid Highlighting",
                                description: "Highlight selected row, column, and box",
                                iconColor: Color(red: 0.4, green: 0.85, blue: 0.6),
                                isOn: $viewModel.tableHighlighting
                            )
                            .onChange(of: viewModel.tableHighlighting) { value in
                                analyticsManager.logEvent(.settingsUpdate, parameters: SettingsAnalytics(setting: .tableHighlighting, isOn: value))
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Assistance Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Assistance")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 10) {
                            SettingCard(
                                icon: "exclamationmark.triangle.fill",
                                title: "Conflict Detection",
                                description: "Alert when numbers conflict in row/column/box",
                                iconColor: Color(red: 0.95, green: 0.4, blue: 0.4),
                                isOn: $viewModel.alertConflict
                            )
                            .onChange(of: viewModel.alertConflict) { value in
                                analyticsManager.logEvent(.settingsUpdate, parameters: SettingsAnalytics(setting: .alertConflict, isOn: value))
                            }

                            SettingCard(
                                icon: "xmark.circle.fill",
                                title: "Wrong Number Alert",
                                description: "Notify when placing incorrect number",
                                iconColor: Color(red: 0.98, green: 0.5, blue: 0.3),
                                isOn: $viewModel.alertNotMatch
                            )
                            .onChange(of: viewModel.alertNotMatch) { value in
                                analyticsManager.logEvent(.settingsUpdate, parameters: SettingsAnalytics(setting: .alertNotMatch, isOn: value))
                            }
                        }
                        .padding(.horizontal, 20)
                    }

                    // Game Features Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Game Features")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)

                        VStack(spacing: 10) {
                            SettingCard(
                                icon: "timer",
                                title: "Timer",
                                description: "Track time spent on each puzzle",
                                iconColor: Color(red: 0.5, green: 0.3, blue: 0.95),
                                isOn: $viewModel.timer
                            )
                            .onChange(of: viewModel.timer) { value in
                                analyticsManager.logEvent(.settingsUpdate, parameters: SettingsAnalytics(setting: .timer, isOn: value))
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
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
