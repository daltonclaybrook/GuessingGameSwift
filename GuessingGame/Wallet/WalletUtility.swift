import Foundation
import web3

enum WalletUtilityError: Error {
	case walletDoesNotExist
}

struct WalletUtility {
	func createWalletIfNecessary() {
		let keyStore = KeyStore()
		guard keyStore.hasStoredKeyAndPassword == false else { return }

		do {
			let password = makeRandomPassword()
			// Discard the result. We don't want to use the wallet right now, just create it.
			_ = try EthereumAccount.create(keyStorage: keyStore, keystorePassword: password)
			try keyStore.storePassword(password)
		} catch let error {
			assertionFailure("Failed to create wallet with error: \(error.localizedDescription)")
		}
	}

	func loadWalletAccount() throws -> EthereumAccount {
		let keyStore = KeyStore()
		guard keyStore.hasStoredKeyAndPassword else {
			throw WalletUtilityError.walletDoesNotExist
		}

		let password = try keyStore.loadPassword()
		return try EthereumAccount(keyStorage: keyStore, keystorePassword: password)
	}

	// MARK: - Private helpers

	private func makeRandomPassword(length: Int = 20) -> String {
		let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
		return String((0..<length).map { _ in characters.randomElement()! })
	}
}
