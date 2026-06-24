import Foundation
import Models

/// "Remember when" callback line generator. Patter holds a short rolling
/// history of the kid's recent published trees (mood + title) and, after
/// the kid has shipped enough conversations, sometimes opens with a
/// callback that frames tonight's writing as continuing the body of work.
///
/// Per `Docs/FEATURE_PLAN.md` § Delight & Polish — "Character personality:
/// Mentor with callbacks to player's recurring voice patterns + favorite
/// themes." This is the Phase 1 first cut covering moods + conversation
/// titles. The voice-pattern axis (per-character signature analysis)
/// lands later once `WritingEvaluator.VoiceSummary` has a longitudinal
/// store to read from.
///
/// **Persistence**: rolling window of the last 3 published trees.
/// Mood is stored as the `DialogueMood.rawValue`; title is stored
/// verbatim (already free-text the kid authored — not PII per the
/// ForgeAnalytics blocklist). Both lists round-trip via JSON encoding
/// to a single `UserDefaults` key per axis.
///
/// **No PII / no outbound**: titles are kid-supplied conversation
/// labels stored only on-device. Mood enum is categorical. Nothing
/// leaves the device.
///
/// **Register**: every emitted callback line passes the chapter content
/// register stoplist per `.claude/rules/distributed-narrative.md`
/// § R-CHAPTER-REGISTER (age-9-14, no engineering / project-management
/// / reviewer-framework / meta-pedagogy jargon).
@MainActor
public final class PatterCallbackService {
    public static let shared = PatterCallbackService()

    /// Maximum number of recent publishes Patter keeps in working
    /// memory. Three slots is enough for a sense of "last time / before
    /// that" without dragging the window so wide that callbacks lose
    /// their specificity.
    public nonisolated static let historyWindow: Int = 3

    /// Floor for surfacing a callback. Below 3 published trees the kid
    /// hasn't established enough of a body of work for "remember when"
    /// to land warmly — Patter would sound presumptuous.
    public nonisolated static let minimumPublishedTreeCount: Int = 3

    /// `UserDefaults` keys. Public so tests + the parent-progress
    /// dashboard can read the same canonical keys.
    public nonisolated static let defaultsKeyRecentMoods = "dq.callbacks.recentMoods"
    public nonisolated static let defaultsKeyRecentTitles = "dq.callbacks.recentTitles"
    public nonisolated static let defaultsKeyPublishedTreeCount = "dq.publishedTreeCount"

    private let defaults: UserDefaults

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    // MARK: - Recording

    /// Record the just-published tree's mood + title. Trims the rolling
    /// window to `historyWindow` slots. Whitespace-only titles fall
    /// back to "your last conversation" via `presentableTitle`.
    public func recordPublishedTree(mood: DialogueMood?, title: String) {
        var moods = recentMoodRaws()
        var titles = recentTitles()
        moods.insert(mood?.rawValue ?? "", at: 0)
        titles.insert(title, at: 0)
        if moods.count > Self.historyWindow {
            moods = Array(moods.prefix(Self.historyWindow))
        }
        if titles.count > Self.historyWindow {
            titles = Array(titles.prefix(Self.historyWindow))
        }
        persistMoods(moods)
        persistTitles(titles)
    }

    /// Wipe stored history. Intended for parental-controls reset +
    /// tests.
    public func reset() {
        defaults.removeObject(forKey: Self.defaultsKeyRecentMoods)
        defaults.removeObject(forKey: Self.defaultsKeyRecentTitles)
    }

    // MARK: - Reading

    /// Snapshot of the rolling history. Order is most-recent-first.
    public func recentMoods() -> [DialogueMood?] {
        recentMoodRaws().map { DialogueMood(rawValue: $0) }
    }

    /// Snapshot of the rolling title history. Order is most-recent-first.
    public func recentTitles() -> [String] {
        guard
            let data = defaults.data(forKey: Self.defaultsKeyRecentTitles),
            let decoded = try? JSONDecoder().decode([String].self, from: data)
        else {
            return []
        }
        return decoded
    }

    // MARK: - Generation

