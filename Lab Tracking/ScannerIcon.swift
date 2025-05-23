import SwiftUI
import AVFoundation

struct ScannerView: UIViewControllerRepresentable {
    /// Completion handler returns the scanned string once detected
    var completion: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(completion: completion)
    }

    func makeUIViewController(context: Context) -> ScannerViewController {
        let vc = ScannerViewController()
        vc.delegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var completion: (String) -> Void

        init(completion: @escaping (String) -> Void) {
            self.completion = completion
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput,
                            didOutput metadataObjects: [AVMetadataObject],
                            from connection: AVCaptureConnection) {
            guard let first = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
                  let code = first.stringValue
            else { return }

            // Pass back and stop further scanning
            completion(code)
        }
    }
}
