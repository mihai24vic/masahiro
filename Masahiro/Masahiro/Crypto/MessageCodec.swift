//
//  MessageCodec.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 10.01.2026.
//

import Foundation

enum MessageCodecError: LocalizedError {
    case invalidPrefix
    case invalidBase64
    case invalidJSON

    var errorDescription: String? {
        switch self {
        case .invalidPrefix: return "Not a masahiro message."
        case .invalidBase64: return "Message data is corrupted (base64)."
        case .invalidJSON: return "Message data is corrupted (json)."
        }
    }
}

/// Encodes/decodes EncryptedMessagePayload into a single shareable String.
enum MessageCodec {
    private static let prefix = "MH1:" // Masahiro v1

    static func encode(_ payload: EncryptedMessagePayload) throws -> String {
        let data = try JSONEncoder().encode(payload)
        return prefix + Base64URL.encode(data)
    }

    static func decode(_ string: String) throws -> EncryptedMessagePayload {
        let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.hasPrefix(prefix) else { throw MessageCodecError.invalidPrefix }

        let encoded = String(trimmed.dropFirst(prefix.count))
        guard let data = Base64URL.decode(encoded) else { throw MessageCodecError.invalidBase64 }

        do {
            return try JSONDecoder().decode(EncryptedMessagePayload.self, from: data)
        } catch {
            throw MessageCodecError.invalidJSON
        }
    }
}
