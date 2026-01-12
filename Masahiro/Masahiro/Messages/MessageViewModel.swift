//
//  MessageViewModel.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 11.01.2026.
//

import Combine
import SwiftUI

@MainActor
final class MessageViewModel: ObservableObject {

    @Published var selectedContact: Contact?
    @Published var composePlaintext: String = ""
    @Published var isPQEncryption: Bool = false
    @Published private(set) var encryptedPayload: String = ""
    
    @Published var readInput: String = ""
    @Published var selectedReadContact: Contact?
    @Published var isPQDecryption: Bool = false
    @Published private(set) var readAuthor: String = ""
    @Published private(set) var readPlaintext: String = ""
    
    @Published var alertMessage: String?
    @Published var isProcessing: Bool = false

    private let crypto: CryptoService
    private let contacts: ContactsService

    init(crypto: CryptoService, contacts: ContactsService) {
        self.crypto = crypto
        self.contacts = contacts
    }

    var contactList: [Contact] { contacts.contacts }

    func encrypt() {
        guard let selectedContact else { return }
        do {
            encryptedPayload = try crypto.encrypt(plaintext: composePlaintext, to: selectedContact, isPQ: isPQEncryption)
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func copyEncrypted() {
        UIPasteboard.general.string = encryptedPayload
    }

    func decrypt() {
        isProcessing = true
        Task {
            do {
                if let selectedReadContact {
                    readPlaintext = try crypto.decrypt(encodedMessage: readInput, using: selectedReadContact, isPQRequest: isPQDecryption)
                    readAuthor = selectedReadContact.name
                } else {
                    let (contact, text) = try crypto.decryptSearchingAll(encodedMessage: readInput, contacts: contacts.contacts, isPQRequest: isPQDecryption)
                    readAuthor = contact.name
                    readPlaintext = text
                }
            } catch {
                alertMessage = "Decryption failed. Ensure you have the correct contact selected and the PQ toggle matches the message type."
            }
            isProcessing = false
        }
    }
}
