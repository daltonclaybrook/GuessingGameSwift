import SwiftUI

struct QRCameraView: UIViewControllerRepresentable {
	/// Block that is called when the QR scanner is finished. If a QR code was selected,
	/// it is provided as the parameter to the block.
	let didFinish: (_ qrCode: String?) -> Void

	func makeUIViewController(context: Context) -> QRCameraViewController {
		QRCameraViewController(didFinish: didFinish)
	}

	func updateUIViewController(_ uiViewController: QRCameraViewController, context: Context) {
		print("updating view controller...")
	}
}
