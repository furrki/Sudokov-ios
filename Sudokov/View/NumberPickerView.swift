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
        VStack(spacing: 20) {
            ForEach(1...3, id: \.self) { row in
                HStack(spacing: 30) {
                    ForEach(1...3, id: \.self) { col in
                        Button(action: {
                            self.gameManager.setValue(getNumber(row: row, col: col))
                        }, label : {
                            Text("\(getNumber(row: row, col: col))")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(Color(R.color.selectableNumberText.name))
                                .frame(width: 40, height: 40)
                                .padding(10)
                                .background(
                                    Color(R.color.numberPickerButtonBackground.name)
                                        .cornerRadius(4.0)
                                )
                                .opacity(shouldHide(number: getNumber(row: row, col: col)) ? 0 : 1)
                        })
                    }
                }
            }
        }
    }

    func shouldHide(number: Int) -> Bool {
        guard configuration.featureFlags.hideNotNeededNumberButtons else {
            return false
        }

        if gameManager.options.contains(number) {
            return false
        }

        return true
    }

    func getNumber(row: Int, col: Int) -> Int {
        (row - 1) * 3 + col
    }
}
