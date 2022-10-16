//
//  ContentView.swift
//  Sudokov
//
//  Created by furrki on 11.06.2022.
//

import SwiftUI
import FirebaseCore
import GoogleMobileAds

struct ContentView: View {
    var body: some View {
        HomeView()
            .onAppear {
                FirebaseApp.configure()
                GADMobileAds.sharedInstance().start(completionHandler: nil)
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
