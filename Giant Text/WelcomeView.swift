//
//  WelcomeView.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI

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
                                    
                                    #if os(iOS)
                                    if UIDevice.current.userInterfaceIdiom == .phone {
                                        Text("• Type your message\n• Text displays in landscape orientation\n• Device stays in portrait mode\n• Choose from multiple animation effects\n• Perfect for sharing short text quickly")
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
                                    } else {
                                        Text("• Type your message\n• Choose from multiple animation effects\n• Perfect for sharing short text quickly\n• Works across all your Apple devices")
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                            .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
                                    }
                                    #else
                                    Text("• Type your message\n• Choose from multiple animation effects\n• Perfect for sharing short text quickly\n• Works across all your Apple devices")
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                        .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
                                    #endif
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
                                        #if os(iOS)
                                        if UIDevice.current.userInterfaceIdiom == .phone {
                                            FeatureRow(icon: "iphone.landscape", title: "Landscape Display", description: "Text displays in landscape orientation")
                                            FeatureRow(icon: "iphone.portrait", title: "Portrait Mode", description: "Device stays in portrait mode")
                                        } else {
                                            FeatureRow(icon: "iphone", title: "Cross-Platform", description: "Works on iPhone, iPad, Mac, and more")
                                        }
                                        #else
                                        FeatureRow(icon: "iphone", title: "Cross-Platform", description: "Works on iPhone, iPad, Mac, and more")
                                        #endif
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
#endif 