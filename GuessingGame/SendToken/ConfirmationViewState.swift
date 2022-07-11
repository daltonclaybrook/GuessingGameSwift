import BigInt
import Combine
import ComposableArchitecture
import Foundation
import web3
import UIKit

enum SelectedGasPrice: Int, CaseIterable, Equatable {
	case low, average, high
}

struct ConfirmationViewState: Equatable, Identifiable {
	/// The current user's address that they are sending the token from
	var fromAddress: String
	/// The recipient address the user is sending the token to
	var toAddress: String
	/// The address of the token contract on the blockchain
	var contractAddress: String
	/// The amount of the token to send
	var tokenAmountToSend: BigUInt
	/// The estimated amount of gas that this transaction will consume
	var estimatedGas: BigUInt? = nil
	/// The gas limit that will be used when sending the transaction. This field is
	/// currently set as 10% higher than the estimated gas.
	var gasLimit: BigUInt? = nil
	/// The latest response from the Etherscan "Gas Oracle," which includes
	/// safe gas prices.
	var gasOracle: GasOracle? = nil
	/// The user's selected gas price
	var selectedGasPrice: SelectedGasPrice = .average
	/// The current price of 1.0 ETH in USD as reported by the Coinbase API
	var ethPriceInUSD: ETHPriceInUSD? = nil
	/// The raw transaction data
	var transactionData: Data

	/// The alert state that is presented when non-nil
	var alert: AlertState<ConfirmationViewAction>? = nil
	/// Whether the whole confirmation view should be dismissed
	var shouldDismissView: Bool = false
}

enum ConfirmationViewAction: Equatable {
	/// Fetch the current price of ETH in USD
	case fetchETHPriceInUSD
	/// Fetch from the Etherscan "Gas Oracle"
	case fetchGasOracle
	/// Fetch the estimated gas for the transaction
	case fetchEstimatedGas
	/// Select the gas price with the provided index
	case selectGasPrice(index: Int)
	/// Show the send confirmation alert
	case showSendConfirmation
	/// Submit the transaction to the network
	case confirmAndSubmitTransaction(gasPrice: Wei, gasLimit: BigUInt)
	/// Set the `state.alert` to nil, dismissing the alert
	case dismissAlert
	/// Shows an alert indicating that the transaction could not be submitted
	case showSendTransactionFailure
	/// Dismiss the whole confirmation view
	case dismissConfirmationView

	// Callbacks

	case updateCurrentETHPrice(ETHPriceInUSD?)
	case handleDidReceiveGasOracle(GasOracle)
	case handleDidReceiveEstimatedGas(BigUInt)
	case handleFailedToReceiveGasOracle(errorDescription: String)
	case handleFailedToReceiveEstimatedGas(errorDescription: String)
}

extension ConfirmationViewState {
	var id: String {
		fromAddress + toAddress + contractAddress + tokenAmountToSend.description
	}

	var toAddressBlockyImage: UIImage? {
		Blockies(seed: toAddress).createImage()
	}

	var fromAddressBlockyImage: UIImage? {
		Blockies(seed: fromAddress).createImage()
	}

	var contractAddressBlockyImage: UIImage? {
		Blockies(seed: contractAddress).createImage()
	}

	var transactionPriceInETH: Double? {
		guard let price = estimatedTransactionPrice else { return nil }
		let ethPriceString = price.displayString(in: .ether)
		return Double(ethPriceString)
	}

	var transactionPriceStringInETH: String {
		guard let price = estimatedTransactionPrice else { return "-- ETH" }
		let ethPriceString = price.displayString(in: .ether)
		return "\(ethPriceString) ETH"
	}

	var transactionPriceStringInUSD: String {
		guard let transactionPriceInETH = transactionPriceInETH,
			  let ethPriceInUSD = ethPriceInUSD
		else { return "--" }
		let usdTotal = transactionPriceInETH * ethPriceInUSD
		return String(format: "$%.2f", usdTotal)
	}

	var estimatedGasString: String {
		guard let estimatedGas = estimatedGas, let gasLimit = gasLimit else {
			return "--"
		}
		return "\(estimatedGas.description) (Limit: \(gasLimit.description))"
	}

	func gasPriceString(for selected: SelectedGasPrice) -> String {
		guard let price = gasOracle?.gasPrice(for: selected) else {
			return selected.defaultString
		}
		return price.displayString(in: .gwei, trimDecimalOnWholeNumber: true)
	}

	// MARK: - Private helpers

	private var estimatedTransactionPrice: Wei? {
		guard let gas = estimatedGas,
			  let oracle = gasOracle,
			  let gasPrice = oracle.gasPrice(for: selectedGasPrice)
		else { return nil }
		return Wei(gas * gasPrice.rawValue)
	}
}

struct ConfirmationViewEnvironment {
	let client: TokenClient
	let exchangeAPI: ExchangeAPI
	let etherscanAPI: EtherscanAPI
}

