import CryptoSwift
import Foundation
import web3

final class GameClient {
	private let account: EthereumAccount
	private let client: EthereumClient

	init() {
		self.account = try! WalletUtility().loadWalletAccount()
		self.client = EthereumClient(url: Constants.rinkebyURL)
	}

	// MARK: - Game functions

	var nextAsker: EthereumAddress? {
		get async {
			let function = GameFunctions.NextAsker(contract: Constants.gameContractAddress)
			return await call(function: function)
		}
	}

	var nextAskerTimeoutDate: Date? {
		get async {
			let function = GameFunctions.NextAskerTimeoutDate(contract: Constants.gameContractAddress)
			return await call(function: function)
		}
	}

	func submitQuestion(prompt: String, answer: String) async {
		guard let answerHash = makeAnswerHash(answer: answer) else {
			fatalError("Failed to make answer hash from: \(answer)")
		}

		let function = GameFunctions.SubmitQuestion(contract: Constants.gameContractAddress, prompt: prompt, answerHash: answerHash)
		await sendTransaction(function: function)
	}

	func canSubmitNewClue() async -> Bool? {
		let function = GameFunctions.CanSubmitNewClue(contract: Constants.gameContractAddress)
		return await call(function: function)
	}

	func submitClue(_ clue: String) async {
		let function = GameFunctions.SubmitClue(contract: Constants.gameContractAddress, newClue: clue)
		await sendTransaction(function: function)
	}

	func isCurrentQuestionActive() async -> Bool? {
		let function = GameFunctions.IsCurrentQuestionActive(contract: Constants.gameContractAddress)
		return await call(function: function)
	}

	func isCurrentQuestionExpired() async -> Bool? {
		let function = GameFunctions.IsCurrentQuestionExpired(contract: Constants.gameContractAddress)
		return await call(function: function)
	}

	func currentQuestionPrompt() async -> String? {
		let function = GameFunctions.CurrentQuestionPrompt(contract: Constants.gameContractAddress)
		return await call(function: function)
	}

	func getClue(index: UInt8) async -> String? {
		let function = GameFunctions.GetClue(contract: Constants.gameContractAddress, index: index)
		return await call(function: function)
	}

	func checkAnswer(_ answer: String) async -> Bool? {
		let function = GameFunctions.CheckAnswer(contract: Constants.gameContractAddress, answer: answer)
		return await call(function: function)
	}

	func submitAnswer(_ answer: String) async {
		let function = GameFunctions.SubmitAnswer(contract: Constants.gameContractAddress, answer: answer)
		await sendTransaction(function: function)
	}

	func expireQuestion() async {
		let function = GameFunctions.ExpireQuestion(contract: Constants.gameContractAddress)
		await sendTransaction(function: function)
	}

	// MARK: - Private

	private func call<Response: ABIResponse>(function: ABIFunction) async -> Response? {
		do {
			return try await function.call(withClient: client, responseType: Response.self)
		} catch let error {
			print("Error calling function \(type(of: function).name) — \(error)")
			return nil
		}
	}

	@discardableResult
	private func sendTransaction(function: ABIFunction) async -> TxHash? {
		do {
			let transaction = try function.transaction()
			// Best practice is to attempt an `eth_call` first before actually
			// sending the transaction to maximize the chances for success.
			let callResponse = try await client.eth_call(transaction)
			print("Preflight request for function \(type(of: function).name) completed with response: \(callResponse)")
			let txHash = try await client.eth_sendRawTransaction(transaction, withAccount: account)
			print("Send transaction for \(type(of: function).name), Tx Hash: \(txHash)")
			return txHash
		} catch let error {
			print("Error sending transaction for function \(type(of: function).name) — \(error)")
			return nil
		}
	}

	private func makeAnswerHash(answer: String) -> Data? {
		guard let answerData = answer.data(using: .utf8) else { return nil }
		do {
			var digest = SHA3(variant: .keccak256)
			let bytes = try digest.finish(withBytes: answerData.bytes)
			return Data(bytes)
		} catch let error {
			print("Failed to create hash for answer: \(answer), Error: \(error)")
			return nil
		}
	}
}
