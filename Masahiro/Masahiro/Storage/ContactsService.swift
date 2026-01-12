//
//  ContactsService.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 10.01.2026.
//

import Foundation
import SwiftUI
import Combine

enum ContactsServiceError: LocalizedError {
    case invalidPublicKey
    case duplicateKey

    var errorDescription: String? {
        switch self {
        case .invalidPublicKey: return "That public key is not valid."
        case .duplicateKey: return "You already added this key."
        }
    }
}

@MainActor
final class ContactsService: ObservableObject {
    @Published private(set) var contacts: [Contact] = []

    private let store: ContactsStoring
    private let crypto: CryptoService
    private let identity: IdentityService

    init(store: ContactsStoring, crypto: CryptoService, identity: IdentityService) {
        self.store = store
        self.crypto = crypto
        self.identity = identity
        self.contacts = (try? store.load()) ?? []
    }

    func addContact(name: String, publicKey: String) throws {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedKey = publicKey.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else { return }
        guard crypto.validatePublicKeyString(trimmedKey) else { throw ContactsServiceError.invalidPublicKey }
        guard !contacts.contains(where: { $0.publicKey == trimmedKey }) else { throw ContactsServiceError.duplicateKey }

        let contact = Contact(name: trimmedName, publicKey: trimmedKey)
        
        // Consume the pending identity for this new contact
        try identity.consumePendingIdentity(forContactID: contact.id)
        
        contacts.append(contact)
        try store.save(contacts)
    }

    func deleteContacts(at offsets: IndexSet) throws {
        for index in offsets {
            let contact = contacts[index]
            identity.deleteIdentity(forContactID: contact.id)
        }
        contacts.remove(atOffsets: offsets)
        try store.save(contacts)
    }

    func contact(forPublicKey publicKey: String) -> Contact? {
        contacts.first(where: { $0.publicKey == publicKey })
    }
}
