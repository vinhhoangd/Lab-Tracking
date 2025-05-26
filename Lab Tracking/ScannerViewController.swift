import UIKit
import AVFoundation

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
  var captureSession = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer!
  var delegate: AVCaptureMetadataOutputObjectsDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black

    // Camera input
    guard let device = AVCaptureDevice.default(for: .video),
          let input = try? AVCaptureDeviceInput(device: device),
          captureSession.canAddInput(input)
    else { return }

    captureSession.addInput(input)

    // Output
    let output = AVCaptureMetadataOutput()
    guard captureSession.canAddOutput(output) else { return }
    captureSession.addOutput(output)
    output.setMetadataObjectsDelegate(delegate, queue: .main)
    output.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]

    // Preview
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.frame = view.layer.bounds
    previewLayer.videoGravity = .resizeAspectFill
    view.layer.addSublayer(previewLayer)

    // ✅ Add Close (X) Button
    let closeButton = UIButton(type: .system)
    closeButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
    closeButton.tintColor = .white
    closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    closeButton.layer.cornerRadius = 20
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.addTarget(self, action: #selector(dismissScanner), for: .touchUpInside)
    view.addSubview(closeButton)

    // 🧭 Position button at top-right
    NSLayoutConstraint.activate([
      closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      closeButton.widthAnchor.constraint(equalToConstant: 40),
      closeButton.heightAnchor.constraint(equalToConstant: 40)
    ])

    // 🔁 Start scanning in background
    DispatchQueue.global(qos: .userInitiated).async {
      self.captureSession.startRunning()
    }
  }

  @objc func dismissScanner() {
    dismiss(animated: true, completion: nil)
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    if captureSession.isRunning {
      captureSession.stopRunning()
    }
  }
}
