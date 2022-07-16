//
//  GameSquareViewModel.swift
//  Sudokov
//
//  Created by furrki on 14.07.2022.
//

import SwiftUI

struct GameSquareViewModel {
    // MARK: - Constants & Enums
    private enum Constants {
        static let borderWidth: CGFloat = 2
    }

    enum SelectionType {
        case none
        case primary
        case secondary
        case selection
    }

    enum ContentType {
        case userAddedValue
        case levelGeneratedValue
        case draft
    }

    // MARK: - Properties
    let selectionType: SelectionType
    let squareText: String
    let row: Int
    let col: Int
    let content: Int
    let drafts: [Int]
    let squareSize: Int
    let boldNumber: Int?

    let leadingBorderWidth: CGFloat
    let topBorderWidth: CGFloat
    let trailingBorderWidth: CGFloat
    let bottomBorderWidth: CGFloat

    let leadingBorderColor: Color
    let topBorderColor: Color
    let trailingBorderColor: Color
    let bottomBorderColor: Color

    let foregroundColor: Color

    var backgroundColor: Color {
        switch selectionType {
        case .none:
            return Color(R.color.noneSquareBackground.name)
        case .primary:
            return Color(R.color.primarySquareBackground.name)
        case .secondary:
            return Color(R.color.secondarySquareBackground.name)
        case .selection:
            return Color(R.color.selectedSquareBackground.name)
        }
    }

    let contentType: ContentType

    // MARK: - Initializer
    init(selectionType: SelectionType,
         contentType: ContentType,
         content: Int,
         drafts: [Int],
         row: Int,
         col: Int,
         squareSize: Int,
         boldNumber: Int? = nil) {
        self.selectionType = selectionType
        self.contentType = contentType

        self.squareText = (1...9).contains(content) ? "\(content)" : ""
        self.content = content
        self.row = row
        self.col = col
        self.squareSize = squareSize
        self.boldNumber = boldNumber
        self.leadingBorderWidth = col % 3 == 0 ? Constants.borderWidth : 0
        self.topBorderWidth = row % 3 == 0 ? Constants.borderWidth : 0
        self.trailingBorderWidth = col == squareSize - 1 ? Constants.borderWidth : 0
        self.bottomBorderWidth = row == squareSize - 1 ? Constants.borderWidth : 0
        self.leadingBorderColor = col % 3 == 0 ? Color(R.color.greatBorder.name) : Color(R.color.subBorder.name)
        self.topBorderColor = row % 3 == 0 ? Color(R.color.greatBorder.name) : Color(R.color.subBorder.name)
        self.trailingBorderColor = col == squareSize - 1 ? Color(R.color.greatBorder.name) : Color(R.color.subBorder.name)
        self.bottomBorderColor = row == squareSize - 1 ? Color(R.color.greatBorder.name) : Color(R.color.subBorder.name)
        self.drafts = drafts

        switch contentType {
        case .userAddedValue:
            foregroundColor = Color(R.color.userSquareText.name)
        case .levelGeneratedValue, .draft:
            foregroundColor = Color(R.color.levelSquareText.name)
        }
    }
}
