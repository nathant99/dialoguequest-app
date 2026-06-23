import Foundation
import AIMentor

/// Easter-egg cameo invitations from the DialogueQuest cast. Surfaced at
/// low probability after a publish, alongside the existing variable-reward
/// voice-craft tip. The cameo is mutually exclusive with the tip — when
/// it wins the roll, it replaces the tip in the same Patter-adjacent
/// `MentorBubbleView` overlay so the kid never sees two pop-ups at once.
///
/// Pattern B (per `.claude/rules/distributed-narrative.md` § "Hero
/// mascot vs cast"): Patter remains the protagonist. The cast members
/// (brogue / glance / rest / sprig / weigh) cameo in as Patter's craft
/// friends offering one specific writing nudge tied to their primitive.
/// Each invitation reads as an INVITE TO TRY SOMETHING NEXT TIME, not as
/// grading the just-published tree.
///
/// **Register**: every invitation passes the chapter content register
/// stoplist (per `.claude/rules/distributed-narrative.md` § R-CHAPTER-REGISTER).
/// No engineering jargon, no project-management terms, no reviewer-framework
/// language — age-9-14 reader register only.
///
/// **Gating** (caller responsibility, NOT enforced here so the picker
/// stays a pure value-type):
/// - `dq.experiments.castVoicing` feature flag must be on
/// - `dq.publishedTreeCount >= 2` so the first-publish aha moment isn't
///   muddied by a cameo
public enum CharacterCameoInvitations {

    /// One cameo invitation produced by `pickInvitation(rng:)`. The
    /// `displayName` mirrors the cast voice profile so the bubble can
    /// attribute the message; `castID` is the stable slug for telemetry +
    /// downstream consumption.
    public nonisolated struct Invitation: Sendable, Equatable, Identifiable {
        public let id: UUID
        public let castID: String
        public let displayName: String
        public let message: String

        public init(
            id: UUID = UUID(),
            castID: String,
            displayName: String,
            message: String
        ) {
            self.id = id
            self.castID = castID
            self.displayName = displayName
            self.message = message
        }

        /// Patter-attributed framing used when rendering in the
        /// `MentorBubbleView` overlay. Reads as a single warm sentence the
        /// kid can parse in one beat.
        public var bubbleMessage: String {
            "\(displayName): \(message)"
        }
    }

    /// All invitations the picker draws from. Each cast member has one
    /// or two — kept short so the pool stays curated and the cadence of
    /// repeats feels intentional rather than templated. Exposed as a
    /// computed property (not a stored constant) so tests can iterate
    /// without paying static-init costs and so future register passes
    /// don't trigger a stored-property change.
    public static var allInvitations: [Invitation] {
        [
            Invitation(
                castID: "brogue",
                displayName: "Brogue",
                message: "Try a line where the music slips for one heartbeat. Even calm characters wobble when the room gets quiet."
            ),
            Invitation(
                castID: "brogue",
                displayName: "Brogue",
                message: "Pick one character and write a single line in a voice register they almost never use. See what shifts."
            ),
            Invitation(
                castID: "glance",
                displayName: "Glance",
                message: "Write a line where the words say one thing and the heart says another. I'll be listening underneath."
            ),
            Invitation(
                castID: "glance",
                displayName: "Glance",
                message: "Try a beat where a character lies kindly. The kid reading should feel both layers at once."
            ),
            Invitation(
                castID: "rest",
                displayName: "Rest",
                message: "Take one breath inside the scene. A sigh, a glance at the floor, a hand on the table. Let the room be quiet for a beat."
            ),
            Invitation(
                castID: "rest",
                displayName: "Rest",
                message: "Add one line where nobody speaks. A small action carries the whole moment."
            ),
            Invitation(
                castID: "sprig",
                displayName: "Sprig",
                message: "Add one more branch where a choice goes somewhere brave. Even if the path is short, let it matter."
            ),
            Invitation(
                castID: "sprig",
                displayName: "Sprig",
                message: "Pick a branch you already wrote and write the OTHER kid's answer to the same question. Two roots, one door."
            ),
            Invitation(
                castID: "weigh",
                displayName: "Weigh",
                message: "Try a line where the action does the talking. No 'said' anywhere — just a small move that lands the line."
            ),
            Invitation(
                castID: "weigh",
                displayName: "Weigh",
                message: "Count your tags out loud. If one character carries them all, give a beat to someone else."
            )
        ]
    }

    /// Pick one invitation via the supplied RNG. Returns `nil` for an
    /// empty pool (defensive — the constant is non-empty in practice).
    /// Determinism is the caller's responsibility: pass a
    /// `SeedableRandom` to lock the sequence for tests.
    public static func pickInvitation(
        rng: inout some RandomNumberGenerator
    ) -> Invitation? {
        allInvitations.randomElement(using: &rng)
    }

    /// Convenience overload using `SystemRandomNumberGenerator`.
    public static func pickInvitation() -> Invitation? {
        var rng = SystemRandomNumberGenerator()
        return pickInvitation(rng: &rng)
    }

