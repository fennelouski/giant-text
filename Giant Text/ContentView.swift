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

enum TextAnimation: String, CaseIterable {
    case none = "none"
    case bloom = "bloom"
    case jitter = "jitter"
    case ripple = "ripple"
    
    var icon: String {
        switch self {
        case .none: return "autostartstop.slash"
        case .bloom: return "sparkles"
        case .jitter: return "waveform"
        case .ripple: return "chevron.up.2"
        }
    }
    
    var localizedName: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    @Query private var documents: [TextDocument]
    @State private var attributedText: NSAttributedString = NSAttributedString(string: "GIANT TEXT")
    @State private var fontSize: CGFloat = 100
    @State private var availableSize: CGSize = .zero
    @State private var isEditing: Bool = true
    @State private var textHistory: [NSAttributedString] = []
    @State private var currentHistoryIndex: Int = -1
    @State private var selectedAnimation: TextAnimation = UserDefaults.standard.string(forKey: "selectedAnimation").flatMap { TextAnimation(rawValue: $0) } ?? .none
    @State private var animationIntensity: Double = UserDefaults.standard.double(forKey: "animationIntensity") > 0 ? UserDefaults.standard.double(forKey: "animationIntensity") : 0.9
    @State private var showingOptionsMenu: Bool = false
    #if os(iOS)
    @State private var deviceOrientation: UIDeviceOrientation = .portrait
    #endif

