//
//  PortraitOnlyOverlay.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI

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