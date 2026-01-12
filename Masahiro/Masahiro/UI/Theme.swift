//
//  Theme.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 11.01.2026.
//

import SwiftUI

extension Color {
    static let marineBlueDark = Color(red: 0.0, green: 0.05, blue: 0.15)
    static let marineBlueLight = Color(red: 0.0, green: 0.15, blue: 0.3)
}

struct MarineGradientBackground: View {
    var body: some View {
        LinearGradient(
            gradient: Gradient(colors: [.marineBlueLight, .marineBlueDark]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct MarineBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        ZStack {
            MarineGradientBackground()
            content
        }
    }
}

extension View {
    func marineBackground() -> some View {
        self.modifier(MarineBackgroundModifier())
    }
}
