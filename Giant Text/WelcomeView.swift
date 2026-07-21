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
        Text(LocalizationManager.welcomeTitle)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(colorScheme == .dark ? .white : .black)
            .multilineTextAlignment(.center)
            .accessibilityIdentifier("WelcomeTitle")
    }

    private var description: some View {
        VStack(spacing: 16) {
            Text(LocalizationManager.welcomeSubtitle)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .multilineTextAlignment(.center)

            VStack(spacing: 10) {
                #if os(iOS)
                if UIDevice.current.userInterfaceIdiom == .phone {
                    BulletPoint(text: LocalizationManager.bulletTypeMessage)
                    BulletPoint(text: LocalizationManager.bulletLandscapeOrientation)
                    BulletPoint(text: LocalizationManager.bulletPortraitMode)
                    BulletPoint(text: LocalizationManager.bulletAnimationEffects)
                    BulletPoint(text: LocalizationManager.bulletShareQuickly)
                } else {
                    BulletPoint(text: LocalizationManager.bulletTypeMessage)
                    BulletPoint(text: LocalizationManager.bulletAnimationEffects)
                    BulletPoint(text: LocalizationManager.bulletShareQuickly)
                    BulletPoint(text: LocalizationManager.bulletCrossPlatform)
                }
                #else
                BulletPoint(text: LocalizationManager.bulletTypeMessage)
                BulletPoint(text: LocalizationManager.bulletAnimationEffects)
                BulletPoint(text: LocalizationManager.bulletShareQuickly)
                BulletPoint(text: LocalizationManager.bulletCrossPlatform)
                #endif
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private var quickTips: some View {
        VStack(spacing: 8) {
            #if os(macOS)
            HStack(spacing: 8) {
                Image(systemName: "cursorhand.click")
                    .foregroundColor(.blue)
                    .frame(width: 16, height: 16)
                Text(LocalizationManager.tipClickEdit)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 8) {
                Image(systemName: "cursorhand.click.2")
                    .foregroundColor(.blue)
                    .frame(width: 16, height: 16)
                Text(LocalizationManager.tipRightClickOptions)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            #elseif os(tvOS)
            HStack(spacing: 8) {
                Image(systemName: "playpause")
                    .foregroundColor(.blue)
                    .frame(width: 16, height: 16)
                Text(LocalizationManager.tipPlayPauseEdit)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 8) {
                Image(systemName: "menubutton.horizontal")
                    .foregroundColor(.blue)
                    .frame(width: 16, height: 16)
                Text(LocalizationManager.tipMenuButtonOptions)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            #else
            HStack(spacing: 8) {
                Image(systemName: "hand.tap")
                    .foregroundColor(.blue)
                    .frame(width: 16, height: 16)
                Text(LocalizationManager.tipTapEdit)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .center)

            HStack(spacing: 8) {
                Image(systemName: "hand.tap.fill")
                    .foregroundColor(.blue)
                    .frame(width: 16, height: 16)
                Text(LocalizationManager.tipTwoFingerTapOptions)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            #endif

            HStack(spacing: 8) {
                Image(systemName: "escape")
                    .foregroundColor(.blue)
                    .frame(width: 16, height: 16)
                Text(LocalizationManager.tipEscClose)
                    .font(.caption)
                    .foregroundColor(colorScheme == .dark ? .white.opacity(0.7) : .black.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.top, 8)
    }
    
    private var features: some View {
        VStack(spacing: 16) {
            Text(LocalizationManager.featuresHeader)
                .font(.headline)
                .foregroundColor(colorScheme == .dark ? .white : .black)
                .frame(maxWidth: .infinity, alignment: .center)

            VStack(spacing: 8) {
                FeatureRow(icon: "textformat.size", title: LocalizationManager.featureGiantTextTitle, description: LocalizationManager.featureGiantTextDesc)
                FeatureRow(icon: "sparkles", title: LocalizationManager.featureAnimationsTitle, description: LocalizationManager.bulletAnimationEffects)
                #if os(iOS)
                if UIDevice.current.userInterfaceIdiom == .phone {
                    FeatureRow(icon: "iphone.landscape", title: LocalizationManager.featureLandscapeTitle, description: LocalizationManager.bulletLandscapeOrientation)
                    FeatureRow(icon: "iphone.portrait", title: LocalizationManager.featurePortraitTitle, description: LocalizationManager.bulletPortraitMode)
                } else {
                    FeatureRow(icon: "iphone", title: LocalizationManager.featureCrossPlatformTitle, description: LocalizationManager.featureCrossPlatformDesc)
                }
                #elseif os(macOS)
                FeatureRow(icon: "laptopcomputer", title: LocalizationManager.featureCrossPlatformTitle, description: LocalizationManager.featureCrossPlatformDesc)
                #elseif os(tvOS)
                FeatureRow(icon: "appletv", title: LocalizationManager.featureCrossPlatformTitle, description: LocalizationManager.featureCrossPlatformDesc)
                #else
                FeatureRow(icon: "iphone", title: LocalizationManager.featureCrossPlatformTitle, description: LocalizationManager.featureCrossPlatformDesc)
                #endif
                #if os(macOS)
                FeatureRow(icon: "cursorhand.click", title: LocalizationManager.featureEasyEditingTitle, description: LocalizationManager.featureEasyEditingDescMacos)
                #elseif os(tvOS)
                FeatureRow(icon: "appletvremote.gen1", title: LocalizationManager.featureEasyEditingTitle, description: LocalizationManager.featureEasyEditingDescTvos)
                #else
                FeatureRow(icon: "hand.tap", title: LocalizationManager.featureEasyEditingTitle, description: LocalizationManager.featureEasyEditingDescOther)
                #endif
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.top, 16)
    }

    private var getStartedButton: some View {
        Button(LocalizationManager.getStartedButton) {
            onGetStarted()
        }
        .buttonStyle(.plain)
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

                #if os(macOS)
                // macOS-optimized layout with horizontal space utilization
                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack(spacing: 24) {
                                appIcon
                                title
                                description

                                // Arrange quickTips and features side by side on macOS
                                HStack(alignment: .top, spacing: 40) {
                                    quickTips
                                        .frame(maxWidth: .infinity)

                                    features
                                        .frame(maxWidth: .infinity)
                                }
                            }
                            .padding(40)
                        }
                        .scrollIndicators(.hidden)

                        getStartedButton
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(colorScheme == .dark ? Color.black : Color.white)
                            .shadow(radius: 30)
                    )
                    .frame(maxWidth: 900)
                    .padding(.horizontal, 60)
                    .padding(.vertical, 40)
                    .contentShape(Rectangle())
                    .accessibilityIdentifier("WelcomeView")
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                #else
                // iOS/tvOS layout (original vertical layout)
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
                #endif
            }
        }
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
}

// MARK: - Bullet Point Component
struct BulletPoint: View {
    let text: LocalizedStringKey
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.footnote)
                .foregroundColor(.blue)
                .padding(.top, 2)

            Text(text)
                .font(.body)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.85) : .black.opacity(0.85))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

// MARK: - Feature Row Component
struct FeatureRow: View {
    let icon: String
    let title: LocalizedStringKey
    let description: LocalizedStringKey
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