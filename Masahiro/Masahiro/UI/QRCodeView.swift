//
//  QRCodeView.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 11.01.2026.
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct QRCodeView: View {
    private let text: String
    private let context = CIContext()
    private let filter = CIFilter.qrCodeGenerator()

    init(text: String) {
        self.text = text
    }

    var body: some View {
        HStack {
            Spacer()
            if let image = makeUIImage(text: text) {
                Image(uiImage: image)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 240, maxHeight: 240)
                    .accessibilityLabel("QR code")
            }
            Spacer()
        }
    }

    private func makeUIImage(text: String) -> UIImage? {
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"

        guard let output = filter.outputImage else { return nil }
        let scaled = output.transformed(by: CGAffineTransform(scaleX: 10, y: 10))

        guard let cgImage = context.createCGImage(scaled, from: scaled.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

#Preview {
    QRCodeView(text: "Masahiro Sample Text")
}
