//
//  NumberPickerButton.swift
//  Sudokov
//
//  Created by furrki on 28.07.2022.
//

import SwiftUI

struct NumberPickerButtonStyle: ButtonStyle {
    let isSelected: Bool

    init(isSelected: Bool = false) {
        self.isSelected = isSelected
    }

    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(isSelected ? Color(R.color.numberPickerSelectedTextColor.name) : Color(R.color.selectableNumberText.name))
            .padding(5)
            .background(
                isSelected ? Color(R.color.numberPickerSelectedBackground.name)
                    .cornerRadius(4.0) :
                Color(R.color.numberPickerButtonBackground.name)
                    .cornerRadius(4.0)
            )
    }
}

struct NumberPickerButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        Button("Press Me") {
            print("Button pressed!")
        }
        .buttonStyle(MenuButton())
    }
}
