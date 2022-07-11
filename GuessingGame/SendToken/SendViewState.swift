import BigInt
import Combine
import ComposableArchitecture
import Foundation
import web3

struct SendViewState: Equatable, Identifiable {
	let id = UUID()

	@BindableState var toAddress: String = ""
	@BindableState var amountString: String = ""
	@BindableState var isPresentingQRCamera = false
	@BindableState var confirmation: ConfirmationViewState? = nil
	/// The alert state that is presented when non-nil
	var alert: AlertState<SendViewAction>? = nil
}

enum SendViewAction: BindableAction, Equatable {
	case presentQRCamera
	case finishPresentingQRCamera(qrCode: String?)
	/// Attempt to show the send confirmation if the fields are valid
	case showSendTokenConfirmation
	case dismissAlert
	case resetFields
	case setConfirmationIsPresented(Bool)
	case dismissConfirmationView

	// Sub-state
	case confirmation(ConfirmationViewAction)

	// Binding
	case binding(BindingAction<SendViewState>)
}

struct SendViewEnvironment {
	let client: TokenClient
}

private let _sendViewReducer = Reducer<SendViewState, SendViewAction, SendViewEnvironment> {
	state, action, environment -> Effect in
	switch action {
	case .presentQRCamera:
		state.isPresentingQRCamera = true
		return .none

	case .finishPresentingQRCamera(let qrCode):
		state.isPresentingQRCamera = false
		state.toAddress = qrCode ?? state.toAddress
		return .none

	case .showSendTokenConfirmation:
		if state.toAddress.isValidEthereumAddress, let amount = state.amountString.tokenAmount {
			state.confirmation = ConfirmationViewState(
				fromAddress: environment.client.userAddress.value,
				toAddress: state.toAddress,
				contractAddress: environment.client.tokenContractAddress.value,
				tokenAmountToSend: amount,
				transactionData: Data()
			)
		} else {
			state.alert = .invalidFields
		}
		return .none

	case .dismissAlert:
		state.alert = nil
		return .none

	case .resetFields:
		state.toAddress = ""
		state.amountString = ""
		return .none

	case .dismissConfirmationView:
		state.confirmation = nil
		return .none

	case .setConfirmationIsPresented(let isPresented):
		if isPresented == false {
			state.confirmation = nil
		}
		return .none

	case .confirmation, .binding:
		return .none
	}
}
	.binding()

let sendViewReducer = Reducer<SendViewState, SendViewAction, SendViewEnvironment>.combine(
	_sendViewReducer,
	confirmationViewReducer.optional().pullback(
		state: \.confirmation,
		action: /SendViewAction.confirmation,
		environment: {
			ConfirmationViewEnvironment(
				client: $0.client,
				exchangeAPI: ExchangeAPI(),
				etherscanAPI: EtherscanAPI()
			)
		}
	)
)

extension Store where State == SendViewState, Action == SendViewAction {
	static var preview: Store<SendViewState, SendViewAction> {
		Store(
			initialState: SendViewState(),
			reducer: sendViewReducer,
			environment: SendViewEnvironment(
				client: TokenClient()
			)
		)
	}
}

extension String {
	static let validHexCharacters = Set("0123456789abcdefABCDEF")

	/// Returns true if the receiver is a valid Ethereum address meaning that it
	/// - begins with "0x"
	/// - has exactly 42 characters
	/// - every character is a valid hex character
	var isValidEthereumAddress: Bool {
		guard count == 42 && hasPrefix("0x") else { return false }
		let firstByteIndex = index(startIndex, offsetBy: 2)
		return self[firstByteIndex...].allSatisfy { character in
			Self.validHexCharacters.contains(character)
		}
	}

	/// If the the receiver is a decimal number, this returns a valid amount of the token
	/// In the future when more of the token has been minted, this should add the appropriate
	/// number of decimal places.
	var tokenAmount: BigUInt? {
		// In the future, this should not convert to double. Instead, it
		// should adjust the decimal place appropriately.
		guard let double = Double(self) else { return nil }
		return BigUInt(double)
	}
}

extension AlertState where Action == SendViewAction {
	static var invalidFields: AlertState<SendViewAction> {
		AlertState(
			title: TextState("Error"),
			message: TextState("One or more fields are invalid"),
			dismissButton: .cancel(TextState("OK"), action: .send(.dismissAlert))
		)
	}
}
