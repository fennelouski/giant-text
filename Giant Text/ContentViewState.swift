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
    
    // MARK: - Platform-specific State
    #if os(iOS)
    var deviceOrientation: UIDeviceOrientation = .portrait
    #endif
    
    // MARK: - Initialization
    init() {
        // Initialize with default values
    }
} 