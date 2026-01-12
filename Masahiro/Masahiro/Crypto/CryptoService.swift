//
//  CryptoService.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 10.01.2026.
//

import Foundation
import CryptoKit

enum CryptoServiceError: LocalizedError {
    case invalidPublicKey
    case invalidSealedBox
    case missingCombined

    var errorDescription: String? {
        switch self {
        case .invalidPublicKey: return "Invalid public key."
        case .invalidSealedBox: return "Invalid encrypted payload."
        case .missingCombined: return "Encryption failed (combined box missing)."
        }
    }
}

/// Stateless crypto operations.
/// Uses:
/// - Curve25519 key agreement (X25519)
/// - HKDF-SHA256 to derive a 256-bit symmetric key
/// - AES-GCM for authenticated encryption
struct CryptoService {
    private let identity: IdentityService

    init(identity: IdentityService) {
        self.identity = identity
    }

    func validatePublicKeyString(_ string: String) -> Bool {
        parsePublicKey(string) != nil
    }

    func encrypt(plaintext: String, to contact: Contact, isPQ: Bool = false) throws -> String {
        guard let recipientPK = parsePublicKey(contact.publicKey) else {
            throw CryptoServiceError.invalidPublicKey
        }

        let senderSK = try identity.privateKey(forContactID: contact.id)
        let sharedSecret = try senderSK.sharedSecretFromKeyAgreement(with: recipientPK)

        // For PQ we vary the KDF parameters,this should be  a hybrid derivation combining X25519 with Kyber.
        let salt = isPQ ? Data("Masahiro.salt.pq.v1".utf8) : Data("Masahiro.salt.v1".utf8)
        let info = isPQ ? Data("Masahiro.info.pq.v1".utf8) : Data("Masahiro.info.v1".utf8)

        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: salt,
            sharedInfo: info,
            outputByteCount: 32
        )

        let messageData = Data(plaintext.utf8)
        let sealedBox = try AES.GCM.seal(messageData, using: symmetricKey)

        guard let combined = sealedBox.combined else { throw CryptoServiceError.missingCombined }

        let payload = EncryptedMessagePayload(
            version: isPQ ? 2 : 1,
            senderPublicKey: try identity.publicKeyString(forContactID: contact.id),
            sealedBoxCombined: Base64URL.encode(combined),
            isPQ: isPQ
        )
        return try MessageCodec.encode(payload)
    }

    func decrypt(encodedMessage: String, using contact: Contact, isPQRequest: Bool = false) throws -> String {
        let payload = try MessageCodec.decode(encodedMessage)
        
        // the message in PQ mode matches what the user is requesting to decrypt as
        let messageIsPQ = payload.isPQ ?? (payload.version >= 2)
        if messageIsPQ != isPQRequest {
            throw CryptoServiceError.invalidSealedBox
        }

        guard let senderPK = parsePublicKey(payload.senderPublicKey),
              let combined = Base64URL.decode(payload.sealedBoxCombined)
        else {
            throw CryptoServiceError.invalidSealedBox
        }

        let receiverSK = try identity.privateKey(forContactID: contact.id)
        let sharedSecret = try receiverSK.sharedSecretFromKeyAgreement(with: senderPK)

        let salt = messageIsPQ ? Data("Masahiro.salt.pq.v1".utf8) : Data("Masahiro.salt.v1".utf8)
        let info = messageIsPQ ? Data("Masahiro.info.pq.v1".utf8) : Data("Masahiro.info.v1".utf8)

        let symmetricKey = sharedSecret.hkdfDerivedSymmetricKey(
            using: SHA256.self,
            salt: salt,
            sharedInfo: info,
            outputByteCount: 32
        )

        let box = try AES.GCM.SealedBox(combined: combined)
        let opened = try AES.GCM.open(box, using: symmetricKey)
        return String(decoding: opened, as: UTF8.self)
    }

    func decryptSearchingAll(encodedMessage: String, contacts: [Contact], isPQRequest: Bool = false) throws -> (Contact, String) {
        for contact in contacts {
            if let plaintext = try? decrypt(encodedMessage: encodedMessage, using: contact, isPQRequest: isPQRequest) {
                return (contact, plaintext)
            }
        }
        
        throw CryptoServiceError.invalidSealedBox
    }

    // MARK private

    private func parsePublicKey(_ string: String) -> Curve25519.KeyAgreement.PublicKey? {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = Base64URL.decode(trimmed), data.count == 32 else { return nil }
        return try? Curve25519.KeyAgreement.PublicKey(rawRepresentation: data)
    }
}
