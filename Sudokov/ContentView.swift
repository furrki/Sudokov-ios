//
//  ContentView.swift
//  Sudokov
//
//  Created by furrki on 11.06.2022.
//

import SwiftUI
import FirebaseCore

struct ContentView: View {
    var body: some View {
        HomeView()
            .onAppear {
                FirebaseApp.configure()
            }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
