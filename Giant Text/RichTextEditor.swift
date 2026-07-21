//
//  RichTextEditor.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#endif

#if os(tvOS)
struct RichTextEditor: View {
    @Binding var attributedText: NSAttributedString
    @Binding var selectedRange: NSRange
    @Binding var isFocused: Bool
    let colorScheme: ColorScheme
    let theme: ColorTheme
    @Binding var selectedAnimation: TextAnimation
    @Binding var animationIntensity: Double
    @Binding var isBold: Bool
    @Binding var isItalicized: Bool
    let useSerifFont: Bool
    let onClear: () -> Void
    let onDone: () -> Void
    let updateDocument: (NSAttributedString) -> Void
    let addToHistory: (NSAttributedString, NSAttributedString) -> Void

    var body: some View {
        VStack {
            // tvOS-compatible text editor
            TextField("", text: Binding(
                get: { attributedText.string },
                set: { newValue in
                    attributedText = NSAttributedString(string: newValue)
                }
            ))
            .font(useSerifFont ? .custom("Times New Roman", size: 48) : .system(size: 48, weight: .regular))
            .foregroundColor(theme.textColor(for: colorScheme))
            .multilineTextAlignment(.center)
            .textFieldStyle(PlainTextFieldStyle())
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
                        .foregroundColor(isBold ? .blue : theme.textColor(for: colorScheme))
                }

                Button(action: {
                    // Toggle italic - simplified for tvOS
                    let mutableText = NSMutableAttributedString(attributedString: attributedText)
                    let font = UIFont.italicSystemFont(ofSize: 16)
                    mutableText.addAttribute(.font, value: font, range: NSRange(location: 0, length: mutableText.length))
                    attributedText = mutableText
                    isItalicized.toggle()
                }) {
                    Image(systemName: "italic")
                        .foregroundColor(isItalicized ? .blue : theme.textColor(for: colorScheme))
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
}
#elseif os(iOS) || os(watchOS) || os(visionOS)
struct RichTextEditor: UIViewRepresentable {
    @Binding var attributedText: NSAttributedString
    @Binding var selectedRange: NSRange
    @Binding var isFocused: Bool
    let colorScheme: ColorScheme
    let theme: ColorTheme
    @Binding var selectedAnimation: TextAnimation
    @Binding var animationIntensity: Double
    @Binding var isBold: Bool
    @Binding var isItalicized: Bool
    let useSerifFont: Bool
    let onClear: () -> Void
    let onDone: () -> Void
    let updateDocument: (NSAttributedString) -> Void
    let addToHistory: (NSAttributedString, NSAttributedString) -> Void

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textColor = UIColor(theme.textColor(for: colorScheme))
        
        // Disable autoresizing mask to prevent constraint conflicts
        textView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create the appropriate font based on formatting state
        let largeFont = createFontForCurrentState()
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
        
        // Set up input accessory view (visionOS has no input accessory views)
        #if !os(visionOS)
        textView.inputAccessoryView = context.coordinator.createInputAccessoryView()
        #endif

        // Store reference to text view in coordinator
        context.coordinator.textView = textView
        
        return textView
    }
    
    private func createFontForCurrentState() -> UIFont {
        if useSerifFont {
            // Use system serif font to match the display font
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
                .withDesign(.serif)?
                .withSymbolicTraits(getSymbolicTraits()) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
            return UIFont(descriptor: descriptor, size: 48)
        } else {
            // Use system font
            let descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
                .withSymbolicTraits(getSymbolicTraits()) ?? UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
            return UIFont(descriptor: descriptor, size: 48)
        }
    }

    private func getSymbolicTraits() -> UIFontDescriptor.SymbolicTraits {
        var traits: UIFontDescriptor.SymbolicTraits = []
        if isBold {
            traits.insert(.traitBold)
        }
        if isItalicized {
            traits.insert(.traitItalic)
        }
        return traits
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        // Update text if it has changed
        let currentText = uiView.text ?? ""
        let newText = attributedText.string
        if currentText != newText {
            uiView.text = newText
        }

        // Always update font when useSerifFont changes or formatting state changes
        let newFont = createFontForCurrentState()
        uiView.font = newFont

        // Update text color to reflect theme and color scheme changes
        uiView.textColor = UIColor(theme.textColor(for: colorScheme))

        if isFocused && !uiView.isFirstResponder {
            uiView.becomeFirstResponder()
            context.coordinator.startFormattingCheckTimer()
        } else if !isFocused && uiView.isFirstResponder {
            uiView.resignFirstResponder()
            context.coordinator.stopFormattingCheckTimer()
        }

        // Update textView reference
        context.coordinator.textView = uiView

        // Update input accessory view to reflect current formatting state
        context.coordinator.updateInputAccessoryView()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: RichTextEditor
        var textView: UITextView?
        private var previousIsBold: Bool = false
        private var previousIsItalicized: Bool = false
        private var formattingCheckTimer: Timer?
        
        init(_ parent: RichTextEditor) {
            self.parent = parent
            self.previousIsBold = parent.isBold
            self.previousIsItalicized = parent.isItalicized
            super.init()
        }

        deinit {
            formattingCheckTimer?.invalidate()
        }

        func startFormattingCheckTimer() {
            // Only start timer if not already running
            guard formattingCheckTimer == nil else { return }
            formattingCheckTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
                self?.checkFormattingStateChanges()
            }
        }

        func stopFormattingCheckTimer() {
            formattingCheckTimer?.invalidate()
            formattingCheckTimer = nil
        }
        
        func textViewDidChange(_ textView: UITextView) {
            // Get the new plain text
            var plainText = textView.text ?? ""

            // Enforce 500 character limit
            let maxCharacters = 500
            if plainText.count > maxCharacters {
                plainText = String(plainText.prefix(maxCharacters))
                textView.text = plainText
            }

            // Create the appropriate font based on current formatting state and serif font setting
            let font = parent.createFontForCurrentState()

            // Create attributed string with the appropriate font
            let attributedString = NSAttributedString(
                string: plainText,
                attributes: [
                    .font: font,
                    .foregroundColor: UIColor(parent.theme.textColor(for: parent.colorScheme))
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
            containerView.backgroundColor = UIColor(parent.theme.backgroundColor(for: parent.colorScheme)).withAlphaComponent(0.95)
            // UIKit stretches an input accessory view to the input view's width,
            // so only the height here is meaningful.
            containerView.frame = CGRect(x: 0, y: 0, width: 320, height: 44)
            
            // Create a horizontal stack view for the buttons
            let stackView = UIStackView()
            stackView.axis = .horizontal
            stackView.distribution = .fill
            stackView.alignment = .center
            stackView.spacing = 16
            stackView.translatesAutoresizingMaskIntoConstraints = false
            
            // Create buttons
            let animationButton = createButton(
                imageName: "play.circle.fill",
                action: #selector(showAnimationMenu),
                tintColor: UIColor(parent.theme.textColor(for: parent.colorScheme))
            )

            let boldButton = createButton(
                imageName: "bold",
                action: #selector(toggleBold),
                tintColor: parent.isBold ? UIColor.systemBlue : UIColor(parent.theme.textColor(for: parent.colorScheme)),
                isUnderlined: parent.isBold
            )

            let italicButton = createButton(
                imageName: "italic",
                action: #selector(toggleItalic),
                tintColor: parent.isItalicized ? UIColor.systemBlue : UIColor(parent.theme.textColor(for: parent.colorScheme)),
                isUnderlined: parent.isItalicized
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
        
        private func createButton(imageName: String, action: Selector, tintColor: UIColor, isUnderlined: Bool = false) -> UIButton {
            let button = UIButton(type: .system)
            button.setImage(UIImage(systemName: imageName), for: .normal)
            button.tintColor = tintColor
            button.addTarget(self, action: action, for: .touchUpInside)
            button.translatesAutoresizingMaskIntoConstraints = false
            
            // Add underline if specified
            if isUnderlined {
                let underline = UIView()
                underline.backgroundColor = tintColor
                underline.translatesAutoresizingMaskIntoConstraints = false
                button.addSubview(underline)
                
                NSLayoutConstraint.activate([
                    underline.leadingAnchor.constraint(equalTo: button.leadingAnchor, constant: 4),
                    underline.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -4),
                    underline.bottomAnchor.constraint(equalTo: button.bottomAnchor, constant: -2),
                    underline.heightAnchor.constraint(equalToConstant: 2)
                ])
            }
            
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
            // Update previous state
            previousIsBold = parent.isBold
            previousIsItalicized = parent.isItalicized
            
            // Recreate the input accessory view to reflect the new state
            #if !os(visionOS)
            if let textView = textView {
                textView.inputAccessoryView = createInputAccessoryView()
                textView.reloadInputViews()
            }
            #endif
        }
        
        func forceInputAccessoryViewUpdate() {
            updateInputAccessoryView()
        }
        
        private func checkFormattingStateChanges() {
            // Only check for changes if the text view is active
            guard let textView = textView, textView.isFirstResponder else { return }
            
            let boldChanged = previousIsBold != parent.isBold
            let italicChanged = previousIsItalicized != parent.isItalicized
            
            if boldChanged || italicChanged {
                DispatchQueue.main.async {
                    self.updateInputAccessoryView()
                }
            }
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
                    DispatchQueue.main.async { [weak self] in
                        guard let self else { return }
                        parent.selectedAnimation = animation
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
            // Save current state to history before toggling
            let oldText = parent.attributedText

            // Simply toggle the bold state
            DispatchQueue.main.async {
                self.parent.isBold.toggle()
                self.updateInputAccessoryView()

                // Update the attributed text with new formatting
                if let textView = self.textView {
                    let newFont = self.parent.createFontForCurrentState()
                    let newText = NSAttributedString(
                        string: textView.text ?? "",
                        attributes: [
                            .font: newFont,
                            .foregroundColor: UIColor(self.parent.theme.textColor(for: self.parent.colorScheme))
                        ]
                    )
                    self.parent.attributedText = newText
                    self.parent.addToHistory(oldText, newText)
                    self.parent.updateDocument(newText)
                }
            }
        }

        @objc func toggleItalic() {
            // Save current state to history before toggling
            let oldText = parent.attributedText

            // Simply toggle the italic state
            DispatchQueue.main.async {
                self.parent.isItalicized.toggle()
                self.updateInputAccessoryView()

                // Update the attributed text with new formatting
                if let textView = self.textView {
                    let newFont = self.parent.createFontForCurrentState()
                    let newText = NSAttributedString(
                        string: textView.text ?? "",
                        attributes: [
                            .font: newFont,
                            .foregroundColor: UIColor(self.parent.theme.textColor(for: self.parent.colorScheme))
                        ]
                    )
                    self.parent.attributedText = newText
                    self.parent.addToHistory(oldText, newText)
                    self.parent.updateDocument(newText)
                }
            }
        }
        
        @objc func clearText() {
            parent.onClear()
        }
        
        @objc func doneEditing() {
            parent.onDone()
        }
    }
}
#endif 
