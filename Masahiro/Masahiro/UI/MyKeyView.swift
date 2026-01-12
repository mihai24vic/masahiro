//
//  MyKeyView.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 11.01.2026.
//

import SwiftUI

struct MyKeyView: View {
    @StateObject private var viewModel: MyKeyViewModel

    init(viewModel: MyKeyViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MarineGradientBackground()
                
                Form {
                    Section("Your Public Key") {
                        Text(viewModel.publicKey)
                            .font(.footnote)
                            .textSelection(.enabled)

                        HStack {
                            Button("Copy") { viewModel.copyKey() }
                            ShareLink(item: viewModel.publicKey) { Text("Share") }
                            Spacer()
                            Button {
                                viewModel.generateNewKey()
                            } label: {
                                Label("Refresh", systemImage: "arrow.clockwise")
                            }
                        }
                    }

                    Section("QR") {
                        QRCodeView(text: viewModel.publicKey)
                    }

                    Section {
                        Text("Share this public key in person (copy, AirDrop, QR). Anyone with it can encrypt messages that only you can decrypt.")
                            .font(.footnote)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("My Key")
            .alert("Error", isPresented: .constant(viewModel.alertMessage != nil)) {
                Button("OK") { viewModel.alertMessage = nil }
            } message: {
                Text(viewModel.alertMessage ?? "")
            }
        }
    }
}

#Preview {
    let deps = AppDependencies()
    MyKeyView(viewModel: MyKeyViewModel(identity: deps.identity))
}
