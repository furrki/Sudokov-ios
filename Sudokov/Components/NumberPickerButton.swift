//
//  NumberPickerButton.swift
//  Sudokov
//
//  Created by furrki on 28.07.2022.
//

import SwiftUI

struct NumberPickerButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration
            .label
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(Color(R.color.selectableNumberText.name))
            .padding(5)
            .background(
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
