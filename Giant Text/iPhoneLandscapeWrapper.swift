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
    let rotation: TextRotation
    #if os(iOS)
    let deviceOrientation: UIDeviceOrientation

    init(isEditing: Bool, deviceOrientation: UIDeviceOrientation, rotation: TextRotation = .left, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isEditing = isEditing
        self.deviceOrientation = deviceOrientation
        self.rotation = rotation
    }
    #else
    init(isEditing: Bool, deviceOrientation: Any = 0, rotation: TextRotation = .left, @ViewBuilder content: () -> Content) {
        self.content = content()
        self.isEditing = isEditing
        self.rotation = rotation
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
                        
                        // Rotated content - rotate based on user setting
                        content
                            .frame(
                                width: geometry.size.height,
                                height: geometry.size.width
                            )
                            .rotationEffect(.degrees(rotation.degrees))
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

 