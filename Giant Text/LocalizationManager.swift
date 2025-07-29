//
//  LocalizationManager.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI

// MARK: - Localization Manager
struct LocalizationManager {
    static let shared = LocalizationManager()
    
    // MARK: - Common
    static let giantText = LocalizedStringKey("giant_text")
    static let done = LocalizedStringKey("done")
    static let close = LocalizedStringKey("close")
    static let cancel = LocalizedStringKey("cancel")
    static let ok = LocalizedStringKey("ok")
    
    // MARK: - Options Menu
    static let options = LocalizedStringKey("options")
    static let display = LocalizedStringKey("display")
    static let animation = LocalizedStringKey("animation")
    static let actions = LocalizedStringKey("actions")
    static let intensity = LocalizedStringKey("intensity")
    
    // MARK: - Actions
    static let editText = LocalizedStringKey("edit_text")
    static let clearText = LocalizedStringKey("clear_text")
    static let undo = LocalizedStringKey("undo")
    
    // MARK: - Portrait Mode
    static let portraitModeRequired = LocalizedStringKey("portrait_mode_required")
    static let portraitModeDescription = LocalizedStringKey("portrait_mode_description")
    
    // MARK: - Accessibility
    static let giantTextDisplay = LocalizedStringKey("giant_text_display")
    static let textAnimation = LocalizedStringKey("text_animation")
    static let bold = LocalizedStringKey("bold")
    static let italic = LocalizedStringKey("italic")
    static let clearTextAccessibility = LocalizedStringKey("clear_text_accessibility")
    static let editTextAccessibility = LocalizedStringKey("edit_text_accessibility")
    static let doneEditingAccessibility = LocalizedStringKey("done_editing_accessibility")
} 