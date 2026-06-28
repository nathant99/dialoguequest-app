import Testing
import Foundation
import ForgeExperiments
@testable import Services

@MainActor
@Suite("CohortHistoryService")
struct CohortHistoryServiceTests {

    private func makeDefaults() -> UserDefaults {
        let suite = "CohortHistoryServiceTests.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return defaults
    }

    /// Pinned-seed experiments service on isolated defaults.
    private func makeExperiments(
        seed: String = "pinned-cohort-seed",
        definitions: [ExperimentDefinition] = DialogueExperimentsService.defaultDefinitions()
    ) -> DialogueExperimentsService {
        let suite = "dq.exp.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        return DialogueExperimentsService(
            installSeed: seed,
            definitions: definitions,
            userDefaults: defaults
        )
    }

    @Test("fresh service has no history")
    func freshEmpty() {
        let store = CohortHistoryService(defaults: makeDefaults())
        #expect(store.history(forExperimentID: DialogueExperimentsService.castVoicingExperimentID).isEmpty)
        #expect(store.currentVariantID(forExperimentID: DialogueExperimentsService.castVoicingExperimentID) == nil)
        #expect(store.consecutiveSessions(forExperimentID: DialogueExperimentsService.castVoicingExperimentID) == 0)
    }

    @Test("recordLaunch records one entry per definition")
    func recordsEveryDefinition() {
        let store = CohortHistoryService(defaults: makeDefaults())
        let experiments = makeExperiments()
        store.recordLaunch(from: experiments, now: Date(timeIntervalSince1970: 1000))
        #expect(store.history(forExperimentID: DialogueExperimentsService.castVoicingExperimentID).count == 1)
        #expect(store.history(forExperimentID: DialogueExperimentsService.thirdCharacterExperimentID).count == 1)
    }

    @Test("consecutiveSessions counts a fixed cohort across launches")
    func consecutiveFixedCohort() {
        let store = CohortHistoryService(defaults: makeDefaults())
        let experiments = makeExperiments()
        // Deterministic seed => same variant every launch.
        for i in 0..<4 {
            store.recordLaunch(from: experiments, now: Date(timeIntervalSince1970: Double(1000 + i)))
        }
        let id = DialogueExperimentsService.castVoicingExperimentID
        #expect(store.consecutiveSessions(forExperimentID: id) == 4)
        // currentVariantID matches the deterministic assignment.
        #expect(store.currentVariantID(forExperimentID: id) == experiments.variant(forExperimentID: id)?.id)
    }

    @Test("consecutiveSessions resets when the variant changes")
    func consecutiveResetsOnChange() {
        let defaults = makeDefaults()
        let store = CohortHistoryService(defaults: defaults)
        let id = "dq.experiment.demo"

        // Build a service whose single definition resolves to "control".
        let control = Variant(id: "control", name: "Control", weight: 100, parameters: [:])
        let controlDef = ExperimentDefinition(
            id: id, name: "Demo", description: "d",
            variants: [control],
            startDate: Date(timeIntervalSince1970: 1_700_000_000),
            endDate: Date(timeIntervalSince1970: 1_700_000_000 + 3600),
            minimumSessions: 1, primaryMetric: .retention(.d7)
        )
        let controlService = makeExperiments(definitions: [controlDef])
        store.recordLaunch(from: controlService, now: Date(timeIntervalSince1970: 1000))
        store.recordLaunch(from: controlService, now: Date(timeIntervalSince1970: 1001))

        // Re-bucket: a new definition that resolves to "treatment".
        let treatment = Variant(id: "treatment", name: "Treatment", weight: 100, parameters: [:])
        let treatmentDef = ExperimentDefinition(
            id: id, name: "Demo", description: "d",
            variants: [treatment],
            startDate: Date(timeIntervalSince1970: 1_700_000_000),
            endDate: Date(timeIntervalSince1970: 1_700_000_000 + 3600),
            minimumSessions: 1, primaryMetric: .retention(.d7)
        )
        let treatmentService = makeExperiments(definitions: [treatmentDef])
        store.recordLaunch(from: treatmentService, now: Date(timeIntervalSince1970: 1002))

        // Most recent is treatment => run-length 1 since the change.
        #expect(store.currentVariantID(forExperimentID: id) == "treatment")
        #expect(store.consecutiveSessions(forExperimentID: id) == 1)
        // Full history retains all three entries (most-recent-first).
        #expect(store.history(forExperimentID: id).count == 3)
    }

    @Test("history caps at the window, dropping oldest")
    func ringCap() {
        let store = CohortHistoryService(defaults: makeDefaults())
        let experiments = makeExperiments()
        let window = CohortHistoryService.historyWindow
        for i in 0..<(window + 5) {
            store.recordLaunch(from: experiments, now: Date(timeIntervalSince1970: Double(i)))
        }
        #expect(store.history(forExperimentID: DialogueExperimentsService.castVoicingExperimentID).count == window)
    }

    @Test("reset clears history")
    func resetClears() {
        let store = CohortHistoryService(defaults: makeDefaults())
        store.recordLaunch(from: makeExperiments())
        store.reset()
        #expect(store.history(forExperimentID: DialogueExperimentsService.castVoicingExperimentID).isEmpty)
    }

    @Test("persistence survives a new store instance on same defaults")
    func persistsAcrossInstances() {
        let defaults = makeDefaults()
        let experiments = makeExperiments()
        let writer = CohortHistoryService(defaults: defaults)
        writer.recordLaunch(from: experiments)
        writer.recordLaunch(from: experiments)
        let reader = CohortHistoryService(defaults: defaults)
        #expect(reader.consecutiveSessions(forExperimentID: DialogueExperimentsService.castVoicingExperimentID) == 2)
    }

    @Test("corrupt stored data degrades to empty, not crash")
    func corruptGraceful() {
        let defaults = makeDefaults()
        defaults.set(Data("not json".utf8), forKey: CohortHistoryService.defaultsKey)
        let store = CohortHistoryService(defaults: defaults)
        #expect(store.history(forExperimentID: DialogueExperimentsService.castVoicingExperimentID).isEmpty)
        store.recordLaunch(from: makeExperiments())
        #expect(store.history(forExperimentID: DialogueExperimentsService.castVoicingExperimentID).count == 1)
    }
}
