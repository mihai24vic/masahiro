//
//  ReadMessageView.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 11.01.2026.
//

import SwiftUI
import Combine

struct ReadMessageView: View {
    @StateObject private var viewModel: MessageViewModel
    @State private var isShowingScanner = false

    init(viewModel: MessageViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MarineGradientBackground()
                
                Form {
                    Section("From (Optional Hint)") {
                        Picker("Contact", selection: $viewModel.selectedReadContact) {
                            Text("Search all contacts").tag(Optional<Contact>.none)
                            ForEach(viewModel.contactList) { c in
                                Text(c.name).tag(Optional(c))
                            }
                        }
                    }

                    Section("Decryption Mode") {
                        Toggle(isOn: $viewModel.isPQDecryption) {
                            VStack(alignment: .leading) {
                                Text("Post-Quantum (PQ)")
                                Text("Decrypt hybrid message").font(.caption).foregroundColor(.secondary)
                            }
                        }
                    }

                    Section("Encrypted Payload") {
                        TextField("Paste or scan…", text: $viewModel.readInput, axis: .vertical)
                            .font(.footnote)

                        HStack {
                            PasteButton(payloadType: String.self) { strings in
                                viewModel.readInput = strings.first ?? ""
                            }
                            Button("Scan QR") { isShowingScanner = true }
                        }
                    }

                    Section {
                        Button("Decrypt") { viewModel.decrypt() }
                            .disabled(viewModel.readInput.isEmpty || viewModel.isProcessing)
                    }

                    if !viewModel.readPlaintext.isEmpty {
                        Section("Author") {
                            Text(viewModel.readAuthor)
                        }
                        Section("Message") {
                            Text(viewModel.readPlaintext)
                                .textSelection(.enabled)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
                
                if viewModel.isProcessing {
                    Color.black.opacity(0.4)
                        .ignoresSafeArea()
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Decrypting...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(40)
                    .background(.ultraThinMaterial)
                    .cornerRadius(20)
                }
            }
            .navigationTitle("Read")
            .sheet(isPresented: $isShowingScanner) {
                QRScannerView { result in
                    viewModel.readInput = result
                    isShowingScanner = false
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
    ReadMessageView(viewModel: MessageViewModel(crypto: deps.crypto, contacts: deps.contacts))
}