    @State private var showingMarqueeTooltip: Bool = false
    @State private var showingWelcomeView: Bool = false
    @State private var isClippingEnabled: Bool = UserDefaults.standard.bool(forKey: "isClippingEnabled")
    @State private var useSerifFont: Bool = UserDefaults.standard.object(forKey: "useSerifFont") == nil ? true : UserDefaults.standard.bool(forKey: "useSerifFont") // Default to serif font
    @State private var forceRecalculation: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Main text area with dynamic sizing
                #if os(iOS)
                GiantTextView(
                    attributedText: $attributedText,
                    fontSize: $fontSize,
                    availableSize: geometry.size,
                    isEditing: $isEditing,
                    selectedAnimation: $selectedAnimation,
                    animationIntensity: $animationIntensity,
                    isClippingEnabled: $isClippingEnabled,
                    useSerifFont: useSerifFont,
                    showingWelcomeView: showingWelcomeView,
                    deviceOrientation: deviceOrientation,
                    forceRecalculation: $forceRecalculation,
                    updateDocument: updateDocument,
                    addToHistory: addToHistory
                )
                .allowsHitTesting(!showingWelcomeView) // Disable touches to GiantTextView when welcome screen is showing
                .onTapGesture {
                    if showingWelcomeView {
                        print("❌ GiantTextView tapped while welcome screen is showing - this should not happen")
                    } else {
                        print("✅ GiantTextView tapped - welcome screen not showing")
                    }
                }
                #elseif os(watchOS)
                GiantTextView(
                    attributedText: $attributedText,
                    fontSize: $fontSize,
                    availableSize: geometry.size,
                    isEditing: $isEditing,
                    selectedAnimation: $selectedAnimation,
                    animationIntensity: $animationIntensity,
                    isClippingEnabled: $isClippingEnabled,
                    showingWelcomeView: showingWelcomeView,
                    forceRecalculation: $forceRecalculation,
                    updateDocument: updateDocument,
                    addToHistory: addToHistory
                )
                .allowsHitTesting(!showingWelcomeView) // Disable touches to GiantTextView when welcome screen is showing
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
                    availableSize: geometry.size,
                    isEditing: $isEditing,
                    selectedAnimation: $selectedAnimation,
                    animationIntensity: $animationIntensity,
                    isClippingEnabled: $isClippingEnabled,
                    showingWelcomeView: showingWelcomeView,
                    forceRecalculation: $forceRecalculation,
                    updateDocument: updateDocument,
                    addToHistory: addToHistory
                )
                .allowsHitTesting(!showingWelcomeView) // Disable touches to GiantTextView when welcome screen is showing
                .onTapGesture {
                    if showingWelcomeView {
                        print("❌ GiantTextView tapped while welcome screen is showing - this should not happen")
                    } else {
                        print("✅ GiantTextView tapped - welcome screen not showing")
                    }
                }
                #endif

                

                
                // Portrait-only editing overlay for iPhone
                #if os(iOS)
                if isEditing && deviceOrientation != .portrait {
                    PortraitOnlyOverlay {
                        isEditing = false
                    }
                }
                #endif
                
                // Welcome view overlay (not shown on watchOS)
                #if !os(watchOS)
                if showingWelcomeView {
                    WelcomeView {
                        showingWelcomeView = false
                    } onGetStarted: {
                        showingWelcomeView = false
                        isEditing = true
                        UserDefaults.standard.set(true, forKey: "hasPressedGetStarted")
                    }
                    .allowsHitTesting(true) // Ensure welcome screen can receive touches
                    .zIndex(1000) // Ensure it's on top
                }
                #endif
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colorScheme == .dark ? Color.black : Color.white)
            #if os(macOS)
            .overlay(
                Color.clear
            )
            #else
            .overlay(
                TwoFingerTapView {
                    showingOptionsMenu = true
                }
                .allowsHitTesting(!showingWelcomeView) // Disable touches to TwoFingerTapView when welcome screen is showing
                .onTapGesture {
                    if showingWelcomeView {
                        print("❌ TwoFingerTapView tapped while welcome screen is showing - this should not happen")
                    } else {
                        print("✅ TwoFingerTapView tapped - welcome screen not showing")
                    }
                }
            )
            #endif
            // Removed .allowsHitTesting(!showingWelcomeView) as it was blocking welcome screen touches
            .onTapGesture {
                if !showingWelcomeView {
                    print("✅ Main content view tapped - welcome screen not showing")
                }
            }
            .onChange(of: attributedText) { oldValue, newValue in
                updateDocument(attributedText: newValue)
                addToHistory(oldValue: oldValue, newValue: newValue)
            }
            .onAppear {
                loadDocument()
                setupOrientationObserver()
            }
            .onChange(of: selectedAnimation) { _, newValue in
                UserDefaults.standard.set(newValue.rawValue, forKey: "selectedAnimation")
            }
            .onChange(of: animationIntensity) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "animationIntensity")
            }
            .onChange(of: isClippingEnabled) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "isClippingEnabled")
            }
            .onChange(of: useSerifFont) { _, newValue in
                UserDefaults.standard.set(newValue, forKey: "useSerifFont")
            }
            #if os(iOS)
            .onChange(of: deviceOrientation) { oldOrientation, newOrientation in
                // Only trigger recalculation for meaningful orientation changes
                let meaningfulOrientations: [UIDeviceOrientation] = [.portrait, .portraitUpsideDown, .landscapeLeft, .landscapeRight]
                
                if meaningfulOrientations.contains(oldOrientation) && meaningfulOrientations.contains(newOrientation) {
                    // Use a delay to ensure all UI updates have completed after rotation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        forceRecalculation = true
                    }
                }
            }
            #endif
            .task {
                checkFirstLaunch()
            }
        }
        .onAppear {
            ensureDocumentExists()
        }
        // Removed .ignoresSafeArea() to ensure text stays within safe area
        #if os(iOS)
        .onReceive(NotificationCenter.default.publisher(for: .deviceDidShakeNotification)) { _ in
            undoLastChange()
        }
        #endif
        .onKeyPress(.escape) { 
            handleEscapeKey()
            return .handled
        }
        .sheet(isPresented: $showingOptionsMenu) {
            OptionsMenuSheet(
                selectedAnimation: $selectedAnimation,
                animationIntensity: $animationIntensity,
                showingMarqueeTooltip: $showingMarqueeTooltip,
                isClippingEnabled: $isClippingEnabled,
                useSerifFont: $useSerifFont,
                onEdit: {
                    showingOptionsMenu = false
                    handleTapToEdit()
                },
                onClear: {
                    let oldText = attributedText
                    attributedText = NSAttributedString(string: "")
                    updateDocument(attributedText: attributedText)
                    addToHistory(oldValue: oldText, newValue: attributedText)
                    showingOptionsMenu = false
                },
                onUndo: {
                    undoLastChange()
                    showingOptionsMenu = false
                },
                canUndo: currentHistoryIndex > 0
            )
        }
    }
    
    private func setupOrientationObserver() {
        #if os(iOS)
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            deviceOrientation = UIDevice.current.orientation
        }
        #endif
    }
    
    private func handleTapToEdit() {
        #if os(iOS)
        // On iPhone, only allow editing in portrait mode
        if deviceOrientation == .portrait {
            isEditing.toggle()
        } else {
            // Show portrait-only message
            // The overlay will handle this visually
        }
        #else
        // On other platforms, allow editing in any orientation
        isEditing.toggle()
        #endif
    }
    
    private func handleEscapeKey() {
        // Close any open menus or stop editing
        showingOptionsMenu = false
        isEditing = false
    }
    
    private func checkFirstLaunch() {
        #if !os(watchOS)
        let hasPressedGetStarted = UserDefaults.standard.bool(forKey: "hasPressedGetStarted")
        let lastLaunchDate = UserDefaults.standard.object(forKey: "lastLaunchDate") as? Date ?? Date.distantPast
        
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date.distantPast
        let hasLaunchedRecently = lastLaunchDate > thirtyDaysAgo
        
        // Show welcome screen if user hasn't pressed "Get Started" OR hasn't launched in 30 days
        if !hasPressedGetStarted || !hasLaunchedRecently {
            showingWelcomeView = true
        }
        
        // Update last launch date
        UserDefaults.standard.set(Date(), forKey: "lastLaunchDate")
        #endif
    }
    

    
    private func ensureDocumentExists() {
        if documents.isEmpty {
            let newDocument = TextDocument()
            modelContext.insert(newDocument)
            try? modelContext.save()
        }
    }
    
    private func loadDocument() {
        guard let document = documents.first else { return }
        if let data = document.richTextData {
            attributedText = (try? NSAttributedString(data: data, options: [:], documentAttributes: nil)) ?? NSAttributedString(string: document.text)
        } else {
            attributedText = NSAttributedString(string: document.text)
        }
        // Initialize history with current text
        textHistory = [attributedText]
        currentHistoryIndex = 0
    }
    
    private func updateDocument(attributedText: NSAttributedString) {
        guard let document = documents.first else { return }
        document.text = attributedText.string
        document.richTextData = try? attributedText.data(from: NSRange(location: 0, length: attributedText.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        document.lastModified = Date()
        try? modelContext.save()
    }
    
    private func addToHistory(oldValue: NSAttributedString, newValue: NSAttributedString) {
        // Don't add to history if it's the same value
        guard oldValue.string != newValue.string else { return }
        
        // Remove any history after current index (for redo functionality)
        if currentHistoryIndex < textHistory.count - 1 {
            textHistory.removeSubrange((currentHistoryIndex + 1)...)
        }
        
        // Add the old value to history
        textHistory.append(oldValue)
        currentHistoryIndex = textHistory.count - 1
        
        // Limit history size to prevent memory issues
        if textHistory.count > 50 {
            textHistory.removeFirst()
            currentHistoryIndex -= 1
        }
    }
    
    private func undoLastChange() {
        guard currentHistoryIndex > 0 else { return }
        
        currentHistoryIndex -= 1
        let previousText = textHistory[currentHistoryIndex]
        attributedText = previousText
        updateDocument(attributedText: previousText)
    }
}

struct PortraitOnlyOverlay: View {
    let onDismiss: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    onDismiss()
                }
            
            // Portrait-only message
            VStack(spacing: 20) {
                Image(systemName: "iphone")
                    .font(.system(size: 60))
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text(LocalizationManager.portraitModeRequired)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text(LocalizationManager.portraitModeDescription)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
                    .padding(.horizontal, 40)
                
                Button(LocalizationManager.ok) {
                    onDismiss()
                }
                .foregroundColor(.blue)
                .padding(.top, 20)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(colorScheme == .dark ? Color.black : Color.white)
                    .shadow(radius: 20)
            )
            .padding(.horizontal, 40)
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.3), value: true)
    }
}

