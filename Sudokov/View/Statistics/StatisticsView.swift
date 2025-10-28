//
//  StatisticsView.swift
//  Sudokov
//
//  Created by furrki on 20.10.2022.
//

import SwiftUI

struct StatisticsView: View {
    // MARK: - Properties
    private let storageManager = DependencyManager.storageManager

    var statistics: [LevelStatistics] {
        storageManager
            .levelStatistics
            .sorted {
                $0.depth < $1.depth
            }
    }

    var totalCompleted: Int {
        statistics.reduce(0) { $0 + $1.count }
    }

    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Summary Card
                    VStack(spacing: 16) {
                        VStack(spacing: 8) {
                            Text("Total Puzzles")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)

                            Text("\(totalCompleted)")
                                .font(.system(size: 56, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.98, green: 0.5, blue: 0.3),
                                            Color(red: 0.3, green: 0.6, blue: 0.98)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )

                            Text("Completed")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 32)
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color(UIColor.secondarySystemGroupedBackground))
                        )
                        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 20)

                    // Difficulty Breakdown
                    VStack(alignment: .leading, spacing: 12) {
                        Text("By Difficulty")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)

                        if statistics.isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "chart.bar.xaxis")
                                    .font(.system(size: 48))
                                    .foregroundColor(.gray.opacity(0.4))

                                Text("No statistics yet")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.gray)

                                Text("Complete puzzles to see your progress")
                                    .font(.system(size: 14, weight: .regular))
                                    .foregroundColor(.gray.opacity(0.7))
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                        } else {
                            VStack(spacing: 12) {
                                ForEach(0..<statistics.count, id: \.self) { index in
                                    DifficultyStatCard(
                                        depth: statistics[index].depth,
                                        count: statistics[index].count,
                                        difficultyName: getDifficultyDescription(depth: statistics[index].depth)
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                }
                .padding(.vertical, 24)
            }
            .background(Color(UIColor.systemGroupedBackground))
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Methods
    private func getDifficultyDescription(depth: Int) -> String {
        switch depth {
        case GameConfiguration.minimumDepth...GameConfiguration.hardDepth:
            return "Hardcore 🔥"
        case (GameConfiguration.hardDepth + 1)...GameConfiguration.mediumDepth:
            return "Hard ❤️‍🔥"
        case (GameConfiguration.mediumDepth + 1)...GameConfiguration.easyDepth:
            return "Medium 👊"
        case (GameConfiguration.easyDepth + 1)...GameConfiguration.veryEasyDepth:
            return "Easy ☀️"
        case (GameConfiguration.veryEasyDepth + 1)...GameConfiguration.maximumDepth:
            return "Basic 🌞"
        default:
            return "Simple ☀️"
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
