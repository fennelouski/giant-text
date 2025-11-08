//
//  MainContentView.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI

struct MainContentView: View {
    @Binding var attributedText: NSAttributedString
    @Binding var fontSize: CGFloat
    let availableSize: CGSize
    @Binding var isEditing: Bool
    @Binding var selectedAnimation: TextAnimation
    @Binding var animationIntensity: Double
    @Binding var isClippingEnabled: Bool
    let useSerifFont: Bool
    let kerning: Double
    let showingWelcomeView: Bool
    #if os(iOS)
    let deviceOrientation: UIDeviceOrientation
    #endif
    @Binding var forceRecalculation: Bool
    @Binding var isBold: Bool
    @Binding var isItalicized: Bool
    let maxLines: Int
    let updateDocument: (NSAttributedString) -> Void
    let addToHistory: (NSAttributedString, NSAttributedString) -> Void
    
    var body: some View {
        #if os(iOS)
        iPhoneLandscapeWrapper(isEditing: isEditing, deviceOrientation: deviceOrientation) {
            GiantTextView(
                attributedText: $attributedText,
                fontSize: $fontSize,
                availableSize: availableSize,
                isEditing: $isEditing,
                selectedAnimation: $selectedAnimation,
                animationIntensity: $animationIntensity,
                isClippingEnabled: $isClippingEnabled,
                useSerifFont: useSerifFont,
                kerning: kerning,
                showingWelcomeView: showingWelcomeView,
                deviceOrientation: deviceOrientation,
                forceRecalculation: $forceRecalculation,
                isBold: $isBold,
                isItalicized: $isItalicized,
                maxLines: maxLines,
                updateDocument: updateDocument,
                addToHistory: addToHistory
            )
        }
        .allowsHitTesting(!showingWelcomeView)
        #elseif os(watchOS)
        GiantTextView(
            attributedText: $attributedText,
            fontSize: $fontSize,
            availableSize: availableSize,
            isEditing: $isEditing,
            selectedAnimation: $selectedAnimation,
            animationIntensity: $animationIntensity,
            isClippingEnabled: $isClippingEnabled,
            useSerifFont: useSerifFont,
            kerning: kerning,
            showingWelcomeView: showingWelcomeView,
            forceRecalculation: $forceRecalculation,
            isBold: $isBold,
            isItalicized: $isItalicized,
            maxLines: maxLines,
            updateDocument: updateDocument,
            addToHistory: addToHistory
        )
        .allowsHitTesting(!showingWelcomeView)
        .onTapGesture {
            if showingWelcomeView {
                print("❌ GiantTextView tapped while welcome screen is showing - this should not happen")
            } else {
                print("✅ GiantTextView tapped - welcome screen not showing")
            }
        }
        #else
        GiantTextView(
            attributedText: $attributedText,
            fontSize: $fontSize,
            availableSize: availableSize,
            isEditing: $isEditing,
            selectedAnimation: $selectedAnimation,
            animationIntensity: $animationIntensity,
            isClippingEnabled: $isClippingEnabled,
            useSerifFont: useSerifFont,
            kerning: kerning,
            showingWelcomeView: showingWelcomeView,
            forceRecalculation: $forceRecalculation,
            isBold: $isBold,
            isItalicized: $isItalicized,
            maxLines: maxLines,
            updateDocument: updateDocument,
            addToHistory: addToHistory
        )
        .allowsHitTesting(!showingWelcomeView)
        .onTapGesture {
            if showingWelcomeView {
                print("❌ GiantTextView tapped while welcome screen is showing - this should not happen")
            } else {
                print("✅ GiantTextView tapped - welcome screen not showing")
            }
        }
        #endif
    }
} 