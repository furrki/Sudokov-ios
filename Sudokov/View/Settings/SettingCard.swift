//
//  SettingCard.swift
//  Sudokov
//

import SwiftUI

struct SettingCard: View {
    let icon: String
    let title: String
    let description: String
    let iconColor: Color
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(iconColor)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)

                Text(description)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
    }
}

struct SettingCard_Previews: PreviewProvider {
    static var previews: some View {
        SettingCard(
            icon: "eye.slash.fill",
            title: "Hide found numbers",
            description: "Auto-hide number buttons when all 9 are placed",
            iconColor: .blue,
            isOn: .constant(true)
        )
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
}