struct OptionsMenuSheet: View {
    @Binding var selectedAnimation: TextAnimation
    @Binding var animationIntensity: Double
    @Binding var showingMarqueeTooltip: Bool
    @Binding var isClippingEnabled: Bool
    @Binding var useSerifFont: Bool
    let onEdit: () -> Void
    let onClear: () -> Void
    let onUndo: () -> Void
    let canUndo: Bool
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)
    }
    
    private func animationBackgroundColor(for animation: TextAnimation) -> Color {
        if selectedAnimation == animation {
            return colorScheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1)
        } else {
            return colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)
        }
    }
    
    private func textColor(for animation: TextAnimation) -> Color {
        if selectedAnimation == animation {
            return .blue
        } else {
            return colorScheme == .dark ? .white : .black
        }
    }
    
    var body: some View {
        NavigationView {
            
            #if os(watchOS)
            // Simplified menu for watchOS
            ScrollView {
                VStack(spacing: 12) {

                    
                    // Animation picker
                    Picker(LocalizationManager.animation, selection: $selectedAnimation) {
                        ForEach(TextAnimation.allCases, id: \.self) { animation in
                            Text(animation.localizedName).tag(animation)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    
                    if selectedAnimation != .none {
                        VStack {
                            Text(LocalizationManager.intensity)
                            Slider(value: $animationIntensity, in: 0.1...1.0)
                                .accentColor(.blue)
                        }
                    }
                    
                    // Actions
                    Button(action: onEdit) {
                        Text(LocalizationManager.editText)
                            .foregroundColor(.blue)
                    }
                    
                    Button(action: onClear) {
                        Text(LocalizationManager.clearText)
                            .foregroundColor(.red)
                    }
                    
                    if canUndo {
                        Button(action: onUndo) {
                            Text(LocalizationManager.undo)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle(LocalizationManager.options)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationManager.close) {
                        dismiss()
                    }
                }
            }
            #else
            ScrollView {
                VStack(spacing: 20) {
                
                // Display settings section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(LocalizationManager.display)
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Spacer()
                    }
                    

                    
                    // Font selection toggle
                    HStack {
                        Toggle("Serif Font", isOn: $useSerifFont)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                    )
                    
                    // Clipping toggle
                    HStack {
                        Toggle("Clip Letters", isOn: $isClippingEnabled)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                    )
                }
                
                // Animation section
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizationManager.animation)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(TextAnimation.allCases, id: \.self) { animation in
                            Button(action: {
                                selectedAnimation = animation
                            }) {
                                HStack {
                                    Image(systemName: animation.icon)
                                        .foregroundColor(textColor(for: animation))
                                    Text(animation.localizedName)
                                        .foregroundColor(textColor(for: animation))
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(animationBackgroundColor(for: animation))
                                )
                            }
                        }
                    }
                    
                    if selectedAnimation != .none {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(LocalizationManager.intensity)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                                Spacer()
                                Text("\(Int(animationIntensity * 100))%")
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            Slider(value: $animationIntensity, in: 0.1...1.0)
                                .accentColor(.blue)
                        }
                        .padding(.top, 8)
                    }
                }
                
                // Actions section
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizationManager.actions)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    VStack(spacing: 8) {
                        Button(action: onEdit) {
                            HStack {
                                Image(systemName: "pencil")
                                Text(LocalizationManager.editText)
                                Spacer()
                            }
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(backgroundColor)
                            )
                        }
                        
                        Button(action: onClear) {
                            HStack {
                                Image(systemName: "trash")
                                Text(LocalizationManager.clearText)
                                Spacer()
                            }
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(colorScheme == .dark ? Color.red.opacity(0.3) : Color.red.opacity(0.1))
                            )
                        }
                        
                        Button(action: onUndo) {
                            HStack {
                                Image(systemName: "arrow.uturn.backward")
                                Text(LocalizationManager.undo)
                                Spacer()
                            }
                            .foregroundColor(canUndo ? (colorScheme == .dark ? .white : .black) : .gray)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(canUndo ? backgroundColor : (colorScheme == .dark ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05)))
                            )
                        }
                        .disabled(!canUndo)
                    }
                }
                
                }
                .padding()
            }
            .navigationTitle(LocalizationManager.options)
            #if os(iOS) || os(tvOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationManager.close) {
                        dismiss()
                    }
                }
            }
            #endif
            #endif
        }
    }
}

struct GiantTextView: View {
    @Binding var attributedText: NSAttributedString
    @Binding var fontSize: CGFloat
    let availableSize: CGSize
    @Binding var isEditing: Bool
    @Binding var selectedAnimation: TextAnimation
    @Binding var animationIntensity: Double
    @Binding var isClippingEnabled: Bool
    let useSerifFont: Bool
    let showingWelcomeView: Bool
    #if os(iOS)
    let deviceOrientation: UIDeviceOrientation
    #endif
    @Binding var forceRecalculation: Bool
    let updateDocument: (NSAttributedString) -> Void
    let addToHistory: (NSAttributedString, NSAttributedString) -> Void
    @Environment(\.colorScheme) private var colorScheme
    @State private var isTextFieldFocused: Bool = false
    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
    @State private var isBold: Bool = false
    @State private var isItalic: Bool = false
    @State private var lastKnownSize: CGSize = .zero
    @State private var needsRecalculation: Bool = false
    
