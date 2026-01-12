//
//  Contact.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 10.01.2026.
//

import Foundation

struct Contact: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var publicKey: String
    let createdAt: Date

    init(id: UUID = UUID(), name: String, publicKey: String, createdAt: Date = Date()) {
        self.id = id
        self.name = name
        self.publicKey = publicKey
        self.createdAt = createdAt
    }
}
