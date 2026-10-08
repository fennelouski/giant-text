#if os(visionOS)
import SwiftUI
import SwiftData

/// The message and styling belong to the workspace; each sign fits its own window.
struct GiantVisionDisplay: View {
    @Bindable var state: ContentViewState
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openWindow) private var openWindow
    @Query(sort: \TextDocument.lastModified, order: .reverse) private var documents: [TextDocument]
    @State private var fontSize: CGFloat = 100

    var body: some View {
        GeometryReader { geometry in
            GiantTextView(
                attributedText: .constant(state.attributedText),
                fontSize: $fontSize,
                availableSize: geometry.size,
                isEditing: .constant(false),
                selectedAnimation: .constant(state.selectedAnimation),
                animationIntensity: .constant(state.animationIntensity),
                isClippingEnabled: .constant(state.isClippingEnabled),
                useSerifFont: state.useSerifFont,
                kerning: state.kerning,
                showingWelcomeView: false,
                forceRecalculation: .constant(false),
                isBold: .constant(state.isBold),
                isItalicized: .constant(state.isItalicized),
                maxLines: state.maxLines,
                theme: state.currentTheme(),
                updateDocument: { _ in },
                addToHistory: { _, _ in }
            )
            .allowsHitTesting(false)
        }
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .frame(minWidth: 480, minHeight: 200)
        .preferredColorScheme(state.appearanceMode.colorScheme)
        .ornament(attachmentAnchor: .scene(.bottom)) {
            HStack(spacing: 20) {
                Button {
                    state.isEditing = true
                    openWindow(id: "workspace", value: "main")
                } label: {
                    Label(LocalizationManager.editText, systemImage: "pencil")
                        .labelStyle(.iconOnly)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .help(LocalizationManager.editText)
                Menu {
                    Button {
                        state.showingOptionsMenu = true
                        openWindow(id: "workspace", value: "main")
                    } label: {
                        Label("Settings", systemImage: "slider.horizontal.3")
                    }
                    Button {
                        state.showingHelp = true
                        openWindow(id: "workspace", value: "main")
                    } label: {
                        Label("Help", systemImage: "questionmark.circle")
                    }
                } label: {
                    Label(LocalizationManager.options, systemImage: "ellipsis")
                        .labelStyle(.iconOnly)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .help(LocalizationManager.options)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .glassBackgroundEffect(in: Capsule())
        }
        .onAppear {
            // A restored sign can open before its editor. Load the same saved message once.
            guard state.textHistory.isEmpty else { return }
            let actions = ContentViewActions(state: state, modelContext: modelContext, documents: documents)
            actions.ensureDocumentExists()
            actions.loadDocument()
        }
    }
}
#endif
