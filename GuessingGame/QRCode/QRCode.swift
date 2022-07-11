import CoreImage
import CoreImage.CIFilterBuiltins
import UIKit

struct QRCode {
	private let context = CIContext()
	private let filter = CIFilter.qrCodeGenerator()

	func generateQRCodeImage(contents: String) -> UIImage? {
		filter.message = Data(contents.utf8)

		guard let outputImage = filter.outputImage,
			  let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
		else {
			return nil
		}

		return UIImage(cgImage: cgImage)
	}
}
