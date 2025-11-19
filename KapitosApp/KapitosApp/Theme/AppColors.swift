//
//  AppColors.swift
//  KapitosApp
//
//  Created by Luisa Cardona on 15/11/25.
//

import SwiftUI

struct AppColors {
    // Light mode beige
    static let backgroundLight = Color(hex: "#F7F1E8")
    static let cardLight = Color(hex: "#FBF7F2")
    static let accentLight = Color(hex: "#E1C59C")
    static let textLight = Color(hex: "#5A4E3C")

    // Dark mode deep blue
    static let backgroundDark = Color(hex: "#0C1136")
    static let cardDark = Color(hex: "#131A4A")
    static let accentDark = Color(hex: "#4F7FFF")
    static let textDark = Color.white
}

extension Color {
    init(hex: String) {
        let cleaned = hex.replacingOccurrences(of: "#", with: "")
        var rgb: UInt64 = 0
        Scanner(string: cleaned).scanHexInt64(&rgb)

        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255,
            green: Double((rgb >> 8) & 0xFF) / 255,
            blue: Double(rgb & 0xFF) / 255
        )
    }
}

