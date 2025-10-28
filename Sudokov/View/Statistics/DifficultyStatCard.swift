//
//  DifficultyStatCard.swift
//  Sudokov
//

import SwiftUI

struct DifficultyStatCard: View {
    let depth: Int
    let count: Int
    let difficultyName: String

    private var gradient: LinearGradient {
        let difficulty = Difficulty.getDifficulty(depth: depth)
        switch difficulty {
        case .easy, .basic:
            return LinearGradient(
                colors: [Color(red: 0.4, green: 0.85, blue: 0.6), Color(red: 0.3, green: 0.75, blue: 0.5)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .medium:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.7, blue: 0.3), Color(red: 0.9, green: 0.6, blue: 0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .hard:
            return LinearGradient(
                colors: [Color(red: 0.95, green: 0.4, blue: 0.4), Color(red: 0.85, green: 0.3, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .hardcore:
            return LinearGradient(
                colors: [Color(red: 0.5, green: 0.2, blue: 0.5), Color(red: 0.4, green: 0.1, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var accentColor: Color {
        let difficulty = Difficulty.getDifficulty(depth: depth)
        switch difficulty {
        case .easy, .basic:
            return Color(red: 0.4, green: 0.85, blue: 0.6)
        case .medium:
            return Color(red: 0.95, green: 0.7, blue: 0.3)
        case .hard:
            return Color(red: 0.95, green: 0.4, blue: 0.4)
        case .hardcore:
            return Color(red: 0.5, green: 0.2, blue: 0.5)
        }
    }

    private var icon: String {
        let difficulty = Difficulty.getDifficulty(depth: depth)
        switch difficulty {
        case .easy, .basic:
            return "sun.max.fill"
        case .medium:
            return "flame.fill"
        case .hard:
            return "bolt.fill"
        case .hardcore:
            return "exclamationmark.triangle.fill"
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header with gradient
            ZStack {
                Rectangle()
                    .fill(gradient)
                    .frame(height: 80)

                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(difficultyName)
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)

                        Text("\(depth) cells")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.9))
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
            }

            // Stats section
            VStack(spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Completed")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.gray)

                        Text("\(count)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(accentColor)
                        .opacity(0.3)
                }
            }
            .padding(16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
        }
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

struct DifficultyStatCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            DifficultyStatCard(depth: 30, count: 15, difficultyName: "Easy ☀️")
            DifficultyStatCard(depth: 45, count: 8, difficultyName: "Medium 👊")
            DifficultyStatCard(depth: 55, count: 3, difficultyName: "Hard ❤️‍🔥")
        }
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
}
