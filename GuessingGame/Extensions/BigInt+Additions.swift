import BigInt
import Foundation

extension BigUInt {
	func stringByAddingDecimalAndTrimming(decimalPlaces: Int = 18) -> String {
		var stringValue = self.description
		// Pad the string to the full length of decimal places if necessary
		while stringValue.count <= decimalPlaces {
			stringValue.insert("0", at: stringValue.startIndex)
		}

		// Insert the decimal in the correct position
		let decimalIndex = stringValue.index(stringValue.endIndex, offsetBy: -decimalPlaces)
		stringValue.insert(".", at: decimalIndex)
		stringValue = stringValue.trimmingCharacters(in: CharacterSet(charactersIn: "0"))

		// Re-add leading and trailing zeroes if the first and last character is a '.'
		if stringValue.first == "." {
			stringValue.insert("0", at: stringValue.startIndex)
		}
		if stringValue.last == "." {
			stringValue.append("0")
		}
		return stringValue
	}
}
