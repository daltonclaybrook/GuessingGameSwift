//
//  GameViewState.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/11/22.
//

import Combine
import ComposableArchitecture
import web3

enum Asker: Equatable {
	case specific(EthereumAddress)
	case anyone
}

enum GameState: Equatable {
	case unknown
	case waitingForQuestion(asker: Asker)
	case answeringQuestion(
		prompt: String,
		asker: EthereumAddress,
		clues: [String],
		canSubmitClue: Bool
	)
}

struct GameViewState: Equatable {
	var gameState: GameState = .unknown
	/// Alert that is presented when non-nil
	var alert: AlertState<GameViewAction>? = nil
}

enum GameViewAction: Equatable {
	case refreshState
	case updateGameState(GameState)
	case errorRefreshingState
	case dismissAlert
}

struct GameViewEnvironment {
	let client: GameClient
}

let gameViewReducer = Reducer<GameViewState, GameViewAction, GameViewEnvironment> {
	state, action, environment -> Effect in
	switch action {
	case .refreshState:
		return Future.async {
			let client = environment.client
			async let isCurrentQuestionActive = client.isCurrentQuestionActive() //
			async let currentAsker = client.currentQuestionAsker() //
			async let canSubmitClue = client.canSubmitNewClue() //
			async let nextAsker = client.nextAsker //
			async let nextAskerTimeout = client.nextAskerTimeoutDate //
			async let prompt = client.currentQuestionPrompt() //
			async let clues = fetchAllClues(client: client)

			guard
				let isCurrentQuestionActive = await isCurrentQuestionActive,
				let currentAsker = await currentAsker,
				let canSubmitClue = await canSubmitClue,
				let nextAsker = await nextAsker,
				let nextAskerTimeout = await nextAskerTimeout,
				let prompt = await prompt
			else { return .errorRefreshingState }

			if isCurrentQuestionActive {
				return .updateGameState(.answeringQuestion(
					prompt: prompt,
					asker: currentAsker,
					clues: await clues,
					canSubmitClue: canSubmitClue
				))
			} else {
				let asker: Asker = nextAskerTimeout >= Date() ? .specific(nextAsker) : .anyone
				return .updateGameState(.waitingForQuestion(asker: asker))
			}
		}.eraseToEffect()

	case .updateGameState(let gameState):
		state.gameState = gameState
		return .none

	case .errorRefreshingState:
		state.alert = .errorRefreshing
		return .none

	case .dismissAlert:
		state.alert = nil
		return .none
	}
}

extension AlertState where Action == GameViewAction {
	static var errorRefreshing: AlertState<GameViewAction> {
		AlertState(
			title: TextState("Error"),
			message: TextState("Failed to refresh game state"),
			dismissButton: .cancel(TextState("OK"), action: .send(.dismissAlert))
		)
	}
}

// MARK: - Free helper functions

private func fetchAllClues(client: GameClient) async -> [String] {
	async let clue1 = client.getClue(index: 0)
	async let clue2 = client.getClue(index: 1)
	async let clue3 = client.getClue(index: 2)
	return await [clue1, clue2, clue3].compactMap { $0 }
}
