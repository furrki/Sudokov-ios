//
//  ControlsView.swift
//  Sudokov
//
//  Created by furrki on 16.07.2022.
//

import SwiftUI

struct ControlsView: View {
    @EnvironmentObject var gameManager: GameManager
    let configuration: GameConfiguration

    var body: some View {
        HStack {
            Button {
                gameManager.removeValue()
            } label: {
                Image(systemName: "trash")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .frame(maxWidth: .infinity)
            }
            
            if configuration.featureFlags.backButton {
                Button {
                    gameManager.revertMove()
                } label: {
                    Image(systemName: "arrowshape.turn.up.backward")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .frame(maxWidth: .infinity)
                }
            }

            Button {
                gameManager.switchFillContentMode()
            } label: {
                Image(systemName: gameManager.fillContentMode == .text ? "pencil.circle" : "pencil.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .frame(maxWidth: .infinity)
            }
        }
    }
}