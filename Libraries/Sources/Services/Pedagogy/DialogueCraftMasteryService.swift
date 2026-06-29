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
