//
//  SettingsAnalytics.swift
//  Sudokov
//
//  Created by furrki on 21.08.2022.
//

import Foundation

struct SettingsAnalytics: Codable {
    enum Setting: String, Codable {
        case hideNotNeededNumberButtons
        case revertButton
        case tableHighlighting
        case alertConflict
        case alertNotMatch
        case lives
        case timer
    }
    
    let setting: Setting
    let isOn: Bool
}
