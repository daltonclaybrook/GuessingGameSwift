import Foundation

private struct ExchangeResponse: Codable {
	let data: ExchangeCurrency
}

private struct ExchangeCurrency: Codable {
	let currency: String
	let rates: ExchangeRates
}

private struct ExchangeRates: Codable {
	/// The prices of 1.0 ETH in USD
	let USD: String
}

typealias ETHPriceInUSD = Double

enum ExchangeAPIError: Error {
	case invalidHTTPResponse(status: Int?)
	case failedToConvertPriceString
}

final class ExchangeAPI {
	private let ethExchangeRateURL = URL(string: "https://api.coinbase.com/v2/exchange-rates?currency=ETH")!

	/// Fetch the current price of ETH in USD
	func fetchCurrentPriceOfETH() async throws -> ETHPriceInUSD {
		let (data, response) = try await URLSession.shared.data(from: ethExchangeRateURL, delegate: nil)

		let statusCode = (response as? HTTPURLResponse)?.statusCode
		guard let statusCode = statusCode, (200..<300).contains(statusCode) else {
			throw ExchangeAPIError.invalidHTTPResponse(status: statusCode)
		}

		let exchangeResponse = try JSONDecoder().decode(ExchangeResponse.self, from: data)
		guard let usdPrice = Double(exchangeResponse.data.rates.USD) else {
			throw ExchangeAPIError.failedToConvertPriceString
		}

		return usdPrice
	}
}
