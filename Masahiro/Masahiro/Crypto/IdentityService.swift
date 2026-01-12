//
//  IdentityService.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 10.01.2026.
//

import Foundation
import CryptoKit
import Combine

enum IdentityError: LocalizedError {
    case invalidStoredKey

    var errorDescription: String? { "Stored identity key is invalid." }
}

/// Owns the device identity keypair.
/// Private key is stored in Keychain; public key is derived when needed.
final class IdentityService {
    let pendingIdentityChanged = PassthroughSubject<Void, Never>()
    private let keychain: KeychainStoring
    private let pendingAccount = "identity.curve25519.pending"
    private let contactAccountPrefix = "identity.curve25519.contact."

    init(keychain: KeychainStoring) {
        self.keychain = keychain
        // we need a pending key at startup.
        _ = try? pendingPrivateKey()
    }

    func pendingPublicKeyString() throws -> String {
        let pk = try pendingPrivateKey()
        return Base64URL.encode(pk.publicKey.rawRepresentation)
    }

    func refreshPendingIdentity() throws {
        let newKey = Curve25519.KeyAgreement.PrivateKey()
        try keychain.saveData(newKey.rawRepresentation, account: pendingAccount)
        pendingIdentityChanged.send()
    }

    func consumePendingIdentity(forContactID id: UUID) throws {
        guard let data = try keychain.readData(account: pendingAccount) else {
            throw IdentityError.invalidStoredKey
        }
        try keychain.saveData(data, account: contactAccountPrefix + id.uuidString)
        try refreshPendingIdentity()
    }

    func privateKey(forContactID id: UUID) throws -> Curve25519.KeyAgreement.PrivateKey {
        if let data = try keychain.readData(account: contactAccountPrefix + id.uuidString) {
            return try Curve25519.KeyAgreement.PrivateKey(rawRepresentation: data)
        }
        throw IdentityError.invalidStoredKey
    }

    func pendingPrivateKey() throws -> Curve25519.KeyAgreement.PrivateKey {
        if let data = try keychain.readData(account: pendingAccount) {
            return try Curve25519.KeyAgreement.PrivateKey(rawRepresentation: data)
        }
        let newKey = Curve25519.KeyAgreement.PrivateKey()
        try keychain.saveData(newKey.rawRepresentation, account: pendingAccount)
        return newKey
    }

    func publicKeyString(forContactID id: UUID) throws -> String {
        let pk = try privateKey(forContactID: id)
        return Base64URL.encode(pk.publicKey.rawRepresentation)
    }
    
    func deleteIdentity(forContactID id: UUID) {
        try? keychain.deleteData(account: contactAccountPrefix + id.uuidString)
    }
}

