//
//  ContactsView.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 11.01.2026.
//

import SwiftUI

struct ContactsView: View {
    @StateObject private var viewModel: ContactsViewModel

    init(viewModel: ContactsViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                MarineGradientBackground()
                
                List {
                    ForEach(viewModel.items) { c in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(c.name).font(.headline)
                            Text(c.publicKey).font(.footnote).lineLimit(1)
                        }
                        .listRowBackground(Color.white.opacity(0.1))
                    }
                    .onDelete(perform: viewModel.delete)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Contacts")
            .toolbar {
                Button {
                    viewModel.isPresentingAdd = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.isPresentingAdd) {
                AddContactView(viewModel: viewModel)
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
    ContactsView(viewModel: ContactsViewModel(contacts: deps.contacts))
}
