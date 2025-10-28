//
//  DifficultyPickerView.swift
//  Sudokov
//

import SwiftUI

struct DifficultyPickerView: View {
    @State private var selectedDifficulty: Difficulty?
    private let storageManager = DependencyManager.storageManager
    let onDifficultySelected: (Difficulty) -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    Button {
                        onDismiss()
                    } label: {
                        Image(systemName: "arrow.uturn.backward.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(Color(R.color.button.name))
                    }

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 20)

                VStack(spacing: 4) {
                    Text("Select Difficulty")
                        .font(.system(size: 22, weight: .bold))

                    Text("Choose your challenge level")
                        .font(.system(size: 13, weight: .regular))
                        .foregroundColor(.gray)
                }
            }
            .padding(.bottom, 12)

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
                    storageManager.preferredDifficulty = selected
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
            selectedDifficulty = storageManager.preferredDifficulty ?? Difficulty.preparedLevels.first
        }
    }
}

struct DifficultyPickerView_Previews: PreviewProvider {
    static var previews: some View {
        DifficultyPickerView(onDifficultySelected: { _ in }, onDismiss: {})
    }
}
