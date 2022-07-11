//
//  SendView.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/11/22.
//

import ComposableArchitecture
import SwiftUI

struct SendView: View {
	let store: Store<SendViewState, SendViewAction>
	let shouldDismiss: () -> Void

	@FocusState private var isToFieldFocused: Bool
	@FocusState private var isAmountFieldFocused: Bool

	var body: some View {
		WithViewStore(store) { viewStore in
			VStack {
				Text("Send GUESS")
					.font(.largeTitle)

				HStack(spacing: 12) {
					TextField("To: (e.g. 0x1a2b....)", text: viewStore.binding(\.$toAddress))
						.focused($isToFieldFocused)
						.padding()
						.background(
							RoundedRectangle(cornerRadius: 4)
								.strokeBorder(.black, lineWidth: 1)
						)

					Button {
						viewStore.send(.presentQRCamera)
					} label: {
						Image(systemName: "qrcode.viewfinder")
							.resizable()
							.frame(width: 50, height: 50)
					}
				}

				TextField("Amount: (e.g. 10)", text: viewStore.binding(\.$amountString))
					.focused($isAmountFieldFocused)
					.keyboardType(.decimalPad)
					.padding()
					.background(
						RoundedRectangle(cornerRadius: 4)
							.strokeBorder(.black, lineWidth: 1)
					)

				Spacer().frame(height: 20)

				RoundedButton(title: "Send") {
					viewStore.send(.showSendTokenConfirmation)
				}
			}
			.padding()
			.fullScreenCover(isPresented: viewStore.binding(\.$isPresentingQRCamera)) {
				QRCameraView(didFinish: { qrCode in
					viewStore.send(.finishPresentingQRCamera(qrCode: qrCode))
				}).ignoresSafeArea()
			}
			.alert(store.scope(state: \.alert), dismiss: .dismissAlert)
			.sheet(
				store.scope(state: \.confirmation),
				dismiss: .dismissConfirmationView,
				subAction: SendViewAction.confirmation,
				onDismiss: shouldDismiss
			) { store in
				ConfirmationView(store: store, shouldDismiss: {
					viewStore.send(.dismissConfirmationView)
				})
			}
			.onTapGesture {
				isToFieldFocused = false
				isAmountFieldFocused = false
			}
			.onChange(of: viewStore.alert) { alert in
				// Stop editing fields if alert is shown
				guard alert != nil else { return }
				isToFieldFocused = false
				isAmountFieldFocused = false
			}
		}
	}
}

struct SendView_Previews: PreviewProvider {
	static var previews: some View {
		SendView(store: .preview, shouldDismiss: {})
	}
}
