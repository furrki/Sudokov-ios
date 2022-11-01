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

    // MARK: - Body
    var body: some View {
        List {
            Section {
                ForEach(0..<statistics.count, id: \.self) { index in
                    row(firstCol: "\(statistics[index].depth) - \(getDifficultyDescription(depth: statistics[index].depth))", secondCol: "\(statistics[index].count)")
                }
            } header: {
                row(firstCol: "Depth", secondCol: "Count")
            }
        }
    }

    // MARK: - Methods
    private func row(firstCol: String, secondCol: String) -> some View {
        HStack {
            Text(firstCol)
            Spacer()
            Text(secondCol)
        }
    }

    private func getDifficultyDescription(depth: Int) -> String {
        switch depth {
        case GameConfiguration.minimumDepth...GameConfiguration.hardDepth:
            return "Hardcore 🔥"
        case (GameConfiguration.hardDepth + 1)...GameConfiguration.mediumDepth:
            return "Hard ❤️‍🔥"
        case (GameConfiguration.mediumDepth + 1)...GameConfiguration.easyDepth:
            return "Medium 👊"
        case (GameConfiguration.easyDepth + 1)...GameConfiguration.veryEasyDepth:
            return "Easy 🌞"
        case (GameConfiguration.veryEasyDepth + 1)...GameConfiguration.maximumDepth:
            return "Basic ☀️"
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