    var body: some View {
        ZStack {
            // Background
            #if os(watchOS)
            Rectangle()
                .fill(Color.black) // Always dark mode on watch
            #else
            Rectangle()
                .fill(colorScheme == .dark ? Color.black : Color.white)
            #endif
            
            if isEditing {
                // Rich text editing mode
                #if os(iOS) || os(tvOS) || os(visionOS)
                RichTextEditor(
                    attributedText: $attributedText,
                    selectedRange: $selectedRange,
                    isFocused: Binding(
                        get: { isTextFieldFocused },
                        set: { isTextFieldFocused = $0 }
                    ),
                    colorScheme: colorScheme,
                    selectedAnimation: $selectedAnimation,
                    animationIntensity: $animationIntensity,
                    isBold: $isBold,
                    isItalic: $isItalic,
                    useSerifFont: useSerifFont,
                    onClear: { [self] in
                        let oldText = attributedText
                        attributedText = NSAttributedString(string: "")
                        updateDocument(attributedText)
                        addToHistory(oldText, attributedText)
                    },
                    onDone: {
                        isEditing = false
                        isTextFieldFocused = false
                    },
                    updateDocument: updateDocument,
                    addToHistory: addToHistory
                )
                .onChange(of: selectedRange) { _, _ in
                    updateFormattingState()
                }
                .onAppear {
                    // Only focus the text field if we're not showing the welcome screen
                    if !showingWelcomeView {
                        isTextFieldFocused = true
                    } else {
                        // Ensure text field is not focused when welcome screen is showing
                        isTextFieldFocused = false
                    }
                }
                #elseif os(macOS)
                TextEditor(text: Binding(
                    get: { attributedText.string },
                    set: { newValue in
                        attributedText = NSAttributedString(string: newValue)
                        updateDocument(attributedText)
                        addToHistory(attributedText, attributedText)
                    }
                ))
                .font(.system(size: 48, weight: .regular, design: .default))
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .multilineTextAlignment(.center)
                .onSubmit {
                    isEditing = false
                }
                #endif
            } else {
                // Text display mode with animations
                AnimatedTextDisplay(
                    attributedText: attributedText,
                    fontSize: fontSize,
                    colorScheme: colorScheme,
                    animation: selectedAnimation,
                    intensity: animationIntensity,
                    isClippingEnabled: isClippingEnabled,
                    useSerifFont: useSerifFont
                )
                .accessibilityLabel(LocalizationManager.giantTextDisplay)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(count: 1) {
            if !isEditing {
                // Handle single tap to edit directly
                #if os(iOS)
                // On iPhone, only allow editing in portrait mode
                if deviceOrientation == .portrait {
                    isEditing.toggle()
                } else {
                    // Show portrait-only message
                    // The overlay will handle this visually
                }
                #else
                // On other platforms, allow editing in any orientation
                isEditing.toggle()
                #endif
            }
        }
        .onTapGesture(count: 2) {
            if !isEditing {
                // Handle double tap to edit directly
                #if os(iOS)
                // On iPhone, only allow editing in portrait mode
                if deviceOrientation == .portrait {
                    isEditing.toggle()
                } else {
                    // Show portrait-only message
                    // The overlay will handle this visually
                }
                #else
                // On other platforms, allow editing in any orientation
                isEditing.toggle()
                #endif
            }
        }
        .onAppear {
            lastKnownSize = availableSize
            calculateOptimalFontSize()
        }
        .onChange(of: availableSize) { oldSize, newSize in
            // Detect significant size changes (like rotation)
            let aspectRatioChanged = abs((newSize.width / newSize.height) - (lastKnownSize.width / lastKnownSize.height)) > 0.1
            let significantSizeChange = abs(newSize.width - lastKnownSize.width) > 50 || abs(newSize.height - lastKnownSize.height) > 50
            
            if aspectRatioChanged || significantSizeChange {
                needsRecalculation = true
                lastKnownSize = newSize
                
                // Use a slight delay to ensure geometry is fully updated
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    calculateOptimalFontSize()
                    needsRecalculation = false
                }
            } else {
                lastKnownSize = newSize
                calculateOptimalFontSize()
            }
        }
        .onChange(of: attributedText) { _, _ in
            calculateOptimalFontSize()
        }
        .onChange(of: selectedAnimation) { _, _ in
            calculateOptimalFontSize()
        }
        .onChange(of: animationIntensity) { _, _ in
            calculateOptimalFontSize()
        }
        .onChange(of: useSerifFont) { _, _ in
            calculateOptimalFontSize()
        }
        .onChange(of: forceRecalculation) { _, _ in
            if forceRecalculation {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    calculateOptimalFontSize()
                    forceRecalculation = false
                }
            }
        }
                        .onChange(of: isEditing) { _, newValue in
                    if !newValue {
                        isTextFieldFocused = false
                    }
                }
                .onChange(of: showingWelcomeView) { _, newValue in
                    if newValue {
                        // Unfocus text field when welcome screen appears
                        isTextFieldFocused = false
                        isEditing = false
                    }
                }
    }
    
    private func updateFormattingState() {
        guard selectedRange.length > 0 else {
            isBold = false
            isItalic = false
            return
        }
        #if os(iOS) || os(tvOS) || os(visionOS)
        let font = attributedText.attribute(.font, at: selectedRange.location, effectiveRange: nil) as? UIFont ?? UIFont.systemFont(ofSize: 16)
        isBold = font.fontDescriptor.symbolicTraits.contains(.traitBold)
        isItalic = font.fontDescriptor.symbolicTraits.contains(.traitItalic)
        #elseif os(macOS)
        // NSFont logic for macOS, or just set to false for now
        isBold = false
        isItalic = false
        #endif
    }
    
    func calculateOptimalFontSize() {
        guard !isEditing else { return }
        guard availableSize.width > 0 && availableSize.height > 0 else { return }
        
        let testString = attributedText.string.isEmpty ? "GIANT TEXT" : attributedText.string
        
        // Conservative margins to ensure no truncation and respect safe area
        let animationScaleFactor: CGFloat = selectedAnimation != .none ? 1.4 : 1.0 // Increased scale factor for safety
        let safetyMarginWidth: CGFloat = selectedAnimation != .none ? 0.20 : 0.10 // Increased margin for safe area
        let safetyMarginHeight: CGFloat = selectedAnimation != .none ? 0.20 : 0.10 // Increased margin for safe area
        
        // More conservative available space calculation with safe area consideration
        let safeAvailableWidth = availableSize.width * (1.0 - safetyMarginWidth)
        let safeAvailableHeight = availableSize.height * (1.0 - safetyMarginHeight)
        
        // Use binary search to find the optimal font size with better precision
        var minFontSize: CGFloat = 8.0 // Start with a reasonable minimum
        var maxFontSize: CGFloat = min(safeAvailableWidth, safeAvailableHeight) * 1.5
        var optimalFontSize: CGFloat = minFontSize
        let precision: CGFloat = 0.5 // Better precision for font size search
        
        // Binary search with improved precision
        while maxFontSize - minFontSize > precision {
            let testFontSize = (minFontSize + maxFontSize) / 2.0
            
            #if os(iOS) || os(tvOS) || os(visionOS)
            let testFont = useSerifFont ? 
                UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withFamily("Times New Roman"), size: testFontSize) :
                UIFont.systemFont(ofSize: testFontSize, weight: .bold)
            #elseif os(macOS)
            let testFont = useSerifFont ? 
                NSFont(descriptor: NSFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withFamily("Times New Roman"), size: testFontSize) :
                NSFont.systemFont(ofSize: testFontSize, weight: .bold)
            #else
            // Fallback for other platforms
            break
            #endif
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: testFont,
                .kern: -2.0 // Tighter kerning
            ]
            
            let attributedString = NSAttributedString(string: testString, attributes: attributes)
            
            // Calculate bounding rect with generous constraints to get accurate measurements
            let constraintSize = CGSize(width: safeAvailableWidth * 2, height: safeAvailableHeight * 2)
            let boundingRect = attributedString.boundingRect(
                with: constraintSize,
                options: [.usesLineFragmentOrigin, .usesFontLeading],
                context: nil
            )
            
            // Apply animation scaling if needed
            let finalWidth = boundingRect.width * animationScaleFactor
            let finalHeight = boundingRect.height * animationScaleFactor
            
            // Check if the text fits within the safe available space
            let fitsWidth = finalWidth <= safeAvailableWidth
            let fitsHeight = finalHeight <= safeAvailableHeight
            
            if fitsWidth && fitsHeight {
                // Text fits, try a larger size
                optimalFontSize = testFontSize
                minFontSize = testFontSize + precision
            } else {
                // Text doesn't fit, try a smaller size
                maxFontSize = testFontSize - precision
            }
        }
        
        // Apply final safety check - reduce by additional 10% to ensure safe area compliance
        optimalFontSize *= 0.90
        
        // Ensure we don't go below a minimum readable size
        let minimumReadableSize: CGFloat = 12.0
        let newFontSize = max(optimalFontSize, minimumReadableSize)
        
        // Only update if there's a significant change to avoid unnecessary updates
        if abs(fontSize - newFontSize) > 1.0 {
            fontSize = newFontSize
        }
    }
}

