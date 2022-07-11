//
//  ContentView.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/10/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
		TabView {
			GameView()
				.tabItem {
					Image(systemName: "gamecontroller")
					Text("Game")
				}
			WalletView(store: .live)
				.tabItem {
					Image(systemName: "creditcard")
					Text("Wallet")
				}
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
