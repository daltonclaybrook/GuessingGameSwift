//
//  GameViewState.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/11/22.
//

import ComposableArchitecture

struct GameViewState: Equatable {
}

enum GameViewAction {
}

struct GameViewEnvironment {
}

let gameViewReducer = Reducer<GameViewState, GameViewAction, GameViewEnvironment> {
	state, action, environment -> Effect in
}
