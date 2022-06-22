//
//  View+Border.swift
//  Sudokov
//
//  Created by furrki on 16.06.2022.
//

import SwiftUI

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}
