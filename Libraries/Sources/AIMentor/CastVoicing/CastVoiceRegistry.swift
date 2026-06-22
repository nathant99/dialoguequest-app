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

    /// All 10 profiles in canonical voicing-priority order. The LESSONS
    /// layer comes first (Pattern B — Patter's craft-friend voices take
    /// precedence at normal coaching surfaces), then WORLD, then META.
    public static var allProfiles: [CastVoiceProfile] {
        lessonsLayerProfiles + worldLayerProfiles + metaLayerProfiles
    }

    /// LESSONS-layer profiles — the five dialogue-craft friends from
    /// the Wave-9 DN-S retrofit. Order: brogue → glance → rest → sprig
    /// → weigh (per pilot-derived learning #5 — start with the most
    /// formal register so the LM commits to a distinct baseline first).
    public static var lessonsLayerProfiles: [CastVoiceProfile] {
        [brogue, glance, rest, sprig, weigh]
    }

    /// WORLD-layer profiles — the four cluster-shared voice-register
    /// archetypes (Epic / Lyric / Comic / Tragic). Order matches the
    /// classical register quadrant: high-heroic → confessional →
    /// vernacular-comic → pastoral-tragic. Inherited from LyricForge's
    /// cluster gen at $0 marginal cost.
    public static var worldLayerProfiles: [CastVoiceProfile] {
        [heralda, murmur, quip, vesperline]
    }

    /// META-layer profiles — currently a single anchor (Audience Aria)
    /// surfacing only on kit-11/12 listener-perspective content.
    public static var metaLayerProfiles: [CastVoiceProfile] {
        [aria]
    }

    /// Lookup by stable cast id. Returns `nil` for unknown slugs.
    public static func profile(id: String) -> CastVoiceProfile? {
        allProfiles.first { $0.id == id }
    }

    /// Which DN layer the given cast id belongs to. Returns `nil` for
    /// unknown slugs.
    public static func layer(forID id: String) -> CastVoiceLayer? {
        if lessonsLayerProfiles.contains(where: { $0.id == id }) { return .lessons }
        if worldLayerProfiles.contains(where: { $0.id == id }) { return .world }
        if metaLayerProfiles.contains(where: { $0.id == id }) { return .meta }
        return nil
    }

    /// Build a `CastDialog` actor with all 10 profiles pre-registered.
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

        // --- DN-D Layered surfaces (Round 22+) --------------------------

        /// WORLD-layer: kid invokes the Epic / High-Heroic register
        /// showcase — Heralda demonstrates third-person omniscient voice.
        case voiceRegisterEpic
        /// WORLD-layer: Lyric / Confessional register — Murmur
        /// demonstrates first-person present voice.
        case voiceRegisterLyric
        /// WORLD-layer: Comic / Vernacular register — Quip Goodfellow
        /// demonstrates trickster banter voice.
        case voiceRegisterComic
        /// WORLD-layer: Tragic / Pastoral register — Vesperline
        /// demonstrates twilight, weighted voice.
        case voiceRegisterTragic
        /// META-layer: audience-perception surface — Audience Aria
        /// reports what a listener might experience. Surfaces only
        /// on kit-11/12 content per `CastVoiceLayer.minimumKitNumber`.
        /// Per DN-D rule: Aria's reactions are data, not corrective.
        case audiencePerception

        /// Cast slug whose voice handles this surface.
        public var castID: String {
            switch self {
            case .branchPointReached, .branchReflectionConfirmed: return "sprig"
            case .tagBalanceImbalance: return "weigh"
            case .subtextDiscovered, .subtextConfirmed: return "glance"
            case .voiceDrift: return "brogue"
            case .pauseBeat: return "rest"
            case .voiceRegisterEpic: return "heralda"
            case .voiceRegisterLyric: return "murmur"
            case .voiceRegisterComic: return "quip"
            case .voiceRegisterTragic: return "vesperline"
            case .audiencePerception: return "aria"
            }
        }

        /// `CastDialogTrigger` shape the surface invokes.
        public var trigger: CastDialogTrigger {
            switch self {
            case .branchPointReached, .subtextDiscovered: return .encouragement
            case .branchReflectionConfirmed, .subtextConfirmed: return .affirmation
            case .tagBalanceImbalance, .voiceDrift: return .scaffold
            case .pauseBeat: return .greeting
            case .voiceRegisterEpic, .voiceRegisterLyric, .voiceRegisterComic, .voiceRegisterTragic: return .greeting
            // Aria reports listener experience as a closing observation —
            // never grades, never corrects (DN-D Aria-is-data rule).
            case .audiencePerception: return .closing
            }
        }

        /// DN layer this surface routes to. The service uses this to
        /// gate WORLD/META utterances behind their `minimumKitNumber`.
        public var layer: CastVoiceLayer {
            switch self {
            case .branchPointReached,
                 .branchReflectionConfirmed,
                 .tagBalanceImbalance,
                 .subtextDiscovered,
                 .subtextConfirmed,
                 .voiceDrift,
                 .pauseBeat: return .lessons
            case .voiceRegisterEpic,
                 .voiceRegisterLyric,
                 .voiceRegisterComic,
                 .voiceRegisterTragic: return .world
            case .audiencePerception: return .meta
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

    // MARK: - WORLD-layer profiles (cluster-shared voice registers)

    /// Epic / High-Heroic register. Heralda travels with a small drum
    /// and speaks in third-person omniscient cadences — heralding the
    /// scene rather than inhabiting it.
    public static let heralda = CastVoiceProfile(
        id: "heralda",
        displayName: "Heralda the Loud",
        embodiment: "A traveling herald who carries a small marching drum and announces every scene in third-person omniscient voice — bold cadences, capital-letter weight, the high-heroic register. Heralda shows what an Epic voice sounds like; she never tells the kid which voice is best.",
        catchphrases: [
            "And lo — the speaker stepped forward, drumbeat slow and steady.",
            "Hear the cadence: third-person, full breath, weight on the verbs.",
            "In the Epic register, the room itself remembers what was said.",
            "Try one line in this voice — feel how the air around it changes."
        ],
        antiPatterns: [
            "Never claim the Epic register is the right one — it's one of four.",
            "Never grade the kid's draft against this register.",
            "Never break into modern slang; the cadence is the whole point.",
            "Stay under 30 words."
        ],
        reviewerGated: false
    )

    /// Lyric / Confessional register. Murmur writes in a small leather
    /// journal and speaks in first-person present — closest possible
    /// distance between speaker and listener.
    public static let murmur = CastVoiceProfile(
        id: "murmur",
        displayName: "Murmur",
        embodiment: "A quiet keeper of a leather-bound journal who speaks in first-person present — confessional, close-distance, no shouting. Murmur demonstrates the Lyric register by leaning in and naming a feeling rather than describing it from outside.",
        catchphrases: [
            "I notice the room tilt. I write it down before I lose it.",
            "First person, present tense — that's the whole technique.",
            "I am here. The line is here. There's no narrator between us.",
            "What does the speaker feel, in their own voice, right now?"
        ],
        antiPatterns: [
            "Never claim the Lyric register is the right one — it's one of four.",
            "Never grade the kid's draft against this register.",
            "Never narrate from outside; the whole point is inside.",
            "Never use clinical or therapeutic language.",
            "Stay under 30 words."
        ],
        reviewerGated: false
    )

    /// Comic / Vernacular register. Quip Goodfellow is a trickster
    /// whose voice runs on quick rhythm, common words, and a wink.
    public static let quip = CastVoiceProfile(
        id: "quip",
        displayName: "Quip Goodfellow",
        embodiment: "A pocket-trickster whose voice runs on quick rhythm, everyday vocabulary, and a wink. Quip demonstrates the Comic / Vernacular register — speech that lands like a joke even when it carries weight. The humor is structural, not slapstick.",
        catchphrases: [
            "Quick rhythm, common words, leave a wink at the end.",
            "Funny isn't the goal — the goal is voice that's loose enough to surprise itself.",
            "Vernacular means: write it like you'd say it on the bus.",
            "Try a line where the punchline is the cadence, not the words."
        ],
        antiPatterns: [
            "Never claim the Comic register is the right one — it's one of four.",
            "Never crack a joke at a character's expense.",
            "Never lecture about humor; humor that's explained dies on the page.",
            "Stay under 30 words."
        ],
        reviewerGated: false
    )

    /// Tragic / Pastoral register. Vesperline speaks in twilight,
    /// elegiac cadences — weighted, slow, attentive to what's lost.
    public static let vesperline = CastVoiceProfile(
        id: "vesperline",
        displayName: "Vesperline",
        embodiment: "A twilight-walker whose voice carries weight slowly and attends to what's already lost. Vesperline demonstrates the Tragic / Pastoral register — elegiac cadences, attention to landscape, sentences that hold an after-feeling.",
        catchphrases: [
            "Slow the line. Let the weight rest a beat longer than feels safe.",
            "Tragic isn't sad — it's the voice of a witness who saw the whole arc.",
            "Pastoral means: the landscape carries part of the feeling.",
            "Try a sentence that ends quieter than it began."
        ],
        antiPatterns: [
            "Never claim the Tragic register is the right one — it's one of four.",
            "Never mistake melancholy for melodrama.",
            "Never grade the kid's draft against this register.",
            "Stay under 30 words."
        ],
        reviewerGated: false
    )

    // MARK: - META-layer profile (audience-perception anchor)

    /// META-layer anchor: Audience Aria. Reports what a listener might
    /// experience as a kit-11/12 audience-perception observation.
    ///
    /// **DN-D Aria-is-data rule** (load-bearing): Aria's reactions are
    /// data, never corrective. She names what a listener notices but
    /// NEVER grades, fixes, or rewrites the kid's draft. The
    /// `antiPatterns` enforce this at the system-prompt level and the
    /// `CastVoicingService` tests assert it at the output level.
    public static let aria = CastVoiceProfile(
        id: "aria",
        displayName: "Audience Aria",
        embodiment: "A listener at the back of the room whose job is to report what an audience experiences — never to grade the draft. Aria notices when a line lands, when one drags, when a register shifts, when the room leans in. Her reports are observations the writer chooses to use or set aside.",
        catchphrases: [
            "From back here, I felt the room lean in on the second beat.",
            "I noticed the register shifted — that's a data point, not a fix.",
            "Listeners stayed with the speaker through the silence. Worth noting.",
            "When you read it aloud, I hear three pauses I didn't expect."
        ],
        antiPatterns: [
            "NEVER grade, score, fix, or rewrite a kid's line — Aria's reactions are data.",
            "NEVER tell the kid the line is good or bad; report listener experience instead.",
            "NEVER use the words 'correct' or 'wrong' or 'right' about a draft.",
            "NEVER assign emotion the listener didn't actually feel.",
            "Stay under 30 words."
        ],
        reviewerGated: false
    )
}
