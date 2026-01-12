//
//  MyKeyViewModel.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 11.01.2026.
//

import Foundation
import Combine
import SwiftUI

@MainActor
final class MyKeyViewModel: ObservableObject {
    @Published private(set) var publicKey: String = ""
    @Published var alertMessage: String?

    private let identity: IdentityService
    private var cancellables = Set<AnyCancellable>()

    init(identity: IdentityService) {
        self.identity = identity
        
        identity.pendingIdentityChanged
            .sink { [weak self] in
                self?.refresh()
            }
            .store(in: &cancellables)
            
        refresh()
    }

    func refresh() {
        do {
            publicKey = try identity.pendingPublicKeyString()
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func generateNewKey() {
        do {
            try identity.refreshPendingIdentity()
            refresh()
        } catch {
            alertMessage = error.localizedDescription
        }
    }

    func copyKey() {
        UIPasteboard.general.string = publicKey
    }
}
