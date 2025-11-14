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
                        state.showingWelcomeView = false
                    } onGetStarted: {
                        state.showingWelcomeView = false
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
        }
        .preferredColorScheme(state.appearanceMode.colorScheme)
        .onAppear {
            let actions = ContentViewActions(state: state, modelContext: modelContext, documents: documents)
            self.actions = actions
            actions.ensureDocumentExists()
            actions.loadDocument()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: TextDocument.self, inMemory: true)
}

