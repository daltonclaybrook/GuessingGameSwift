import Foundation
import BigInt

protocol DenominationType {
	/// The number of decimal places this denomination has relative to the base currency type
	/// e.g. if the base currency type is `Wei` and the denomination is `Gwei`, the decimal
	/// shift is 9 since Wei is 9 orders of magnitude larger than Gwei.
	var decimalShift: Int { get }
	/// The base denomination, which should have a `decimalShift` of zero
	static var baseDenomination: Self { get }
}

protocol CurrencyType: RawRepresentable where RawValue == BigUInt {
	associatedtype Denomination: DenominationType

	var rawValue: BigUInt { get }
	init(rawValue: BigUInt)
}

extension CurrencyType {
	init(_ value: BigUInt) {
		self.init(rawValue: value)
	}

	/// Initialize the currency by providing a decimal string and a denomination. For example, in Wei, if the value is
	/// `1.2` and the denomination is `Gwei`, the result will be `Wei("1200000000")`
	init?(decimalValue: String, denomination: Denomination) {
		guard decimalValue.first?.isNumber == true && decimalValue.last?.isNumber == true else {
			// First and last characters must be numbers
			return nil
		}

		let countOfPeriods = decimalValue.count { $0 == "." }
		guard countOfPeriods <= 1 else {
			// Must contain zero or one '.'
			return nil
		}

		var decimalValue = decimalValue
		if countOfPeriods == 0 {
			// Add a period if one does not exist
			decimalValue.append(".0")
		}

		let components = decimalValue.components(separatedBy: ".")
		let beforePeriod = components[0]
		var afterPeriod = components[1]
		let shift = denomination.decimalShift

		// Append zeroes until the segment after the period is as large as the shift.
		while afterPeriod.count <= shift {
			afterPeriod.append("0")
		}

		let trimIndex = afterPeriod.index(afterPeriod.startIndex, offsetBy: shift)
		let trimmedAfterPeriod = String(afterPeriod[..<trimIndex])
		let newString = beforePeriod + trimmedAfterPeriod
		guard let rawValue = BigUInt(newString) else {
			return nil
		}

		self.init(rawValue: rawValue)
	}

	/// Returns a string used to display the currency in the provided denomination.
	func displayString(in denomination: Denomination = .baseDenomination, trimDecimalOnWholeNumber: Bool = false) -> String {
		var stringValue = rawValue.description
		let shift = denomination.decimalShift
		// Pad the string with leading zeroes if necessary
		while stringValue.count <= shift {
			stringValue.insert("0", at: stringValue.startIndex)
		}

		// Insert the decimal in the correct position
		let decimalIndex = stringValue.index(stringValue.endIndex, offsetBy: -shift)
		stringValue.insert(".", at: decimalIndex)
		stringValue = stringValue.trimmingCharacters(in: CharacterSet(charactersIn: "0"))

		// Re-add leading and trailing zeroes if the first and/or last character is a '.'
		if stringValue.first == "." {
			stringValue.insert("0", at: stringValue.startIndex)
		}
		if stringValue.last == "." {
			stringValue.append("0")
		}

		// Trim decimal on whole number if necessary
		if trimDecimalOnWholeNumber && stringValue.hasSuffix(".0") {
			stringValue = String(stringValue.dropLast(2))
		}
		return stringValue
	}
}

extension Sequence {
	func count(satisfying: (Element) -> Bool) -> Int {
		var total = 0
		for element in self where satisfying(element) == true {
			total += 1
		}
		return total
	}
}
