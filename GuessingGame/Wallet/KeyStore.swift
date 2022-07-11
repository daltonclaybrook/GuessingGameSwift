import Foundation
import KeychainAccess
import web3

private let passwordKey = "passwordKey"
private let defaultKeyName = "defaultEthereumPrivateKey"

enum KeyStoreError: Error {
	case failedToLoadKey
	case failedToLoadPassword
}

struct KeyStore: EthereumKeyStorageProtocol {
	private let keychain = Keychain(service: "com.daltonclaybrook.GuessingGame")

	var hasStoredKeyAndPassword: Bool {
		let hasKey = (try? keychain.getData(defaultKeyName)) != nil
		let hasPassword = (try? keychain.getData(passwordKey)) != nil
		return hasKey && hasPassword
	}

	func storePassword(_ password: String) throws {
		try keychain.set(password, key: passwordKey)
	}

	func loadPassword() throws -> String {
		guard let password = try keychain.get(passwordKey) else {
			throw KeyStoreError.failedToLoadPassword
		}
		return password
	}

	func storePrivateKey(key: Data) throws {
		try keychain.set(key, key: defaultKeyName)
	}

	func loadPrivateKey() throws -> Data {
		guard let keyData = try keychain.getData(defaultKeyName) else {
			throw KeyStoreError.failedToLoadKey
		}
		return keyData
	}
}
