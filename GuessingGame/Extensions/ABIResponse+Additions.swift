//
//  ABIResponse+Additions.swift
//  GuessingGame
//
//  Created by Dalton Claybrook on 7/11/22.
//

import BigInt
import Foundation
import web3

extension EthereumAddress: ABIResponse {
	public static var types: [ABIType.Type] {
		[EthereumAddress.self]
	}

	public init?(values: [ABIDecoder.DecodedValue]) throws {
		guard values.count == 1 else { return nil }
		self = try values[0].decoded()
	}
}

extension Date: ABIResponse {
	public static var types: [ABIType.Type] {
		[BigUInt.self]
	}

	public init?(values: [ABIDecoder.DecodedValue]) throws {
		guard values.count == 1 else { return nil }
		let timestamp: BigUInt = try values[0].decoded()
		self = Date(timeIntervalSince1970: TimeInterval(timestamp))
	}
}

extension Bool: ABIResponse {
	public static var types: [ABIType.Type] {
		[Bool.self]
	}

	public init?(values: [ABIDecoder.DecodedValue]) throws {
		guard values.count == 1 else { return nil }
		self = try values[0].decoded()
	}
}

extension String: ABIResponse {
	public static var types: [ABIType.Type] {
		[String.self]
	}

	public init?(values: [ABIDecoder.DecodedValue]) throws {
		guard values.count == 1 else { return nil }
		self = try values[0].decoded()
	}
}