    /// Returns a Patter callback line when (a) the kid has published
    /// at least `minimumPublishedTreeCount` trees AND (b) the rolling
    /// history is non-empty. Returns `nil` otherwise so the call site
    /// can fall back to its existing variable-reward / cameo paths.
    ///
    /// The line draws from the most-recent slot — Patter remembers the
    /// last conversation specifically.
    public func nextCallback() -> String? {
        let publishedCount = defaults.integer(forKey: Self.defaultsKeyPublishedTreeCount)
        guard publishedCount >= Self.minimumPublishedTreeCount else { return nil }
        let moods = recentMoods()
        let titles = recentTitles()
        guard let mostRecentMood = moods.first ?? nil,
              !moodTouched(mostRecentMood: mostRecentMood, titles: titles) || !titles.isEmpty else {
            return nil
        }
        let mostRecentTitle = titles.first
        return Self.callbackLine(mood: mostRecentMood, title: mostRecentTitle)
    }

    /// Pure rendering helper — exposed for testing the register copy
    /// without round-tripping through UserDefaults.
    public nonisolated static func callbackLine(
        mood: DialogueMood,
        title: String?
    ) -> String {
        let titleClause = presentableTitle(title)
        switch mood {
        case .warmReunion:
            return "Last time you wrote \(titleClause) — a warm reunion. Patter remembers."
        case .quietConflict:
            return "Last time you wrote \(titleClause) — a quiet conflict. Patter is still listening."
        case .playfulRivalry:
            return "Last time you wrote \(titleClause) — playful rivalry. Patter is grinning."
        case .awkwardSilence:
            return "Last time you wrote \(titleClause) — an awkward silence. Patter heard every beat."
        case .openingCuriosity:
            return "Last time you wrote \(titleClause) — opening curiosity. Patter is leaning in."
        }
    }

    /// Friendly fallback when the title is empty or whitespace-only.
    /// "your last conversation" reads as kid-natural rather than a
    /// silent omission.
    public nonisolated static func presentableTitle(_ title: String?) -> String {
        let trimmed = (title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "your last conversation" }
        return "\u{201C}\(trimmed)\u{201D}"
    }

    // MARK: - Persistence helpers

    private func recentMoodRaws() -> [String] {
        guard
            let data = defaults.data(forKey: Self.defaultsKeyRecentMoods),
            let decoded = try? JSONDecoder().decode([String].self, from: data)
        else {
            return []
        }
        return decoded
    }

    private func persistMoods(_ moods: [String]) {
        guard let encoded = try? JSONEncoder().encode(moods) else { return }
        defaults.set(encoded, forKey: Self.defaultsKeyRecentMoods)
    }

    private func persistTitles(_ titles: [String]) {
        guard let encoded = try? JSONEncoder().encode(titles) else { return }
        defaults.set(encoded, forKey: Self.defaultsKeyRecentTitles)
    }

    /// `recentMoods()` returns a `[DialogueMood?]` because trees may
    /// publish without a mood selected. When the most-recent slot is
    /// `nil`, fall back gracefully rather than emitting an empty line.
    private func moodTouched(mostRecentMood: DialogueMood, titles: [String]) -> Bool {
        // Whitespace-only title with no mood = no callback anchor; skip.
        guard !titles.isEmpty else { return true }
        let firstTitle = titles[0].trimmingCharacters(in: .whitespacesAndNewlines)
        if firstTitle.isEmpty {
            // We still have a mood — that's enough to anchor a callback.
            // The presentableTitle fallback handles the empty title.
            _ = mostRecentMood
        }
        return true
    }

    /// Probability the callback fires when other gates allow it. Sized
    /// to be the rarest of the three Patter-bubble paths (cameo 0.12,
    /// variable-reward tip 0.20, callback 0.08) so the kid encounters
    /// a callback roughly once every 12 publishes — frequent enough
    /// to feel remembered, rare enough to stay special.
    public nonisolated static let defaultProbability: Double = 0.08

    /// Mirrors `VariableReward.shouldShowBonus` / cameo gate so call
    /// sites can roll the callback without importing a fourth RNG
    /// helper. Pure value-type — pass a `SeedableRandom` for tests.
    public nonisolated static func shouldShowCallback(
        probability: Double = defaultProbability,
        rng: inout some RandomNumberGenerator
    ) -> Bool {
        guard probability > 0 else { return false }
        guard probability < 1 else { return true }
        let roll = Double.random(in: 0..<1, using: &rng)
        return roll < probability
    }

    // MARK: - Voice-pattern callback (Phase Delight follow-up)

