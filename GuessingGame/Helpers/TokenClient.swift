import BigInt
import Foundation
import web3

/// Transaction hash
typealias TxHash = String

final class TokenClient {
	let tokenContractAddress = EthereumAddress("0xA12e5242F9E8BA38eb738a4F234077B0C08E0D7a")
	let gameContractAddress = EthereumAddress("0xcC88ffDfb45677D950f35c28BDEa817C2eC3049b")

	var userAddress: EthereumAddress {
		account.address
	}

	private let url = URL(string: "https://rinkeby.infura.io/v3/9b881136a0064850aa755873914a946c")!
	private let client: EthereumClient
	private let account: EthereumAccount

	init() {
		self.account = try! WalletUtility().loadWalletAccount()
		self.client = EthereumClient(url: url)
	}

	func ethBalance() async -> BigUInt? {
		do {
			let balance = try await client.eth_getBalance(address: account.address, block: .Latest)
			return balance
		} catch let error {
			print("Error getting eth balance: \(error)")
			return nil
		}
	}

	func tokenBalance() async -> BigUInt? {
		let balanceOf = ERC20Functions.balanceOf(contract: tokenContractAddress, from: nil, gasPrice: nil, gasLimit: nil, account: account.address)
		do {
			let balance = try await balanceOf.call(withClient: client, responseType: ERC20Responses.balanceResponse.self, block: .Latest)
			return balance.value
		} catch let error {
			print("Error getting token balance: \(error)")
			return nil
		}
	}

	func fetchEstimatedGasToSendToken(amount: BigUInt, to: EthereumAddress) async throws -> BigUInt {
		let send = ERC20Functions.transfer(contract: tokenContractAddress, from: account.address, to: to, value: amount)
		let transaction = try send.transaction()
		let estimatedGas = try await client.eth_estimateGas(transaction)
		return estimatedGas
	}

	func sendToken(amount: BigUInt, to toAddress: EthereumAddress, gasPrice: Wei, gasLimit: BigUInt) async -> TxHash? {
		let send = ERC20Functions.transfer(contract: tokenContractAddress, from: account.address, gasPrice: gasPrice.rawValue, gasLimit: gasLimit, to: toAddress, value: amount)
		do {
			let transaction = try send.transaction()
			let callResponse = try await client.eth_call(transaction)
			print("Call completed with response: \(callResponse)")
			let txHash = try await client.eth_sendRawTransaction(transaction, withAccount: account)
			return txHash
		} catch let error {
			print("Error sending transaction: \(error)")
			return nil
		}
	}
}