struct AnimatedTextDisplay: View {
    let attributedText: NSAttributedString
    let fontSize: CGFloat
    let colorScheme: ColorScheme
    let animation: TextAnimation
    let intensity: Double
    let isClippingEnabled: Bool
    let useSerifFont: Bool

    
    @State private var animationPhase: Double = 0
    @State private var characterAnimations: [CharacterAnimation] = []
    @State private var animationTimer: Timer?
    @State private var isAnimationActive: Bool = false
    
    var body: some View {
        // Use consistent character-based rendering for ALL animations, including .none
        HStack(spacing: -fontSize * 0.1) { // Allow letters to overlap by 10% of font size
            ForEach(Array(attributedText.string.enumerated()), id: \.offset) { index, character in
                CharacterView(
                    character: character,
                    index: index,
                    totalCharacters: attributedText.string.count,
                    fontSize: fontSize,
                    colorScheme: colorScheme,
                    animation: animation,
                    intensity: intensity,
                    characterAnimation: characterAnimations.indices.contains(index) ? characterAnimations[index] : CharacterAnimation(),
                    isClippingEnabled: isClippingEnabled,
                    useSerifFont: useSerifFont
                )
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped(antialiased: isClippingEnabled)
        .allowsHitTesting(false)
        .onAppear { setupCharacterAnimations() }
        .onChange(of: animation) { _, _ in 
            // Immediately reset and restart animation
            DispatchQueue.main.async {
                setupCharacterAnimations()
            }
        }
        .onChange(of: intensity) { _, _ in 
            // Immediately reset and restart animation with new intensity
            DispatchQueue.main.async {
                setupCharacterAnimations()
            }
        }
        .onChange(of: attributedText) { _, _ in setupCharacterAnimations() }
        .onChange(of: useSerifFont) { _, _ in setupCharacterAnimations() }
        .onDisappear { animationTimer?.invalidate(); animationTimer = nil }
    }
    
    private func setupCharacterAnimations() {
        // Immediately stop any existing animations and reset state
        animationTimer?.invalidate()
        animationTimer = nil
        isAnimationActive = false
        
        // Immediately reset all character animations to default state
        for i in characterAnimations.indices {
            characterAnimations[i] = CharacterAnimation()
        }
        
        // Create fresh character animations array
        characterAnimations = Array(repeating: CharacterAnimation(), count: attributedText.string.count)
        
        // Start new animation based on current settings
        switch animation {
        case .none:
            // No animation timers needed - characters remain at default state (scale: 1.0, offset: .zero, rotation: 0)
            break
        case .ripple:
            startIndividualRippleAnimation()
        case .jitter:
            startIndividualJitterAnimation()
        case .bloom:
            startIndividualBloomAnimation()
        }
    }
    

    
    // MARK: - Normal Mode Animations (for entire text block)
    
    private func startNormalBloomAnimation() {
        let animationDuration = 2.0 / intensity
        let coolOffDuration = 2.0
        let totalCycleDuration = animationDuration + coolOffDuration
        
        isAnimationActive = true
        
        func startNormalBloomCycle() {
            guard isAnimationActive else { return }
            
            withAnimation(.easeInOut(duration: animationDuration)) {
                if characterAnimations.indices.contains(0) {
                    characterAnimations[0].scale = 1.0 + (intensity * 0.3)
                }
            }
            
            // Return to normal size after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
                guard isAnimationActive else { return }
                withAnimation(.easeInOut(duration: animationDuration)) {
                    if characterAnimations.indices.contains(0) {
                        characterAnimations[0].scale = 1.0
                    }
                }
            }
            
            // Schedule next cycle after cool-off period
            animationTimer = Timer.scheduledTimer(withTimeInterval: totalCycleDuration, repeats: false) { _ in
                if isAnimationActive {
                    startNormalBloomCycle()
                }
            }
        }
        
        startNormalBloomCycle()
    }
    
    private func startIndividualJitterAnimation() {
        let jitterDuration: ()->TimeInterval = { .random(in: 0.05...0.1) / intensity }
        let coolOffDuration = 2.0
        let totalCycleDuration = 3.0 + coolOffDuration // 3 seconds of jittering + 2 seconds cool-off
        
        isAnimationActive = true
        
        func startIndividualJitterCycle() {
            guard isAnimationActive else { return }
            
            // Start with current intensity and ease in
            var currentIntensity: Double = 0.0
            let fullJitterDuration = 2.0
            let easeOutDuration = 0.5
            
            // Ease in phase
            Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
                guard isAnimationActive else {
                    timer.invalidate()
                    return
                }
                
                currentIntensity += 0.1
                if currentIntensity >= intensity {
                    currentIntensity = intensity
                    timer.invalidate()
                    
                    // Full jitter phase - animate each character individually
                    let fullJitterTimer = Timer.scheduledTimer(
                        withTimeInterval: jitterDuration(),
                        repeats: true
                    ) { jitterTimer in
                        guard isAnimationActive else {
                            jitterTimer.invalidate()
                            return
                        }
                        
                        let currentMaxOffset = CGFloat(currentIntensity * 8)
                        
                        // Update each character's animation individually
                        for index in characterAnimations.indices {
                            withAnimation(.easeInOut(duration: jitterDuration())) {
                                characterAnimations[index].offset = CGSize(
                                    width: CGFloat.random(in: -currentMaxOffset...currentMaxOffset),
                                    height: CGFloat.random(in: -currentMaxOffset...currentMaxOffset)
                                )
                            }
                        }
                    }
                    
                    // Stop full jitter after duration
                    DispatchQueue.main.asyncAfter(deadline: .now() + fullJitterDuration) {
                        fullJitterTimer.invalidate()
                        
                        // Ease out phase
                        let easeOutTimer = Timer.scheduledTimer(
                            withTimeInterval: 0.05,
                            repeats: true
                        ) { easeOutTimer in
                            guard isAnimationActive else {
                                easeOutTimer.invalidate()
                                return
                            }
                            
                            currentIntensity -= 0.1
                            if currentIntensity <= 0 {
                                currentIntensity = 0
                                easeOutTimer.invalidate()
                                
                                // Reset all characters to normal position
                                withAnimation(.easeInOut(duration: 0.1)) {
                                    for index in characterAnimations.indices {
                                        characterAnimations[index].offset = .zero
                                    }
                                }
                            }
                        }
                        
                        // Stop ease out after duration
                        DispatchQueue.main.asyncAfter(
                            deadline: .now() + easeOutDuration
                        ) {
                            easeOutTimer.invalidate()
                        }
                    }
                }
            }
            
            // Schedule next cycle after cool-off period
            animationTimer = Timer.scheduledTimer(withTimeInterval: totalCycleDuration, repeats: false) { _ in
                if isAnimationActive {
                    startIndividualJitterCycle()
                }
            }
        }
        
        startIndividualJitterCycle()
    }
    
