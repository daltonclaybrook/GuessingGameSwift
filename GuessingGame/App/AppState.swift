//
//  AppState.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/11/22.
//

import ComposableArchitecture

struct AppState: Equatable {
	var gameViewState: GameViewState
	var walletViewState: WalletViewState
}

enum AppAction {
	case gameViewAction(GameViewAction)
	case walletViewAction(WalletViewAction)
}

struct AppEnvironment {
	let gameViewEnvironment: GameViewEnvironment
	let walletViewEnvironment: WalletViewEnvironment
}

let appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer.combine(
	walletViewReducer.pullback(
		state: \.walletViewState,
		action: /AppAction.walletViewAction,
		environment: \.walletViewEnvironment
	),
	gameViewReducer.pullback(
		state: \.gameViewState,
		action: /AppAction.gameViewAction,
		environment: \.gameViewEnvironment
	)
)

// MARK: - Store convenience

extension Store where State == AppState, Action == AppAction {
	static var live: Store<AppState, AppAction> {
		let account = try! WalletUtility().loadWalletAccount()
		let tokenClient = TokenClient()
		return Store(
			initialState: AppState(
				gameViewState: GameViewState(),
				walletViewState: WalletViewState(
					receiveViewState: ReceiveViewState(
						address: account.address.value
					)
				)
			),
			reducer: appReducer,
			environment: AppEnvironment(
				gameViewEnvironment: GameViewEnvironment(),
				walletViewEnvironment: WalletViewEnvironment(
					client: tokenClient,
					sendViewEnvironment: SendViewEnvironment(
						client: tokenClient
					),
					receiveViewEnvironment: ReceiveViewEnvironment()
				)
			)
		)
	}
}
