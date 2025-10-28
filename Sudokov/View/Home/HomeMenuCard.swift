//
//  HomeMenuCard.swift
//  Sudokov
//

import SwiftUI

struct HomeMenuCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let action: () -> Void
    let gradient: LinearGradient

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 64, height: 64)
                    .background(
                        Circle()
                            .fill(Color.white.opacity(0.2))
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)

                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.white.opacity(0.9))
                        .lineLimit(1)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .padding(.horizontal, 20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(gradient)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct HomeMenuCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            HomeMenuCard(
                icon: "gamecontroller.fill",
                title: "Start Game",
                subtitle: "Pick a level and play",
                action: {},
                gradient: LinearGradient(
                    colors: [Color(red: 0.98, green: 0.5, blue: 0.3), Color(red: 0.95, green: 0.3, blue: 0.4)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            HomeMenuCard(
                icon: "sparkles",
                title: "Generate Level",
                subtitle: "Create a random puzzle",
                action: {},
                gradient: LinearGradient(
                    colors: [Color(red: 0.3, green: 0.6, blue: 0.98), Color(red: 0.2, green: 0.4, blue: 0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
        .padding()
    }
}
