//
//  WalletView.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/11/22.
//

import ComposableArchitecture
import SwiftUI

struct WalletView: View {
	let store: Store<WalletViewState, WalletViewAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			VStack(alignment: .center, spacing: 12) {
				Text("Guess Token")
					.font(.largeTitle)

				Text("\(viewStore.tokenBalanceString) GUESS")
					.font(Font.system(size: 24, weight: .light))

				Text("\(viewStore.ethBalanceString) ETH")
					.font(Font.system(size: 16, weight: .regular))
					.foregroundColor(.gray)

				Spacer().frame(maxHeight: 16)

				HStack {
					RoundedButton(title: "Send") {
						viewStore.send(.showSendSheet)
					}
					RoundedButton(title: "Receive") {
						viewStore.send(.showReceiveSheet)
					}
				}
				.padding([.leading, .trailing], 20)
			}
			.sheet(store.scope(state: \.sendViewState), dismiss: .dismissSendSheet, subAction: WalletViewAction.sendViewAction) { store in
				SendView(store: store, shouldDismiss: {
					viewStore.send(.dismissSendSheet)
				})
			}
			.sheet(isPresented: viewStore.binding(\.$isShowingReceiveSheet)) {
				ReceiveView(store: store.scope(state: \.receiveViewState, action: WalletViewAction.receiveViewAction))
			}
			.onTapGesture {
				viewStore.send(.refreshBalances)
			}
			.onAppear {
				viewStore.send(.refreshBalancesOnInterval)
			}
			.onDisappear {
				viewStore.send(.stopRefreshingBalances)
			}
		}
	}
}

struct WalletView_Previews: PreviewProvider {
	static var previews: some View {
		WalletView(
			store: Store(
				initialState: WalletViewState(
					receiveViewState: ReceiveViewState(
						address: "0xADe61Bc8c716d8244FfBb188d6dD5369C1CbE81D"
					)
				),
				reducer: walletViewReducer,
				environment: WalletViewEnvironment(
					client: TokenClient(),
					sendViewEnvironment: SendViewEnvironment(client: TokenClient()),
					receiveViewEnvironment: ReceiveViewEnvironment()
				)
			)
		)
	}
}
