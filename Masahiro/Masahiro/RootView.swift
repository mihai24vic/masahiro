//
//  RootView.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 10.01.2026.
//

import SwiftUI

struct RootView: View {
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    var body: some View {
        TabView {
            MyKeyView(viewModel: MyKeyViewModel(identity: dependencies.identity))
                .tabItem { Label("My Key", systemImage: "key.fill") }

            ContactsView(viewModel: ContactsViewModel(contacts: dependencies.contacts))
                .tabItem { Label("Contacts", systemImage: "person.2.fill") }

            ComposeMessageView(viewModel: MessageViewModel(crypto: dependencies.crypto, contacts: dependencies.contacts))
                .tabItem { Label("Write", systemImage: "square.and.pencil") }

            ReadMessageView(viewModel: MessageViewModel(crypto: dependencies.crypto, contacts: dependencies.contacts))
                .tabItem { Label("Read", systemImage: "lock.open.fill") }
        }
        .tint(.white)
    }
}


#Preview {
    RootView(dependencies: AppDependencies())
}
