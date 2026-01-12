//
//  ContactsStore.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 10.01.2026.
//

import Foundation

protocol ContactsStoring {
    func load() throws -> [Contact]
    func save(_ contacts: [Contact]) throws
}

/// Stores contacts as JSON in Application Support.
final class ContactsStore: ContactsStoring {
    private let url: URL

    init(filename: String = "contacts.json") {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        self.url = dir.appendingPathComponent(filename)
    }

    func load() throws -> [Contact] {
        let fm = FileManager.default
        let dir = url.deletingLastPathComponent()
        if !fm.fileExists(atPath: dir.path) {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        guard fm.fileExists(atPath: url.path) else { return [] }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([Contact].self, from: data)
    }

    func save(_ contacts: [Contact]) throws {
        let fm = FileManager.default
        let dir = url.deletingLastPathComponent()
        if !fm.fileExists(atPath: dir.path) {
            try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        }

        let data = try JSONEncoder().encode(contacts)
        try data.write(to: url, options: [.atomic])
    }
}