    private func startIndividualRippleAnimation() {
        let jumpUpDuration: TimeInterval = 0.6
        let jumpDownDuration: TimeInterval = 0.5
        let stagger: TimeInterval = 0.05
        let totalLetters = characterAnimations.count
        let totalCycleDuration = (stagger * Double(max(0, totalLetters-1))) + jumpUpDuration + jumpDownDuration + 1.0
        isAnimationActive = true
        
        func animateCycle() {
            guard isAnimationActive else { return }
            for i in 0..<totalLetters {
                let startDelay = stagger * Double(i)
                DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                    guard isAnimationActive else { return }
                    // Jump up
                    withAnimation(.easeOut(duration: jumpUpDuration)) {
                        characterAnimations[i].offset = CGSize(width: 0, height: -intensity * 20)
                    }
                    // Hold
                    DispatchQueue.main.asyncAfter(deadline: .now() + jumpUpDuration) {
                        guard isAnimationActive else { return }
                        // Hold for holdDuration, then jump down
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            guard isAnimationActive else { return }
                            withAnimation(.easeIn(duration: jumpDownDuration)) {
                                characterAnimations[i].offset = .zero
                            }
                        }
                    }
                }
            }
            // Schedule next cycle
            animationTimer = Timer.scheduledTimer(withTimeInterval: totalCycleDuration, repeats: false) { _ in
                if isAnimationActive {
                    animateCycle()
                }
            }
        }
        animateCycle()
    }

    // MARK: - Individual Letter Bloom Animation
    private func startIndividualBloomAnimation() {
        let scaleUpDuration: TimeInterval = 0.6
        let holdDuration: TimeInterval = 0.035
        let scaleDownDuration: TimeInterval = 0.5
        let stagger: TimeInterval = 0.05
        let totalLetters = characterAnimations.count
        let totalCycleDuration = (stagger * Double(max(0, totalLetters-1))) + scaleUpDuration + holdDuration + scaleDownDuration + 0.5
        isAnimationActive = true
        
        func animateCycle() {
            guard isAnimationActive else { return }
            for i in 0..<totalLetters {
                let startDelay = stagger * Double(i)
                DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
                    guard isAnimationActive else { return }
                    // Scale up
                    withAnimation(.easeInOut(duration: scaleUpDuration)) {
                        characterAnimations[i].scale = 1.3
                    }
                    // Hold
                    DispatchQueue.main.asyncAfter(deadline: .now() + scaleUpDuration) {
                        guard isAnimationActive else { return }
                        // Hold for holdDuration, then scale down
                        DispatchQueue.main.asyncAfter(deadline: .now() + holdDuration) {
                            guard isAnimationActive else { return }
                            withAnimation(.easeInOut(duration: scaleDownDuration)) {
                                characterAnimations[i].scale = 1.0
                            }
                        }
                    }
                }
            }
            // Schedule next cycle
            animationTimer = Timer.scheduledTimer(withTimeInterval: totalCycleDuration, repeats: false) { _ in
                if isAnimationActive {
                    animateCycle()
                }
            }
        }
        animateCycle()
    }
}

struct CharacterAnimation {
    var scale: CGFloat = 1.0
    var offset: CGSize = .zero
    var rotation: Double = 0
}

struct CharacterView: View {
    let character: Character
    let index: Int
    let totalCharacters: Int
    let fontSize: CGFloat
    let colorScheme: ColorScheme
    let animation: TextAnimation
    let intensity: Double
    let characterAnimation: CharacterAnimation
    let isClippingEnabled: Bool
    let useSerifFont: Bool
    
    var body: some View {
        Text(String(character))
            .font(useSerifFont ? 
                .system(size: fontSize, weight: .bold, design: .serif) :
                .system(size: fontSize, weight: .bold, design: .default))
            #if os(watchOS)
            .foregroundColor(.white)
            #else
            .foregroundColor(colorScheme == .dark ? .white : .black)
            #endif
            .opacity(0.9) // Set opacity to 90%
            .scaleEffect(characterAnimation.scale)
            .offset(characterAnimation.offset)
            .rotationEffect(.degrees(characterAnimation.rotation))
    }
}

