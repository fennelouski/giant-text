import Foundation
import SwiftData
import AppKit

@main
struct ReleaseChecks {
    @MainActor
    static func main() throws {
        let oldKerning = UserDefaults.standard.object(forKey: "kerning")
        let groupName = "group.com.fennel.Giant-Text"
        let oldGroup = UserDefaults.appGroup.persistentDomain(forName: groupName)
        defer {
            if let oldKerning { UserDefaults.standard.set(oldKerning, forKey: "kerning") }
            else { UserDefaults.standard.removeObject(forKey: "kerning") }
            if let oldGroup { UserDefaults.appGroup.setPersistentDomain(oldGroup, forName: groupName) }
            else { UserDefaults.appGroup.removePersistentDomain(forName: groupName) }
        }
        var failures = 0
        func check(_ condition: Bool, _ message: String) {
            print("\(condition ? "PASS" : "FAIL"): \(message)")
            if !condition { failures += 1 }
        }

        let storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("giant-text-checks-\(UUID().uuidString)", isDirectory: true)
        try FileManager.default.createDirectory(at: storeURL, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: storeURL) }
        let configuration = ModelConfiguration(url: storeURL.appendingPathComponent("text.store"))
        let container = try ModelContainer(for: TextDocument.self, configurations: configuration)
        let state = ContentViewState()
        let actions = ContentViewActions(state: state, modelContext: container.mainContext, documents: [])
        actions.ensureDocumentExists()
        actions.ensureDocumentExists()
        actions.loadDocument()
        let typed = NSAttributedString(string: "Meet at gate 12")
        actions.updateDocument(attributedText: typed)
        let saved = try ModelContext(container).fetch(FetchDescriptor<TextDocument>())
        check(saved.count == 1 && saved.first?.text == typed.string,
              "First-launch edits persist, and initialization does not duplicate the document")

        let initial = NSAttributedString(string: "A")
        state.attributedText = initial
        state.textHistory = [initial]
        state.currentHistoryIndex = 0
        func edit(_ string: String) {
            let old = state.attributedText
            state.attributedText = NSAttributedString(string: string)
            actions.addToHistory(oldValue: old, newValue: state.attributedText)
            // The editor and SwiftUI observer both report the same change.
            actions.addToHistory(oldValue: old, newValue: state.attributedText)
        }
        func undo() {
            let old = state.attributedText
            actions.undoLastChange()
            // SwiftUI also observes the programmatic undo.
            actions.addToHistory(oldValue: old, newValue: state.attributedText)
        }
        edit("B")
        edit("C")
        undo()
        check(state.attributedText.string == "B", "One undo restores the preceding edit")
        undo()
        check(state.attributedText.string == "A", "Repeated undo reaches the initial text")
        edit("D")
        undo()
        check(state.attributedText.string == "A", "An edit after undo starts a new history branch")
        actions.handleClearText()
        undo()
        check(state.attributedText.string == "A", "Cleared text can be restored")

        state.kerning = -7
        check(ContentViewState().kerning == -7, "Negative letter spacing survives model recreation")
        state.showingHelp = true
        state.showingOptionsMenu = true
        state.isEditing = true
        actions.handleEscapeKey()
        check(!state.showingHelp && !state.showingOptionsMenu && !state.isEditing,
              "Escape dismisses Help, settings, and editing")
        if failures > 0 { exit(1) }
    }
}
