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
		print("User address: \(wallet.address.value)")

		// Testing...
		let answer = "Apple"
		let hash = GameClient.makeAnswerHash(answer: answer)!.toHexString()
		print("Answer: \(answer), hash: 0x\(hash)")

		return true
	}
}
