//
//  ContentViewState.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI
import SwiftData
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#endif

enum AppearanceMode: String, CaseIterable {
    case system = "system"
    case light = "light"
    case dark = "dark"

    var localizedName: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

enum TextRotation: String, CaseIterable {
    case left = "left"
    case right = "right"

    var localizedName: String {
        switch self {
        case .left:
            return "Left"
        case .right:
            return "Right"
        }
    }

    var degrees: Double {
        switch self {
        case .left:
            return 90
        case .right:
            return -90
        }
    }
}

@Observable
class ContentViewState {
    // MARK: - Text and Display State
    var attributedText: NSAttributedString = NSAttributedString(string: "GIANT TEXT")
    var fontSize: CGFloat = 100
    var availableSize: CGSize = .zero
    var isEditing: Bool = true
    var forceRecalculation: Bool = false
    
    // MARK: - History State
    var textHistory: [NSAttributedString] = []
    var currentHistoryIndex: Int = -1
    
    // MARK: - Animation State
    var selectedAnimation: TextAnimation = UserDefaults.standard.string(forKey: "selectedAnimation").flatMap { TextAnimation(rawValue: $0) } ?? .none
    var animationIntensity: Double = UserDefaults.standard.double(forKey: "animationIntensity") > 0 ? UserDefaults.standard.double(forKey: "animationIntensity") : 0.9
    
    // MARK: - Text Formatting State
    var isBold: Bool = UserDefaults.standard.bool(forKey: "isBold")
    var isItalicized: Bool = UserDefaults.standard.bool(forKey: "isItalicized")
    
    // MARK: - UI State
    var showingOptionsMenu: Bool = false
    var showingMarqueeTooltip: Bool = false
    var showingWelcomeView: Bool = false
    
    // MARK: - Display Settings
    var isClippingEnabled: Bool = UserDefaults.standard.bool(forKey: "isClippingEnabled")
    var useSerifFont: Bool = UserDefaults.standard.object(forKey: "useSerifFont") == nil ? true : UserDefaults.standard.bool(forKey: "useSerifFont")
    var kerning: Double = UserDefaults.standard.double(forKey: "kerning") > 0 ? UserDefaults.standard.double(forKey: "kerning") : 0.0
    var maxLines: Int = {
        let stored = UserDefaults.standard.integer(forKey: "maxLines")
        return (stored >= 1 && stored <= 5) ? stored : 1
    }()
    var appearanceMode: AppearanceMode = {
        if let rawValue = UserDefaults.standard.string(forKey: "appearanceMode"),
           let mode = AppearanceMode(rawValue: rawValue) {
            return mode
        }
        return .system
    }() {
        didSet {
            UserDefaults.standard.set(appearanceMode.rawValue, forKey: "appearanceMode")
        }
    }
    var textRotation: TextRotation = {
        if let rawValue = UserDefaults.standard.string(forKey: "textRotation"),
           let rotation = TextRotation(rawValue: rawValue) {
            return rotation
        }
        return .left
    }() {
        didSet {
            UserDefaults.standard.set(textRotation.rawValue, forKey: "textRotation")
        }
    }

    // MARK: - Theme Settings
    var selectedThemeId: String = UserDefaults.appGroup.string(forKey: "selectedThemeId") ?? "classic" {
        didSet {
            UserDefaults.appGroup.set(selectedThemeId, forKey: "selectedThemeId")
            saveThemeToAppGroup()
        }
    }
    var useRandomTheme: Bool = UserDefaults.appGroup.bool(forKey: "useRandomTheme") {
        didSet {
            UserDefaults.appGroup.set(useRandomTheme, forKey: "useRandomTheme")
        }
    }
    private var lastThemeChangeDate: Date? {
        get {
            UserDefaults.appGroup.object(forKey: "lastThemeChangeDate") as? Date
        }
        set {
            UserDefaults.appGroup.set(newValue, forKey: "lastThemeChangeDate")
        }
    }
    
    // MARK: - Platform-specific State
    #if os(iOS)
    var deviceOrientation: UIDeviceOrientation = .portrait
    #endif
    
    // MARK: - Initialization
    init() {
        // Initialize with default values
        checkAndUpdateThemeIfNeeded()
    }

    // MARK: - Theme Management
    func currentTheme() -> ColorTheme {
        ColorTheme.theme(withId: selectedThemeId)
    }

    func checkAndUpdateThemeIfNeeded() {
        guard useRandomTheme else { return }

        let now = Date()
        let shouldUpdate: Bool

        if let lastChange = lastThemeChangeDate {
            // Check if 24 hours (86400 seconds) have passed
            shouldUpdate = now.timeIntervalSince(lastChange) >= 86400
        } else {
            // First launch or no previous date
            shouldUpdate = true
        }

        if shouldUpdate {
            randomizeTheme()
        }
    }

    func randomizeTheme() {
        // Get a random theme that's different from the current one
        let availableThemes = ColorTheme.allThemes.filter { $0.id != selectedThemeId }
        if let randomTheme = availableThemes.randomElement() {
            selectedThemeId = randomTheme.id
            lastThemeChangeDate = Date()
        }
    }

    private func saveThemeToAppGroup() {
        // Save theme data for widget access
        if let encoded = try? JSONEncoder().encode(currentTheme()) {
            UserDefaults.appGroup.set(encoded, forKey: "currentThemeData")
        }
    }
}
