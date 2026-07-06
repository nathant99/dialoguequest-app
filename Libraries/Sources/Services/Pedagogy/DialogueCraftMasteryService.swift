import Foundation
import Models
import ForgeModels
import ForgeGamification
import ForgeMasteryEngine

/// DialogueQuest's adoption of ForgeKit 1.0.0-rc's `ForgeMasteryEngine`
/// adaptive-mastery spine (Priority B).
///
/// Tracks the kid's per-pillar mastery of the six dialogue-craft primitives
/// (`DialogueCraftTopic`) as a `MasteryGraph<DialogueCraftTopic>` + a
/// persisted `[DialogueCraftTopic: TopicMasteryState]`. Each published tree
/// records one `AttemptOutcome` per pillar the tree exercised; the FSRS-6
/// retention state + rolling-window accuracy then drive
/// `NextProblemPicker.recommendations` so Patter's coaching surface can
/// answer "should the kid extend the pillar they're mid-mastering,
/// consolidate one whose retention has decayed, or stretch into a newly
/// unblocked frontier pillar?".
///
/// **Relationship to `DialogueCraftSkillGraph`**: that type is the static
/// `ForgeKnowledgeGraph` curriculum DAG (prerequisites + CCSS/NCAS standards
/// mapping). This service is the *dynamic* layer — per-kid mastery over time.
/// The two share slugs (`DialogueCraftTopic.rawValue == NodeID.*`) so a future
/// `ForgeReporting` join is free.
///
/// **Persistence**: a single `UserDefaults` key under the `dq.*` namespace,
/// JSON-encoding the topic→state dictionary. Mirrors
/// `PublishedTreeSnapshotStore` / `VoicePatternHistoryService` — `@MainActor`
/// final class, `.shared` singleton, value-type read API. Encode / decode
/// failures route through `DialogueQuestDebugLog.data` (silent-fail
/// detection) and degrade to empty state rather than crashing.
///
/// **No PII / no outbound**: every field is a categorical topic slug or a
/// clamped 0...1 mastery score. Nothing leaves the device.
@MainActor
public final class DialogueCraftMasteryService {
    public static let shared = DialogueCraftMasteryService()

    /// `UserDefaults` key. Public so tests + dashboard readers reference the
    /// canonical key.
    public nonisolated static let defaultsKey = "dq.craftMasteryStates"

    /// Mastery score at which a pillar is considered "solid enough" to unlock
    /// its dependents. Matches `NextProblemPicker.Configuration` default so
    /// the frontier the picker reasons over agrees with `masteredTopics()`.
    public nonisolated static let masteryThreshold: Double = 0.85

    /// Neutral per-attempt elapsed time. DialogueQuest doesn't measure
    /// per-pillar solve time (a published tree isn't a timed problem), so a
    /// neutral value keeps the `isRacingAhead` / `isStuck` time heuristics
    /// from firing spuriously — mastery derives from FSRS retrievability +
    /// recent accuracy, not time.
    private nonisolated static let neutralElapsed: Double = 12.0

