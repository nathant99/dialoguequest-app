import Foundation

/// DN-D layered-cast taxonomy. Each `CastVoiceProfile` registered with
/// DialogueQuest's `CastVoiceRegistry` lives in exactly one layer.
///
/// Reference: `Docs/HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md` § 1
/// (Layered methodology), and `.claude/rules/distributed-narrative.md`
/// § Hero mascot vs. cast (Pattern B — Patter stays the primary
/// protagonist; WORLD + META layers are explicitly framed as Patter's
/// conversational guests).
///
/// **Voicing priority rule** (Pattern B preservation): LESSONS-layer
/// utterances take precedence at every coaching surface that the kid
/// reaches during normal authoring. WORLD utterances only surface when
/// the kid (or the kit) explicitly invokes a voice-register showcase.
/// META utterances surface only when the audience-perception kit-11/12
/// content is on-screen. The layer enum lets the service filter without
/// touching `CastVoiceProfile` (which is a ForgeAI type and can't carry
/// app-specific metadata).
public nonisolated enum CastVoiceLayer: String, Sendable, Codable, CaseIterable {
    /// The five dialogue-craft primitives — Sprig / Glance / Weigh /
    /// Brogue / Rest. Wave-9 retrofit; preserved verbatim from DN-S
    /// Move D Phase 1.
    case lessons

    /// Cluster-shared voice-register archetypes — Heralda / Murmur /
    /// Quip / Vesperline. Inherited from LyricForge's cluster gen
    /// (queue #304) at $0 marginal cost. Frame: "the medium in which
    /// the teaching happens" — each character demonstrates ONE
    /// voice register the kid can write toward.
    case world

    /// The reader-from-without stance — Audience Aria. Surfaces only
    /// when kit 11-12 content puts the listener perspective in view.
    /// Per DN-D rule: Aria's reactions are *data*, not corrective —
    /// she reports what a listener might experience, never grades a
    /// kid's draft.
    case meta

    /// Human-facing label used in chips + accessibility hints.
    public var displayName: String {
        switch self {
        case .lessons: "Craft friend"
        case .world: "Voice register"
        case .meta: "Audience perspective"
        }
    }

    /// Minimum kit number at which the layer becomes pedagogically
    /// load-bearing. `CastVoicingService` consults this to decide
    /// whether to surface a WORLD or META utterance early in the
    /// 16-kit arc.
    public var minimumKitNumber: Int {
        switch self {
        case .lessons: 1
        case .world: 5
        case .meta: 11
        }
    }
}
