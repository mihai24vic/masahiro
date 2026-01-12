//
//  Base64URL.swift
//  Masahiro
//
//  Created by Bocanu Mihai on 10.01.2026.
//

import Foundation

/// Base64URL encoding makes the payload QR- and copy/paste-friendly.
/// (No '+' or '/', and padding '=' is removed.)
enum Base64URL {
    static func encode(_ data: Data) -> String {
        data.base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }

    static func decode(_ string: String) -> Data? {
        var s = string
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = s.count % 4
        if remainder != 0 {
            s.append(String(repeating: "=", count: 4 - remainder))
        }
        return Data(base64Encoded: s)
    }
}
