//
//  GameView.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/11/22.
//

import ComposableArchitecture
import SwiftUI

struct GameView: View {
	let store: Store<GameViewState, GameViewAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			Text("Loading")
				.onAppear {
					viewStore.send(.refreshState)
				}
		}
	}
}

struct GameView_Previews: PreviewProvider {
	static var previews: some View {
		GameView(
			store: Store(
				initialState: GameViewState(),
				reducer: gameViewReducer,
				environment: GameViewEnvironment(
					client: GameClient()
				)
			)
		)
	}
}
