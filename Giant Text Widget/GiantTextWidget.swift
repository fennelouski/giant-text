//
//  GiantTextWidget.swift
//  Giant Text Widget
//
//  Created by Nathan Fennel on 7/27/25.
//

import WidgetKit
import SwiftUI

struct GiantTextWidgetEntry: TimelineEntry {
    let date: Date
    let attributedText: NSAttributedString?
    let theme: ColorTheme
}

struct GiantTextWidgetEntryView: View {
    var entry: GiantTextWidgetEntry
    @Environment(\.widgetFamily) var family
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        if let attributedText = entry.attributedText, !attributedText.string.isEmpty {
            WidgetTextDisplay(
                attributedText: attributedText,
                theme: entry.theme
            )
        } else {
            Text("GIANT TEXT 5")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(entry.theme.textColor(for: colorScheme))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct GiantTextWidget: Widget {
    let kind: String = "GiantTextWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GiantTextWidgetProvider()) { entry in
            GiantTextWidgetEntryView(entry: entry)
                .containerBackground(for: .widget) {
                    Color(entry.theme.lightBackground.color)
                }
        }
        .configurationDisplayName("GIANT TEXT")
        .description("Display your giant text on the home screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct GiantTextWidgetProvider: TimelineProvider {
    typealias Entry = GiantTextWidgetEntry
    
    func placeholder(in context: Context) -> GiantTextWidgetEntry {
        GiantTextWidgetEntry(
            date: Date(),
            attributedText: NSAttributedString(string: "Sample Text"),
            theme: getStoredTheme()
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (GiantTextWidgetEntry) -> ()) {
        let entry = GiantTextWidgetEntry(
            date: Date(),
            attributedText: getStoredText(),
            theme: getStoredTheme()
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = GiantTextWidgetEntry(
            date: Date(),
            attributedText: getStoredText(),
            theme: getStoredTheme()
        )

        // Update every 5 minutes for more responsive widget updates
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 5, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }

    private func getStoredTheme() -> ColorTheme {
        let sharedDefaults = UserDefaults(suiteName: "group.com.fennel.Giant-Text")

        // Try to get theme from shared defaults
        if let themeData = sharedDefaults?.data(forKey: "currentThemeData"),
           let theme = try? JSONDecoder().decode(ColorTheme.self, from: themeData) {
            print("Widget: Found theme: \(theme.name)")
            return theme
        }

        print("Widget: No theme found, using default")
        return ColorTheme.defaultTheme
    }
    
    private func getStoredText() -> NSAttributedString? {
        let sharedDefaults = UserDefaults(suiteName: "group.com.fennel.Giant-Text")
        
        // Try to get rich text data first
        if let textData = sharedDefaults?.data(forKey: "currentTextData"),
           let attributedString = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NSAttributedString.self, from: textData) {
            print("Widget: Found rich text data")
            return attributedString
        }
        
        // Fallback to plain text
        if let plainText = sharedDefaults?.string(forKey: "currentText"), !plainText.isEmpty {
            print("Widget: Found plain text: \(plainText)")
            return NSAttributedString(string: plainText)
        }
        
        print("Widget: No text found, using default")
        // Return a default message if no text is available
        return NSAttributedString(string: "GIANT TEXT 7")
    }
}

#Preview(as: .systemSmall) {
    GiantTextWidget()
} timeline: {
    GiantTextWidgetEntry(
        date: Date(),
        attributedText: NSAttributedString(string: "Hello World"),
        theme: ColorTheme.defaultTheme
    )
}

#Preview(as: .systemMedium) {
    GiantTextWidget()
} timeline: {
    GiantTextWidgetEntry(
        date: Date(),
        attributedText: NSAttributedString(string: "Medium Widget Text"),
        theme: ColorTheme.defaultTheme
    )
}

#Preview(as: .systemLarge) {
    GiantTextWidget()
} timeline: {
    GiantTextWidgetEntry(
        date: Date(),
        attributedText: NSAttributedString(string: "Large Widget Text"),
        theme: ColorTheme.defaultTheme
    )
}
