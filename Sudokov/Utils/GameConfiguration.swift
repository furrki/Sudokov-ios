//
//  Configuration.swift
//  Sudokov
//
//  Created by furrki on 17.07.2022.
//

import Foundation

class GameConfiguration {
    static let shared: GameConfiguration = GameConfiguration()
    
    var featureFlags: FeatureFlagManager = FeatureFlagManager(hideNotNeededNumberButtons: true,
                                                              revertButton: true,
                                                              tableHighlighting: true,
                                                              alertConflict: true,
                                                              alertNotMatch: true)
}
