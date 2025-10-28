//
//  DifficultyCard.swift
//  Sudokov
//

import SwiftUI

struct DifficultyCard: View {
    let difficulty: Difficulty
    let isSelected: Bool
    let action: () -> Void

    private var description: String {
        switch difficulty {
        case .easy:
            return "Perfect for beginners"
        case .medium:
            return "For puzzle enthusiasts"
        case .hard:
            return "Master challenge"
        case .basic:
            return "Learning experience"
        case .hardcore:
            return "Extreme difficulty"
        }
    }

    private var gradient: LinearGradient {
        switch difficulty {
        case .easy:
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
        case .basic:
            return LinearGradient(
                colors: [Color(red: 0.6, green: 0.8, blue: 0.95), Color(red: 0.5, green: 0.7, blue: 0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var iconName: String {
        switch difficulty {
        case .easy:
            return "sun.max.fill"
        case .medium:
            return "flame.fill"
        case .hard:
            return "bolt.fill"
        case .hardcore:
            return "exclamationmark.triangle.fill"
        case .basic:
            return "star.fill"
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.25))
                        .frame(width: 56, height: 56)

                    Image(systemName: iconName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.name)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.2), radius: 2)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(gradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DifficultyCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            DifficultyCard(difficulty: .easy, isSelected: false) {}
            DifficultyCard(difficulty: .medium, isSelected: true) {}
            DifficultyCard(difficulty: .hard, isSelected: false) {}
        }
        .padding()
    }
}