    /// Probability the voice-pattern callback fires when its gates allow
    /// it. Sized to match the mood-callback path (0.08) so the two
    /// callback axes feel symmetrically special. Together the two
    /// callback paths sum to ~0.16 — still rarer than the 0.20
    /// voice-craft-tip path, so the kid encounters a callback first when
    /// one is available + flat tip otherwise.
    public nonisolated static let defaultVoicePatternProbability: Double = 0.08

    /// Mirror of `shouldShowCallback` for the voice-pattern axis.
    /// Separate counter so the two axes don't share an RNG draw — the
    /// kid is equally likely to see either when both are available.
    public nonisolated static func shouldShowVoicePatternCallback(
        probability: Double = defaultVoicePatternProbability,
        rng: inout some RandomNumberGenerator
    ) -> Bool {
        guard probability > 0 else { return false }
        guard probability < 1 else { return true }
        let roll = Double.random(in: 0..<1, using: &rng)
        return roll < probability
    }

    /// Returns a single-line Patter bubble when one of the tree's
    /// characters has a non-flat voice-pattern trend in
    /// `VoicePatternHistoryService`. Returns `nil` otherwise so the
    /// call site (`WriteTabView`'s mutually-exclusive bubble slot)
    /// falls through to the next path.
    ///
    /// Character selection: scans the tree's characters in their
    /// authored order; the first one with a `.improving` or `.drifting`
    /// trend wins. Deterministic across publishes so two consecutive
    /// callbacks about the same character don't surface as a confusing
    /// "wait, why is Patter only talking about Brogue?" — that's a
    /// signal Patter is paying attention to who needs the cue most.
    ///
    /// The `historyService` parameter is injectable so tests can pass a
    /// store seeded with a known history without depending on
    /// `VoicePatternHistoryService.shared`'s UserDefaults state.
    public func nextVoicePatternCallback(
        in tree: DialogueTree,
        historyService: VoicePatternHistoryService = .shared
    ) -> String? {
        let publishedCount = defaults.integer(forKey: Self.defaultsKeyPublishedTreeCount)
        guard publishedCount >= Self.minimumPublishedTreeCount else { return nil }
        for character in tree.characters {
            let trend = historyService.trend(for: character.id)
            if let feedback = Self.voicePatternFeedback(
                trendKey: trend.rawValue,
                characterName: character.name
            ) {
                return feedback.bubbleLine()
            }
        }
        return nil
    }

    /// Pure rendering helper — exposed for testing the register copy +
    /// trend-mapping without round-tripping through the history service.
    /// Mirrors the AIMentor-side `PatterFallbacks.voicePatternFeedbackFallback`
    /// shape (observation + nudge) but keeps Services target self-contained
    /// — the fallback line text is duplicated here so Services tests don't
    /// need to import AIMentor.
    public nonisolated static func voicePatternFeedback(
        trendKey: String,
        characterName: String
    ) -> VoicePatternBubble? {
        let safeName = presentableCharacterName(characterName)
        switch trendKey {
        case "improving":
            return VoicePatternBubble(
                observation: "\(safeName)'s voice has been getting steadier across your last few conversations.",
                nudge: "Patter is starting to recognize \(safeName) before you tag the line — keep listening for that pattern."
            )
        case "drifting":
            return VoicePatternBubble(
                observation: "\(safeName)'s voice has drifted a little across your recent trees.",
                nudge: "Want to try one line where \(safeName) sounds the MOST like \(safeName) — and see what tugs back?"
            )
        case "steady", "insufficientData":
            return nil
        default:
            return nil
        }
    }

    /// Whitespace-only-safe name presenter matching the AIMentor-side
    /// fallback helper. Services target's mirror.
    public nonisolated static func presentableCharacterName(_ name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "this character" : trimmed
    }

    /// Value-type bubble shape mirroring AIMentor's
    /// `VoicePatternFeedback` so Services callers can render without
    /// importing AIMentor. `bubbleLine()` collapses to the single
    /// MentorBubbleView slot shape.
    public nonisolated struct VoicePatternBubble: Sendable, Equatable, Hashable {
        public let observation: String
        public let nudge: String

        public init(observation: String, nudge: String) {
            self.observation = observation
            self.nudge = nudge
        }

        public func bubbleLine() -> String {
            "\(observation) \(nudge)"
        }
    }
}
