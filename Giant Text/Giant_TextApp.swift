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
    }
}
