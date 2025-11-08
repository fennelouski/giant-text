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
    let onEdit: () -> Void
    let onClear: () -> Void
    let onUndo: () -> Void
    let canUndo: Bool
    let currentTheme: ColorTheme
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

                // Theme section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Theme")
                        .font(.headline)
                        .foregroundColor(colorScheme == .dark ? .white : .black)

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
                                    VStack(spacing: 4) {
                                        // Preview colors
                                        HStack(spacing: 2) {
                                            Rectangle()
                                                .fill(theme.backgroundColor(for: colorScheme))
                                                .frame(height: 30)
                                            Rectangle()
                                                .fill(theme.textColor(for: colorScheme))
                                                .frame(height: 30)
                                        }
                                        .cornerRadius(4)

                                        Text(theme.name)
                                            .font(.caption)
                                            .foregroundColor(themeTextColor(for: theme))
                                    }
                                    .padding(8)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(themeBackgroundColor(for: theme))
                                    )
                                }
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
                            HStack(spacing: 2) {
                                Rectangle()
                                    .fill(currentTheme.backgroundColor(for: colorScheme))
                                    .frame(height: 40)
                                Rectangle()
                                    .fill(currentTheme.textColor(for: colorScheme))
                                    .frame(height: 40)
                            }
                            .cornerRadius(4)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(backgroundColor)
                        )
                    }
                }

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
                            .accentColor(.blue)
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
