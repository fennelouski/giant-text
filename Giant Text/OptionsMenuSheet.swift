//
//  OptionsMenuSheet.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI

struct OptionsMenuSheet: View {
    @Binding var selectedAnimation: TextAnimation
    @Binding var animationIntensity: Double
    @Binding var showingMarqueeTooltip: Bool
    @Binding var isClippingEnabled: Bool
    @Binding var useSerifFont: Bool
    @Binding var kerning: Double
    @Binding var maxLines: Int
    @Binding var selectedThemeId: String
    @Binding var useRandomTheme: Bool
    @Binding var appearanceMode: AppearanceMode
    @Binding var textRotation: TextRotation
    let onEdit: () -> Void
    let onClear: () -> Void
    let onUndo: () -> Void
    let canUndo: Bool
    let currentTheme: ColorTheme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .body) private var controlMinimumWidth: CGFloat = 64
    #if DEBUG
    @State private var isThemeSectionExpanded: Bool =
        ProcessInfo.processInfo.arguments.contains("--ss-expand-theme")
    #else
    @State private var isThemeSectionExpanded: Bool = false
    #endif
    
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

    private func themeBackgroundColor(for theme: ColorTheme) -> Color {
        if selectedThemeId == theme.id {
            return colorScheme == .dark ? Color.blue.opacity(0.3) : Color.blue.opacity(0.1)
        } else {
            return colorScheme == .dark ? Color.gray.opacity(0.3) : Color.gray.opacity(0.1)
        }
    }

    // A live "Aa" swatch rendered in the theme's own colors so each option
    // previews exactly how the giant text will look.
    @ViewBuilder
    private func themePreview(_ theme: ColorTheme, height: CGFloat) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(theme.backgroundColor(for: colorScheme))

            Text("Aa")
                .font(.system(size: height * 0.45, weight: .semibold, design: .serif))
                .foregroundColor(theme.textColor(for: colorScheme))

            if selectedThemeId == theme.id {
                VStack {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 15))
                            .foregroundStyle(.white, .blue)
                            .padding(5)
                    }
                    Spacer()
                }
            }
        }
        .frame(height: height)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(Color.primary.opacity(0.12), lineWidth: 1)
        )
    }

    private var settingsRowLayout: AnyLayout {
        dynamicTypeSize.isAccessibilitySize
            ? AnyLayout(VStackLayout(alignment: .leading, spacing: 8))
            : AnyLayout(HStackLayout())
    }

    private var actionButtons: some View {
        HStack(spacing: 16) {
            Button(action: onEdit) {
                Label(LocalizationManager.editText, systemImage: "pencil")
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .help(LocalizationManager.editText)
            Button(action: onUndo) {
                Label(LocalizationManager.undo, systemImage: "arrow.uturn.backward")
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .disabled(!canUndo)
            .help(LocalizationManager.undo)
            Button(role: .destructive, action: onClear) {
                Label(LocalizationManager.clearText, systemImage: "trash")
                    .labelStyle(.iconOnly)
                    .frame(minWidth: 44, minHeight: 44)
            }
            .help(LocalizationManager.clearText)
        }
        .font(.system(size: 22))
        .buttonStyle(.bordered)
        .frame(maxWidth: .infinity)
    }

    var body: some View {
        NavigationStack {

            #if os(tvOS)
            ScrollView {
                VStack(spacing: 32) {
                    HStack(spacing: 16) {
                        Text("Settings").font(.headline)
                        Spacer()
                        NavigationLink {
                            ControlsHelpView()
                        } label: {
                            Image(systemName: "questionmark.circle")
                                .font(.system(size: 30))
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel(Text("Help"))
                        .accessibilityIdentifier("SettingsHelpButton")
                        Button { dismiss() } label: {
                            Image(systemName: "xmark")
                                .font(.system(size: 30))
                                .frame(width: 44, height: 44)
                        }
                        .accessibilityLabel(Text(LocalizationManager.close))
                        .accessibilityIdentifier("CloseSettingsButton")
                    }
                    HStack(spacing: 16) {
                        ForEach(TextAnimation.allCases, id: \.self) { animation in
                            Button { selectedAnimation = animation } label: {
                                Image(systemName: animation.icon)
                                    .font(.system(size: 30))
                                    .frame(width: 44, height: 44)
                            }
                            .accessibilityLabel(Text(animation.localizedName))
                            .tint(selectedAnimation == animation ? .blue : .primary)
                            .accessibilityAddTraits(selectedAnimation == animation ? .isSelected : [])
                        }
                    }
                    actionButtons
                }
                .padding(24)
            }
            #elseif os(watchOS)
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
                                .accessibilityLabel(LocalizationManager.intensity)
                                .tint(.blue)
                        }
                    }
                    
                    actionButtons
                }
                .padding()
            }
            .navigationTitle(LocalizationManager.options)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        ControlsHelpView()
                    } label: {
                        Label("Help", systemImage: "questionmark.circle")
                            .labelStyle(.iconOnly)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .help("Help")
                    .accessibilityIdentifier("SettingsHelpButton")
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { dismiss() } label: {
                        Label(LocalizationManager.close, systemImage: "xmark")
                            .labelStyle(.iconOnly)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .help(LocalizationManager.close)
                    .accessibilityIdentifier("CloseSettingsButton")
                }
            }
            #else
            ScrollView {
                VStack(spacing: 20) {
                
                // Animation section (moved to top)
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizationManager.animation)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: controlMinimumWidth))], spacing: 12) {
                        ForEach(TextAnimation.allCases, id: \.self) { animation in
                            Button(action: {
                                selectedAnimation = animation
                            }) {
                                Label(animation.localizedName, systemImage: animation.icon)
                                    .labelStyle(.iconOnly)
                                    .foregroundColor(textColor(for: animation))
                                    .frame(minHeight: 44)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(animationBackgroundColor(for: animation))
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(
                                            selectedAnimation == animation ? Color.blue : Color.clear,
                                            lineWidth: 2
                                        )
                                )
                            }
                            .buttonStyle(.plain)
                            .help(animation.localizedName)
                            .accessibilityAddTraits(selectedAnimation == animation ? .isSelected : [])
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
                                .accessibilityLabel(LocalizationManager.intensity)
                                .tint(.blue)
                        }
                        .padding(.top, 8)
                    }
                }

                // Theme section (collapsible)
                DisclosureGroup(
                    isExpanded: $isThemeSectionExpanded,
                    content: {
                        VStack(alignment: .leading, spacing: 12) {
                            // Random theme toggle
                            HStack {
                                Toggle(LocalizationManager.randomThemeDaily, isOn: $useRandomTheme)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(backgroundColor)
                            )

                            if !useRandomTheme {
                                // Theme grid
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                                    ForEach(ColorTheme.allThemes) { theme in
                                        Button(action: {
                                            selectedThemeId = theme.id
                                        }) {
                                            themePreview(theme, height: 52)
                                            .padding(8)
                                            .frame(maxWidth: .infinity)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(themeBackgroundColor(for: theme))
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .strokeBorder(
                                                        selectedThemeId == theme.id ? Color.blue : Color.clear,
                                                        lineWidth: 2
                                                    )
                                            )
                                        }
                                        .buttonStyle(.plain)
                                        .accessibilityLabel(theme.name)
                                        .accessibilityAddTraits(selectedThemeId == theme.id ? .isSelected : [])
                                        .help(theme.name)
                                    }
                                }
                            } else {
                                // Show current random theme
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text(LocalizationManager.currentTheme)
                                            .foregroundColor(colorScheme == .dark ? .white : .black)
                                        Spacer()
                                        Text(currentTheme.name)
                                            .foregroundColor(.blue)
                                    }
                                    themePreview(currentTheme, height: 56)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(backgroundColor)
                                )
                            }
                        }
                        .padding(.top, 8)
                    },
                    label: {
                        Text(LocalizationManager.themeSection)
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                )

                // Display settings section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(LocalizationManager.display)
                            .font(.headline)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                        Spacer()
                    }

                    // Appearance mode picker
                    VStack(alignment: .leading, spacing: 8) {
                        settingsRowLayout {
                            Text(LocalizationManager.appearance)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Picker(LocalizationManager.appearance, selection: $appearanceMode) {
                                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                    Text(mode.localizedName).tag(mode)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                    )

                    #if !os(tvOS)
                    // Text rotation picker (not available on tvOS)
                    VStack(alignment: .leading, spacing: 8) {
                        settingsRowLayout {
                            Text(LocalizationManager.textRotation)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Picker(LocalizationManager.textRotation, selection: $textRotation) {
                                ForEach(TextRotation.allCases, id: \.self) { rotation in
                                    Text(rotation.localizedName).tag(rotation)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                    )
                    #endif

                    // Font selection toggle
                    HStack {
                        Toggle(LocalizationManager.serifFont, isOn: $useSerifFont)
                            .foregroundColor(colorScheme == .dark ? .white : .black)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                    )
                    
                    // Kerning slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(LocalizationManager.letterSpacing)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Text("\(Int(kerning))")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        Slider(value: $kerning, in: -10...30)
                            .accessibilityLabel(LocalizationManager.letterSpacing)
                            .tint(.blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                    )

                    // Max lines picker
                    VStack(alignment: .leading, spacing: 8) {
                        settingsRowLayout {
                            Text(LocalizationManager.maxLines)
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Picker(LocalizationManager.maxLines, selection: $maxLines) {
                                ForEach(1...5, id: \.self) { lines in
                                    Text("\(lines)").tag(lines)
                                }
                            }
                            .pickerStyle(.menu)
                            .labelsHidden()
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                    )
                }
                
                actionButtons
                
                }
                .frame(maxWidth: 680)
                .padding()
                .frame(maxWidth: .infinity)
            }
            .navigationTitle(LocalizationManager.options)
            #if os(iOS) || os(visionOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink {
                        ControlsHelpView()
                    } label: {
                        Label("Help", systemImage: "questionmark.circle")
                            .labelStyle(.iconOnly)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .help("Help")
                    .accessibilityIdentifier("SettingsHelpButton")
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Label(LocalizationManager.close, systemImage: "xmark")
                            .labelStyle(.iconOnly)
                            .frame(minWidth: 44, minHeight: 44)
                    }
                    .help(LocalizationManager.close)
                    .accessibilityIdentifier("CloseSettingsButton")
                }
            }
            #endif
        }
    }
}