#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var selectedRange: NSRange
    @Binding var isFocused: Bool
    let colorScheme: ColorScheme
    @Binding var selectedAnimation: TextAnimation
    @Binding var animationIntensity: Double
    @Binding var isBold: Bool
    @Binding var isItalic: Bool
    let useSerifFont: Bool
    let onClear: () -> Void
    let onDone: () -> Void
    let updateDocument: (NSAttributedString) -> Void
    let addToHistory: (NSAttributedString, NSAttributedString) -> Void
    
    #if os(tvOS)
    var body: some View {
        VStack {
            // tvOS-compatible text editor
            TextField("", text: Binding(
                get: { attributedText.string },
                set: { newValue in
                    attributedText = NSAttributedString(string: newValue)
                }
            ))
            .font(.system(size: 48, weight: .regular))
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .multilineTextAlignment(.center)
            .textFieldStyle(PlainTextFieldStyle())
            .focused($isFocused)
            .onSubmit {
                onDone()
            }
            
            // tvOS toolbar
            HStack {
                Button(action: {
                    selectedAnimation = selectedAnimation == .none ? .bloom : .none
                }) {
                    Image(systemName: selectedAnimation.icon)
                        .foregroundColor(.blue)
                }
                
                Button(action: {
                    // Toggle bold - simplified for tvOS
                    let mutableText = NSMutableAttributedString(attributedString: attributedText)
                    let font = UIFont.systemFont(ofSize: 16, weight: isBold ? .regular : .bold)
                    mutableText.addAttribute(.font, value: font, range: NSRange(location: 0, length: mutableText.length))
                    attributedText = mutableText
                    isBold.toggle()
                }) {
                    Image(systemName: "bold")
                        .foregroundColor(isBold ? .blue : (colorScheme == .dark ? .white : .black))
                }
                
                Button(action: {
                    // Toggle italic - simplified for tvOS
                    let mutableText = NSMutableAttributedString(attributedString: attributedText)
                    let font = UIFont.italicSystemFont(ofSize: 16)
                    mutableText.addAttribute(.font, value: font, range: NSRange(location: 0, length: mutableText.length))
                    attributedText = mutableText
                    isItalic.toggle()
                }) {
                    Image(systemName: "italic")
                        .foregroundColor(isItalic ? .blue : (colorScheme == .dark ? .white : .black))
                }
                
                Button(action: onClear) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                
                Spacer()
                
                Button(LocalizationManager.done) {
                    onDone()
                }
                .foregroundColor(.blue)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1))
            )
        }
    }
    #else
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textColor = colorScheme == .dark ? .white : .black
        
        // Disable autoresizing mask to prevent constraint conflicts
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // Large, plain font for editing
        let largeFont = useSerifFont ? 
            UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withFamily("Times New Roman"), size: 48) :
            UIFont.systemFont(ofSize: 48, weight: .regular)
        textView.font = largeFont
        
        // Center the text
        textView.textAlignment = .center
        
        textView.isScrollEnabled = true
        textView.isEditable = true
        
        // Add safe area insets to the text view
        textView.contentInset = UIEdgeInsets(
            top: 0,
            left: 0,
            bottom: 0,
            right: 0
        )
        
        // Use actual safe area insets with additional padding
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        let safeAreaInsets = window?.safeAreaInsets ?? UIEdgeInsets.zero
        textView.textContainerInset = UIEdgeInsets(
            top: safeAreaInsets.top + 40, // Top safe area + extra padding
            left: safeAreaInsets.left + 30, // Left safe area + extra padding
            bottom: safeAreaInsets.bottom + 30, // Bottom safe area + extra padding
            right: safeAreaInsets.right + 30  // Right safe area + extra padding
        )
        
        // Convert attributed text to plain text for editing
        let plainText = attributedText.string
        textView.text = plainText
        textView.autocapitalizationType = .allCharacters
        
        // Set up input accessory view
        textView.inputAccessoryView = context.coordinator.createInputAccessoryView()
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Update text if it has changed
        let currentText = uiView.text ?? ""
        let newText = attributedText.string
        if currentText != newText {
            uiView.text = newText
        }
        
        if isFocused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
        } else if !isFocused && uiView.isFirstResponder {
            uiView.resignFirstResponder()
        }
        
        // Update input accessory view
        context.coordinator.updateInputAccessoryView()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
            super.init()
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // Convert plain text back to attributed text with large font
            let plainText = textView.text ?? ""
            let largeFont = UIFont.systemFont(ofSize: 48, weight: .regular)
            let attributedString = NSAttributedString(
                string: plainText,
                attributes: [
                    .font: largeFont,
                    .foregroundColor: parent.colorScheme == .dark ? UIColor.white : UIColor.black
                ]
            )
            
            // Use async to avoid modifying state during view update
            DispatchQueue.main.async {
                self.parent.attributedText = attributedString
            }
        }
        
        func textViewDidChangeSelection(_ textView: UITextView) {
            parent.selectedRange = textView.selectedRange
        }
        
        func createInputAccessoryView() -> UIView {
            // Create a custom container view instead of using UIToolbar
            let containerView = UIView()
            containerView.backgroundColor = parent.colorScheme == .dark ? UIColor.systemGray6 : UIColor.systemGray5
            containerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44)
            
            // Create a horizontal stack view for the buttons
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.alignment = .center
            stackView.spacing = 16
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            // Create buttons
            let animationButton = createButton(
                imageName: parent.selectedAnimation.icon,
                action: #selector(showAnimationMenu),
                tintColor: parent.colorScheme == .dark ? UIColor.white : UIColor.black
            )
            
            let boldButton = createButton(
                imageName: "bold",
                action: #selector(toggleBold),
                tintColor: parent.colorScheme == .dark ? UIColor.white : UIColor.black
            )
            
            let italicButton = createButton(
                imageName: "italic",
                action: #selector(toggleItalic),
                tintColor: parent.colorScheme == .dark ? UIColor.white : UIColor.black
            )
            
            let clearButton = createButton(
                imageName: "trash",
                action: #selector(clearText),
                tintColor: UIColor.red
            )
            
            let doneButton = createButton(
                title: NSLocalizedString("done", comment: "Done button"),
                action: #selector(doneEditing),
                tintColor: UIColor.systemBlue
            )
            
            // Add buttons to stack view
            stackView.addArrangedSubview(animationButton)
            stackView.addArrangedSubview(boldButton)
            stackView.addArrangedSubview(italicButton)
            stackView.addArrangedSubview(UIView()) // Flexible space
            stackView.addArrangedSubview(clearButton)
            stackView.addArrangedSubview(UIView()) // Flexible space
            stackView.addArrangedSubview(doneButton)
            
            // Add stack view to container
            containerView.addSubview(stackView)
            
            // Set up constraints
            NSLayoutConstraint.activate([
                stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
                stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
                stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
                stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
            
            return containerView
        }
        
        private func createButton(imageName: String, action: Selector, tintColor: UIColor) -> UIButton {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: imageName), for: .normal)
            button.tintColor = tintColor
            button.addTarget(self, action: action, for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // Set fixed size for consistent layout
            NSLayoutConstraint.activate([
                button.widthAnchor.constraint(equalToConstant: 44),
                button.heightAnchor.constraint(equalToConstant: 44)
            ])
            
            return button
        }
        
        private func createButton(title: String, action: Selector, tintColor: UIColor) -> UIButton {
            let button = UIButton(type: .system)
            button.setTitle(title, for: .normal)
            button.tintColor = tintColor
            button.addTarget(self, action: action, for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // Set minimum size for text button
            NSLayoutConstraint.activate([
                button.heightAnchor.constraint(equalToConstant: 44),
                button.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
            ])
            
            return button
        }
        
        func updateInputAccessoryView() {
            // Recreate the input accessory view when needed
            // This will be called when the text view updates
        }
        
        @objc func showAnimationMenu() {
            let alertController = UIAlertController(
                title: NSLocalizedString("text_animation", comment: "Text animation menu title"),
                message: nil,
                preferredStyle: .actionSheet
            )
            
            for animation in TextAnimation.allCases {
                let action = UIAlertAction(
                    title: NSLocalizedString(animation.rawValue, comment: "Animation type"),
                    style: .default
                ) { _ in
                    DispatchQueue.main.async {
                        self.parent.selectedAnimation = animation
                    }
                }
                alertController.addAction(action)
            }
            
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("cancel", comment: "Cancel button"),
                style: .cancel
            )
            alertController.addAction(cancelAction)
            
            // Present the alert controller
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first {
                window.rootViewController?.present(alertController, animated: true)
            }
        }
        
        @objc func toggleBold() {
            let mutableText = NSMutableAttributedString(attributedString: parent.attributedText)
            let font = mutableText.attribute(.font, at: parent.selectedRange.location, effectiveRange: nil) as? UIFont ?? UIFont.systemFont(ofSize: 16)
            
            let newFont: UIFont
            if parent.isBold {
                newFont = font.withTraits(.traitBold, removed: true)
            } else {
                newFont = font.withTraits(.traitBold, added: true)
            }
            
            mutableText.addAttribute(.font, value: newFont, range: parent.selectedRange)
            DispatchQueue.main.async {
                self.parent.attributedText = mutableText
            }
        }
        
        @objc func toggleItalic() {
            let mutableText = NSMutableAttributedString(attributedString: parent.attributedText)
            let font = mutableText.attribute(.font, at: parent.selectedRange.location, effectiveRange: nil) as? UIFont ?? UIFont.systemFont(ofSize: 16)
            
            let newFont: UIFont
            if parent.isItalic {
                newFont = font.withTraits(.traitItalic, removed: true)
            } else {
                newFont = font.withTraits(.traitItalic, added: true)
            }
            
            mutableText.addAttribute(.font, value: newFont, range: parent.selectedRange)
            DispatchQueue.main.async {
                self.parent.attributedText = mutableText
            }
        }
        
        @objc func clearText() {
            parent.onClear()
        }
        
        @objc func doneEditing() {
            parent.onDone()
        }
    }
    #endif
}
#endif

