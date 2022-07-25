//
//  Transitions.swift
//  Sudokov
//
//  Created by furrki on 26.07.2022.
//

import SwiftUI

extension AnyTransition {
    static var moveAndScale: AnyTransition {
        AnyTransition.move(edge: .bottom).combined(with: .scale)
    }
}

