//
//  AddContactView.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 11.01.2026.
//

import SwiftUI

struct AddContactView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: ContactsViewModel
    @State private var isShowingScanner = false

    var body: some View {
        NavigationStack {
            ZStack {
                MarineGradientBackground()
                
                Form {
                    Section("Name") {
                        TextField("e.g. Alex", text: $viewModel.newName)
                    }

                    Section("Their Public Key") {
                        TextField("Paste or scan", text: $viewModel.newPublicKey, axis: .vertical)
                            .font(.footnote)

                        HStack {
                            PasteButton(payloadType: String.self) { strings in
                                viewModel.newPublicKey = strings.first ?? ""
                            }
                            Button("Scan QR") { isShowingScanner = true }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Contact")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.save() { dismiss() }
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner) {
                QRScannerView { result in
                    viewModel.newPublicKey = result
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
    AddContactView(viewModel: ContactsViewModel(contacts: deps.contacts))
}
