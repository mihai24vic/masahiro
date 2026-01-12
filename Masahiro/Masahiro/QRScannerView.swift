//
//  QRScannerView.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 11.01.2026.
//

import SwiftUI
import AVFoundation

struct QRScannerView: UIViewControllerRepresentable {
    let onResult: (String) -> Void

    func makeUIViewController(context: Context) -> QRScannerViewController {
        QRScannerViewController(onResult: onResult)
    }

    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

final class QRScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    private let onResult: (String) -> Void
    private let session = AVCaptureSession()

    init(onResult: @escaping (String) -> Void) {
        self.onResult = onResult
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        guard
            let device = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: device),
            session.canAddInput(input)
        else { return }

        session.addInput(input)

        let output = AVCaptureMetadataOutput()
        guard session.canAddOutput(output) else { return }
        session.addOutput(output)

        output.setMetadataObjectsDelegate(self, queue: .main)
        output.metadataObjectTypes = [.qr]

        let preview = AVCaptureVideoPreviewLayer(session: session)
        preview.frame = view.layer.bounds
        preview.videoGravity = .resizeAspectFill
        view.layer.addSublayer(preview)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !session.isRunning { session.startRunning() } //TODO:move this to bk thread
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if session.isRunning { session.stopRunning() }
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        guard
            let object = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
            object.type == .qr,
            let string = object.stringValue
        else { return }

        session.stopRunning()
        onResult(string)
    }
}

#Preview {
    QRScannerView { result in
        print("Scanned: \(result)")
    }
}
