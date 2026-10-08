//
//  Giant_TextApp.swift
//  Giant Text
//
//  Created by Nathan Fennel on 7/27/25.
//

import SwiftUI
import SwiftData

@main
struct Giant_TextApp: App {
    #if os(visionOS)
    @State private var visionState = ContentViewState()
    #endif

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TextDocument.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        #if os(visionOS)
        WindowGroup("Giant Text", id: "workspace", for: String.self) { _ in
            ContentView(state: visionState)
        } defaultValue: {
            "main"
        }
        .modelContainer(sharedModelContainer)
        .defaultSize(width: 1000, height: 680)
        .windowResizability(.contentMinSize)

        WindowGroup("Giant Text Display", id: "live-sign", for: UUID.self) { _ in
            GiantVisionDisplay(state: visionState)
        } defaultValue: {
            UUID()
        }
        .modelContainer(sharedModelContainer)
        .windowStyle(.plain)
        .defaultSize(width: 1200, height: 500)
        .windowResizability(.contentMinSize)
        .defaultWindowPlacement { _, context in
            if let workspace = context.windows.first(where: { $0.id == "workspace" }) {
                WindowPlacement(.trailing(workspace))
            } else {
                WindowPlacement(nil)
            }
        }
        #else
        WindowGroup {
            ContentView()
                .onAppear {
                    // Handle UI testing launch arguments
                    if ProcessInfo.processInfo.arguments.contains("--reset-welcome-screen") {
                        UserDefaults.standard.removeObject(forKey: "hasPressedGetStarted")
                        UserDefaults.standard.removeObject(forKey: "lastLaunchDate")
                    }
                }
        }
        .modelContainer(sharedModelContainer)
        
        // AirPlay/External Display Window
        WindowGroup("AirPlay Display", id: "airplay") {
            AirPlayDisplayView()
        }
        .modelContainer(sharedModelContainer)
        #if os(macOS)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        #endif
        #endif
    }
}
