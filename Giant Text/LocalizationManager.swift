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

    // MARK: - Theme & Display
    static let themeSection = LocalizedStringKey("theme_section")
    static let randomThemeDaily = LocalizedStringKey("random_theme_daily")
    static let currentTheme = LocalizedStringKey("current_theme")
    static let appearance = LocalizedStringKey("appearance")
    static let textRotation = LocalizedStringKey("text_rotation")
    static let serifFont = LocalizedStringKey("serif_font")
    static let letterSpacing = LocalizedStringKey("letter_spacing")
    static let maxLines = LocalizedStringKey("max_lines")

    // MARK: - Welcome View
    static let welcomeTitle = LocalizedStringKey("welcome_title")
    static let welcomeSubtitle = LocalizedStringKey("welcome_subtitle")
    static let bulletTypeMessage = LocalizedStringKey("bullet_type_message")
    static let bulletLandscapeOrientation = LocalizedStringKey("bullet_landscape_orientation")
    static let bulletPortraitMode = LocalizedStringKey("bullet_portrait_mode")
    static let bulletAnimationEffects = LocalizedStringKey("bullet_animation_effects")
    static let bulletShareQuickly = LocalizedStringKey("bullet_share_quickly")
    static let bulletCrossPlatform = LocalizedStringKey("bullet_cross_platform")
    static let tipClickEdit = LocalizedStringKey("tip_click_edit")
    static let tipRightClickOptions = LocalizedStringKey("tip_right_click_options")
    static let tipPlayPauseEdit = LocalizedStringKey("tip_playpause_edit")
    static let tipMenuButtonOptions = LocalizedStringKey("tip_menu_button_options")
    static let tipTapEdit = LocalizedStringKey("tip_tap_edit")
    static let tipTwoFingerTapOptions = LocalizedStringKey("tip_two_finger_tap_options")
    static let tipEscClose = LocalizedStringKey("tip_esc_close")
    static let featuresHeader = LocalizedStringKey("features_header")
    static let featureGiantTextTitle = LocalizedStringKey("feature_giant_text_title")
    static let featureGiantTextDesc = LocalizedStringKey("feature_giant_text_desc")
    static let featureAnimationsTitle = LocalizedStringKey("feature_animations_title")
    static let featureLandscapeTitle = LocalizedStringKey("feature_landscape_title")
    static let featurePortraitTitle = LocalizedStringKey("feature_portrait_title")
    static let featureCrossPlatformTitle = LocalizedStringKey("feature_cross_platform_title")
    static let featureCrossPlatformDesc = LocalizedStringKey("feature_cross_platform_desc")
    static let featureEasyEditingTitle = LocalizedStringKey("feature_easy_editing_title")
    static let featureEasyEditingDescMacos = LocalizedStringKey("feature_easy_editing_desc_macos")
    static let featureEasyEditingDescTvos = LocalizedStringKey("feature_easy_editing_desc_tvos")
    static let featureEasyEditingDescOther = LocalizedStringKey("feature_easy_editing_desc_other")
    static let getStartedButton = LocalizedStringKey("get_started_button")
}