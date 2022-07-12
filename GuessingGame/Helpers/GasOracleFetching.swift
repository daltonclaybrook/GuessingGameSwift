//
//  GasOracleFetching.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/11/22.
//

import Foundation

protocol GasOracleFetching {
	func fetchGasOracle() async throws -> GasOracle
}

extension EtherscanAPI: GasOracleFetching {}
