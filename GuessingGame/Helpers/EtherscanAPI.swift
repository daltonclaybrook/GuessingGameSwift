import Foundation

enum EtherscanAPIError: Error {
	case invalidURL
	case invalidHTTPResponse(status: Int?)
}

final class EtherscanAPI {
	private let apiKey = "YTYHWFBW7TBYJEDTXV7U78FAW9X8UTR1Y9"
	private let baseURL = URL(string: "https://api.etherscan.io/api")!

	/// Fetch the "gas oracle" from Etherscan, which includes suggested gas prices
	///
	/// https://docs.etherscan.io/api-endpoints/gas-tracker#get-gas-oracle
	func fetchGasOracle() async throws -> GasOracle {
		let data = try await fetchDataAndValidateResponseCode(url: urlForGasOracle())
		let response = try JSONDecoder().decode(GasOracleResponse.self, from: data)
		return response.result
	}

	// MARK: - Private helpers

	private func fetchDataAndValidateResponseCode(url: URL) async throws -> Data {
		let (data, response) = try await URLSession.shared.data(from: url, delegate: nil)
		let statusCode = (response as? HTTPURLResponse)?.statusCode
		guard let statusCode = statusCode, (200..<300).contains(statusCode) else {
			throw EtherscanAPIError.invalidHTTPResponse(status: statusCode)
		}
		return data
	}

	private func urlForGasOracle() throws -> URL {
		guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
			throw EtherscanAPIError.invalidURL
		}
		components.queryItems = [
			URLQueryItem(name: "apikey", value: apiKey),
			URLQueryItem(name: "module", value: "gastracker"),
			URLQueryItem(name: "action", value: "gasoracle")
		]
		guard let resultURL = components.url else {
			throw EtherscanAPIError.invalidURL
		}
		return resultURL
	}
}