    /// Probability that a cameo invitation fires on a given publish.
    /// Sized to be RARER than the variable-reward voice-craft tip
    /// (default 0.20 per `VariableReward`) so cameos feel special —
    /// roughly one cameo per ~8 publishes when both gates are open.
    public static let defaultProbability: Double = 0.12

    /// Returns true with the supplied probability. Mirrors
    /// `VariableReward.shouldShowBonus` so call sites can roll the cameo
    /// gate without importing two RNG helpers.
    public static func shouldShowInvitation(
        probability: Double = defaultProbability,
        rng: inout some RandomNumberGenerator
    ) -> Bool {
        guard probability > 0 else { return false }
        guard probability < 1 else { return true }
        let roll = Double.random(in: 0..<1, using: &rng)
        return roll < probability
    }

    /// Minimum `dq.publishedTreeCount` value required before a cameo can
    /// fire. The first publish (count 0 → 1) is the aha-moment slot per
    /// `Docs/FEATURE_PLAN.md` § Onboarding & Child Safety; cameos hold
    /// off until the second publish so they don't dilute it.
    public static let minimumPublishedTreeCount: Int = 2

    /// Every cast slug a `CharacterCameoInvitations.Invitation` may
    /// surface. Used by tests for matrix coverage + by callers wanting
    /// to gate the cameo on the cast member having a `CastVoiceProfile`
    /// registered in `CastVoiceRegistry`.
    public static var coveredCastIDs: Set<String> {
        Set(allInvitations.map(\.castID))
    }

    // MARK: - Discovery cameos
    //
    // Phase Delight micro-delight coverage § Discovery — a single warm
    // hello from a random LESSONS-layer cast member, surfaced once per
    // session via the Write tab `.task`. Distinct copy + selection pool
    // from the post-publish invitations: discovery cameos read as
    // *"glad to see you"*, not *"try this next time"*.

    /// Pool of discovery-cameo hellos, one per LESSONS-layer cast member.
    /// Kept short so the bubble reads in one breath when the kid lands
    /// on the Write tab.
    public static var discoveryCameos: [Invitation] {
        [
            Invitation(
                castID: "brogue",
                displayName: "Brogue",
                message: "Glad to hear you back at the workbench. Listen for the music your characters keep, even when the room goes quiet."
            ),
            Invitation(
                castID: "glance",
                displayName: "Glance",
                message: "Welcome in. I'll be listening underneath the words today — pick a line where the heart says something the mouth won't."
            ),
            Invitation(
                castID: "rest",
                displayName: "Rest",
                message: "Hello, friend. Take a breath before the first line. Silence is a line too."
            ),
            Invitation(
                castID: "sprig",
                displayName: "Sprig",
                message: "Hey, you. Branch boldly today — even a small choice can re-route the whole story."
            ),
            Invitation(
                castID: "weigh",
                displayName: "Weigh",
                message: "Welcome back. Counting tags only counts when one feels off — trust your ear before my scale."
            )
        ]
    }

    /// Pick a discovery cameo via the supplied RNG. Returns `nil` for an
    /// empty pool (defensive). Determinism is the caller's responsibility.
    public static func pickDiscoveryCameo(
        rng: inout some RandomNumberGenerator
    ) -> Invitation? {
        discoveryCameos.randomElement(using: &rng)
    }

    /// Convenience overload using `SystemRandomNumberGenerator`.
    public static func pickDiscoveryCameo() -> Invitation? {
        var rng = SystemRandomNumberGenerator()
        return pickDiscoveryCameo(rng: &rng)
    }

    /// Probability that the discovery cameo fires on a given Write-tab
    /// session-open roll. Sized to feel like a warm coincidence (one in
    /// roughly every three sessions) rather than a guaranteed greeting.
    public static let discoveryDefaultProbability: Double = 0.33

    /// Returns true with the supplied probability. Same shape as
    /// `shouldShowInvitation` for symmetry.
    public static func shouldShowDiscoveryCameo(
        probability: Double = discoveryDefaultProbability,
        rng: inout some RandomNumberGenerator
    ) -> Bool {
        guard probability > 0 else { return false }
        guard probability < 1 else { return true }
        let roll = Double.random(in: 0..<1, using: &rng)
        return roll < probability
    }

    /// Minimum `dq.publishedTreeCount` value required before a discovery
    /// cameo can fire. The first session is the aha-moment slot per
    /// `Docs/FEATURE_PLAN.md` § Onboarding & Child Safety; discovery
    /// cameos hold off until the kid has shipped at least once so the
    /// hello reads as warm rather than forced.
    public static let discoveryMinimumPublishedTreeCount: Int = 1

    /// Cast slugs covered by `discoveryCameos`. Used by tests to assert
    /// every LESSONS-layer cast member is present.
    public static var discoveryCoveredCastIDs: Set<String> {
        Set(discoveryCameos.map(\.castID))
    }
}
