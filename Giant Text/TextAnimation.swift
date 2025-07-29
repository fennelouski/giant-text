//
//  TextAnimation.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI

enum TextAnimation: String, CaseIterable {
    case none = "none"
    case bloom = "bloom"
    case jitter = "jitter"
    case ripple = "ripple"
    
    var icon: String {
        switch self {
        case .none: return "autostartstop.slash"
        case .bloom: return "sparkles"
        case .jitter: return "waveform"
        case .ripple: return "chevron.up.2"
        }
    }
    
    var localizedName: LocalizedStringKey {
        LocalizedStringKey(self.rawValue)
    }
} 