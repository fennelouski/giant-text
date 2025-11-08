//
//  AirPlayDisplayView.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI
import SwiftData

struct AirPlayDisplayView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var documents: [TextDocument]
    
    @State private var state = ContentViewState()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background
                Rectangle()
                    .fill(state.currentTheme().backgroundColor(for: colorScheme))

                // Only show the animated text display for AirPlay
                if !state.attributedText.string.isEmpty {
                    AnimatedTextDisplay(
                        attributedText: state.attributedText,
                        fontSize: state.fontSize,
                        colorScheme: colorScheme,
                        theme: state.currentTheme(),
                        animation: state.selectedAnimation,
                        intensity: state.animationIntensity,
                        isClippingEnabled: state.isClippingEnabled,
                        useSerifFont: state.useSerifFont,
                        kerning: state.kerning,
                        isBold: state.isBold,
                        isItalicized: state.isItalicized,
                        maxLines: state.maxLines
                    )
                    .accessibilityLabel(LocalizationManager.giantTextDisplay)
                } else {
                    // Show placeholder when no text
                    Text(LocalizationManager.giantText)
                        .font(.system(size: 72, weight: .bold, design: .default))
                        .foregroundColor(state.currentTheme().textColor(for: colorScheme))
                        .multilineTextAlignment(.center)
                        .opacity(0.3)
                }
            }
        }
        .onAppear {
            // Load the most recent document or create a new one
            if let latestDocument = documents.first {
                loadDocumentFromModel(latestDocument)
            }
        }
        .onChange(of: documents) { _, newDocuments in
            // Update when documents change (sync from main device)
            if let latestDocument = newDocuments.first {
                loadDocumentFromModel(latestDocument)
            }
        }
    }
    
    private func loadDocumentFromModel(_ document: TextDocument) {
        // Convert TextDocument to NSAttributedString using the same logic as ContentViewActions
        if let data = document.richTextData {
            state.attributedText = (try? NSAttributedString(data: data, options: [:], documentAttributes: nil)) ?? NSAttributedString(string: document.text)
        } else {
            state.attributedText = NSAttributedString(string: document.text)
        }
        
        // Load other settings from UserDefaults (same as ContentViewState initialization)
        state.fontSize = 100
        state.selectedAnimation = UserDefaults.standard.string(forKey: "selectedAnimation").flatMap { TextAnimation(rawValue: $0) } ?? .none
        state.animationIntensity = UserDefaults.standard.double(forKey: "animationIntensity") > 0 ? UserDefaults.standard.double(forKey: "animationIntensity") : 0.9
        state.isClippingEnabled = UserDefaults.standard.bool(forKey: "isClippingEnabled")
        state.useSerifFont = UserDefaults.standard.object(forKey: "useSerifFont") == nil ? true : UserDefaults.standard.bool(forKey: "useSerifFont")
        state.kerning = UserDefaults.standard.double(forKey: "kerning") > 0 ? UserDefaults.standard.double(forKey: "kerning") : 0.0
        state.isBold = UserDefaults.standard.bool(forKey: "isBold")
        state.isItalicized = UserDefaults.standard.bool(forKey: "isItalicized")
    }
}

#Preview {
    AirPlayDisplayView()
        .modelContainer(for: TextDocument.self, inMemory: true)
} 