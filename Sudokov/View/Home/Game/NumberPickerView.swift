//
//  NumberPickerView.swift
//  Sudokov
//
//  Created by furrki on 15.07.2022.
//

import SwiftUI

struct NumberPickerView: View {
    @EnvironmentObject var gameManager: GameManager
    let configuration: GameConfiguration

    var body: some View {
        HStack {
            ForEach(1...9, id: \.self) { number in
                Button(action: {
                    self.gameManager.setValue(number)
                }, label : {
                    Text("\(number)")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color(R.color.selectableNumberText.name))
                        .frame(maxWidth: .infinity, minHeight: 30)
                        .padding(5)
                        .background(
                            Color(R.color.numberPickerButtonBackground.name)
                                .cornerRadius(4.0)
                        )
                        .opacity(shouldHide(number: number) ? 0 : 1)
                        .disabled(shouldHide(number: number))
                })
                .disabled(shouldHide(number: number))
            }
        }
    }

    func shouldHide(number: Int) -> Bool {
        guard configuration.featureFlags.hideNotNeededNumberButtons else {
            return false
        }

        return !gameManager.options.contains(number)
    }
}
