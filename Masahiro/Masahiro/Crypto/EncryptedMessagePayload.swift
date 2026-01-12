//
//  EncryptedMessagePayload.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 10.01.2026.
//

import Foundation

/// Minimal payload for public sharing (website / paste / QR).
/// - senderPublicKey: needed to identify the author and derive the shared key for decryption.
/// - sealedBoxCombined: AES-GCM combined representation (nonce + ciphertext + tag).
struct EncryptedMessagePayload: Codable, Hashable {
    let version: Int
    let senderPublicKey: String
    let sealedBoxCombined: String
    let isPQ: Bool?
}

