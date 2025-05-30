import UIKit
import AVFoundation
import AudioToolbox

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    var captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var delegate: AVCaptureMetadataOutputObjectsDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Thiết lập input từ camera
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device),
              captureSession.canAddInput(input) else {
            print("Cannot set input from camera")
            return
        }

        captureSession.addInput(input)

        // Thiết lập output để nhận barcode/QR
        let output = AVCaptureMetadataOutput()
        guard captureSession.canAddOutput(output) else {
            print("Cannot set output")
            return
        }

        captureSession.addOutput(output)
        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr, .ean8, .ean13, .pdf417]

        // Xem trước camera
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        // Bắt đầu quét ở thread nền
        DispatchQueue.global(qos: .userInitiated).async {
            self.captureSession.startRunning()
        }

        // Thêm nút "X" để quay lại
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.titleLabel?.font = .systemFont(ofSize: 28, weight: .bold)
        closeButton.tintColor = .white
        closeButton.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        closeButton.layer.cornerRadius = 20
        closeButton.frame = CGRect(x: 20, y: 50, width: 40, height: 40)
        closeButton.addTarget(self, action: #selector(dismissScanner), for: .touchUpInside)
        view.addSubview(closeButton)
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let code = metadataObject.stringValue {

            // Rung
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

            // Gọi delegate (ScannerView sẽ xử lý completion)
            if let delegate = delegate as? ScannerView.Coordinator {
                delegate.metadataOutput(output, didOutput: metadataObjects, from: connection)
            }

            // Đóng scanner
            dismiss(animated: true)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }

    @objc func dismissScanner() {
        dismiss(animated: true)
    }
}
