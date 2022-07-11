// This code is taken from https://github.com/Boilertalk/BlockiesSwift
// which does not support Swift Package Manager
//
// The MIT License (MIT)
//
// Copyright (c) 2018 Boilertalk Ltd.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#if os(iOS) || os(tvOS) || os(watchOS)
import UIKit
#elseif os(OSX)
import AppKit
#endif

#if os(iOS) || os(tvOS) || os(watchOS)
typealias BColor = UIColor
#elseif os(OSX)
typealias BColor = NSColor
#endif

extension BColor {

	/**
	 * Initializes Color with the given HSL color values.
	 *
	 * H must be bigger than 0 and smaller than 360.
	 *
	 * S must be between 0 and 1.
	 *
	 * L must be between 0 and 1.
	 *
	 * - parameter h: The h value.
	 * - parameter s: The s value.
	 * - parameter l: The l value.
	 */
	convenience init?(h: Double, s: Double, l: Double) {
		let c = (1 - abs(2 * l - 1)) * s
		let x = c * (1 - abs((h / 60).truncatingRemainder(dividingBy: 2) - 1))
		let m = l - (c / 2)

		let (tmpR, tmpG, tmpB): (Double, Double, Double)
		if 0 <= h && h < 60 {
			(tmpR, tmpG, tmpB) = (c, x, 0)
		} else if 60 <= h && h < 120 {
			(tmpR, tmpG, tmpB) = (x, c, 0)
		} else if 120 <= h && h < 180 {
			(tmpR, tmpG, tmpB) = (0, c, x)
		} else if 180 <= h && h < 240 {
			(tmpR, tmpG, tmpB) = (0, x, c)
		} else if 240 <= h && h < 300 {
			(tmpR, tmpG, tmpB) = (x, 0, c)
		} else if 300 <= h && h < 360 {
			(tmpR, tmpG, tmpB) = (c, 0, x)
		} else {
			return nil
		}

		let r = (tmpR + m)
		let g = (tmpG + m)
		let b = (tmpB + m)

		self.init(red: CGFloat(r), green: CGFloat(g), blue: CGFloat(b), alpha: 1)
	}

	static func fromHSL(h: Double, s: Double, l: Double) -> BColor? {
		return BColor(h: h, s: s, l: l)
	}
}
