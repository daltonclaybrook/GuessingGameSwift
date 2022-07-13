//
//  GuessingGameApp.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/10/22.
//

import SwiftUI
import UIKit

@main
struct GuessingGameApp: App {
	@UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
			ContentView(store: .live)
        }
    }
}

final class AppDelegate: NSObject, UIApplicationDelegate {
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
		let walletUtility = WalletUtility()
		walletUtility.createWalletIfNecessary()

		let wallet = try! walletUtility.loadWalletAccount()
		let password = try! walletUtility.keyStore.loadPassword()
		let privateKey = try! walletUtility.keyStore.loadAndDecryptPrivateKey(keystorePassword: password)
		print("User address: \(wallet.address.value), private key: 0x\(privateKey.toHexString())")

		// Testing...
		let answer = "Mona"
		let hash = GameClient.makeAnswerHash(answer: answer)!.toHexString()
		print("Answer: \(answer), hash: 0x\(hash)")

		return true
	}

	// MARK: - Testing

	private func storeInitialTestPrivateKey() {
		let keyStore = KeyStore()
		let password = WalletUtility.makeRandomPassword()
		try! keyStore.storePassword(password)
		let privateKeyString = "0x5fb20f4a50f6e04d1ff1ead4256af3927e06d91853b2b7aff1d5617b37f74a86"
		try! keyStore.storePrivateKey(key: Data(hex: privateKeyString)!)
	}
}