let confirmationViewReducer = Reducer<ConfirmationViewState, ConfirmationViewAction, ConfirmationViewEnvironment> {
	state, action, environment in
	switch action {

	case .fetchETHPriceInUSD:
		return Future.async { () -> ConfirmationViewAction in
			do {
				let price = try await environment.exchangeAPI.fetchCurrentPriceOfETH()
				return .updateCurrentETHPrice(price)
			} catch let error {
				print("Error fetching exchange rate")
				return .updateCurrentETHPrice(nil)
			}
		}
		.receive(on: RunLoop.main)
		.eraseToEffect()

	case .fetchGasOracle:
		return Future.async { () -> ConfirmationViewAction in
			do {
				let gasOracle = try await environment.etherscanAPI.fetchGasOracle()
				return .handleDidReceiveGasOracle(gasOracle)
			} catch let error {
				return .handleFailedToReceiveGasOracle(errorDescription: error.localizedDescription)
			}
		}
		.receive(on: RunLoop.main)
		.eraseToEffect()

	case .fetchEstimatedGas:
		let tokenAmountToSend = state.tokenAmountToSend
		let toAddress = state.toAddress
		return Future.async { () -> ConfirmationViewAction in
			do {
				let estimatedGas = try await environment.client.fetchEstimatedGasToSendToken(amount: tokenAmountToSend, to: EthereumAddress(toAddress))
				return .handleDidReceiveEstimatedGas(estimatedGas)
			} catch let error {
				return .handleFailedToReceiveEstimatedGas(errorDescription: "\(error)")
			}
		}
		.receive(on: RunLoop.main)
		.eraseToEffect()

	case .selectGasPrice(let index):
		state.selectedGasPrice = SelectedGasPrice(rawValue: index) ?? state.selectedGasPrice
		return .none

	case .showSendConfirmation:
		if let gasPrice = state.gasOracle?.gasPrice(for: state.selectedGasPrice), let gasLimit = state.gasLimit {
			state.alert = .sendTokenConfirmation(gasPrice: gasPrice, gasLimit: gasLimit)
		} else {
			state.alert = .missingGasPriceOrLimit
		}
		return .none

	case .confirmAndSubmitTransaction(let gasPrice, let gasLimit):
		let recipient = state.toAddress
		let amountToSend = state.tokenAmountToSend
		return Future.async { () -> ConfirmationViewAction in
			let address = EthereumAddress(recipient)
			let txHash = await environment.client.sendToken(
				amount: amountToSend,
				to: address,
				gasPrice: gasPrice,
				gasLimit: gasLimit
			)
			if let txHash = txHash {
				print("Sent transaction with hash: \(txHash)")
				return .dismissConfirmationView
			} else {
				return .showSendTransactionFailure
			}
		}
		.receive(on: RunLoop.main)
		.eraseToEffect()

	case .dismissAlert:
		state.alert = nil
		return .none

	case .dismissConfirmationView:
		state.shouldDismissView = true
		return .none

	case .showSendTransactionFailure:
		state.alert = .sendFailure
		return .none

	case .updateCurrentETHPrice(let ethPrice):
		state.ethPriceInUSD = ethPrice
		return .none

	case .handleDidReceiveGasOracle(let gasOracle):
		state.gasOracle = gasOracle
		return .none

	case .handleDidReceiveEstimatedGas(let estimatedGas):
		state.estimatedGas = estimatedGas
		// gas limit is estimated gas + 10%
		state.gasLimit = estimatedGas / 10 + estimatedGas
		return .none

	case .handleFailedToReceiveGasOracle(let error):
		print("Failed to receive gas oracle. Consider showing alert.\nError: \(error)")
		return .none

	case .handleFailedToReceiveEstimatedGas(let error):
		print("Failed to receive estimated gas: \(error))")
		return .none
	}
}

extension Store where State == ConfirmationViewState, Action == ConfirmationViewAction {
	static var preview: Store<ConfirmationViewState, ConfirmationViewAction> {
		Store.init(
			initialState: ConfirmationViewState(
				fromAddress: "0xADe61Bc8c716d8244FfBb188d6dD5369C1CbE81D",
				toAddress: "0xADe61Bc8c716d8244FfBb188d6dD5369C1CbE81D",
				contractAddress: "0xADe61Bc8c716d8244FfBb188d6dD5369C1CbE81D",
				tokenAmountToSend: 5,
				estimatedGas: 53_441,
				gasLimit: 58_785,
				gasOracle: GasOracle(lastBlock: "", safeGasPrice: "48", proposedGasPrice: "49", fastGasPrice: "52", suggestBaseFee: "", gasUsedRatio: ""),
				selectedGasPrice: .low,
				ethPriceInUSD: 2735.78,
				transactionData: Data([1, 2, 3, 4, 5])
			),
			reducer: confirmationViewReducer,
			environment: ConfirmationViewEnvironment(
				client: TokenClient(),
				exchangeAPI: ExchangeAPI(),
				etherscanAPI: EtherscanAPI()
			)
		)
	}
}

extension SelectedGasPrice: Identifiable {
	var id: Int { rawValue }
}

extension SelectedGasPrice {
	var defaultString: String {
		switch self {
		case .low:
			return "Low"
		case .average:
			return "Average"
		case .high:
			return "High"
		}
	}
}

extension AlertState where Action == ConfirmationViewAction {
	static func sendTokenConfirmation(gasPrice: Wei, gasLimit: BigUInt) -> AlertState<ConfirmationViewAction> {
		AlertState(
			title: TextState("Submit the transaction"),
			message: TextState("You are about to submit the transaction to the blockchain. This operation cannot be undone."),
			primaryButton: .default(
				TextState("Submit"),
				action: .send(.confirmAndSubmitTransaction(gasPrice: gasPrice, gasLimit: gasLimit))
			),
			secondaryButton: .cancel(TextState("Cancel"), action: .send(.dismissAlert))
		)
	}

	static var missingGasPriceOrLimit: AlertState<ConfirmationViewAction> {
		AlertState(
			title: TextState("Error"),
			message: TextState("Unable to determine gas price and/or gas limit. Try again later."),
			dismissButton: .cancel(TextState("OK"), action: .send(.dismissAlert))
		)
	}

	static var sendFailure: AlertState<ConfirmationViewAction> {
		AlertState(
			title: TextState("Failure"),
			message: TextState("The transaction failed. Please try again later."),
			dismissButton: .cancel(TextState("OK"), action: .send(.dismissAlert))
		)
	}
}
