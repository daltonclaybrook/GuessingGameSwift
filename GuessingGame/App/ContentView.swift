//
//  ContentView.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/10/22.
//

import ComposableArchitecture
import SwiftUI

struct ContentView: View {
	let store: Store<AppState, AppAction>

    var body: some View {
		TabView {
			GameView(store: store.scope(state: \.gameViewState, action: AppAction.gameViewAction))
				.tabItem {
					Image(systemName: "gamecontroller")
					Text("Game")
				}
			WalletView(store: store.scope(state: \.walletViewState, action: AppAction.walletViewAction))
				.tabItem {
					Image(systemName: "creditcard")
					Text("Wallet")
				}
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView(store: .live)
    }
}
