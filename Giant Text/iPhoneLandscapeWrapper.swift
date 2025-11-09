//
//  iPhoneLandscapeWrapper.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI
#if os(iOS)
import UIKit
#endif

struct iPhoneLandscapeWrapper<Content: View>: View {
    let content: Content
    let isEditing: Bool
    #if os(iOS)
    let deviceOrientation: UIDeviceOrientation

    init(isEditing: Bool, deviceOrientation: UIDeviceOrientation, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isEditing = isEditing
        self.deviceOrientation = deviceOrientation
    }
    #else
    init(isEditing: Bool, deviceOrientation: Any = 0, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isEditing = isEditing
    }
    #endif
    
    var body: some View {
        #if os(iOS)
        if UIDevice.current.userInterfaceIdiom == .phone {
            // On iPhone, only apply rotation when NOT editing
            if isEditing {
                // Keep text input in portrait orientation
                content
            } else {
                // Apply landscape rotation for display mode
                GeometryReader { geometry in
                    ZStack(alignment: .center) {
                        // Background to fill the entire space
                        Color.clear
                        
                        // Rotated content - always rotate 90 degrees for landscape display
                        content
                            .frame(
                                width: geometry.size.height,
                                height: geometry.size.width
                            )
                            .rotationEffect(.degrees(90))
                            .position(
                                x: geometry.size.width / 2,
                                y: geometry.size.height / 2
                            )
                            .allowsHitTesting(true)
                            .clipped()
                    }
                }
            }
        } else {
            // On iPad, return content as-is
            content
        }
        #else
        // On other platforms, return content as-is
        content
        #endif
    }
}

 