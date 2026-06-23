import Foundation
import AIMentor
import Services

/// Voice Crucible adventure-mode state machine. The kid picks a target
/// cast member from the LESSONS layer (Brogue / Glance / Rest / Sprig /
/// Weigh), writes one line in that character's voice, then submits and
/// sees a voice-match score + a Patter-side coaching line.
///
/// Per `.claude/rules/state-machines.md` § "`*Machine` Structs":
/// top-level value type, organized via `// MARK:`, `mutating func reset()`
/// re-assigns `self` to a fresh instance. Pure logic — no UI, no services.
///
/// Scoring leverages `VoiceConsistencyAnalyzer.score(sample:against:)` so
/// the algorithm matches the rest of the app (Jaccard token-overlap
/// against the cast's catchphrase pool).
public nonisolated struct VoiceCrucibleMachine: Sendable, Equatable {

    // MARK: - Stage

    /// Voice Crucible's 4-stage lifecycle. Each stage carries only what
    /// the next transition needs — no overlapping state.
    public enum Stage: Sendable, Equatable {
        /// Kid is choosing which cast member's voice to target.
        case selectingCast
        /// Kid has picked a target; now writing one line in their voice.
        case writing(targetCastID: String)
        /// Score computed; coaching line ready to read.
        case scored(targetCastID: String, voiceMatchScore: Double)
    }

    // MARK: - State

    public var stage: Stage = .selectingCast

    /// Kid's draft for the current attempt. Lives across `.writing` and
    /// `.scored` so the kid can re-read what they wrote alongside the score.
    public var draft: String = ""

    /// How many lines the kid has attempted across this session. Bumps on
    /// `submit()`. Used by the parent view to award a small XP bonus on
    /// the first attempt of a day.
    public private(set) var attemptCount: Int = 0

    public init() {}

    // MARK: - Transitions

    /// Pick a target cast member. Resolves to `nil` if the id isn't in
    /// `CastVoiceRegistry.lessonsLayerProfiles` — Voice Crucible only
    /// targets the LESSONS layer because those profiles encode the five
    /// dialogue-craft primitives. WORLD / META layers are demonstration
    /// surfaces, not authoring targets.
    public mutating func selectCast(id: String) {
        guard CastVoiceRegistry.lessonsLayerProfiles.contains(where: { $0.id == id }) else {
            return
        }
        stage = .writing(targetCastID: id)
        draft = ""
    }

    /// Submit the current draft. Computes the voice-match score against
    /// the target cast's catchphrase pool. The catchphrase pool is the
    /// canonical sample-line set per `CastVoiceProfile`.
    public mutating func submit() {
        guard case let .writing(targetCastID) = stage else { return }
        guard !draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let score = Self.score(line: draft, targetCastID: targetCastID)
        stage = .scored(targetCastID: targetCastID, voiceMatchScore: score)
        attemptCount += 1
    }

    /// Start a fresh attempt at the same cast. Used by the "Try again"
    /// button after `.scored` — keeps the target locked in so the kid can
    /// iterate on register without re-picking from the cast list.
    public mutating func retryWithSameCast() {
        guard case let .scored(targetCastID, _) = stage else { return }
        stage = .writing(targetCastID: targetCastID)
        draft = ""
    }

    /// Drop back to cast selection. Used by the "Pick a different voice"
    /// button after `.scored`.
    public mutating func reselectCast() {
        stage = .selectingCast
        draft = ""
    }

    /// Required by the portfolio state-machine convention. Re-assigns
    /// `self` to a fresh instance so every field including `attemptCount`
    /// resets.
    public mutating func reset() {
        self = VoiceCrucibleMachine()
    }

    // MARK: - Scoring

    /// Compute a voice-match score for `line` against `targetCastID`'s
    /// catchphrase pool. Returns 0.0 for unknown ids (so callers don't
    /// need to gate on registry membership). Pure function — safe to
    /// unit-test without instantiating the machine.
    public static func score(line: String, targetCastID: String) -> Double {
        guard let baseline = CastVoiceRegistry.voiceBaseline(for: targetCastID) else { return 0 }
        return VoiceConsistencyAnalyzer.score(sample: line, against: baseline)
    }

    // MARK: - Band classification

    /// Three-band classifier matching `WritingEvaluator.VoiceBand` so the
    /// UI can render the same red / amber / green semantics the
    /// SubtextPanel voice-match bar uses elsewhere in the app.
    public enum VoiceBand: Sendable, Equatable {
        case drifting    // < 0.4
        case onRegister  // 0.4 ≤ x < 0.65
        case locked      // 0.65 ≤ x

        public init(score: Double) {
            switch score {
            case ..<0.4: self = .drifting
            case 0.4..<0.65: self = .onRegister
            default: self = .locked
            }
        }
    }

    // MARK: - Coaching line picker

    /// A short, register-clean coaching line keyed to the (cast, band)
    /// pair. The lines stay in age-9-14 register per
    /// `.claude/rules/distributed-narrative.md` § R-CHAPTER-REGISTER —
    /// no engineering jargon, no clinical language.
    ///
    /// Returns deterministic copy so the coaching feels personal to the
    /// target voice instead of a generic "good job / try again". Each
    /// cast member's coaching line invokes their own primitive
    /// (e.g., Brogue talks about voice consistency, Glance about subtext).
    public static func coachingLine(targetCastID: String, band: VoiceBand) -> String {
        switch (targetCastID, band) {
        case ("brogue", .drifting):
            return "Aye, the line drifted off Brogue's voice. Try a signature word — 'aye,' 'lad,' or 'mind ye.'"
        case ("brogue", .onRegister):
            return "Brogue hears you reaching for his voice. One more signature word and the line settles."
        case ("brogue", .locked):
            return "That's Brogue — same lilt, same words, same person."
        case ("glance", .drifting):
            return "Glance wants the line to say one thing and mean two. What is the line not saying?"
        case ("glance", .onRegister):
            return "Glance hears a layer underneath. Stay quiet — let the subtext do the work."
        case ("glance", .locked):
            return "Two layers, clean. Glance is nodding."
        case ("rest", .drifting):
            return "Rest would slow this line down. Try a beat with fewer words — maybe a sentence the silence finishes."
        case ("rest", .onRegister):
            return "Rest hears the beat starting to settle. Hold one more pause before the next word."
        case ("rest", .locked):
            return "The pause carries the line. Rest is grinning quietly."
        case ("sprig", .drifting):
            return "Sprig wants this line to cost the speaker something. What does it lose them?"
        case ("sprig", .onRegister):
            return "Sprig sees the choice growing. Lean further into the stake."
        case ("sprig", .locked):
            return "That branch actually branches. Sprig's leaves are quivering."
        case ("weigh", .drifting):
            return "Weigh's scale tipped. The rhythm is uneven — try a tag-free beat or a glance instead of a 'said.'"
        case ("weigh", .onRegister):
            return "Weigh hears the rhythm steadying. One more attribution and the line balances."
        case ("weigh", .locked):
            return "Balanced. Weigh's scale is level."
        default:
            // Fallback for unknown ids — should never hit in practice
            // because selectCast(id:) gates on registry membership.
            return "Patter is listening. Keep going."
        }
    }
}
