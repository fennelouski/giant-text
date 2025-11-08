//
//  WidgetTextDisplay.swift
//  Giant Text Widget
//
//  Created by Nathan Fennel on 7/27/25.
//

import WidgetKit
import SwiftUI

// MARK: - Widget Text Display
struct WidgetTextDisplay: View {
    let attributedText: NSAttributedString
    
    var body: some View {
        Text(AttributedString(attributedText))
            .minimumScaleFactor(0.1) // Allow text to scale down
            .lineLimit(nil) // Allow multiple lines if needed
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Fill available space
    }
}

#Preview {
    WidgetTextDisplay(
        attributedText: NSAttributedString(string: "Hello World")
    )
    .frame(width: 200, height: 200)
}