//
//  ComposeMessageView.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 11.01.2026.
//

import SwiftUI

struct ComposeMessageView: View {
    @StateObject private var viewModel: MessageViewModel
    @State private var showingQR = false

    init(viewModel: MessageViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MarineGradientBackground()
                
                Form {
                    Section("To") {
                        Picker("Contact", selection: $viewModel.selectedContact) {
                            Text("Select…").tag(Optional<Contact>.none)
                            ForEach(viewModel.contactList) { c in
                                Text(c.name).tag(Optional(c))
                            }
                        }
                    }

                    Section("Encryption Mode") {
                        Toggle(isOn: $viewModel.isPQEncryption) {
                            VStack(alignment: .leading) {
                                Text("Post-Quantum (PQ)")
                                Text("Stronger hybrid encryption").font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }

                    Section("Message") {
                        TextField("Type something…", text: $viewModel.composePlaintext, axis: .vertical)
                    }

                    Section {
                        Button("Encrypt") { viewModel.encrypt() }
                            .disabled(viewModel.selectedContact == nil || viewModel.composePlaintext.isEmpty)
                    }

                    if !viewModel.encryptedPayload.isEmpty {
                        Section("Encrypted Payload") {
                            Text(viewModel.encryptedPayload)
                                .font(.footnote)
                                .textSelection(.enabled)

                            HStack {
                                Button("Copy") { viewModel.copyEncrypted() }
                                ShareLink(item: viewModel.encryptedPayload) { Text("Share") }
                                Button("QR") { showingQR = true }
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Write")
            .sheet(isPresented: $showingQR) {
                NavigationStack {
                    ZStack {
                        MarineGradientBackground()
                        VStack {
                            Spacer()
                            QRCodeView(text: viewModel.encryptedPayload)
                                .padding()
                            Text("Anyone can scan this, but only the intended recipient can decrypt it.")
                                .font(.footnote)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                                .padding()
                            Spacer()
                        }
                    }
                    .navigationTitle("Encrypted QR")
                    .toolbar {
                        Button("Done") { showingQR = false }
                    }
                }
            }
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
    ComposeMessageView(viewModel: MessageViewModel(crypto: deps.crypto, contacts: deps.contacts))
}
