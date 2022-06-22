//
//  HomeView.swift
//  Sudokov
//
//  Created by furrki on 11.06.2022.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Button("Start Game") {
                
            }
            .buttonStyle(MenuButton())
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
