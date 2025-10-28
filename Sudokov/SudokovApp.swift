//
//  SudokovApp.swift
//  Sudokov
//
//  Created by furrki on 11.06.2022.
//

import SwiftUI
import FirebaseCore
import GoogleMobileAds

@main
struct SudokovApp: App {
    init() {
        FirebaseApp.configure()
        MobileAds.shared.start(completionHandler: nil)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