struct ControlsHelpView: View {
    var body: some View {
        List {
            Section("Controls") {
                helpRow(LocalizationManager.options, icon: "ellipsis", detail: "Open editing actions, Settings, and Help.")
                helpRow(LocalizationManager.editText, icon: "pencil", detail: "Edit the message shown on the display.")
                helpRow(LocalizationManager.done, icon: "checkmark", detail: "Finish editing and show your giant text.")
                helpRow(LocalizationManager.undo, icon: "arrow.uturn.backward", detail: "Restore the previous text. Available after a change.")
                helpRow(LocalizationManager.clearText, icon: "trash", detail: "Erase the message and start typing a new one.")
                helpRow("Settings", icon: "slider.horizontal.3", detail: "Adjust how your text appears.")
                helpRow("Help", icon: "questionmark.circle", detail: "Show this guide to the controls.")
                helpRow(LocalizationManager.close, icon: "xmark", detail: "Close the current panel.")
                helpRow(LocalizationManager.getStartedButton, icon: "arrow.right", detail: "Leave the welcome screen and start your message.")
                #if os(visionOS)
                helpRow("Open live display", icon: "rectangle.on.rectangle", detail: "Open another sign window that follows your message and styling.")
                helpRow("Present text", icon: "textformat.size", detail: "Switch from the editor to the giant text display.")
                #endif
            }
            #if os(iOS) || os(tvOS)
            Section("Editor") {
                helpRow(LocalizationManager.textAnimation, icon: "play.circle.fill", detail: "Change the text animation from the editor toolbar.")
                helpRow(LocalizationManager.bold, icon: "bold", detail: "Turn bold text on or off.")
                helpRow(LocalizationManager.italic, icon: "italic", detail: "Turn italic text on or off.")
            }
            #endif
            Section(LocalizationManager.animation) {
                helpRow(TextAnimation.none.localizedName, icon: TextAnimation.none.icon, detail: "Keep the text still.")
                helpRow(TextAnimation.bloom.localizedName, icon: TextAnimation.bloom.icon, detail: "Pulse the size of the text.")
                helpRow(TextAnimation.jitter.localizedName, icon: TextAnimation.jitter.icon, detail: "Shake the text.")
                helpRow(TextAnimation.ripple.localizedName, icon: TextAnimation.ripple.icon, detail: "Move a wave through the letters.")
            }
            #if !os(tvOS) && !os(watchOS)
            Section(LocalizationManager.themeSection) {
                Text("Tap a color preview to apply that theme. A checkmark marks the selected theme.")
            }
            #endif
        }
        .navigationTitle("Help")
        #if os(iOS) || os(visionOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }

    private func helpRow(_ title: LocalizedStringKey, icon: String, detail: LocalizedStringKey) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.headline)
                Text(detail).font(.body).foregroundStyle(.secondary)
            }
        } icon: {
            Image(systemName: icon)
        }
        .accessibilityElement(children: .combine)
    }
}
