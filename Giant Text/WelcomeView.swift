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
    
    private var backgroundOverlay: some View {
        Color.black.opacity(0.7)
            .ignoresSafeArea()
            .onTapGesture {
                print("🔴 Background overlay tapped - dismissing welcome screen")
                onDismiss()
            }
    }
    
    private var appIcon: some View {
        Image("AppLogo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .cornerRadius(16)
            .accessibilityIdentifier("AppLogo")
    }
    
    private var title: some View {
        Text("Welcome to Giant Text!")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .multilineTextAlignment(.center)
            .accessibilityIdentifier("WelcomeTitle")
    }
    
    private var description: some View {
        VStack(spacing: 12) {
            Text("Create stunning, animated text displays")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .multilineTextAlignment(.center)
            
                                                #if os(iOS)
                                    if UIDevice.current.userInterfaceIdiom == .phone {
                                        VStack(spacing: 4) {
                                            BulletPoint(text: "Type your message")
                                            BulletPoint(text: "Text displays in landscape orientation")
                                            BulletPoint(text: "Device stays in portrait mode")
                                            BulletPoint(text: "Choose from multiple animation effects")
                                            BulletPoint(text: "Perfect for sharing short text quickly")
                                        }
                                        .frame(maxWidth: .infinity)
                                    } else {
                                        VStack(spacing: 4) {
                                            BulletPoint(text: "Type your message")
                                            BulletPoint(text: "Choose from multiple animation effects")
                                            BulletPoint(text: "Perfect for sharing short text quickly")
                                            BulletPoint(text: "Works across all your Apple devices")
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                    #else
                                    VStack(spacing: 4) {
                                        BulletPoint(text: "Type your message")
                                        BulletPoint(text: "Choose from multiple animation effects")
                                        BulletPoint(text: "Perfect for sharing short text quickly")
                                        BulletPoint(text: "Works across all your Apple devices")
                                    }
                                    .frame(maxWidth: .infinity)
                                    #endif
        }
    }
    
    private var quickTips: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: "hand.tap")
                    .foregroundColor(.blue)
                    .frame(width: 16, height: 16)
                Text("Single tap to edit text")
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(spacing: 8) {
                Image(systemName: "hand.tap.fill")
                    .foregroundColor(.blue)
                    .frame(width: 16, height: 16)
                Text("Two-finger tap for options")
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            HStack(spacing: 8) {
                Image(systemName: "escape")
                    .foregroundColor(.blue)
                    .frame(width: 16, height: 16)
                Text("Press ESC to close menus")
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.top, 8)
    }
    
    private var features: some View {
        VStack(spacing: 16) {
            Text("Features:")
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(spacing: 8) {
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
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.top, 16)
    }
    
    private var getStartedButton: some View {
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
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backgroundOverlay
                
                VStack(spacing: 0) {
                    Color.clear
                        .frame(height: geometry.safeAreaInsets.top)
                    
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 24) {
                                appIcon
                                title
                                description
                                quickTips
                                features
                            }
                            .padding(32)
                        }
                        .frame(maxHeight: (geometry.size.height - geometry.safeAreaInsets.top - geometry.safeAreaInsets.bottom) * 0.6)
                        .scrollIndicators(.hidden)
                        
                        getStartedButton
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .shadow(radius: 30)
                    )
                    .padding(.horizontal, 40)
                    .padding(.top, 20)
                    .padding(.bottom, geometry.safeAreaInsets.bottom + 20)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("WelcomeView")
                    
                    Color.clear
                        .frame(height: geometry.safeAreaInsets.bottom)
                }
            }
        }
        .transition(.opacity.combined(with: .scale))
        .animation(.easeInOut(duration: 0.3), value: true)
    }
}

// MARK: - Bullet Point Component
struct BulletPoint: View {
    let text: String
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 8) {
            Text("•")
                .font(.body)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
                .frame(width: 12, alignment: .center)
            
            Text(text)
                .font(.body)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.8) : .black.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, alignment: .center)
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
                .padding(.top, 2)
            
            VStack(spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                    .multilineTextAlignment(.center)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 4)
    }
}
#endif 