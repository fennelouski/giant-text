//
//  FlowLayout.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI

// Helper to calculate line breaks for text
struct LineBreakCalculator {
    static func calculateLines(
        text: String,
        fontSize: CGFloat,
        useSerifFont: Bool,
        isBold: Bool,
        availableWidth: CGFloat,
        maxLines: Int,
        kerning: Double
    ) -> [[Character]] {
        // Split text into words to avoid breaking words across lines
        let words = text.split(separator: " ", omittingEmptySubsequences: false).map { String($0) }

        // Calculate width of a single character at this font size (approximation)
        let charWidth = fontSize * 0.6 // Rough approximation for character width

        // Calculate total text width including kerning
        let totalTextWidth = CGFloat(text.count) * charWidth + CGFloat(text.count - 1) * CGFloat(kerning)

        // Determine how many lines we need based on 60% threshold
        var targetLines = 1
        for lineCount in 1...maxLines {
            let widthPerLine = availableWidth * CGFloat(lineCount)
            if totalTextWidth > widthPerLine * 0.6 && lineCount < maxLines {
                targetLines = lineCount + 1
            } else {
                break
            }
        }

        if targetLines == 1 {
            // Single line - return all characters in one array
            return [Array(text)]
        }

        // Multi-line layout - distribute words across lines
        var lines: [[Character]] = []
        var currentLine: [Character] = []
        var currentLineWidth: CGFloat = 0
        let targetWidthPerLine = availableWidth / CGFloat(targetLines)

        for (wordIndex, word) in words.enumerated() {
            let wordChars = Array(word)
            let wordWidth = CGFloat(wordChars.count) * charWidth + CGFloat(max(0, wordChars.count - 1)) * CGFloat(kerning)

            // Check if adding this word would exceed the target width for this line
            let wouldExceed = (currentLineWidth + wordWidth) > targetWidthPerLine

            // Start a new line if:
            // 1. Adding this word would exceed target width
            // 2. We're not on the last allowed line
            // 3. Current line is not empty
            if wouldExceed && lines.count < (targetLines - 1) && !currentLine.isEmpty {
                lines.append(currentLine)
                currentLine = []
                currentLineWidth = 0
            }

            // Add word to current line
            if !currentLine.isEmpty && wordIndex > 0 {
                // Add space before word (except for first word)
                currentLine.append(" ")
                currentLineWidth += charWidth + CGFloat(kerning)
            }
            currentLine.append(contentsOf: wordChars)
            currentLineWidth += wordWidth
        }

        // Add the last line
        if !currentLine.isEmpty {
            lines.append(currentLine)
        }

        // If we somehow ended up with no lines, return single line with all text
        if lines.isEmpty {
            return [Array(text)]
        }

        return lines
    }
}

struct FlowLayout<Content: View>: View {
    let spacing: Double
    let maxLines: Int
    let content: () -> Content

    init(spacing: Double, maxLines: Int, @ViewBuilder content: @escaping () -> Content) {
        self.spacing = spacing
        self.maxLines = maxLines
        self.content = content
    }

    var body: some View {
        // Use HStack for backward compatibility
        // The line breaking logic is now handled by AnimatedTextDisplay
        HStack(spacing: spacing) {
            content()
        }
    }
}
