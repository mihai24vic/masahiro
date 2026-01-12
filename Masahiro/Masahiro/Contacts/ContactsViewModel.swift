//
//  ContactsViewModel.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 11.01.2026.
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class ContactsViewModel: ObservableObject {
    @Published var isPresentingAdd = false
    @Published var newName: String = ""
    @Published var newPublicKey: String = ""
    @Published var alertMessage: String?

    let contactsService: ContactsService
    private var cancellables = Set<AnyCancellable>()

    init(contacts: ContactsService) {
        self.contactsService = contacts
        
        // observe changes from service to trigger updates in this VM
        contactsService.objectWillChange
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }

    var items: [Contact] { contactsService.contacts }

    // MARK: Actions
    func delete(at offsets: IndexSet) {
        do {
            try contactsService.deleteContacts(at: offsets)
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func save() -> Bool {
        do {
            try contactsService.addContact(name: newName, publicKey: newPublicKey)
            // reset fields on success
            newName = ""
            newPublicKey = ""
            return true
        } catch {
            alertMessage = error.localizedDescription
            return false
        }
    }
}
