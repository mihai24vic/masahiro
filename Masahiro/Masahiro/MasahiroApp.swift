//
//  MasahiroApp.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 09.01.2026.
//

import SwiftUI

@main
struct MasahiroApp: App {
    private let dependencies = AppDependencies()
    
    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
                .preferredColorScheme(.dark)
        }
    }
}
