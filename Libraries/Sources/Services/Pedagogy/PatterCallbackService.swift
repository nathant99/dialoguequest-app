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
}
