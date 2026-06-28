import Testing
import Foundation
import Services
import ForgeExperiments
@testable import AppFeature

/// Priority N.3 (2026-07-05) — `ParentProgressDashboardView` reads
/// the assigned variant per definition from `DialogueExperimentsService`
/// and renders one row per cohort assignment under the
/// "Experiment cohorts" section. Transparency, not control — no flag
/// mutation, no @AppStorage write.
///
/// These tests cover the **value-type seam** (`cohortReadouts(from:)`)
/// so the rendering logic is testable without driving the view.
@MainActor
@Suite("ParentProgressDashboardView experiment-cohorts reader")
struct ParentProgressDashboardExperimentCohortsTests {

    /// Pinned-seed service so cohort assignments are deterministic.
    private func makeService(
        seed: String = "pinned-test-seed",
        definitions: [ExperimentDefinition] = DialogueExperimentsService.defaultDefinitions()
    ) -> DialogueExperimentsService {
        // Test-scoped UserDefaults so the seed read-back doesn't collide
        // with the shared singleton's `dq.experiments.installSeed`.
        let suite = "dq.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return DialogueExperimentsService(
            installSeed: seed,
            definitions: definitions,
            userDefaults: defaults
        )
    }

    @Test("readouts cover every definition with a resolved variant")
    func readoutsCoverEveryDefinition() {
        let service = makeService()
        let readouts = ParentProgressDashboardView.cohortReadouts(from: service)
        // Phase 1 ships exactly 2 definitions: castVoicing + thirdCharacter.
        #expect(readouts.count == 2)
        let experimentIDs = Set(readouts.map(\.experimentID))
        #expect(experimentIDs.contains(DialogueExperimentsService.castVoicingExperimentID))
        #expect(experimentIDs.contains(DialogueExperimentsService.thirdCharacterExperimentID))
    }

    @Test("readout for cast-voicing carries the variant name (Control or Treatment)")
    func castVoicingVariantName() {
        let service = makeService()
        let readouts = ParentProgressDashboardView.cohortReadouts(from: service)
        let castVoicing = readouts.first {
            $0.experimentID == DialogueExperimentsService.castVoicingExperimentID
        }
        let unwrapped = try? #require(castVoicing)
        guard let unwrapped else { return }
        // Variant names are canonical reader-friendly strings.
        #expect(["Control", "Treatment"].contains(unwrapped.variantName))
        // Experiment name comes from the catalog so the reader sees a
        // descriptive label, not an opaque ID.
        #expect(unwrapped.experimentName.contains("Cast voicing"))
    }

    @Test("readout count matches `definitions` when every definition resolves")
    func readoutCountMatchesResolvedDefinitions() {
        // Pin a custom catalog with a single definition; verify a single
        // readout. Guards against silently dropping a definition during
        // future refactors.
        let onlyVariant = Variant(
            id: "control",
            name: "Control",
            weight: 100,
            parameters: ["enabled": .bool(false)]
        )
        let onlyDefinition = ExperimentDefinition(
            id: "dq.experiment.demo",
            name: "Demo experiment",
            description: "Single-definition fixture for the readout count test.",
            variants: [onlyVariant],
            startDate: Date(timeIntervalSince1970: 1_700_000_000),
            endDate: Date(timeIntervalSince1970: 1_700_000_000 + 3600 * 24 * 90),
            minimumSessions: 1,
            primaryMetric: .retention(.d7)
        )
        let service = makeService(definitions: [onlyDefinition])
        let readouts = ParentProgressDashboardView.cohortReadouts(from: service)
        #expect(readouts.count == 1)
        #expect(readouts.first?.experimentName == "Demo experiment")
        #expect(readouts.first?.variantName == "Control")
    }

    @Test("empty catalog yields zero readouts (section omits)")
    func emptyCatalog() {
        let service = makeService(definitions: [])
        let readouts = ParentProgressDashboardView.cohortReadouts(from: service)
        #expect(readouts.isEmpty)
    }

    @Test("readouts are stable across calls (deterministic)")
    func readoutsAreStable() {
        let service = makeService()
        let first = ParentProgressDashboardView.cohortReadouts(from: service)
        let second = ParentProgressDashboardView.cohortReadouts(from: service)
        #expect(first == second)
    }

    // MARK: - Priority Q (2026-07-08) — cohort change-history wiring

    private func makeHistory() -> CohortHistoryService {
        let suite = "dq.cohorthist.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return CohortHistoryService(defaults: defaults)
    }

    @Test("sessionsInCohort defaults to 0 when no history is passed")
    func sessionsDefaultZero() {
        let service = makeService()
        let readouts = ParentProgressDashboardView.cohortReadouts(from: service)
        #expect(readouts.allSatisfy { $0.sessionsInCohort == 0 })
    }

    @Test("sessionsInCohort reflects recorded launches when history is passed")
    func sessionsReflectHistory() {
        let service = makeService()
        let history = makeHistory()
        // Record three launches with the same deterministic service.
        history.recordLaunch(from: service)
        history.recordLaunch(from: service)
        history.recordLaunch(from: service)
        let readouts = ParentProgressDashboardView.cohortReadouts(from: service, history: history)
        #expect(readouts.allSatisfy { $0.sessionsInCohort == 3 })
    }
}
