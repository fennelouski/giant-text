//
//  Extensions.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
import UIKit
#endif

// MARK: - Font Extensions
#if os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
extension UIFont {
    func withTraits(_ traits: UIFontDescriptor.SymbolicTraits, added: Bool = true, removed: Bool = false) -> UIFont {
        var newTraits = fontDescriptor.symbolicTraits
        
        if added {
            newTraits.insert(traits)
        }
        if removed {
            newTraits.remove(traits)
        }
        
        guard let newDescriptor = fontDescriptor.withSymbolicTraits(newTraits) else {
            return self
        }
        
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}
#endif

// MARK: - Shake Detection
#if os(iOS)
extension Notification.Name {
    static let deviceDidShakeNotification = Notification.Name("deviceDidShakeNotification")
}

extension UIWindow {
    open override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: .deviceDidShakeNotification, object: nil)
        }
    }
}
#endif 