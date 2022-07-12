import Foundation
import web3

enum Constants {
	/// The address of the GuessToken contract on Rinkeby
	static let tokenContractAddress = EthereumAddress("0x2802DF21Ef41951A30BebE49C786E504103cD9f9")
	/// The address of the GuessingGame contract on Rinkeby
	static let gameContractAddress = EthereumAddress("0x0D65B3238ceBd5Ed0a17e2D2aBA4485567689156")
	/// The URL used to access the Ethereum JSON-RPC
	static let rinkebyURL = URL(string: "https://rinkeby.infura.io/v3/9b881136a0064850aa755873914a946c")!
	/// The Etherscan API Key used to fetch the gas oracle
	static let etherscanAPIKey = "YTYHWFBW7TBYJEDTXV7U78FAW9X8UTR1Y9"
}
