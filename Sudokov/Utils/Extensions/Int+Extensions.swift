//
//  Int+Extensions.swift
//  Sudokov
//
//  Created by furrki on 3.08.2022.
//

import Foundation

extension Int {
    func getFormattedCounter() -> String {
        let minutes = self / 60 % 60
        let seconds = self % 60
        return String(format: "%02i:%02i", minutes, seconds)
    }
}
