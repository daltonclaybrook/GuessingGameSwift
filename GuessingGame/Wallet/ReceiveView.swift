//
//  ReceiveView.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/11/22.
//

import ComposableArchitecture
import SwiftUI

struct ReceiveViewState: Equatable {
	var address: String
	@BindableState var isShowingCopyAlert: Bool = false
}

enum ReceiveViewAction: BindableAction {
	case copyPublicKeyAndShowAlert
	case binding(BindingAction<ReceiveViewState>)
}

struct ReceiveViewEnvironment {}

let receiveViewReducer = Reducer<ReceiveViewState, ReceiveViewAction, ReceiveViewEnvironment> {
	state, action, environment -> Effect in
	switch action {
	case .copyPublicKeyAndShowAlert:
		UIPasteboard.general.string = state.address
		state.isShowingCopyAlert = true
		return .none

	case .binding:
		return .none
	}
}

struct ReceiveView: View {
	let store: Store<ReceiveViewState, ReceiveViewAction>

	var body: some View {
		WithViewStore(store) { viewStore in
			VStack(spacing: 20) {
				qrCodeImage(contents: viewStore.address)
					.interpolation(.none)
					.resizable()
					.scaledToFit()
					.frame(width: 200, height: 200)

				Text(viewStore.address.addressSpaced)
					.font(.body)
					.multilineTextAlignment(.center)
			}
			.padding()
			.onTapGesture {
				viewStore.send(.copyPublicKeyAndShowAlert)
			}
			.alert("Copied Address", isPresented: viewStore.binding(\.$isShowingCopyAlert)) {
				Button("OK", role: .cancel) {}
			}
			.onAppear {
				print("loaded wallet: \(viewStore.address)")
			}
		}
	}

	// MARK: - Private helpers

	func qrCodeImage(contents: String) -> Image {
		if let uiImage = QRCode().generateQRCodeImage(contents: contents) {
			return Image(uiImage: uiImage)
		} else {
			return Image(systemName: "xmark.circle")
		}
	}
}

struct ReceiveView_Previews: PreviewProvider {
    static var previews: some View {
		ReceiveView(store: .preview)
    }
}

extension Store where State == ReceiveViewState, Action == ReceiveViewAction {
	static var preview: Store<ReceiveViewState, ReceiveViewAction> {
		Store(
			initialState: .preview,
			reducer: receiveViewReducer,
			environment: ReceiveViewEnvironment()
		)
	}
}

extension ReceiveViewState {
	static var preview: ReceiveViewState {
		ReceiveViewState(
			address: "0xADe61Bc8c716d8244FfBb188d6dD5369C1CbE81D"
		)
	}
}

extension String {
	var addressSpaced: String {
		var newString = self
		var spaceIndex = newString.index(startIndex, offsetBy: 6)
		while spaceIndex < newString.endIndex {
			newString.insert(" ", at: spaceIndex)
			spaceIndex = newString.index(spaceIndex, offsetBy: 5)
		}
		return newString
	}
}
