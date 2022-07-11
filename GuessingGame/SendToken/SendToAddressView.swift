import SwiftUI
import UIKit

struct SendToAddressView: View {
	let fromAddress: String
	let toAddress: String

	private let imageSize: CGFloat = 60

	var body: some View {
		HStack(spacing: 8) {
			imageAndText(address: fromAddress)
				.frame(maxWidth: .infinity)

			Image(systemName: "arrow.right")
				.font(.system(size: 30))

			imageAndText(address: toAddress)
				.frame(maxWidth: .infinity)
		}
	}

	// MARK: - Helper functions

	private func imageAndText(address: String) -> some View {
		VStack(spacing: 8) {
			blockiesImage(address: address)
				.frame(width: imageSize, height: imageSize)
				.mask(Circle())
			//				.overlay(
			//					Circle().stroke(Color.black, lineWidth: 2)
			//				)
			Text(address)
				.lineLimit(1)
				.truncationMode(.middle)
				.font(.callout)
		}
	}

	private func blockiesImage(address: String) -> some View {
		let uiImage = Blockies(seed: address).createImage()
		if let uiImage = uiImage {
			return AnyView(
				Image(uiImage: uiImage)
					.resizable()
					.interpolation(.none)
			)
		} else {
			return AnyView(
				ZStack {
					Color.gray
					Image(systemName: "qrcode")
						.font(.system(size: 30))
				}
			)
		}
	}
}

extension Color {
	static var darkGray: Color {
		Color(red: 0.46, green: 0.46, blue: 0.49)
	}
}

struct SendToAddressView_Previews: PreviewProvider {
	static var previews: some View {
		SendToAddressView(
			fromAddress: "0x8B4de256180CFEC54c436A470AF50F9EE2813dbB",
			toAddress: "0x12604E48121DAC64b1Ce3C0a3294f3895D83B4Ef"
		)
	}
}
