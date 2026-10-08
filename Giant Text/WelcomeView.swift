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

    private var getStartedButton: some View {
        Button(action: onGetStarted) {
            Label(LocalizationManager.getStartedButton, systemImage: "arrow.right")
                .labelStyle(.iconOnly)
                .frame(minWidth: 44, minHeight: 44)
        }
        .help(LocalizationManager.getStartedButton)
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
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 20) {
                            appIcon
                            title
                            Text(LocalizationManager.bulletTypeMessage)
                                .font(.body)
                                .multilineTextAlignment(.center)
                                .foregroundStyle(.secondary)
                        }
                        .padding(32)
                    }
                    getStartedButton
                }
                .background(colorScheme == .dark ? Color.black : Color.white, in: RoundedRectangle(cornerRadius: 20))
                .frame(maxWidth: 560, maxHeight: min(520, max(0, geometry.size.height - 48)))
                .padding(.horizontal, 24)
                .contentShape(Rectangle())
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("WelcomeView")
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
#endif
