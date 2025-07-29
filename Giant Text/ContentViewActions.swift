//
//  ContentViewActions.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI
import SwiftData
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#endif

class ContentViewActions {
    private let state: ContentViewState
    private let modelContext: ModelContext
    private let documents: [TextDocument]
    
    init(state: ContentViewState, modelContext: ModelContext, documents: [TextDocument]) {
        self.state = state
        self.modelContext = modelContext
        self.documents = documents
    }
    
    // MARK: - Document Management
    func ensureDocumentExists() {
        if documents.isEmpty {
            let newDocument = TextDocument()
            modelContext.insert(newDocument)
            try? modelContext.save()
        }
    }
    
    func loadDocument() {
        guard let document = documents.first else { return }
        if let data = document.richTextData {
            state.attributedText = (try? NSAttributedString(data: data, options: [:], documentAttributes: nil)) ?? NSAttributedString(string: document.text)
        } else {
            state.attributedText = NSAttributedString(string: document.text)
        }
        // Initialize history with current text
        state.textHistory = [state.attributedText]
        state.currentHistoryIndex = 0
    }
    
    func updateDocument(attributedText: NSAttributedString) {
        guard let document = documents.first else { return }
        document.text = attributedText.string
        document.richTextData = try? attributedText.data(from: NSRange(location: 0, length: attributedText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        document.lastModified = Date()
        try? modelContext.save()
    }
    
    // MARK: - History Management
    func addToHistory(oldValue: NSAttributedString, newValue: NSAttributedString) {
        // Don't add to history if it's the same value
        guard oldValue.string != newValue.string else { return }
        
        // Remove any history after current index (for redo functionality)
        if state.currentHistoryIndex < state.textHistory.count - 1 {
            state.textHistory.removeSubrange((state.currentHistoryIndex + 1)...)
        }
        
        // Add the old value to history
        state.textHistory.append(oldValue)
        state.currentHistoryIndex = state.textHistory.count - 1
        
        // Limit history size to prevent memory issues
        if state.textHistory.count > 50 {
            state.textHistory.removeFirst()
            state.currentHistoryIndex -= 1
        }
    }
    
    func undoLastChange() {
        guard state.currentHistoryIndex > 0 else { return }
        
        state.currentHistoryIndex -= 1
        let previousText = state.textHistory[state.currentHistoryIndex]
        state.attributedText = previousText
        updateDocument(attributedText: previousText)
    }
    
    // MARK: - UI Actions
    func handleTapToEdit() {
        #if os(iOS)
        state.isEditing.toggle()
        #else
        // On other platforms, allow editing in any orientation
        state.isEditing.toggle()
        #endif
    }
    
    func handleEscapeKey() {
        // Close any open menus or stop editing
        state.showingOptionsMenu = false
        state.isEditing = false
    }
    
    func handleClearText() {
        let oldText = state.attributedText
        state.attributedText = NSAttributedString(string: "")
        updateDocument(attributedText: state.attributedText)
        addToHistory(oldValue: oldText, newValue: state.attributedText)
        state.showingOptionsMenu = false
    }
    
    func handleUndo() {
        undoLastChange()
        state.showingOptionsMenu = false
    }
    
    func handleEditFromMenu() {
        state.showingOptionsMenu = false
        handleTapToEdit()
    }
    
    // MARK: - First Launch Logic
    func checkFirstLaunch() {
        #if !os(watchOS)
        let hasPressedGetStarted = UserDefaults.standard.bool(forKey: "hasPressedGetStarted")
        let lastLaunchDate = UserDefaults.standard.object(forKey: "lastLaunchDate") as? Date ?? Date.distantPast
        
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date.distantPast
        let hasLaunchedRecently = lastLaunchDate > thirtyDaysAgo
        
        // Show welcome screen if user hasn't pressed "Get Started" OR hasn't launched in 30 days
        if !hasPressedGetStarted || !hasLaunchedRecently {
            state.showingWelcomeView = true
        }
        
        // Update last launch date
        UserDefaults.standard.set(Date(), forKey: "lastLaunchDate")
        #endif
    }
    
    // MARK: - Orientation Management
    func setupOrientationObserver() {
        #if os(iOS)
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.state.deviceOrientation = UIDevice.current.orientation
        }
        #endif
    }
    
    func handleOrientationChange(oldOrientation: UIDeviceOrientation, newOrientation: UIDeviceOrientation) {
        #if os(iOS)
        // Only trigger recalculation for meaningful orientation changes
        let meaningfulOrientations: [UIDeviceOrientation] = [.portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight]
        
        if meaningfulOrientations.contains(oldOrientation) && meaningfulOrientations.contains(newOrientation) {
            // Use a delay to ensure all UI updates have completed after rotation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                self.state.forceRecalculation = true
            }
        }
        #endif
    }
    
    // MARK: - UserDefaults Management
    func saveUserDefaults() {
        UserDefaults.standard.set(state.selectedAnimation.rawValue, forKey: "selectedAnimation")
        UserDefaults.standard.set(state.animationIntensity, forKey: "animationIntensity")
        UserDefaults.standard.set(state.isClippingEnabled, forKey: "isClippingEnabled")
        UserDefaults.standard.set(state.useSerifFont, forKey: "useSerifFont")
        UserDefaults.standard.set(state.kerning, forKey: "kerning")
        UserDefaults.standard.set(state.isBold, forKey: "isBold")
        UserDefaults.standard.set(state.isItalicized, forKey: "isItalicized")
    }
    
    func saveFormattingState() {
        UserDefaults.standard.set(state.isBold, forKey: "isBold")
        UserDefaults.standard.set(state.isItalicized, forKey: "isItalicized")
    }
    
    // MARK: - Welcome View Actions
    func dismissWelcomeView() {
        state.showingWelcomeView = false
    }
    
    func handleGetStarted() {
        state.showingWelcomeView = false
        state.isEditing = true
        UserDefaults.standard.set(true, forKey: "hasPressedGetStarted")
    }
} 
