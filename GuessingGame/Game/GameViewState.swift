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

struct AnsweringState: Equatable {
	let prompt: String
	let asker: EthereumAddress
	let askerIsUser: Bool
	let clues: [String]
	let canSubmitClue: Bool
}

enum GameState: Equatable {
	case unknown
	case waitingForQuestion(Asker)
	case answeringQuestion(AnsweringState)
}

struct GameViewState: Equatable {
	var gameState: GameState = .unknown
	var userIsEligibleToSubmitQuestion: Bool = false
	/// Alert that is presented when non-nil
	var alert: AlertState<GameViewAction>? = nil
}

enum GameViewAction: Equatable {
	case refreshState
	case submitQuestion(prompt: String, answer: String)
	case updateGameState(GameState, userIsEligibleToSubmitQuestion: Bool)
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
			await fetchGameState(client: environment.client)
		}
		.receive(on: RunLoop.main)
		.eraseToEffect()

	case .submitQuestion(let prompt, let answer):
		return Future.async {
			await environment.client.submitQuestion(prompt: prompt, answer: answer)
			return .refreshState
		}
		.receive(on: RunLoop.main)
		.eraseToEffect()

	case .updateGameState(let gameState, let userIsEligibleToSubmitQuestion):
		state.gameState = gameState
		state.userIsEligibleToSubmitQuestion = userIsEligibleToSubmitQuestion
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

extension Asker {
	func isUserEligibleAsker(_ user: EthereumAddress) -> Bool {
		switch self {
		case .specific(let address):
			return user == address
		case .anyone:
			return true
		}
	}
}

// MARK: - Free helper functions

private func fetchGameState(client: GameClient) async -> GameViewAction {
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
		return .updateGameState(
			.answeringQuestion(
				AnsweringState(
					prompt: prompt,
					asker: currentAsker,
					askerIsUser: currentAsker == client.userAddress,
					clues: await clues,
					canSubmitClue: canSubmitClue
				)
			),
			userIsEligibleToSubmitQuestion: false
		)
	} else {
		let asker: Asker = nextAskerTimeout >= Date() ? .specific(nextAsker) : .anyone
		let isUserEligible = asker.isUserEligibleAsker(client.userAddress)
		return .updateGameState(
			.waitingForQuestion(asker),
			userIsEligibleToSubmitQuestion: isUserEligible
		)
	}
}

private func fetchAllClues(client: GameClient) async -> [String] {
	async let clue1 = client.getClue(index: 0)
	async let clue2 = client.getClue(index: 1)
	async let clue3 = client.getClue(index: 2)
	return await [clue1, clue2, clue3]
		.compactMap { $0 }
		.filter { !$0.isEmpty }
}
