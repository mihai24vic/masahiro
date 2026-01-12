//
//  KeychainStore.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 10.01.2026.
//

import Foundation
import Security

enum KeychainError: LocalizedError {
    case unexpectedStatus(OSStatus)
    case itemNotFound

    var errorDescription: String? {
        switch self {
        case .unexpectedStatus(let status): return "Keychain error (\(status))."
        case .itemNotFound: return "Key not found."
        }
    }
}

protocol KeychainStoring {
    func readData(account: String) throws -> Data?
    func saveData(_ data: Data, account: String) throws
    func deleteData(account: String) throws
}

/// Tiny Keychain wrapper for storing raw key bytes.
/// Uses `kSecAttrAccessibleWhenUnlockedThisDeviceOnly` for strong local protection.
final class KeychainStore: KeychainStoring {
    private let service: String

    init(service: String) {
        self.service = service
    }

    func readData(account: String) throws -> Data? {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        if status == errSecItemNotFound { return nil }
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }

        return item as? Data
    }

    func saveData(_ data: Data, account: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]

        let attributes: [CFString: Any] = [
            kSecValueData: data,
            kSecAttrAccessible: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]

        let status: OSStatus
        if try readData(account: account) != nil {
            status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        } else {
            var addQuery = query
            attributes.forEach { addQuery[$0.key] = $0.value }
            status = SecItemAdd(addQuery as CFDictionary, nil)
        }

        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
    }

    func deleteData(account: String) throws {
        let query: [CFString: Any] = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account
        ]
        let status = SecItemDelete(query as CFDictionary)

        if status == errSecItemNotFound { return }
        guard status == errSecSuccess else { throw KeychainError.unexpectedStatus(status) }
    }
}
