import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
  var captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer!
  var delegate: AVCaptureMetadataOutputObjectsDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    guard let device = AVCaptureDevice.default(for: .video),
          let input = try? AVCaptureDeviceInput(device: device),
          captureSession.canAddInput(input)
    else { return }

    captureSession.addInput(input)

    let output = AVCaptureMetadataOutput()
    guard captureSession.canAddOutput(output) else { return }
    captureSession.addOutput(output)

    output.setMetadataObjectsDelegate(delegate, queue: .main)
    output.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]

    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.layer.bounds
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.addSublayer(previewLayer)

    captureSession.startRunning()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if captureSession.isRunning {
      captureSession.stopRunning()
    }
  }
}
