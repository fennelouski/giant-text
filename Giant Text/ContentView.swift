//
//  ContentView.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI
import SwiftData
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#endif
#if os(macOS)
import AppKit
#endif

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var documents: [TextDocument]
    
    @State private var state = ContentViewState()
    @State private var actions: ContentViewActions?

    #if os(iOS) || os(visionOS)
    private var optionsDetents: Set<PresentationDetent> {
        #if DEBUG
        // Screenshot staging: pin the sheet open so the full theme grid is visible.
        if ProcessInfo.processInfo.arguments.contains("--ss-expand-theme") { return [.large] }
        #endif
        return [.medium, .large]
    }
    #endif
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main content view
                #if os(iOS)
                MainContentView(
                    attributedText: $state.attributedText,
                    fontSize: $state.fontSize,
                    availableSize: geometry.size,
                    isEditing: $state.isEditing,
                    selectedAnimation: $state.selectedAnimation,
                    animationIntensity: $state.animationIntensity,
                    isClippingEnabled: $state.isClippingEnabled,
                    useSerifFont: state.useSerifFont,
                    kerning: state.kerning,
                    showingWelcomeView: state.showingWelcomeView,
                    deviceOrientation: state.deviceOrientation,
                    forceRecalculation: $state.forceRecalculation,
                    isBold: $state.isBold,
                    isItalicized: $state.isItalicized,
                    maxLines: state.maxLines,
                    theme: state.currentTheme(),
                    textRotation: state.textRotation,
                    updateDocument: { text in
                        actions?.updateDocument(attributedText: text)
                    },
                    addToHistory: { oldValue, newValue in
                        actions?.addToHistory(oldValue: oldValue, newValue: newValue)
                    }
                )
                #else
                MainContentView(
                    attributedText: $state.attributedText,
                    fontSize: $state.fontSize,
                    availableSize: geometry.size,
                    isEditing: $state.isEditing,
                    selectedAnimation: $state.selectedAnimation,
                    animationIntensity: $state.animationIntensity,
                    isClippingEnabled: $state.isClippingEnabled,
                    useSerifFont: state.useSerifFont,
                    kerning: state.kerning,
                    showingWelcomeView: state.showingWelcomeView,
                    forceRecalculation: $state.forceRecalculation,
                    isBold: $state.isBold,
                    isItalicized: $state.isItalicized,
                    maxLines: state.maxLines,
                    theme: state.currentTheme(),
                    textRotation: state.textRotation,
                    updateDocument: { text in
                        actions?.updateDocument(attributedText: text)
                    },
                    addToHistory: { oldValue, newValue in
                        actions?.addToHistory(oldValue: oldValue, newValue: newValue)
                    }
                )
                #endif
                
                // Portrait-only editing overlay for iPhone - REMOVED since device is always in portrait mode
                
                // Welcome view overlay (not shown on watchOS)
                #if !os(watchOS)
                if state.showingWelcomeView {
                    WelcomeView {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            state.showingWelcomeView = false
                        }
                    } onGetStarted: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            state.showingWelcomeView = false
                        }
                        state.isEditing = true
                        UserDefaults.standard.set(true, forKey: "hasPressedGetStarted")
                    }
                    .allowsHitTesting(true)
                    .zIndex(1000)
                }
                #endif
            }
            .contentViewBackgroundModifiers(theme: state.currentTheme(), colorScheme: colorScheme)
            .contentViewOverlayModifiers(state: state, actions: actions ?? ContentViewActions(state: state, modelContext: modelContext, documents: documents))
            .contentViewModifiers(state: state, actions: actions ?? ContentViewActions(state: state, modelContext: modelContext, documents: documents))
        }
        .contentViewPlatformModifiers(state: state, actions: actions ?? ContentViewActions(state: state, modelContext: modelContext, documents: documents))
        #if os(iOS)
        .statusBarHidden(!state.isEditing)
        .modifier(HomeIndicatorModifier(isEditing: state.isEditing))
        #endif
        .sheet(isPresented: $state.showingOptionsMenu) {
            OptionsMenuSheet(
                selectedAnimation: $state.selectedAnimation,
                animationIntensity: $state.animationIntensity,
                showingMarqueeTooltip: $state.showingMarqueeTooltip,
                isClippingEnabled: $state.isClippingEnabled,
                useSerifFont: $state.useSerifFont,
                kerning: $state.kerning,
                maxLines: $state.maxLines,
                selectedThemeId: $state.selectedThemeId,
                useRandomTheme: $state.useRandomTheme,
                appearanceMode: $state.appearanceMode,
                textRotation: $state.textRotation,
                onEdit: {
                    state.showingOptionsMenu = false
                    actions?.handleTapToEdit()
                },
                onClear: {
                    actions?.handleClearText()
                },
                onUndo: {
                    actions?.handleUndo()
                },
                canUndo: state.currentHistoryIndex > 0,
                currentTheme: state.currentTheme()
            )
            #if os(iOS) || os(visionOS)
            .presentationDetents(optionsDetents)
            .presentationDragIndicator(.visible)
            #endif
        }
        .preferredColorScheme(state.appearanceMode.colorScheme)
        .onAppear {
            let actions = ContentViewActions(state: state, modelContext: modelContext, documents: documents)
            self.actions = actions
            actions.ensureDocumentExists()
            actions.loadDocument()
            #if DEBUG
            applyScreenshotArgumentsIfNeeded()
            #endif
        }
    }

    #if DEBUG
    /// Test-only hook used to stage deterministic App Store screenshots.
    private func applyScreenshotArgumentsIfNeeded() {
        let args = ProcessInfo.processInfo.arguments
        func value(after flag: String) -> String? {
            guard let i = args.firstIndex(of: flag), i + 1 < args.count else { return nil }
            return args[i + 1]
        }
        guard args.contains(where: { $0.hasPrefix("--ss-") }) else { return }

        // Stop checkFirstLaunch() from re-showing the welcome overlay after this runs.
        UserDefaults.standard.set(true, forKey: "hasPressedGetStarted")
        UserDefaults.standard.set(Date(), forKey: "lastLaunchDate")

        state.showingWelcomeView = false
        state.isEditing = false
        if let text = value(after: "--ss-text") {
            let attributed = NSAttributedString(string: text)
            state.attributedText = attributed
            // Persist it too, so a later loadDocument() doesn't overwrite it.
            actions?.updateDocument(attributedText: attributed)
        }
        if let theme = value(after: "--ss-theme") {
            state.selectedThemeId = theme
        }
        if let animation = value(after: "--ss-animation"),
           let parsed = TextAnimation(rawValue: animation) {
            state.selectedAnimation = parsed
        }
        if args.contains("--ss-options") {
            state.showingOptionsMenu = true
        }
    }
    #endif
}

#Preview {
    ContentView()
        .modelContainer(for: TextDocument.self, inMemory: true)
}

