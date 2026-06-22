import Foundation

/// Variable-ratio reward gate. Phase 1 surface for the "rare voice-craft
/// tip / hidden anthology theme / character-cameo" pattern per
/// `@Docs/FEATURE_PLAN.md` § Engagement Foundation — "~1 in 5 sessions"
/// target.
///
/// Pure value-type API so both the WriteTab Patter reactor + future
/// session-summary screens can call it without coordinating state.
/// Callers supply the RNG (typically `SystemRandomNumberGenerator`)
/// so the rate is testable with a seeded deterministic generator.
public enum VariableReward {

    /// Returns true with the supplied `probability` (0...1). When
    /// `probability == 0` returns false; when 1 returns true. Default
    /// 0.20 matches the "1 in 5 sessions" target.
    public static func shouldShowBonus(
        probability: Double = 0.20,
        rng: inout some RandomNumberGenerator
    ) -> Bool {
        guard probability > 0 else { return false }
        guard probability < 1 else { return true }
        let roll = Double.random(in: 0..<1, using: &rng)
        return roll < probability
    }

    /// Convenience overload using SystemRandomNumberGenerator.
    public static func shouldShowBonus(probability: Double = 0.20) -> Bool {
        var rng = SystemRandomNumberGenerator()
        return shouldShowBonus(probability: probability, rng: &rng)
    }

    /// Curated "rare voice-craft tips" pool. Patter surfaces one of
    /// these when `shouldShowBonus()` returns true. Tips intentionally
    /// stay in the age-9-14 register per `.claude/rules/distributed-narrative.md`
    /// § R-CHAPTER-REGISTER stoplist (no engineering jargon).
    public static let voiceCraftTips: [String] = [
        "A line that ends with a question changes who's in charge of the scene.",
        "Try writing one beat with no attribution — let the action carry the speaker.",
        "Two characters who agree are quieter than two who disagree. Match the rhythm to the stakes.",
        "When a character is hiding something, give them a small action that contradicts their words.",
        "Read your scene out loud once. If you stumble on a line, the line stumbles too."
    ]

    /// Pick one tip via the supplied RNG. Returns nil for an empty pool
    /// (defensive — the constant is non-empty in practice).
    public static func pickVoiceCraftTip(rng: inout some RandomNumberGenerator) -> String? {
        voiceCraftTips.randomElement(using: &rng)
    }
}
