//
//  PlaySetPickerView.swift
//  Sudokov
//

import SwiftUI

struct PlaySetPickerView: View {
    @State private var selectedPlaySet: PlaySet?
    private let storageManager = DependencyManager.storageManager
    let onPlaySetSelected: (PlaySet) -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                VStack(spacing: 4) {
                    Text("Welcome to Sudokov!")
                        .font(.system(size: 28, weight: .bold))

                    Text("Choose your play style")
                        .font(.system(size: 15, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 40)
            .padding(.bottom, 20)

            Divider()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(PlaySet.allCases, id: \.self) { playSet in
                        PlaySetCard(
                            playSet: playSet,
                            isSelected: selectedPlaySet == playSet
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedPlaySet = playSet
                            }
                        }
                    }
                }
                .padding(24)
            }

            Divider()

            Button("Continue") {
                if let selected = selectedPlaySet {
                    onPlaySetSelected(selected)
                }
            }
            .buttonStyle(MenuButton())
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .disabled(selectedPlaySet == nil)
            .opacity(selectedPlaySet == nil ? 0.5 : 1)
        }
        .onAppear {
            selectedPlaySet = PlaySet.allCases.first
        }
        .interactiveDismissDisabled()
    }
}

struct PlaySetPickerView_Previews: PreviewProvider {
    static var previews: some View {
        PlaySetPickerView { _ in }
    }
}
