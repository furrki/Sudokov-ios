//
//  MenuButton.swift
//  Sudokov
//
//  Created by furrki on 11.06.2022.
//

import SwiftUI

struct MenuButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.all, 20)
            .background(.yellow)
            .foregroundColor(.black)
            .clipShape(Capsule())
    }
}

struct MenuButton_Previews: PreviewProvider {
    static var previews: some View {
        Button("Press Me") {
            print("Button pressed!")
        }
        .buttonStyle(MenuButton())
    }
}

