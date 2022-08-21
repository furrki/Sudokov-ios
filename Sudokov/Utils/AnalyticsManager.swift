//
//  AnalyticsManager.swift
//  Sudokov
//
//  Created by furrki on 20.08.2022.
//

import Foundation
import FirebaseAnalytics

class AnalyticsManager {
    enum Event {
        case homePlaySet
        case homeSettings
        case settingsPlaySet
        case settingsUpdate
        case gameTurnOnDraft
        case gameTurnOffDraft
        case gameRemove
        case gameRevert
        case gameAbandon
        case gameFinish
        case gameLost

        var key: String {
            switch self {
            case .homePlaySet: return "home_playSet"
            case .homeSettings: return "home_settings"
            case .settingsPlaySet: return "settings_playSet"
            case .settingsUpdate: return "settings_update"
            case .gameTurnOnDraft: return "game_turnOnDraft"
            case .gameTurnOffDraft: return "game_turnOffDraft"
            case .gameRemove: return "game_remove"
            case .gameRevert: return "game_revert"
            case .gameAbandon: return "game_abandon"
            case .gameFinish: return "game_finish"
            case .gameLost: return "game_lost"
            }
        }
    }

    func logEvent(_ event: Event, parameters: Encodable? = nil) {
        Analytics.logEvent(event.key, parameters: parameters?.dictionary ?? [:])
    }
}
