import Testing
import Foundation
import ForgeAnalytics
import ForgeExperiments
@testable import Services

/// Priority N.2 (2026-07-04) — `DialogueQuestAnalytics.recordExperimentAssignments`
/// emits one `experiment_variant_assigned` event per registered
/// experiment with categorical `experiment_id` + `variant_id`
/// properties. RootView calls this at cold launch so the on-device
/// retention reader can segment by cohort.
@MainActor
@Suite("DialogueQuestAnalytics experiment variant assignment")
struct DialogueQuestAnalyticsExperimentVariantTests {

    private func makeDefaults() -> UserDefaults {
        let name = "dq.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test func recordEmitsOneEventPerDefinition() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)
        let experiments = DialogueExperimentsService(
            installSeed: "test-seed-A",
            definitions: DialogueExperimentsService.defaultDefinitions(),
            userDefaults: makeDefaults()
        )

        analytics.recordExperimentAssignments(experiments: experiments)

        // Two definitions ship by default — wait for two events.
        for _ in 0..<60 {
            let count = await engine.eventCount
            if count >= 2 { break }
            try? await Task.sleep(for: .milliseconds(20))
        }

        let recorded = await engine.exportEvents()
        let assignments = recorded.filter { $0.name == "experiment_variant_assigned" }
        #expect(assignments.count == 2, "Expected one event per definition; got \(assignments.count)")
    }

    @Test func eachEventCarriesCategoricalIDs() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)
        let experiments = DialogueExperimentsService(
            installSeed: "test-seed-B",
            definitions: DialogueExperimentsService.defaultDefinitions(),
            userDefaults: makeDefaults()
        )

        analytics.recordExperimentAssignments(experiments: experiments)

        for _ in 0..<60 {
            let count = await engine.eventCount
            if count >= 2 { break }
            try? await Task.sleep(for: .milliseconds(20))
        }

        let recorded = await engine.exportEvents()
        let assignments = recorded.filter { $0.name == "experiment_variant_assigned" }
        #expect(!assignments.isEmpty)
        for event in assignments {
            let experimentID = event.properties["experiment_id"]
            let variantID = event.properties["variant_id"]
            #expect(experimentID != nil, "experiment_id missing from event properties")
            #expect(variantID != nil, "variant_id missing from event properties")
            // The IDs are categorical: known constants from the
            // experiments service, not free-form text.
            #expect(
                experimentID == DialogueExperimentsService.castVoicingExperimentID ||
                experimentID == DialogueExperimentsService.thirdCharacterExperimentID,
                "Unexpected experiment_id: \(experimentID ?? "<nil>")"
            )
            #expect(
                variantID == DialogueExperimentsService.controlVariantID ||
                variantID == DialogueExperimentsService.treatmentVariantID,
                "Unexpected variant_id: \(variantID ?? "<nil>")"
            )
        }
    }

    @Test func assignmentsAreDeterministicAcrossRepeatCalls() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)
        let experiments = DialogueExperimentsService(
            installSeed: "test-seed-C",
            definitions: DialogueExperimentsService.defaultDefinitions(),
            userDefaults: makeDefaults()
        )

        // Two cold-launch emissions in a row produce identical
        // variant_id sets per experiment_id (deterministic per seed).
        analytics.recordExperimentAssignments(experiments: experiments)
        analytics.recordExperimentAssignments(experiments: experiments)

        for _ in 0..<60 {
            let count = await engine.eventCount
            if count >= 4 { break }
            try? await Task.sleep(for: .milliseconds(20))
        }

        let recorded = await engine.exportEvents()
        let assignments = recorded.filter { $0.name == "experiment_variant_assigned" }
        let perExperiment = Dictionary(grouping: assignments) {
            $0.properties["experiment_id"] ?? "<missing>"
        }
        for (_, events) in perExperiment {
            let variants = Set(events.compactMap { $0.properties["variant_id"] })
            #expect(variants.count == 1, "Variant assignment drift detected across cold launches: \(variants)")
        }
    }

    @Test func emptyDefinitionsEmitNothing() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)
        let experiments = DialogueExperimentsService(
            installSeed: "test-seed-D",
            definitions: [],
            userDefaults: makeDefaults()
        )

        analytics.recordExperimentAssignments(experiments: experiments)

        // Short wait — no events should land.
        try? await Task.sleep(for: .milliseconds(60))

        let recorded = await engine.exportEvents()
        let assignments = recorded.filter { $0.name == "experiment_variant_assigned" }
        #expect(assignments.isEmpty)
    }
}
