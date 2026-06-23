import Foundation
import Models

/// Trauma-informed advisory gate for kid-authored dialogue lines. Closes the
/// Phase Accessibility & Trauma-Informed Polish checkbox *"flag conflict /
/// loss / identity-shame themes before exposing to kid (SAMHSA TIP 57
/// register; off-ramps)"*.
///
/// **Design posture (load-bearing)**: this gate is ADVISORY ONLY. It NEVER:
///
/// - Blocks publication of the kid's draft.
/// - Rewrites or grades the kid's words.
/// - Moralizes "concerning content."
/// - Censors creative conflict (dialogue craft *is* conflict craft — Patter
///   coaches the kid INTO emotional weight, not away from it).
///
/// What it DOES:
///
/// - Surfaces a soft, register-clean banner inviting the kid to take a moment
///   when a strong crisis signal or tender theme appears in the line they
///   typed OR in the mood they tagged.
/// - Routes to the existing `CrisisResourcesProvider` (988 / Childhelp /
///   Crisis Text Line).
/// - De-dupes within a session so a kid writing a tender-themed tree doesn't
///   get a banner per line.
///
/// Per SAMHSA TIP 57 § "Trauma-Informed Care: A Sociocultural Perspective":
/// validate-then-inform / hold-space / refer-up. The advisory copy follows
/// the validate-then-inform pattern — no "we noticed concerning content"
/// (which is the failure-mode register).
///
/// **Lexical surface (deliberately narrow)**: only the strongest crisis cues
/// trigger `.crisisCue`. Common conflict-craft words (`push`, `hurt`, `lost`,
/// `cry`) do NOT trigger anything — the whole point of the app is exploring
/// those exact words in safe creative space. Tender themes (`die / death /
/// gone forever / disappear`) trigger the softer `.tenderTheme` band.
///
/// See `Docs/AUDIT_TRAUMA_INFORMED_GATE_REVIEW_2026-06-23.md` for the
/// authoring review behind the lexical set + SAMHSA TIP 57 mapping.
public nonisolated struct TraumaAxisAdvisoryService: Sendable {

    /// The advisory band surfaced by `inspect(line:mood:)`. Higher band =
    /// more urgent / closer to crisis resources.
    public enum Advisory: Equatable, Sendable {
        /// Strongest band: a near-explicit crisis cue. The banner copy
        /// validates the kid's feeling and surfaces 988 + Childhelp + Crisis
        /// Text Line. Never auto-dialed; always opt-in.
        case crisisCue

        /// Softer band: tender themes (loss / family rupture / despair). The
        /// banner acknowledges the weight + offers a graceful pause +
        /// surfaces the same crisis-resource list under "Need help?"
        case tenderTheme

        /// Reader-facing banner title. Age-9-14 register; no clinical
        /// language; no engineering jargon (per § R-CHAPTER-REGISTER).
        public var bannerTitle: String {
            switch self {
            case .crisisCue:   return "What you're feeling matters."
            case .tenderTheme: return "Heavy beats deserve a quiet breath."
            }
        }

        /// One-line body that invites a pause without grading the draft.
        public var bannerBody: String {
            switch self {
            case .crisisCue:
                return "If something here is real and hard for you too, the people below answer day or night."
            case .tenderTheme:
                return "Writing through hard moments is brave craft. Take a breath. The resources below are here if you want them."
            }
        }

        /// Whether the banner should auto-foreground the crisis-resource
        /// list as part of the same surface (vs requiring an extra tap).
        public var foregroundsResources: Bool {
            switch self {
            case .crisisCue:   return true
            case .tenderTheme: return false
            }
        }
    }

    public init() {}

    /// Inspect a line + the active mood and return an advisory band, or
    /// `nil` when nothing crosses the surface. Pure function; safe to call
    /// per-keystroke (no I/O, no state).
    public func inspect(line: String, mood: DialogueMood?) -> Advisory? {
        let lowered = line.lowercased()

        for cue in Self.crisisCues where lowered.containsCueToken(cue) {
            return .crisisCue
        }

        for theme in Self.tenderThemes where lowered.containsCueToken(theme) {
            return .tenderTheme
        }

        // Mood-only path: `.awkwardSilence` is the canonical "hard scene"
        // marker but does NOT alone trigger an advisory — the kid is
        // already exploring tender territory by design. Surfacing on
        // mood-alone is too eager and breaks the craft loop. The advisory
        // requires a line-level cue to fire.
        _ = mood
        return nil
    }

    // MARK: - Lexical surface
    //
    // Tokens are matched as whole-word-ish substrings — see `containsCueToken`
    // for the matching rule. Kept narrow so the advisory rarely fires on
    // normal craft writing.

    /// Strongest crisis cues. These map to immediate `.crisisCue` band.
    /// Curated against SAMHSA TIP 57's strongest-signal list; reviewed in
    /// `Docs/AUDIT_TRAUMA_INFORMED_GATE_REVIEW_2026-06-23.md`.
    static let crisisCues: [String] = [
        "kill myself",
        "kill himself",
        "kill herself",
        "kill themself",
        "end my life",
        "end it all",
        "want to die",
        "wish i was dead",
        "wish i were dead",
        "no point living",
        "no reason to live",
        "hurt myself",
        "cutting myself",
        "took the pills",
        "took all the pills",
        "running away from home",
        "ran away from home",
        "he hits me",
        "she hits me",
        "they hit me"
    ]

    /// Tender themes — softer band. Surfaces the banner without
    /// foregrounding the resource list as urgently. Curated to AVOID
    /// false-positives on common conflict-craft writing.
    static let tenderThemes: [String] = [
        "gone forever",
        "never coming back",
        "she died",
        "he died",
        "they died",
        "lost my mom",
        "lost my dad",
        "lost my grandma",
        "lost my grandpa",
        "my parents are gone",
        "i miss her so much it hurts",
        "i miss him so much it hurts",
        "everyone leaves me",
        "no one cares about me",
        "i'm worthless",
        "nobody listens"
    ]
}

private extension String {
    /// Match cue tokens as whole-phrase substrings on the lowercased
    /// haystack. The cues are multi-word phrases so word-boundary checks
    /// aren't needed — but we still want to avoid matching across
    /// arbitrary word fragments (e.g., "killing" should NOT match
    /// "kill myself"). Plain `contains` is fine for the multi-word cues
    /// currently shipped.
    nonisolated func containsCueToken(_ cue: String) -> Bool {
        contains(cue)
    }
}
