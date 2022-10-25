//
//  BackButton.swift
//  Sudokov
//
//  Created by furrki on 17.10.2022.
//

import SwiftUI

struct BackButton: View {
    let onTapBack: (() -> Void)

    var body: some View {
        HStack {
            Button {
                onTapBack()
            } label: {
                Image(systemName: "arrow.uturn.backward.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .foregroundColor(Color(R.color.button.name))
            }

            Spacer()
        }
        .padding(.horizontal, 30)
        .padding(.top, 10)
    }
}
