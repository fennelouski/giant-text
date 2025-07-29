//
//  TwoFingerTapView.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#endif

// MARK: - Two Finger Tap View
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
struct TwoFingerTapView: UIViewRepresentable {
    let onTwoFingerTap: () -> Void
    let onOneFingerTap: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = true
        
        // Two-finger tap gesture
        let twoFingerTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleTwoFingerTap)
        )
        twoFingerTapGesture.numberOfTapsRequired = 1
        twoFingerTapGesture.numberOfTouchesRequired = 2
        twoFingerTapGesture.cancelsTouchesInView = false
        twoFingerTapGesture.delaysTouchesBegan = false
        twoFingerTapGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(twoFingerTapGesture)
        
        let oneFingerTapGesture = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleOneFingerTap)
        )
        oneFingerTapGesture.numberOfTapsRequired = 1
        oneFingerTapGesture.numberOfTouchesRequired = 1
        oneFingerTapGesture.cancelsTouchesInView = false
        oneFingerTapGesture.delaysTouchesBegan = false
        oneFingerTapGesture.delaysTouchesEnded = false
        view.addGestureRecognizer(oneFingerTapGesture)
        
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(
            onOneFingerTap: onOneFingerTap,
            onTwoFingerTap: onTwoFingerTap
        )
    }
    
    class Coordinator: NSObject {
        let onOneFingerTap: () -> Void
        let onTwoFingerTap: () -> Void
        
        init(
            onOneFingerTap: @escaping () -> Void,
            onTwoFingerTap: @escaping () -> Void
        ) {
            self.onOneFingerTap = onOneFingerTap
            self.onTwoFingerTap = onTwoFingerTap
        }
        
        @objc func handleTwoFingerTap() {
            onTwoFingerTap()
        }
        
        @objc func handleOneFingerTap() {
            onOneFingerTap()
        }
    }
}
#endif
