import SwiftUI
import AVFoundation

struct ScannerView: UIViewControllerRepresentable {
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
    let completion: (String) -> Void
    init(completion: @escaping (String) -> Void) {
      self.completion = completion
    }
    func metadataOutput(
      _ output: AVCaptureMetadataOutput,
      didOutput metadataObjects: [AVMetadataObject],
      from connection: AVCaptureConnection
    ) {
      if let obj = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
         let str = obj.stringValue {
        completion(str)
      }
    }
  }
}
