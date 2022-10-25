//
//  LinearGradientSlider.swift
//  Sudokov
//
//  Created by furrki on 16.10.2022.
//
// https://stackoverflow.com/questions/61509167/how-to-apply-gradient-to-an-accentcolor-of-any-view-swiftui

import SwiftUI

struct LinearGradientSlider: View {
    @Binding var value: Double
    var colors: [Color] = [.red, .green, .green]
    var range: ClosedRange<Double>
    var step: Double

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: colors),
                startPoint: .leading,
                endPoint: .trailing
            )
            .mask(Slider(value: $value, in: range, step: step))

            // Dummy replicated slider, to allow sliding
            Slider(value: $value, in: range, step: step)
                .accentColor(.clear)
        }
    }
}
