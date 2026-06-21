import Foundation
import Models

/// UI-test seam for the Write tab. When the `-uiTestSeedSubtextLine`
/// launch arg is present, `WriteTabView` swaps its default empty
/// `DialogueTreeMachine` for a pre-authored one with 2 characters,
/// one populated root line, mood `.quietConflict`, and stage
/// `.editingTree` — which means the subtext panel surfaces a
/// non-empty fallback inferred subtext immediately, and the kid (or
/// a UI test) can drive the confirm-subtext path without first
/// running through character authoring.
///
/// Production code path is unchanged (the static `if-present` check
/// returns `nil` outside test runs).
enum WriteTabUITestSeed {

    /// Launch-arg the UI test passes to opt into seeded state.
    static let launchArgument = "-uiTestSeedSubtextLine"

    /// Returns a pre-seeded `DialogueTreeMachine` when the launch arg is
    /// present; `nil` otherwise (so production builds skip the seed).
    static func seedIfRequested() -> DialogueTreeMachine? {
        guard ProcessInfo.processInfo.arguments.contains(launchArgument) else {
            return nil
        }
        return makeSeed()
    }

    /// The canonical seed: Iris + Cal, one root line "I'm fine.", mood
    /// `.quietConflict`. With these inputs, `PatterFallbacks
    /// .lineAnalysisFallback(for: .quietConflict)` returns
    /// "The words are gentle but the feelings are loud." — a non-empty
    /// subtext that surfaces the confirm-reject buttons in the panel.
    static func makeSeed() -> DialogueTreeMachine {
        let iris = DialogueCharacterRef(
            name: "Iris",
            voiceRegister: "clipped, withdrawn — short replies, almost guarded.",
            sampleLines: ["I guess.", "It's whatever.", "I said I'm fine."]
        )
        let cal = DialogueCharacterRef(
            name: "Cal",
            voiceRegister: "warm, stalling — circles before landing on a feeling.",
            sampleLines: ["So, like, yeah.", "Hey — wait."]
        )
        let root = DialogueNode(
            speakerID: iris.id,
            surfaceText: "I'm fine.",
            tag: .said("said")
        )
        let tree = DialogueTree(
            title: "Seeded for tests",
            characters: [iris, cal],
            nodes: [root],
            rootNodeID: root.id,
            mood: .quietConflict
        )
        return DialogueTreeMachine(
            stage: .editingTree,
            tree: tree,
            selectedNodeID: root.id,
            sessionTier: .experienced
        )
    }
}
