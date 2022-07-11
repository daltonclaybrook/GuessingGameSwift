import AVFoundation
import UIKit

final class QRCameraViewController: UIViewController {
	private let captureSession = AVCaptureSession()
	private let previewLayer = AVCaptureVideoPreviewLayer()
	private let shapeLayer = CAShapeLayer()
	private let operationQueue = OperationQueue()
	private let didFinish: (_ qrCode: String?) -> Void

	private lazy var cancelButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.setImage(UIImage(systemName: "xmark"), for: .normal)
		button.widthAnchor.constraint(equalToConstant: 44).isActive = true
		button.heightAnchor.constraint(equalToConstant: 44).isActive = true
		return button
	}()

	init(didFinish: @escaping (_ qrCode: String?) -> Void) {
		self.didFinish = didFinish
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	//MARK: Superclass

	override func viewDidLoad() {
		super.viewDidLoad()

		view.addSubview(cancelButton)
		cancelButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 44).isActive = true
		cancelButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true

		cancelButton.addAction(UIAction { [weak self] action in
			self?.didFinish(nil) // finish without providing QR code
		}, for: .touchUpInside)

		let status = AVCaptureDevice.authorizationStatus(for: .video)
		switch status {
		case .notDetermined:
			AVCaptureDevice.requestAccess(for: .video) { [weak self] isAuthorized in
				if isAuthorized {
					self?.setupCaptureSession()
				} else {
					print("Do not have permission to access camera")
				}
			}
		case .authorized:
			setupCaptureSession()
		case .denied, .restricted:
			print("Do not have permission to access camera")
		@unknown default:
			break
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		previewLayer.frame = view.layer.bounds
		shapeLayer.frame = view.layer.bounds
	}

	//MARK: Private

	fileprivate func setupCaptureSession() {
		guard let device = AVCaptureDevice.default(for: .video) else { return }
		do {
			let input = try AVCaptureDeviceInput(device: device)
			captureSession.addInput(input)

			let output = AVCaptureMetadataOutput()
			captureSession.addOutput(output)

			let outputQueue = DispatchQueue(label: "scanner_queue", attributes: [])
			output.setMetadataObjectsDelegate(self, queue: outputQueue)
			output.metadataObjectTypes = [.qr]

			previewLayer.session = captureSession
			previewLayer.videoGravity = .resizeAspectFill

			DispatchQueue.main.async(execute: {
				self.previewLayer.frame = self.view.layer.bounds
				self.view.layer.addSublayer(self.previewLayer)
				self.setupShapeLayer()
				self.view.bringSubviewToFront(self.cancelButton)
			})

			captureSession.startRunning()
		} catch let error {
			print("setup error: \(error)")
		}
	}

	fileprivate func setupShapeLayer() {
		let marzRedColor = UIColor(red: 226/255, green: 123/255, blue: 88/255, alpha: 1.0)
		shapeLayer.strokeColor = marzRedColor.cgColor
		shapeLayer.fillColor = nil
		shapeLayer.lineWidth = 6.0
		shapeLayer.lineJoin = .round
		view.layer.addSublayer(shapeLayer)
	}

	fileprivate func drawCodeCornersIfNecessary(_ corners: [CGPoint]) -> Bool {
		let path = UIBezierPath()
		var hasMoved = false
		for corner in corners {
			if !previewLayer.bounds.contains(corner) {
				return false
			}

			if !hasMoved {
				hasMoved = true
				path.move(to: corner)
			} else {
				path.addLine(to: corner)
			}
		}

		path.close()
		DispatchQueue.main.async {
			self.shapeLayer.path = path.cgPath
		}
		return true
	}

	fileprivate func showConfirmationWithCode(_ code: String) {
		let alert = UIAlertController(title: "Found Code", message: code, preferredStyle: .actionSheet)
		alert.addAction(UIAlertAction(title: "Use Code", style: .default, handler: { [weak self] (action) in
			self?.didFinish(code)
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
			self.captureSession.startRunning()
			self.previewLayer.connection?.isEnabled = true
			self.shapeLayer.path = nil
		}))
		present(alert, animated: true, completion: nil)
	}
}

extension QRCameraViewController: AVCaptureMetadataOutputObjectsDelegate {
	func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
		guard let object = metadataObjects.first,
			  let transformed = previewLayer.transformedMetadataObject(for: object) as? AVMetadataMachineReadableCodeObject,
			  transformed.type == .qr,
			  let qrCodeString = transformed.stringValue
		else { return }

		if drawCodeCornersIfNecessary(transformed.corners) {
			previewLayer.connection?.isEnabled = false
			captureSession.stopRunning()

			DispatchQueue.main.async(execute: {
				self.showConfirmationWithCode(qrCodeString)
			})
		}
	}
}
