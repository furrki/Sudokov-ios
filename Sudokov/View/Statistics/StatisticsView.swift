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
        storageManager.levelStatistics
    }

    // MARK: - Body
    var body: some View {

        List {
            Section {
                ForEach(0..<statistics.count, id: \.self) { index in
                    row(firstCol: "\(statistics[index].depth)", secondCol: "\(statistics[index].count)")
                }
            } header: {
                row(firstCol: "Depth", secondCol: "Count")
            }
        }
    }

    private func row(firstCol: String, secondCol: String) -> some View {
        HStack {
            Text(firstCol)
            Spacer()
            Text(secondCol)
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsView()
    }
}
