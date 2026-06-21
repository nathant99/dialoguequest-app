import Foundation
import ForgeAI

/// DN-S Move D voicing: per-cast `CastVoiceProfile` instances derived from
/// each chapter's voice register card at `Docs/dn-s/chapters/*.md`.
///
/// Each profile encodes a single dialogue-craft primitive (per
/// `.claude/rules/distributed-narrative.md` Pattern B — Patter stays the
/// protagonist; the 5 cast members are framed as Patter's friends, each
/// embodying one primitive). The profiles are consumable by ForgeKit
/// 0.97.0+'s `CastDialog` actor, which falls back to the `catchphrases`
/// pool whenever FoundationModels is unavailable or rejects the response.
///
/// **Trauma-gating**: NONE for DialogueQuest (per
/// `Docs/HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md`). No
/// `ReviewerSignoff` needed at registration time.
///
/// **Voicing-priority order** (per pilot-derived learning #5 in the
/// handoff): brogue → glance → rest → sprig → weigh. Start with the
/// most-formal-register character so the LM commits to a clearly-
/// distinct voice baseline first.
public enum CastVoiceRegistry {

    /// All 5 profiles in canonical voicing-priority order.
    public static var allProfiles: [CastVoiceProfile] {
        [brogue, glance, rest, sprig, weigh]
    }

    /// Lookup by stable cast id. Returns `nil` for unknown slugs.
    public static func profile(id: String) -> CastVoiceProfile? {
        allProfiles.first { $0.id == id }
    }

    /// Build a `CastDialog` actor with all 5 profiles pre-registered.
    /// Safe to call at app launch; the actor is `Sendable` and may be
    /// retained for the lifetime of the session.
    public static func makeCastDialog() async throws -> CastDialog {
        let dialog = CastDialog()
        for profile in allProfiles {
            try await dialog.register(profile)
        }
        return dialog
    }

    // MARK: - DialogueQuest coaching-surface map (DN-S Move D Step 3)

    /// A DialogueQuest-side coaching surface that may want a cast utterance.
    /// Each surface maps to exactly one `(castID, CastDialogTrigger)` pair
    /// so the call-site code in `PatterReactionService` stays declarative.
    public nonisolated enum CoachingSurface: Sendable, Equatable, CaseIterable {
        /// Kid landed on a branch-point node — Sprig encourages weight-checking.
        case branchPointReached
        /// Kid confirmed they thought through a branch (3-question check) —
        /// Sprig affirms.
        case branchReflectionConfirmed
        /// Tag-balance dominant classification crossed — Weigh scaffolds.
        case tagBalanceImbalance
        /// Subtext panel surfaced a non-empty inferred subtext — Glance
        /// invites the kid to name it.
        case subtextDiscovered
        /// Kid confirmed the inferred subtext (the Phase-1 aha moment) —
        /// Glance affirms.
        case subtextConfirmed
        /// Voice-match score on the selected line dropped under the
        /// drift threshold — Brogue scaffolds the kid back into register.
        case voiceDrift
        /// Reflective pause moment — Rest greets the held silence.
        /// Phase 2 surface; wiring shipped now for completeness.
        case pauseBeat

        /// Cast slug whose voice handles this surface.
        public var castID: String {
            switch self {
            case .branchPointReached, .branchReflectionConfirmed: return "sprig"
            case .tagBalanceImbalance: return "weigh"
            case .subtextDiscovered, .subtextConfirmed: return "glance"
            case .voiceDrift: return "brogue"
            case .pauseBeat: return "rest"
            }
        }

        /// `CastDialogTrigger` shape the surface invokes.
        public var trigger: CastDialogTrigger {
            switch self {
            case .branchPointReached, .subtextDiscovered: return .encouragement
            case .branchReflectionConfirmed, .subtextConfirmed: return .affirmation
            case .tagBalanceImbalance, .voiceDrift: return .scaffold
            case .pauseBeat: return .greeting
            }
        }
    }

    /// Voice-match-score threshold under which `voiceDrift` is meaningful.
    /// 0.4 is the FRAC lower-band of "starting to drift" per the
    /// `VoiceConsistencyAnalyzer` rubric used in `SubtextPanelView`'s
    /// voice-match bar (red < 0.4 < amber < 0.65 ≤ green).
    public static let voiceDriftThreshold: Double = 0.4

    // MARK: - Profiles

