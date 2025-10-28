//
//  PlaySetCard.swift
//  Sudokov
//

import SwiftUI

struct PlaySetCard: View {
    let playSet: PlaySet
    let isSelected: Bool
    let action: () -> Void

    private var gradient: LinearGradient {
        switch playSet {
        case .arcade:
            return LinearGradient(
                colors: [Color(red: 0.98, green: 0.5, blue: 0.3), Color(red: 0.95, green: 0.3, blue: 0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .oldSchool:
            return LinearGradient(
                colors: [Color(red: 0.4, green: 0.5, blue: 0.4), Color(red: 0.3, green: 0.4, blue: 0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private var icon: String {
        switch playSet {
        case .arcade:
            return "gamecontroller.fill"
        case .oldSchool:
            return "book.fill"
        }
    }

    private var description: String {
        switch playSet {
        case .arcade:
            return "Lives, timer, and hints for a challenge"
        case .oldSchool:
            return "Pure Sudoku experience, no distractions"
        }
    }

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.25))
                            .frame(width: 48, height: 48)

                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                    }

                    Spacer()

                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 2)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(playSet.rawValue)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text(description)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(2)
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(gradient)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.white : Color.clear, lineWidth: 3)
            )
            .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PlaySetCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            PlaySetCard(playSet: .arcade, isSelected: true, action: {})
            PlaySetCard(playSet: .oldSchool, isSelected: false, action: {})
        }
        .padding()
    }
}
