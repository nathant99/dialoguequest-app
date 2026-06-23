import SwiftUI
import Models
import Services
import SharedUI

/// Phase 2 first-cut import surface for `CharacterForgeImportService`.
/// The kid (or grown-up helper) pastes a CharacterForge JSON export into
/// the text editor; on Import, the service validates the manifest and
/// returns `DialogueCharacterRef` rows that pre-fill the character
/// authoring form.
///
/// **Why clipboard-paste, not ForgeSync auto-discover (Phase 2)**: the
/// ForgeSync cross-app bridge for arbitrary value-type payloads isn't
/// wired yet. Clipboard-paste keeps the import path unblocked while
/// preserving the canonical schema — when ForgeSync ships, the service
/// is unchanged; only the sheet surface adds a "Detect CharacterForge
/// cast" affordance alongside the existing paste field.
///
/// Closes the Phase 2 unchecked item *"Implement CharacterForge import
/// hook"* in `@Docs/FEATURE_PLAN.md`.
struct CharacterForgeImportSheet: View {
    let onImport: ([DialogueCharacterRef]) -> Void
    let onCancel: () -> Void

    @State private var pastedJSON: String = ""
    @State private var errorMessage: String?

    private let service = CharacterForgeImportService()

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Text("Paste a CharacterForge cast export below. The names, voice registers, and sample lines will fill in automatically.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                } header: {
                    Text("Import from CharacterForge")
                }

                Section {
                    TextEditor(text: $pastedJSON)
                        .font(.system(.footnote, design: .monospaced))
                        .frame(minHeight: 200)
                        .accessibilityLabel("CharacterForge export JSON")
                        .accessibilityHint("Paste the JSON exactly as CharacterForge exported it.")
                        .accessibilityIdentifier("characterForge.import.jsonField")
                } header: {
                    Text("JSON")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(DialoguePalette.rust)
                            .accessibilityIdentifier("characterForge.import.error")
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(DialoguePalette.cream.opacity(0.6))
            .navigationTitle("CharacterForge")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                }
                ToolbarItem(placement: .primaryAction) {
                    Button("Import", action: handleImport)
                        .disabled(pastedJSON.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .accessibilityIdentifier("characterForge.import.commit")
                }
            }
        }
    }

    private func handleImport() {
        let bytes = Data(pastedJSON.utf8)
        switch service.importCharacters(jsonPayload: bytes) {
        case .success(let refs):
            errorMessage = nil
            onImport(refs)
        case .failure(let error):
            errorMessage = error.errorDescription ?? "That import couldn't be read. Try copying the export again."
        }
    }
}
