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
    @State private var isThemeSectionExpanded: Bool = false
    
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

    private func themeTextColor(for theme: ColorTheme) -> Color {
        if selectedThemeId == theme.id {
            return .blue
        } else {
            return colorScheme == .dark ? .white : .black
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

    var body: some View {
        NavigationStack {

            #if os(tvOS)
            // Simplified menu for tvOS
            ScrollView {
                VStack(spacing: 12) {
                    // Animation picker
                    Picker(LocalizationManager.animation, selection: $selectedAnimation) {
                        ForEach(TextAnimation.allCases, id: \.self) { animation in
                            Text(animation.localizedName).tag(animation)
                        }
                    }
                    .pickerStyle(.menu)

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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(LocalizationManager.close) {
                        dismiss()
                    }
                }
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
                                .tint(.blue)
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
                
                // Animation section (moved to top)
                VStack(alignment: .leading, spacing: 12) {
                    Text(LocalizationManager.animation)
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                        ForEach(TextAnimation.allCases, id: \.self) { animation in
                            Button(action: {
                                selectedAnimation = animation
                            }) {
                                HStack(spacing: 8) {
                                    Image(systemName: animation.icon)
                                        .foregroundColor(textColor(for: animation))
                                    Text(animation.localizedName)
                                        .fontWeight(selectedAnimation == animation ? .semibold : .regular)
                                        .foregroundColor(textColor(for: animation))
                                }
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
                                Toggle("Random Theme (Daily)", isOn: $useRandomTheme)
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
                                            VStack(spacing: 8) {
                                                themePreview(theme, height: 44)

                                                Text(theme.name)
                                                    .font(.caption)
                                                    .fontWeight(selectedThemeId == theme.id ? .semibold : .regular)
                                                    .foregroundColor(themeTextColor(for: theme))
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.8)
                                            }
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
                                    }
                                }
                            } else {
                                // Show current random theme
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Text("Current Theme:")
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
                        Text("Theme")
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
                        HStack {
                            Text("Appearance")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Picker("", selection: $appearanceMode) {
                                ForEach(AppearanceMode.allCases, id: \.self) { mode in
                                    Text(mode.localizedName).tag(mode)
                                }
                            }
                            .pickerStyle(.menu)
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
                        HStack {
                            Text("Text Rotation")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Picker("", selection: $textRotation) {
                                ForEach(TextRotation.allCases, id: \.self) { rotation in
                                    Text(rotation.localizedName).tag(rotation)
                                }
                            }
                            .pickerStyle(.menu)
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
                        Toggle("Serif Font", isOn: $useSerifFont)
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
                            Text("Letter Spacing")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Text("\(Int(kerning))")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                        }
                        Slider(value: $kerning, in: -10...30)
                            .tint(.blue)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                    )

                    // Max lines picker
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Max Lines")
                                .foregroundColor(colorScheme == .dark ? .white : .black)
                            Spacer()
                            Picker("", selection: $maxLines) {
                                ForEach(1...5, id: \.self) { lines in
                                    Text("\(lines)").tag(lines)
                                }
                            }
                            .pickerStyle(.menu)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(backgroundColor)
                    )
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
                        .buttonStyle(.plain)

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
                        .buttonStyle(.plain)

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
                        .buttonStyle(.plain)
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
