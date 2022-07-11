import Foundation

struct GasOracleResponse: Decodable {
	let status: String
	let message: String
	let result: GasOracle
}

struct GasOracle: Decodable, Equatable {
	let lastBlock: String
	/// The cheapest "safe" gas price in Gwei
	let safeGasPrice: String
	/// The average gas price in Gwei
	let proposedGasPrice: String
	/// The higher suggested gas price for faster transactions in Gwei
	let fastGasPrice: String
	let suggestBaseFee: String
	let gasUsedRatio: String

	enum CodingKeys: String, CodingKey {
		case lastBlock = "LastBlock"
		case safeGasPrice = "SafeGasPrice"
		case proposedGasPrice = "ProposeGasPrice"
		case fastGasPrice = "FastGasPrice"
		case suggestBaseFee
		case gasUsedRatio
	}
}

extension GasOracle {
	/// Returns the gas price for the provided selection
	func gasPrice(for selection: SelectedGasPrice) -> Wei? {
		let priceInGwei = gasPriceString(for: selection)
		return Wei(decimalValue: priceInGwei, denomination: .gwei)
	}

	// MARK: - Private helpers

	/// Returns the gas price string for the provided selection in Gwei
	private func gasPriceString(for selection: SelectedGasPrice) -> String {
		switch selection {
		case .low:
			return safeGasPrice
		case .average:
			return proposedGasPrice
		case .high:
			return fastGasPrice
		}
	}
}
