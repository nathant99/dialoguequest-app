import Foundation

/// Pure helper that picks the two listener candidates for a multi-listener
/// subtext analysis given the speaker + the full character cast.
///
/// The Phase 2 multi-speaker shape (`MultiSpeakerSubtextAnalysis`) takes
/// exactly two listeners. When a triangle scene has 3 characters, the
/// speaker is identified by `speakerID` and the remaining two characters
/// become the primary + secondary listeners. The helper keeps the
/// selection deterministic so re-analyzing the same line picks the same
/// pair every time (predictable kid-facing UX + stable tests).
///
/// Ordering rule: among the non-speaker characters, the one whose
/// `id.uuidString` sorts FIRST is the primary listener. This is purely
/// a tie-break — both readings are surfaced together, and the kid picks
/// which one matches the line they wrote.
public nonisolated enum MultiListenerCandidates {

    /// Result shape — both candidates as `DialogueCharacterRef` values.
    /// `nil` when the cast doesn't support a 2-listener pair (fewer
    /// than 3 characters, or the speakerID isn't present in the cast).
    public struct Pair: Sendable, Hashable {
        public let speaker: DialogueCharacterRef
        public let primaryListener: DialogueCharacterRef
        public let secondaryListener: DialogueCharacterRef

        public init(
            speaker: DialogueCharacterRef,
            primaryListener: DialogueCharacterRef,
            secondaryListener: DialogueCharacterRef
        ) {
            self.speaker = speaker
            self.primaryListener = primaryListener
            self.secondaryListener = secondaryListener
        }
    }

    /// Compute the listener pair for a given speaker + cast. Returns
    /// `nil` when the cast doesn't include the speaker OR the cast has
    /// fewer than 3 characters (no second listener available).
    public static func pair(
        speakerID: UUID,
        characters: [DialogueCharacterRef]
    ) -> Pair? {
        guard characters.count >= 3 else { return nil }
        guard let speaker = characters.first(where: { $0.id == speakerID }) else {
            return nil
        }
        let candidates = characters
            .filter { $0.id != speakerID }
            .sorted { $0.id.uuidString < $1.id.uuidString }
        guard candidates.count >= 2 else { return nil }
        return Pair(
            speaker: speaker,
            primaryListener: candidates[0],
            secondaryListener: candidates[1]
        )
    }
}
