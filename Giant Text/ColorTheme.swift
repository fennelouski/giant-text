//
//  ColorTheme.swift
//  Giant Text
//
//  Color theme system with 20 curated themes
//  Each theme has separate light and dark mode variants
//

import SwiftUI

struct ColorTheme: Codable, Identifiable, Equatable {
    let id: String
    let name: String
    let lightBackground: CodableColor
    let lightText: CodableColor
    let darkBackground: CodableColor
    let darkText: CodableColor

    // Get colors for current color scheme
    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkBackground.color : lightBackground.color
    }

    func textColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? darkText.color : lightText.color
    }

    // All available themes
    static let allThemes: [ColorTheme] = [
        // 1. Classic (Default) - Traditional black/white
        ColorTheme(
            id: "classic",
            name: "Classic",
            lightBackground: CodableColor(.white),
            lightText: CodableColor(.black),
            darkBackground: CodableColor(.black),
            darkText: CodableColor(.white)
        ),

        // 2. Ocean Breeze - Cool blues
        ColorTheme(
            id: "ocean",
            name: "Ocean Breeze",
            lightBackground: CodableColor(red: 0.93, green: 0.96, blue: 0.99),
            lightText: CodableColor(red: 0.05, green: 0.20, blue: 0.40),
            darkBackground: CodableColor(red: 0.05, green: 0.15, blue: 0.25),
            darkText: CodableColor(red: 0.70, green: 0.90, blue: 1.00)
        ),

        // 3. Forest Twilight - Deep greens
        ColorTheme(
            id: "forest",
            name: "Forest Twilight",
            lightBackground: CodableColor(red: 0.94, green: 0.97, blue: 0.93),
            lightText: CodableColor(red: 0.10, green: 0.30, blue: 0.15),
            darkBackground: CodableColor(red: 0.08, green: 0.18, blue: 0.12),
            darkText: CodableColor(red: 0.65, green: 0.95, blue: 0.75)
        ),

        // 4. Sunset Glow - Warm oranges and pinks
        ColorTheme(
            id: "sunset",
            name: "Sunset Glow",
            lightBackground: CodableColor(red: 1.00, green: 0.96, blue: 0.93),
            lightText: CodableColor(red: 0.50, green: 0.15, blue: 0.10),
            darkBackground: CodableColor(red: 0.25, green: 0.12, blue: 0.15),
            darkText: CodableColor(red: 1.00, green: 0.75, blue: 0.65)
        ),

        // 5. Lavender Dreams - Soft purples
        ColorTheme(
            id: "lavender",
            name: "Lavender Dreams",
            lightBackground: CodableColor(red: 0.97, green: 0.95, blue: 0.99),
            lightText: CodableColor(red: 0.30, green: 0.15, blue: 0.45),
            darkBackground: CodableColor(red: 0.15, green: 0.10, blue: 0.22),
            darkText: CodableColor(red: 0.88, green: 0.75, blue: 0.98)
        ),

        // 6. Crimson Night - Bold reds
        ColorTheme(
            id: "crimson",
            name: "Crimson Night",
            lightBackground: CodableColor(red: 0.99, green: 0.95, blue: 0.95),
            lightText: CodableColor(red: 0.55, green: 0.05, blue: 0.10),
            darkBackground: CodableColor(red: 0.20, green: 0.05, blue: 0.08),
            darkText: CodableColor(red: 1.00, green: 0.60, blue: 0.65)
        ),

        // 7. Golden Hour - Warm yellows
        ColorTheme(
            id: "golden",
            name: "Golden Hour",
            lightBackground: CodableColor(red: 0.99, green: 0.98, blue: 0.92),
            lightText: CodableColor(red: 0.45, green: 0.35, blue: 0.05),
            darkBackground: CodableColor(red: 0.22, green: 0.18, blue: 0.08),
            darkText: CodableColor(red: 1.00, green: 0.90, blue: 0.50)
        ),

        // 8. Midnight Blue - Deep blues
        ColorTheme(
            id: "midnight",
            name: "Midnight Blue",
            lightBackground: CodableColor(red: 0.95, green: 0.97, blue: 1.00),
            lightText: CodableColor(red: 0.08, green: 0.12, blue: 0.35),
            darkBackground: CodableColor(red: 0.03, green: 0.05, blue: 0.15),
            darkText: CodableColor(red: 0.60, green: 0.75, blue: 1.00)
        ),

        // 9. Cherry Blossom - Soft pinks
        ColorTheme(
            id: "cherry",
            name: "Cherry Blossom",
            lightBackground: CodableColor(red: 1.00, green: 0.96, blue: 0.97),
            lightText: CodableColor(red: 0.55, green: 0.15, blue: 0.30),
            darkBackground: CodableColor(red: 0.22, green: 0.12, blue: 0.16),
            darkText: CodableColor(red: 1.00, green: 0.70, blue: 0.82)
        ),

        // 10. Mint Fresh - Cool mint greens
        ColorTheme(
            id: "mint",
            name: "Mint Fresh",
            lightBackground: CodableColor(red: 0.94, green: 0.99, blue: 0.96),
            lightText: CodableColor(red: 0.10, green: 0.40, blue: 0.30),
            darkBackground: CodableColor(red: 0.10, green: 0.20, blue: 0.17),
            darkText: CodableColor(red: 0.60, green: 1.00, blue: 0.85)
        ),

        // 11. Amber Warmth - Rich amber
        ColorTheme(
            id: "amber",
            name: "Amber Warmth",
            lightBackground: CodableColor(red: 0.99, green: 0.97, blue: 0.93),
            lightText: CodableColor(red: 0.50, green: 0.30, blue: 0.05),
            darkBackground: CodableColor(red: 0.25, green: 0.16, blue: 0.06),
            darkText: CodableColor(red: 1.00, green: 0.80, blue: 0.45)
        ),

        // 12. Slate Gray - Professional grays
        ColorTheme(
            id: "slate",
            name: "Slate Gray",
            lightBackground: CodableColor(red: 0.96, green: 0.96, blue: 0.97),
            lightText: CodableColor(red: 0.25, green: 0.27, blue: 0.30),
            darkBackground: CodableColor(red: 0.12, green: 0.13, blue: 0.15),
            darkText: CodableColor(red: 0.85, green: 0.87, blue: 0.90)
        ),

        // 13. Coral Reef - Vibrant coral
        ColorTheme(
            id: "coral",
            name: "Coral Reef",
            lightBackground: CodableColor(red: 1.00, green: 0.95, blue: 0.93),
            lightText: CodableColor(red: 0.55, green: 0.20, blue: 0.15),
            darkBackground: CodableColor(red: 0.22, green: 0.10, blue: 0.12),
            darkText: CodableColor(red: 1.00, green: 0.65, blue: 0.55)
        ),

        // 14. Teal Wave - Aqua teals
        ColorTheme(
            id: "teal",
            name: "Teal Wave",
            lightBackground: CodableColor(red: 0.93, green: 0.98, blue: 0.97),
            lightText: CodableColor(red: 0.08, green: 0.35, blue: 0.38),
            darkBackground: CodableColor(red: 0.08, green: 0.18, blue: 0.20),
            darkText: CodableColor(red: 0.55, green: 0.95, blue: 0.95)
        ),

        // 15. Plum Twilight - Deep plums
        ColorTheme(
            id: "plum",
            name: "Plum Twilight",
            lightBackground: CodableColor(red: 0.97, green: 0.94, blue: 0.98),
            lightText: CodableColor(red: 0.35, green: 0.12, blue: 0.40),
            darkBackground: CodableColor(red: 0.16, green: 0.08, blue: 0.20),
            darkText: CodableColor(red: 0.90, green: 0.65, blue: 0.95)
        ),

        // 16. Sage Garden - Earthy sage
        ColorTheme(
            id: "sage",
            name: "Sage Garden",
            lightBackground: CodableColor(red: 0.95, green: 0.97, blue: 0.94),
            lightText: CodableColor(red: 0.25, green: 0.35, blue: 0.25),
            darkBackground: CodableColor(red: 0.15, green: 0.18, blue: 0.15),
            darkText: CodableColor(red: 0.75, green: 0.88, blue: 0.72)
        ),

        // 17. Mocha Delight - Rich browns
        ColorTheme(
            id: "mocha",
            name: "Mocha Delight",
            lightBackground: CodableColor(red: 0.97, green: 0.95, blue: 0.93),
            lightText: CodableColor(red: 0.30, green: 0.20, blue: 0.15),
            darkBackground: CodableColor(red: 0.15, green: 0.12, blue: 0.10),
            darkText: CodableColor(red: 0.90, green: 0.80, blue: 0.70)
        ),

        // 18. Electric Violet - Vibrant purples
        ColorTheme(
            id: "violet",
            name: "Electric Violet",
            lightBackground: CodableColor(red: 0.96, green: 0.94, blue: 0.99),
            lightText: CodableColor(red: 0.35, green: 0.10, blue: 0.55),
            darkBackground: CodableColor(red: 0.12, green: 0.08, blue: 0.22),
            darkText: CodableColor(red: 0.85, green: 0.60, blue: 1.00)
        ),

        // 19. Peachy Keen - Soft peaches
        ColorTheme(
            id: "peach",
            name: "Peachy Keen",
            lightBackground: CodableColor(red: 1.00, green: 0.96, blue: 0.94),
            lightText: CodableColor(red: 0.55, green: 0.25, blue: 0.15),
            darkBackground: CodableColor(red: 0.22, green: 0.14, blue: 0.10),
            darkText: CodableColor(red: 1.00, green: 0.75, blue: 0.60)
        ),

        // 20. Steel Blue - Industrial blues
        ColorTheme(
            id: "steel",
            name: "Steel Blue",
            lightBackground: CodableColor(red: 0.94, green: 0.96, blue: 0.98),
            lightText: CodableColor(red: 0.20, green: 0.28, blue: 0.40),
            darkBackground: CodableColor(red: 0.10, green: 0.14, blue: 0.20),
            darkText: CodableColor(red: 0.70, green: 0.82, blue: 0.95)
        )
    ]

    static let defaultTheme = allThemes[0] // Classic theme

    // Find theme by ID
    static func theme(withId id: String) -> ColorTheme {
        allThemes.first { $0.id == id } ?? defaultTheme
    }
}

// Codable wrapper for SwiftUI Color
struct CodableColor: Codable, Equatable {
    let red: Double
    let green: Double
    let blue: Double
    let alpha: Double

    init(red: Double, green: Double, blue: Double, alpha: Double = 1.0) {
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
    }

    init(_ color: Color) {
        // Default to white for system colors
        if color == .white {
            self.red = 1.0
            self.green = 1.0
            self.blue = 1.0
            self.alpha = 1.0
        } else if color == .black {
            self.red = 0.0
            self.green = 0.0
            self.blue = 0.0
            self.alpha = 1.0
        } else {
            // For other colors, use default white
            self.red = 1.0
            self.green = 1.0
            self.blue = 1.0
            self.alpha = 1.0
        }
    }

    var color: Color {
        Color(red: red, green: green, blue: blue, opacity: alpha)
    }
}
