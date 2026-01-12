//
//  AppDependencies.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 10.01.2026.
//

import Foundation

struct AppDependencies {
    let identity: IdentityService
    let crypto: CryptoService
    let contacts: ContactsService

    init() {
        let keychain = KeychainStore(service: "com.mike.masahiro")
        let identity = IdentityService(keychain: keychain)
        let crypto = CryptoService(identity: identity)
        let contactsStore = ContactsStore()
        let contacts = ContactsService(store: contactsStore, crypto: crypto, identity: identity)

        self.identity = identity
        self.crypto = crypto
        self.contacts = contacts
    }
}