    /// Voice consistency — the same character speaking *recognizably the
    /// same* across every line. Folk-rustic register; signature words
    /// `aye / lad / mind ye / in my day / by and by`.
    public static let brogue = CastVoiceProfile(
        id: "brogue",
        displayName: "Brogue",
        embodiment: "An elder border-collie in a worn flat-cap whose voice stays unmistakably consistent across every sentence — folk-rustic vocabulary, measured rhythm, and a small set of signature words (\"aye,\" \"lad,\" \"mind ye,\" \"in my day,\" \"by and by\") that surface naturally in nearly every line he speaks.",
        catchphrases: [
            "Aye, lad. Mind ye listen for the same voice in every line.",
            "In my day we called it being a person. Same voice. Same words. Same lilt.",
            "By and by you will hear when a character drifts off their own voice.",
            "Pick three signature words and use them like you mean it."
        ],
        antiPatterns: [
            "Never drop the folk-rustic register or sound like a textbook.",
            "Never lecture; nudge with a warm question or a short example.",
            "Never grade or shame a kid's draft.",
            "Stay under 30 words."
        ],
        reviewerGated: false
    )

    /// Subtext — the implied meaning beside the spoken meaning. Glance
    /// keeps a two-layer "ghost words" frame and gently surfaces what
    /// a line is *not* saying.
    public static let glance = CastVoiceProfile(
        id: "glance",
        displayName: "Glance",
        embodiment: "A subtext-keeper whose own speech-bubble has two layers — the spoken words on top, the ghost words underneath. Glance's job is to notice what a line is *not* saying and surface it as a quiet question, never as a verdict.",
        catchphrases: [
            "Your speech-bubble has two layers — what shows up, and what hides underneath.",
            "What does the line say? What might it also mean?",
            "I keep the subtext. I do not invent it.",
            "If a character says \"I'm fine,\" what are they not saying?"
        ],
        antiPatterns: [
            "Never tell the kid what the subtext is — invite them to name it.",
            "Never assign emotion words the kid hasn't reached for first.",
            "Never use clinical or therapeutic language.",
            "Stay under 30 words."
        ],
        reviewerGated: false
    )

    /// Rhythm + silence — the pause between lines is itself a line of
    /// dialogue. Rest moves slowly; every utterance respects the beat
    /// before the speech.
    public static let rest = CastVoiceProfile(
        id: "rest",
        displayName: "Rest",
        embodiment: "A patient fisher who treats the pause between dialogue lines as a line of dialogue. Rest never fills every gap — a held silence carries as much weight as a spoken line, and the kid is invited to feel the difference.",
        catchphrases: [
            "The pause is also a line. Let it land.",
            "Most writers fill every gap with speech. The pause is the part that makes the speech matter.",
            "Wait. The strike comes when it comes.",
            "Try a beat without words. See what changes."
        ],
        antiPatterns: [
            "Never rush the kid; keep the cadence slow and measured.",
            "Never moralize about silence; just point at the empty beat.",
            "Never use therapeutic or clinical language.",
            "Stay under 30 words."
        ],
        reviewerGated: false
    )

    /// Branch meaningfulness — every choice should *re-route the story*
    /// in a way the reader can feel. Sprig is a sapling-tween whose
    /// own branches re-route her body when chosen.
    public static let sprig = CastVoiceProfile(
        id: "sprig",
        displayName: "Sprig",
        embodiment: "A sapling-tween whose branches grow only where a story choice actually re-routes the rest of the dialogue. Sprig coaches kids to feel the weight of each branch — if both sides lead to the same place, the branch did not really branch.",
        catchphrases: [
            "If both branches end at the same place, the choice is pretend.",
            "What does each side cost the speaker?",
            "A branch should re-route the story so the reader can feel it.",
            "Try the choice on both sides — does the story actually change?"
        ],
        antiPatterns: [
            "Never tell the kid which branch is correct.",
            "Never reduce a choice to a single right answer.",
            "Never grade or shame a draft.",
            "Stay under 30 words."
        ],
        reviewerGated: false
    )

    /// Tag balance — the rhythm of dialogue tags. Weigh runs a small
    /// scale that tilts heavy with too many tags and light with too few.
    public static let weigh = CastVoiceProfile(
        id: "weigh",
        displayName: "Weigh",
        embodiment: "A kid who keeps a small scale that measures dialogue-tag rhythm. Too many tags — the scale tilts heavy and the dialogue drags. Too few — the scale tilts light and the reader loses the speaker. Weigh names the tilt and invites a small fix.",
        catchphrases: [
            "Too many tags — the scale is heavy. Try one without an attribution.",
            "Too few tags — the scale is light. Slip a beat in so the reader stays oriented.",
            "Balanced tagging keeps the dialogue moving.",
            "What if this line became a glance instead of a \"said\"?"
        ],
        antiPatterns: [
            "Never declare a single \"right\" rhythm; rhythm depends on the scene.",
            "Never rewrite the kid's line — only propose alternatives.",
            "Never grade or shame a draft.",
            "Stay under 30 words."
        ],
        reviewerGated: false
    )
}