// MARK: - Font Extensions
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits, added: Bool = true, removed: Bool = false) -> UIFont {
        var newTraits = fontDescriptor.symbolicTraits
        
        if added {
            newTraits.insert(traits)
        }
        if removed {
            newTraits.remove(traits)
        }
        
        guard let newDescriptor = fontDescriptor.withSymbolicTraits(newTraits) else {
            return self
        }
        
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}
#endif

// MARK: - Shake Detection
#if os(iOS)
extension Notification.Name {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShakeNotification, object: nil)
        }
    }
}
#endif

#Preview {
    ContentView()
        .modelContainer(for: TextDocument.self, inMemory: true)
}



// MARK: - Two Finger Tap View
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
struct TwoFingerTapView: UIViewRepresentable {
    let onTwoFingerTap: () -> Void
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = true
        
        // Two-finger tap gesture
        let twoFingerTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTwoFingerTap))
        twoFingerTapGesture.numberOfTapsRequired = 1
        twoFingerTapGesture.numberOfTouchesRequired = 2
        twoFingerTapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(twoFingerTapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onTwoFingerTap: onTwoFingerTap)
    }
    
    class Coordinator: NSObject {
        let onTwoFingerTap: () -> Void
        
        init(onTwoFingerTap: @escaping () -> Void) {
            self.onTwoFingerTap = onTwoFingerTap
        }
        
        @objc func handleTwoFingerTap() {
            onTwoFingerTap()
        }
    }
}
#endif

// MARK: - Welcome View
#if !os(watchOS)
struct WelcomeView: View {
    let onDismiss: () -> Void
    let onGetStarted: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background overlay
                Color.black.opacity(0.7)
                    .ignoresSafeArea()
                    .onTapGesture {
                        print("🔴 Background overlay tapped - dismissing welcome screen")
                        onDismiss()
                    }
                
                // Main content container with safe area handling
                VStack(spacing: 0) {
                    // Top safe area spacer
                    Color.clear
                        .frame(height: geometry.safeAreaInsets.top)
                    
                    // Main content area with integrated button
                    VStack(spacing: 0) {
                        // Content area that prevents background dismiss
                        VStack(spacing: 0) {
                            // Accessibility identifier for UI testing
                        // Scrollable content area
                        ScrollView {
                            VStack(spacing: 24) {
                                // Content wrapper to prevent gesture conflicts
                                VStack(spacing: 24) {
                                    // Ensure this area can receive touches
                                                            // App icon
                            Image("AppLogo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 80, height: 80)
                                .cornerRadius(16)
                                .accessibilityIdentifier("AppLogo")
                                
                                                            // Title
                            Text("Welcome to Giant Text!")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .accessibilityIdentifier("WelcomeTitle")
                                
                                // Description
                                VStack(spacing: 12) {
                                    Text("Create stunning, animated text displays")
                                        .font(.headline)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                    
                                    Text("• Type your message\n• Choose from multiple animation effects\n• Perfect for sharing short text quickly\n• Works across all your Apple devices")
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
                                }
                                
                                // Quick tips
                                VStack(spacing: 8) {
                                    HStack {
                                        Image(systemName: "hand.tap")
                                            .foregroundColor(.blue)
                                        Text("Single tap to edit text")
                                            .font(.caption)
                                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                                    }
                                    
                                    HStack {
                                        Image(systemName: "hand.tap.fill")
                                            .foregroundColor(.blue)
                                        Text("Two-finger tap for options")
                                            .font(.caption)
                                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                                    }
                                    
                                    HStack {
                                        Image(systemName: "escape")
                                            .foregroundColor(.blue)
                                        Text("Press ESC to close menus")
                                        .font(.caption)
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                                    }
                                }
                                .padding(.top, 8)
                                
                                // Additional content to ensure scrolling
                                VStack(spacing: 16) {
                                    Text("Features:")
                                        .font(.headline)
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        FeatureRow(icon: "textformat.size", title: "Giant Text Display", description: "Create text that fills your screen")
                                        FeatureRow(icon: "sparkles", title: "Animations", description: "Choose from multiple animation effects")
                                        FeatureRow(icon: "iphone", title: "Cross-Platform", description: "Works on iPhone, iPad, Mac, and more")
                                        FeatureRow(icon: "hand.tap", title: "Easy Editing", description: "Tap to edit, two-finger tap for options")
                                    }
                                }
                                .padding(.top, 16)
                                }
                            }
                            .padding(32)
                        }
                        .frame(maxHeight: (geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom) * 0.6) // Reduced height to make room for button
                        .scrollIndicators(.hidden) // Hide scroll indicators
                        .onTapGesture {
                            print("🔵 ScrollView tapped")
                        }
                        
                        // Integrated "Get Started" button
                        Button("Get Started") {
                            print("🟢 Get Started button tapped")
                            onGetStarted()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                        )
                        .padding(.horizontal, 40)
                        .padding(.vertical, 20)
                        .accessibilityIdentifier("GetStartedButton")
                        .onTapGesture {
                            print("🟣 Get Started button container tapped")
                        }
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .shadow(radius: 30)
                    )
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20) // Account for bottom safe area
                    .contentShape(Rectangle()) // Ensure the content area is properly tappable
                    .accessibilityIdentifier("WelcomeView")
                    .onTapGesture {
                        print("🟡 Welcome screen content area tapped")
                    }
                }
            }
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.3), value: true)
    }
}
#endif

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20, height: 20)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