    private let defaults: UserDefaults
    private let srs: SpacedRepetitionEngine
    private let updater: MasteryUpdater<DialogueCraftTopic>
    /// Built once at init. Optional so a (provably-impossible for the static
    /// node set) build failure degrades to "no recommendations" instead of a
    /// force-unwrap crash.
    private let graph: MasteryGraph<DialogueCraftTopic>?

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.srs = SpacedRepetitionEngine(desiredRetention: 0.9)
        self.updater = MasteryUpdater(recentWindowSize: 8)
        self.graph = Self.buildGraph()
    }

    // MARK: - Recording

    /// Record a freshly published tree as one attempt per exercised pillar.
    ///
    /// Mapping (all derived from telemetry the publish path already computes):
    /// - **voiceConsistency** ← `averageVoiceMatch` (every tree has voice)
    /// - **branchMeaningfulness** ← `reflectionRatio` (every tree has branch
    ///   structure; the publish path passes the 0.5 midpoint when a tree has
    ///   no branch points so a trivial tree neither ramps nor tanks the pillar)
    /// - **tagBalance** ← `dominantTagAbsent` (balanced attribution = correct)
    /// - **subtextDetection** ← recorded ONLY when the kid confirmed at least
    ///   one subtext (a tree with no subtext focus didn't attempt the pillar)
    /// - **multiListenerSubtext** + **triangleDynamics** ← recorded only for
    ///   3+ character trees (the pillars a trio exercises), scored off voice
    public func recordPublishedTree(
        averageVoiceMatch: Double,
        reflectionRatio: Double,
        dominantTagAbsent: Bool,
        subtextConfirmed: Bool,
        characterCount: Int,
        now: Date = .now
    ) {
        var state = decoded()
        record(&state, .voiceConsistency, outcome(forScore: averageVoiceMatch), now)
        record(&state, .branchMeaningfulness, outcome(forScore: reflectionRatio), now)
        record(
            &state,
            .tagBalance,
            dominantTagAbsent
                ? .correctFirstTry(elapsedSeconds: Self.neutralElapsed)
                : .incorrect(elapsedSeconds: Self.neutralElapsed),
            now
        )
        if subtextConfirmed {
            record(&state, .subtextDetection, .correctFirstTry(elapsedSeconds: Self.neutralElapsed), now)
        }
        if characterCount >= 3 {
            record(&state, .multiListenerSubtext, outcome(forScore: averageVoiceMatch), now)
            record(&state, .triangleDynamics, outcome(forScore: averageVoiceMatch), now)
        }
        persist(state)
    }

    /// Test seam + parental-controls reset hook. Wipes every pillar's state.
    public func reset() {
        defaults.removeObject(forKey: Self.defaultsKey)
    }

    // MARK: - Reading

    /// Derived mastery score (0...1) for one pillar. `0` for a never-attempted
    /// pillar.
    public func masteryScore(for topic: DialogueCraftTopic) -> Double {
        decoded()[topic]?.masteryScore ?? 0
    }

    /// Full persisted state for one pillar, or `nil` if never attempted.
    public func state(for topic: DialogueCraftTopic) -> TopicMasteryState? {
        decoded()[topic]
    }

    /// Pillars whose mastery has reached `masteryThreshold`.
    public func masteredTopics() -> Set<DialogueCraftTopic> {
        guard let graph else { return [] }
        return graph.masteredTopics(atOrAbove: Self.masteryThreshold, state: decoded())
    }

    /// Up to three coaching recommendations (extend / consolidate / stretch).
    /// Empty when no eligible pillar can be surfaced (e.g. fresh install with
    /// nothing attempted yet, or everything mastered).
    public func recommendations() -> [NextProblemPicker<DialogueCraftTopic, DialogueCraftTopic>.Recommendation] {
        guard let graph else { return [] }
        let picker = NextProblemPicker(
            graph: graph,
            problemsByTopic: Self.problemsByTopic
        )
        return picker.recommendations(state: decoded())
    }

    /// The single pillar Patter should suggest the kid focus on next, or
    /// `nil` when there's nothing to recommend. Prefers the `.extend`
    /// (actively-working, edge-of-competence) rationale because
    /// `recommendations()` orders extend → consolidate → stretch.
    public func nextFocusTopic() -> DialogueCraftTopic? {
        recommendations().first?.topic
    }

    // MARK: - Patter-bubble focus nudge (B-follow)

    /// Minimum number of published trees before the kid-facing Patter-bubble
    /// focus nudge is eligible. A brand-new install surfaces a `.stretch`
    /// recommendation immediately (the FSRS frontier always offers a starting
    /// suggestion), so `nextFocusTopic()` is non-nil from launch — gating the
    /// nudge on `nextFocusTopic() != nil` would fire it before the kid has any
    /// real mastery signal. Gate on a genuine "has published a few times"
    /// signal instead. Matches `PatterCallbackService`'s history threshold.
    public nonisolated static let minimumPublishedForFocusNudge = 3

    /// Probability the focus nudge fills the shared Patter-bubble slot on a
    /// publish, when eligible. Sized to match the other low-probability bubble
    /// paths (callback / voice-pattern / seasonal at 0.08) so it feels special
    /// rather than nagging.
    public nonisolated static let focusNudgeProbability: Double = 0.08

    /// Slot-gate roll for the focus nudge. Pure value-type; takes the caller's
    /// RNG so the `WriteTabView` publish path threads one generator through
    /// every mutually-exclusive bubble path. Pass a `SeedableRandom` in tests.
    public nonisolated static func shouldShowFocusNudge(
        probability: Double = focusNudgeProbability,
        rng: inout some RandomNumberGenerator
    ) -> Bool {
        guard probability > 0 else { return false }
        guard probability < 1 else { return true }
        let roll = Double.random(in: 0..<1, using: &rng)
        return roll < probability
    }

    /// A warm, kid-facing one-line invitation to lean into the pillar Patter
    /// suggests focusing on next, or `nil` when the picker has nothing to
    /// recommend. Calls `recommendations()` exactly ONCE (via
    /// `nextFocusTopic()`) per the picker-non-determinism gotcha — never call
    /// it again expecting parity. Register-stoplist clean (no engineering /
    /// FSRS / picker-rationale jargon reaches the bubble).
    public func nextFocusNudge() -> String? {
        guard let topic = nextFocusTopic() else { return nil }
        return Self.focusNudgeLine(for: topic)
    }

    /// The kid-facing focus-nudge line for one pillar, voiced by the cast
    /// member who embodies it (per Pattern B distributed narrative) when one
    /// exists — so the nudge composes with the cameo system rather than always
    /// speaking as Patter. Brogue (voice consistency) invites toward voice
    /// consistency, Glance toward subtext, Weigh toward tag balance, Sprig
    /// toward branch craft. `triangleDynamics` emerges from the trio and has no
    /// single embodiment, so it falls back to Patter.
    ///
    /// The cast display name is the capitalized `castEmbodiment` slug
    /// (`brogue` → `Brogue`) — kept here rather than reaching into
    /// `AIMentor.CastVoiceRegistry` so `Services` never has to import the
    /// FoundationModels-gated module. Register-stoplist clean: cast names are
    /// warm narrative, not engineering jargon.
    public nonisolated static func focusNudgeLine(for topic: DialogueCraftTopic) -> String {
        let inviter = topic.castEmbodiment?.capitalized ?? "Patter"
        return "\(inviter) has an idea for next time — a conversation that leans into \(topic.displayName.lowercased())."
    }

    /// A gentle "start here" line for the Progress tab's empty state — shown
    /// before the kid has published anything (all mastery bars at zero), naming
    /// the pillar the picker suggests beginning with. Distinct from
    /// `focusNudgeLine` ("next time") because there is no "this time" yet.
    /// Voiced by the pillar's cast member on the same rule as `focusNudgeLine`.
    public nonisolated static func startNudgeLine(for topic: DialogueCraftTopic) -> String {
        let inviter = topic.castEmbodiment?.capitalized ?? "Patter"
        return "\(inviter) suggests starting with a conversation that leans into \(topic.displayName.lowercased())."
    }

    // MARK: - Dashboard readouts (B-follow)

    /// A per-pillar mastery bar for the kid's Progress tab. `score` is the
    /// derived 0...1 mastery; `isMastered` reflects `masteryThreshold`.
    public nonisolated struct CraftMasteryReadout: Sendable, Identifiable, Equatable {
        public let topic: DialogueCraftTopic
        public let score: Double
        public let isMastered: Bool
        public var id: DialogueCraftTopic { topic }
        public var displayName: String { topic.displayName }

        public init(topic: DialogueCraftTopic, score: Double, isMastered: Bool) {
            self.topic = topic
            self.score = score
            self.isMastered = isMastered
        }
    }

    /// One coaching recommendation projected for a reader-facing surface (the
    /// parent dashboard's three-card extend / consolidate / stretch layout).
    /// Copy is age-9-14 / parent register — no engineering jargon per
    /// `.claude/rules/distributed-narrative.md` § R-CHAPTER-REGISTER.
    public nonisolated struct CraftRecommendationReadout: Sendable, Identifiable, Equatable {
        public enum Kind: String, Sendable, Equatable {
            case extend, consolidate, stretch
        }
        public let topic: DialogueCraftTopic
        public let kind: Kind
        public let headline: String
        public let detail: String
        public var id: DialogueCraftTopic { topic }

        public init(topic: DialogueCraftTopic, kind: Kind, headline: String, detail: String) {
            self.topic = topic
            self.kind = kind
            self.headline = headline
            self.detail = detail
        }
    }

    /// Per-pillar mastery bars for all six craft primitives, in the canonical
    /// `DialogueCraftTopic.allCases` order. A never-attempted pillar reads `0`.
    /// The Progress-tab surface gates its own visibility on whether ANY bar is
    /// non-zero (i.e. the kid has published at least once).
    public func masteryReadouts() -> [CraftMasteryReadout] {
        let states = decoded()
        let mastered = masteredTopics()
        return DialogueCraftTopic.allCases.map { topic in
            CraftMasteryReadout(
                topic: topic,
                score: states[topic]?.masteryScore ?? 0,
                isMastered: mastered.contains(topic)
            )
        }
    }

    /// Up to three reader-facing coaching cards (extend / consolidate /
    /// stretch), one per `NextProblemPicker.SelectionRationale`. Empty when the
    /// picker has nothing to surface (fresh install, or everything solid).
    /// Preserves the picker's extend → consolidate → stretch ordering.
    public func recommendationReadouts() -> [CraftRecommendationReadout] {
        recommendations().map { recommendation in
            Self.readout(for: recommendation.topic, rationale: recommendation.rationale)
        }
    }

    private nonisolated static func readout(
        for topic: DialogueCraftTopic,
        rationale: NextProblemPicker<DialogueCraftTopic, DialogueCraftTopic>.SelectionRationale
    ) -> CraftRecommendationReadout {
        let name = topic.displayName
        switch rationale {
        case .extend:
            return CraftRecommendationReadout(
                topic: topic,
                kind: .extend,
                headline: "Keep building: \(name)",
                detail: "\(name) is right at the edge of what your writer has — a great skill to keep practising."
            )
        case .consolidate:
            return CraftRecommendationReadout(
                topic: topic,
                kind: .consolidate,
                headline: "Worth revisiting: \(name)",
                detail: "It has been a while since \(name) came up. A quick refresher will help it stick."
            )
        case .stretch:
            return CraftRecommendationReadout(
                topic: topic,
                kind: .stretch,
                headline: "Ready to stretch: \(name)",
                detail: "\(name) just opened up. Your writer's earlier skills set them up to try it."
            )
        }
    }

    // MARK: - Outcome mapping

    private func record(
        _ state: inout [DialogueCraftTopic: TopicMasteryState],
        _ topic: DialogueCraftTopic,
        _ outcome: AttemptOutcome,
        _ now: Date
    ) {
        let prior = state[topic] ?? TopicMasteryState()
        state[topic] = updater.recordAttempt(
            topic: topic,
            outcome: outcome,
            state: prior,
            srs: srs,
            now: now
        )
    }

    /// Map a 0...1 craft score to an `AttemptOutcome`. ≥ 0.85 reads as a
    /// clean solve, ≥ 0.5 as a solve-with-help, below as incorrect.
    private func outcome(forScore score: Double) -> AttemptOutcome {
        if score >= 0.85 { return .correctFirstTry(elapsedSeconds: Self.neutralElapsed) }
        if score >= 0.5 { return .correctWithHints(hintCount: 1, elapsedSeconds: Self.neutralElapsed) }
        return .incorrect(elapsedSeconds: Self.neutralElapsed)
    }

    // MARK: - Graph

    /// Each pillar maps to itself as its single synthetic "problem" — in
    /// DialogueQuest the next problem to surface IS the next tree to write
    /// focusing on that pillar, so the picker only needs a non-empty bank per
    /// topic to return a recommendation.
    private nonisolated static let problemsByTopic: [DialogueCraftTopic: [DialogueCraftTopic]] =
        Dictionary(uniqueKeysWithValues: DialogueCraftTopic.allCases.map { ($0, [$0]) })

    /// Build the canonical mastery graph. Prerequisites mirror the
    /// `.required` edges of `DialogueCraftSkillGraph` (the `.recommended`
    /// edges stay soft — they don't gate the frontier). Returns `nil` only on
    /// the (impossible for this static, acyclic, fully-resolved node set)
    /// build failure; callers degrade to no recommendations.
    private nonisolated static func buildGraph() -> MasteryGraph<DialogueCraftTopic>? {
        let nodes: [MasteryGraph<DialogueCraftTopic>.Node] = [
            .init(topic: .voiceConsistency, prerequisites: [],
                  bloomLevel: .analyze, displayName: DialogueCraftTopic.voiceConsistency.displayName),
            .init(topic: .subtextDetection, prerequisites: [.voiceConsistency],
                  bloomLevel: .analyze, displayName: DialogueCraftTopic.subtextDetection.displayName),
            .init(topic: .tagBalance, prerequisites: [],
                  bloomLevel: .apply, displayName: DialogueCraftTopic.tagBalance.displayName),
            .init(topic: .branchMeaningfulness, prerequisites: [.voiceConsistency],
                  bloomLevel: .create, displayName: DialogueCraftTopic.branchMeaningfulness.displayName),
            .init(topic: .multiListenerSubtext, prerequisites: [.subtextDetection],
                  bloomLevel: .evaluate, displayName: DialogueCraftTopic.multiListenerSubtext.displayName),
            .init(topic: .triangleDynamics, prerequisites: [.voiceConsistency],
                  bloomLevel: .create, displayName: DialogueCraftTopic.triangleDynamics.displayName)
        ]
        do {
            return try MasteryGraph(nodes: nodes)
        } catch {
            DialogueQuestDebugLog.error(
                "DialogueCraftMasteryService.buildGraph — graph build failed; recommendations disabled",
                error: error
            )
            return nil
        }
    }

    // MARK: - Persistence helpers

    private func decoded() -> [DialogueCraftTopic: TopicMasteryState] {
        guard let data = defaults.data(forKey: Self.defaultsKey) else {
            return [:]
        }
        do {
            return try JSONDecoder().decode([DialogueCraftTopic: TopicMasteryState].self, from: data)
        } catch {
            DialogueQuestDebugLog.data("DialogueCraftMasteryService.decoded — decode failed; treating as empty", error: error)
            return [:]
        }
    }

    private func persist(_ state: [DialogueCraftTopic: TopicMasteryState]) {
        do {
            let encoded = try JSONEncoder().encode(state)
            defaults.set(encoded, forKey: Self.defaultsKey)
        } catch {
            DialogueQuestDebugLog.data("DialogueCraftMasteryService.persist — encode failed; mastery not persisted this publish", error: error)
        }
    }
}
