import web3

final class GameClient {
	let gameContractAddress = EthereumAddress("0x2Fdf480E99e8B3b696f15Eb6028a5dD705FaE41B")

	private let account: EthereumAccount
	private let client: EthereumClient

	init() {
		self.account = try! WalletUtility().loadWalletAccount()
		self.client = EthereumClient(url: Constants.rinkebyURL)
	}
}
