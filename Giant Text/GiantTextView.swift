//
//  GiantTextView.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#endif

//struct GiantTextView: View {
//    @Binding var attributedText: NSAttributedString
//    @Binding var fontSize: CGFloat
//    let availableSize: CGSize
//    @Binding var isEditing: Bool
//    @Binding var selectedAnimation: TextAnimation
//    @Binding var animationIntensity: Double
//    @Binding var isClippingEnabled: Bool
//    let useSerifFont: Bool
//    let kerning: Double
//    let showingWelcomeView: Bool
//    #if os(iOS)
//    let deviceOrientation: UIDeviceOrientation
//    #endif
//    @Binding var forceRecalculation: Bool
//    @Binding var isBold: Bool
//    @Binding var isItalicized: Bool
//    let updateDocument: (NSAttributedString) -> Void
//    let addToHistory: (NSAttributedString, NSAttributedString) -> Void
//    @Environment(\.colorScheme) private var colorScheme
//    @State private var isTextFieldFocused: Bool = false
//    @State private var selectedRange: NSRange = NSRange(location: 0, length: 0)
//    @State private var lastKnownSize: CGSize = .zero
//    @State private var needsRecalculation: Bool = false
//    @State private var isCalculating: Bool = false
//    @State private var pendingRecalculation: Bool = false
//    
//    // MARK: - Computed Properties
//    private var adjustedAvailableSize: CGSize {
//        // Use available size directly - SwiftUI's GeometryReader already provides
//        // the correct dimensions based on the current view orientation
//        return availableSize
//    }
//    
//    var body: some View {
//        ZStack {
//            // Background
//            #if os(watchOS)
//            Rectangle()
//                .fill(Color.black) // Always dark mode on watch
//            #else
//            Rectangle()
//                .fill(colorScheme == .dark ? Color.black : Color.white)
//            #endif
//            
//            if isEditing {
//                // Rich text editing mode
//                #if os(iOS) || os(tvOS) || os(visionOS)
//                RichTextEditor(
//                    attributedText: $attributedText,
//                    selectedRange: $selectedRange,
//                    isFocused: Binding(
//                        get: { isTextFieldFocused },
//                        set: { isTextFieldFocused = $0 }
//                    ),
//                    colorScheme: colorScheme,
//                    selectedAnimation: $selectedAnimation,
//                    animationIntensity: $animationIntensity,
//                    isBold: $isBold,
//                    isItalicized: $isItalicized,
//                    useSerifFont: useSerifFont,
//                    onClear: { [self] in
//                        let oldText = attributedText
//                        attributedText = NSAttributedString(string: "")
//                        updateDocument(attributedText)
//                        addToHistory(oldText, attributedText)
//                    },
//                    onDone: {
//                        isEditing = false
//                        isTextFieldFocused = false
//                    },
//                    updateDocument: updateDocument,
//                    addToHistory: addToHistory
//                )
//                .onChange(of: selectedRange) { _, _ in
//                    // No longer need to update formatting state here
//                }
//                .onAppear {
//                    // Only focus the text field if we're not showing the welcome screen
//                    if !showingWelcomeView {
//                        isTextFieldFocused = true
//                    } else {
//                        // Ensure text field is not focused when welcome screen is showing
//                        isTextFieldFocused = false
//                    }
//                }
//                #elseif os(macOS)
//                TextEditor(text: Binding(
//                    get: { attributedText.string },
//                    set: { newValue in
//                        attributedText = NSAttributedString(string: newValue)
//                        updateDocument(attributedText)
//                        addToHistory(attributedText, attributedText)
//                    }
//                ))
//                .font(useSerifFont ? .custom("Times New Roman", size: 48) : .system(size: 48, weight: .regular, design: .default))
//                .foregroundColor(colorScheme == .dark ? .white : .black)
//                .multilineTextAlignment(.center)
//                .onSubmit {
//                    isEditing = false
//                }
//                #endif
//            } else {
//                // Text display mode with animations
//                AnimatedTextDisplay(
//                    attributedText: attributedText,
//                    fontSize: fontSize,
//                    colorScheme: colorScheme,
//                    animation: selectedAnimation,
//                    intensity: animationIntensity,
//                    isClippingEnabled: isClippingEnabled,
//                    useSerifFont: useSerifFont,
//                    kerning: kerning,
//                    isBold: isBold,
//                    isItalicized: isItalicized
//                )
//                .accessibilityLabel(LocalizationManager.giantTextDisplay)
//            }
//        }
//        .contentShape(Rectangle())
//        .onTapGesture(count: 1) {
//            if !isEditing {
//                // Handle single tap to edit directly
//                isEditing.toggle()
//            }
//        }
//        .onTapGesture(count: 2) {
//            if !isEditing {
//                // Handle double tap to edit directly
//                isEditing.toggle()
//            }
//        }
//        .onAppear {
//            lastKnownSize = adjustedAvailableSize
//            calculateOptimalFontSize()
//            // updateFormattingState() // No longer needed
//        }
//        .onChange(of: adjustedAvailableSize) { oldSize, newSize in
//            // Detect significant size changes (like rotation)
//            let aspectRatioChanged = abs((newSize.width / newSize.height) - (lastKnownSize.width / lastKnownSize.height)) > 0.1
//            let significantSizeChange = abs(newSize.width - lastKnownSize.width) > 50 || abs(newSize.height - lastKnownSize.height) > 50
//            
//            if aspectRatioChanged || significantSizeChange {
//                needsRecalculation = true
//                lastKnownSize = newSize
//                
//                // Use a slight delay to ensure geometry is fully updated
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
//                    calculateOptimalFontSize()
//                    needsRecalculation = false
//                }
//            } else {
//                lastKnownSize = newSize
//                calculateOptimalFontSize()
//            }
//        }
//        .onChange(of: attributedText) { _, _ in
//            calculateOptimalFontSize()
//            // updateFormattingState() // No longer needed
//        }
//        .onChange(of: selectedAnimation) { _, _ in
//            calculateOptimalFontSize()
//        }
//        .onChange(of: animationIntensity) { _, _ in
//            calculateOptimalFontSize()
//        }
//        .onChange(of: useSerifFont) { _, _ in
//            calculateOptimalFontSize()
//        }
//        .onChange(of: forceRecalculation) { _, _ in
//            if forceRecalculation {
//                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//                    calculateOptimalFontSize()
//                    forceRecalculation = false
//                }
//            }
//        }
//        .onChange(of: isEditing) { _, newValue in
//            if !newValue {
//                isTextFieldFocused = false
//            }
//        }
//        .onChange(of: showingWelcomeView) { _, newValue in
//            if newValue {
//                // Unfocus text field when welcome screen appears
//                isTextFieldFocused = false
//                isEditing = false
//            }
//        }
//    }
//    
//    func calculateOptimalFontSize() {
//        guard !isEditing else { return }
//        guard adjustedAvailableSize.width > 0 && adjustedAvailableSize.height > 0 else { return }
//
//        // If already calculating, mark that we need another recalculation after this one finishes
//        if isCalculating {
//            pendingRecalculation = true
//            return
//        }
//
//        isCalculating = true
//        pendingRecalculation = false
//
//        let testString = attributedText.string.isEmpty ? "GIANT TEXT" : attributedText.string
//        
//        // Conservative margins to ensure no truncation and respect safe area
//        let animationScaleFactor: CGFloat = selectedAnimation != .none ? 1.4 : 1.0 // Increased scale factor for safety
//        let safetyMarginWidth: CGFloat = selectedAnimation != .none ? 0.20 : 0.10 // Increased margin for safe area
//        let safetyMarginHeight: CGFloat = selectedAnimation != .none ? 0.20 : 0.10 // Increased margin for safe area
//        
//        // More conservative available space calculation with safe area consideration
//        let safeAvailableWidth = adjustedAvailableSize.width * (1.0 - safetyMarginWidth)
//        let safeAvailableHeight = adjustedAvailableSize.height * (1.0 - safetyMarginHeight)
//        
//        // Use binary search to find the optimal font size with better precision
//        var minFontSize: CGFloat = 8.0 // Start with a reasonable minimum
//        var maxFontSize: CGFloat = min(safeAvailableWidth, safeAvailableHeight) * 1.5
//        var optimalFontSize: CGFloat = minFontSize
//        let precision: CGFloat = 0.5 // Better precision for font size search
//        
//        // Binary search with improved precision
//        while maxFontSize - minFontSize > precision {
//            let testFontSize = (minFontSize + maxFontSize) / 2.0
//            
//            #if os(iOS) || os(tvOS) || os(visionOS)
//            let testFont = useSerifFont ? 
//                UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withFamily("Times New Roman"), size: testFontSize) :
//                UIFont.systemFont(ofSize: testFontSize, weight: .bold)
//            #elseif os(macOS)
//            let testFont = useSerifFont ? 
//                NSFont(descriptor: NSFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withFamily("Times New Roman"), size: testFontSize) :
//                NSFont.systemFont(ofSize: testFontSize, weight: .bold)
//            #else
//            // Fallback for other platforms
//            break
//            #endif
//            
//            let attributes: [NSAttributedString.Key: Any] = [
//                .font: testFont,
//                .kern: -2.0 // Tighter kerning
//            ]
//            
//            let attributedString = NSAttributedString(string: testString, attributes: attributes)
//            
//            // Calculate bounding rect with generous constraints to get accurate measurements
//            let constraintSize = CGSize(width: safeAvailableWidth * 2, height: safeAvailableHeight * 2)
//            let boundingRect = attributedString.boundingRect(
//                with: constraintSize,
//                options: [.usesLineFragmentOrigin, .usesFontLeading],
//                context: nil
//            )
//            
//            // Apply animation scaling if needed
//            let finalWidth = boundingRect.width * animationScaleFactor
//            let finalHeight = boundingRect.height * animationScaleFactor
//            
//            // Check if the text fits within the safe available space
//            let fitsWidth = finalWidth <= safeAvailableWidth
//            let fitsHeight = finalHeight <= safeAvailableHeight
//            
//            if fitsWidth && fitsHeight {
//                // Text fits, try a larger size
//                optimalFontSize = testFontSize
//                minFontSize = testFontSize + precision
//            } else {
//                // Text doesn't fit, try a smaller size
//                maxFontSize = testFontSize - precision
//            }
//        }
//        
//        // Apply final safety check - reduce by additional 10% to ensure safe area compliance
//        optimalFontSize *= 0.90
//        
//        // Ensure we don't go below a minimum readable size
//        let minimumReadableSize: CGFloat = 12.0
//        let newFontSize = max(optimalFontSize, minimumReadableSize)
//        
//        // Only update if there's a significant change to avoid unnecessary updates
//        if abs(fontSize - newFontSize) > 1.0 {
//            fontSize = newFontSize
//        }
//
//        // Mark calculation as complete
//        isCalculating = false
//
//        // If there was a pending recalculation request, perform it now
//        if pendingRecalculation {
//            pendingRecalculation = false
//            // Schedule on next run loop to avoid stack overflow
//            DispatchQueue.main.async {
//                self.calculateOptimalFontSize()
//            }
//        }
//    }
//} 
