import BigInt
import Foundation

struct Wei: CurrencyType, Equatable {
	enum Denomination: DenominationType {
		case wei
		case gwei
		case ether
	}

	let rawValue: BigUInt
}

extension Wei.Denomination {
	static var baseDenomination: Wei.Denomination { .wei }

	var decimalShift: Int {
		switch self {
		case .wei:
			return 0
		case .gwei:
			return 9
		case .ether:
			return 18
		}
	}
}
