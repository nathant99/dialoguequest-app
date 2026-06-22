import SwiftUI
import Models
import SharedUI

/// 2-kid pass-and-play co-authored dialogue surface per C5 deepening
/// move. Renders one of 4 sub-views keyed off
/// `CollaborativeDialogueSession.Phase`:
///   • notStarted → start sheet (player A + B names, character picks)
///   • authoring  → cast-anchored prompt + line composer
///   • handoff    → privacy curtain ("Pass the device to Kid B")
///   • confirmReady → "Kid B — tap to reveal" confirmation
///   • complete   → completed-tree archive with "Open in Write tab" CTA
///
/// Solo path remains: the kid can dismiss this sheet at any time and
/// continue writing alone in the Write tab. Collaboration is opt-in.
public struct CollaborativeDialogueView: View {
    @State private var session = CollaborativeDialogueSession()
    @State private var playerA: String = "Player A"
    @State private var playerB: String = "Player B"
    @State private var characterA: DialogueCharacterRef = .init(name: "Iris", voiceRegister: "Quiet, careful", sampleLines: ["I'm fine.", "Maybe later.", "Sure."])
    @State private var characterB: DialogueCharacterRef = .init(name: "Cal", voiceRegister: "Bright, fast", sampleLines: ["Yeah no totally.", "Wait what?", "Try again."])
    @State private var lineDraft: String = ""

    /// Closure handed completed trees so the host (e.g. WriteTabView)
    /// can hand the tree over to the canonical builder for further
    /// editing / publishing.
    let onSessionComplete: (DialogueTree) -> Void
    let onDismiss: () -> Void

    public init(
        onSessionComplete: @escaping (DialogueTree) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.onSessionComplete = onSessionComplete
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Together")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done for now") {
                            if case .notStarted = session.phase {
                                onDismiss()
                            } else {
                                session.endEarly()
                            }
                        }
                        .accessibilityHint("End this collaborative session and go back. Anything you wrote so far stays in the anthology.")
                    }
                }
        }
        .onChange(of: completedTree) { _, newValue in
            guard let tree = newValue else { return }
            onSessionComplete(tree)
        }
    }

    // MARK: - Phase-driven content

    @ViewBuilder
    private var content: some View {
        switch session.phase {
        case .notStarted:
            startSheet
        case .authoring(let playerName, let prompt):
            authoringSurface(playerName: playerName, prompt: prompt)
        case .handoff(let toName):
            handoffSurface(toName: toName)
        case .confirmReady(let playerName):
            confirmReadySurface(playerName: playerName)
        case .complete:
            completeSurface
        }
    }

    private var startSheet: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Write a conversation together")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(DialoguePalette.inkBlue)
                    Text("Pass the device back and forth. Each turn, one of you writes the next line — but you can't see what the other wrote until your turn comes around.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
                Section { } header: {
                    Text("Who's playing").font(.subheadline.weight(.semibold))
                }
                TextField("Player A name", text: $playerA)
                    .textFieldStyle(.roundedBorder)
                TextField("Player B name", text: $playerB)
                    .textFieldStyle(.roundedBorder)
                Section { } header: {
                    Text("Your characters").font(.subheadline.weight(.semibold))
                }
                characterEditor(for: $characterA, label: "Character A")
                characterEditor(for: $characterB, label: "Character B")
                Button {
                    Task {
                        await session.start(
                            playerA: playerA,
                            playerB: playerB,
                            characterA: characterA,
                            characterB: characterB
                        )
                    }
                } label: {
                    Text("Start together")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(DialoguePalette.rust)
                .disabled(playerA.isEmpty || playerB.isEmpty)
                .accessibilityHint("Start the pass-and-play session with both characters.")
                Text("Collaboration is opt-in. You can still write a tree alone from the Write tab.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
        }
        .background(DialoguePalette.cream.opacity(0.6))
    }

    private func authoringSurface(playerName: String, prompt: CollaborativeDialogueSession.TurnPrompt) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text(playerName)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(DialoguePalette.inkBlue)
                Spacer()
                Text("Line \(session.authoredLines.count + 1)")
                    .font(.footnote.monospaced())
                    .foregroundStyle(.secondary)
            }
            MentorBubbleView(
                message: "\(prompt.castDisplayName) — \(prompt.promptText)"
            )
            TextField("Write the next line", text: $lineDraft, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...6)
                .accessibilityHint("Compose the next line of the conversation.")
            Button {
                Task {
                    let text = lineDraft.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !text.isEmpty else { return }
                    await session.recordLine(text)
                    lineDraft = ""
                }
            } label: {
                Text("Submit and pass")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)
            .disabled(lineDraft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            Spacer()
        }
        .padding()
        .background(DialoguePalette.cream.opacity(0.6))
    }

    private func handoffSurface(toName: String) -> some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "arrow.left.arrow.right")
                .font(.system(size: 48))
                .foregroundStyle(DialoguePalette.rust)
            Text("Pass the device to \(toName)")
                .font(.title2.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
                .multilineTextAlignment(.center)
                .accessibilityAddTraits(.isHeader)
            Text("They tap when ready.")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button("\(toName), tap when ready") {
                Task { await session.acceptHandoff() }
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)
            Spacer()
        }
        .padding()
        .background(DialoguePalette.cream)
    }

    private func confirmReadySurface(playerName: String) -> some View {
        VStack(spacing: 18) {
            Spacer()
            Image(systemName: "eye.slash.fill")
                .font(.system(size: 48))
                .foregroundStyle(DialoguePalette.rust)
            Text("\(playerName), this is your turn")
                .font(.title2.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
                .accessibilityAddTraits(.isHeader)
            Text("Tap to see the latest line. Don't peek if it's not your turn.")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Tap to reveal") {
                Task { await session.revealAndBegin() }
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)
            Spacer()
        }
        .padding()
        .background(DialoguePalette.cream)
    }

    private var completeSurface: some View {
        VStack(spacing: 18) {
            Spacer(minLength: 12)
            Image(systemName: "sparkles.tv")
                .font(.system(size: 48))
                .foregroundStyle(DialoguePalette.rust)
            Text("You wrote it together")
                .font(.title2.weight(.semibold))
                .foregroundStyle(DialoguePalette.inkBlue)
            Text("\(session.authoredLines.count) line\(session.authoredLines.count == 1 ? "" : "s") between \(characterA.name) and \(characterB.name).")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Button("Open in Write tab") {
                if case .complete(let tree) = session.phase {
                    onSessionComplete(tree)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)
            Button("Done") {
                onDismiss()
            }
            .buttonStyle(.bordered)
            Spacer()
        }
        .padding()
        .background(DialoguePalette.cream)
    }

    private func characterEditor(for ref: Binding<DialogueCharacterRef>, label: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            TextField("Character name", text: Binding(
                get: { ref.wrappedValue.name },
                set: { newValue in
                    ref.wrappedValue = DialogueCharacterRef(
                        id: ref.wrappedValue.id,
                        name: newValue,
                        voiceRegister: ref.wrappedValue.voiceRegister,
                        sampleLines: ref.wrappedValue.sampleLines
                    )
                }
            ))
            .textFieldStyle(.roundedBorder)
        }
    }

    private var completedTree: DialogueTree? {
        if case .complete(let tree) = session.phase { return tree }
        return nil
    }
}

#Preview {
    CollaborativeDialogueView(
        onSessionComplete: { _ in },
        onDismiss: {}
    )
}
