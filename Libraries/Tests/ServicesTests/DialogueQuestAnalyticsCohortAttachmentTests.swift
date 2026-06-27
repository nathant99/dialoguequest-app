import Testing
import Foundation
import ForgeAnalytics
import ForgeExperiments
@testable import Services

/// Priority A (2026-07-07) — `DialogueQuestAnalytics.attachExperimentCohorts(...)`
/// caches a cohort lens (`cohort.<experiment-id>` ⇒ variant-id) that is
/// merged into every subsequent `track(_:properties:)` call so the
/// on-device retention reader can segment any event by cohort without a
/// time-join against the cold-launch `experiment_variant_assigned`
/// emission stream.
@MainActor
@Suite("DialogueQuestAnalytics cohort lens attachment")
struct DialogueQuestAnalyticsCohortAttachmentTests {

    private func makeDefaults() -> UserDefaults {
        let name = "dq.test.\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    private func waitForEventCount(_ engine: AnalyticsEngine, atLeast minimum: Int) async {
        for _ in 0..<60 {
            let count = await engine.eventCount
            if count >= minimum { break }
            try? await Task.sleep(for: .milliseconds(20))
        }
    }

    @Test func defaultLensIsEmpty_soTrackEmitsWithoutCohortKeys() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)

        analytics.track(.treePublished, properties: ["mood": "quietConflict"])

        await waitForEventCount(engine, atLeast: 1)

        let recorded = await engine.exportEvents()
        let event = recorded.first { $0.name == "tree_published" }
        let cohortKeys = (event?.properties.keys ?? [:].keys)
            .filter { $0.hasPrefix("cohort.") }
        #expect(
            cohortKeys.isEmpty,
            "No cohort lens attached — track should not synthesize cohort.X keys; got \(Array(cohortKeys))"
        )
    }

    @Test func attachAddsCohortKeysToSubsequentTrackedEvents() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)
        let experiments = DialogueExperimentsService(
            installSeed: "test-seed-cohort-attach",
            definitions: DialogueExperimentsService.defaultDefinitions(),
            userDefaults: makeDefaults()
        )

        analytics.attachExperimentCohorts(experiments: experiments)
        analytics.track(.treePublished, properties: ["mood": "quietConflict"])

        await waitForEventCount(engine, atLeast: 1)

        let recorded = await engine.exportEvents()
        let event = recorded.first { $0.name == "tree_published" }
        let castKey = "cohort.\(DialogueExperimentsService.castVoicingExperimentID)"
        let thirdKey = "cohort.\(DialogueExperimentsService.thirdCharacterExperimentID)"
        #expect(event?.properties[castKey] != nil, "Expected \(castKey) on tracked event")
        #expect(event?.properties[thirdKey] != nil, "Expected \(thirdKey) on tracked event")
        // Original caller property remains untouched.
        #expect(event?.properties["mood"] == "quietConflict")
    }

    @Test func cohortValuesAreCategorical_neverFreeForm() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)
        let experiments = DialogueExperimentsService(
            installSeed: "test-seed-cohort-categorical",
            definitions: DialogueExperimentsService.defaultDefinitions(),
            userDefaults: makeDefaults()
        )

        analytics.attachExperimentCohorts(experiments: experiments)
        analytics.track(.subtextConfirmed)

        await waitForEventCount(engine, atLeast: 1)

        let recorded = await engine.exportEvents()
        let event = recorded.first { $0.name == "subtext_confirmed" }
        let cohortValues = (event?.properties ?? [:])
            .filter { $0.key.hasPrefix("cohort.") }
            .map(\.value)
        #expect(!cohortValues.isEmpty)
        for value in cohortValues {
            #expect(
                value == DialogueExperimentsService.controlVariantID ||
                value == DialogueExperimentsService.treatmentVariantID,
                "Cohort value must be a canonical variant id; got \(value)"
            )
        }
    }

    @Test func callerSuppliedPropertyWinsOnKeyCollision() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)
        let experiments = DialogueExperimentsService(
            installSeed: "test-seed-cohort-collision",
            definitions: DialogueExperimentsService.defaultDefinitions(),
            userDefaults: makeDefaults()
        )

        analytics.attachExperimentCohorts(experiments: experiments)
        let key = "cohort.\(DialogueExperimentsService.castVoicingExperimentID)"
        // Caller supplies a sentinel value the lens would never produce.
        analytics.track(.treePublished, properties: [key: "override-sentinel"])

        await waitForEventCount(engine, atLeast: 1)

        let recorded = await engine.exportEvents()
        let event = recorded.first { $0.name == "tree_published" }
        #expect(
            event?.properties[key] == "override-sentinel",
            "Caller-supplied properties must win on key collision; got \(event?.properties[key] ?? "<nil>")"
        )
    }

    @Test func attachIsIdempotent() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)
        let experiments = DialogueExperimentsService(
            installSeed: "test-seed-cohort-idempotent",
            definitions: DialogueExperimentsService.defaultDefinitions(),
            userDefaults: makeDefaults()
        )

        analytics.attachExperimentCohorts(experiments: experiments)
        analytics.track(.treePublished)
        analytics.attachExperimentCohorts(experiments: experiments) // second call
        analytics.track(.treePublished)

        await waitForEventCount(engine, atLeast: 2)

        let recorded = await engine.exportEvents()
            .filter { $0.name == "tree_published" }
        let castKey = "cohort.\(DialogueExperimentsService.castVoicingExperimentID)"
        let firstCohort = recorded.first?.properties[castKey]
        let secondCohort = recorded.dropFirst().first?.properties[castKey]
        #expect(firstCohort != nil)
        #expect(firstCohort == secondCohort, "Idempotent attach should produce a stable lens; got \(firstCohort ?? "<nil>") vs \(secondCohort ?? "<nil>")")
    }

    @Test func clearForTestingDetachesLensFromSubsequentTracks() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)
        let experiments = DialogueExperimentsService(
            installSeed: "test-seed-cohort-clear",
            definitions: DialogueExperimentsService.defaultDefinitions(),
            userDefaults: makeDefaults()
        )

        analytics.attachExperimentCohorts(experiments: experiments)
        analytics.clearExperimentCohortsForTesting()
        analytics.track(.treePublished)

        await waitForEventCount(engine, atLeast: 1)

        let recorded = await engine.exportEvents()
        let event = recorded.first { $0.name == "tree_published" }
        let cohortKeys = (event?.properties.keys ?? [:].keys)
            .filter { $0.hasPrefix("cohort.") }
        #expect(
            cohortKeys.isEmpty,
            "clearExperimentCohortsForTesting should detach the lens; got \(Array(cohortKeys))"
        )
    }

    @Test func emptyDefinitionsAttachLeavesLensEmpty() async {
        let engine = AnalyticsEngine(config: AnalyticsConfig())
        let analytics = DialogueQuestAnalytics(engine: engine)
        let experiments = DialogueExperimentsService(
            installSeed: "test-seed-cohort-empty",
            definitions: [],
            userDefaults: makeDefaults()
        )

        analytics.attachExperimentCohorts(experiments: experiments)
        analytics.track(.treePublished)

        await waitForEventCount(engine, atLeast: 1)

        let recorded = await engine.exportEvents()
        let event = recorded.first { $0.name == "tree_published" }
        let cohortKeys = (event?.properties.keys ?? [:].keys)
            .filter { $0.hasPrefix("cohort.") }
        #expect(
            cohortKeys.isEmpty,
            "Empty definitions should leave the lens empty; got \(Array(cohortKeys))"
        )
    }
}
