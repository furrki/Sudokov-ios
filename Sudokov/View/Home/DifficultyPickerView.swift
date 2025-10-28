//
//  DifficultyPickerView.swift
//  Sudokov
//

import SwiftUI

struct DifficultyPickerView: View {
    @State private var selectedDifficulty: Difficulty?
    let onDifficultySelected: (Difficulty) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.gray.opacity(0.3))
                    }

                    Spacer()
                }

                VStack(spacing: 4) {
                    Text("Select Difficulty")
                        .font(.system(size: 22, weight: .bold))

                    Text("Choose your challenge level")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 20)

            Divider()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    ForEach(Difficulty.preparedLevels, id: \.self) { difficulty in
                        DifficultyCard(
                            difficulty: difficulty,
                            isSelected: selectedDifficulty == difficulty
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedDifficulty = difficulty
                            }
                        }
                    }
                }
                .padding(24)
            }

            Divider()

            Button("Continue") {
                if let selected = selectedDifficulty {
                    onDifficultySelected(selected)
                }
            }
            .buttonStyle(MenuButton())
            .font(.system(size: 16, weight: .bold))
            .padding(.horizontal, 24)
            .padding(.vertical, 20)
            .disabled(selectedDifficulty == nil)
            .opacity(selectedDifficulty == nil ? 0.5 : 1)
        }
        .onAppear {
            selectedDifficulty = Difficulty.preparedLevels.first
        }
    }
}

struct DifficultyPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DifficultyPickerView(onDifficultySelected: { _ in }, onDismiss: {})
    }
}
