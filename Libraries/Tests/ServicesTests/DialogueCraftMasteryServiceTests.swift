import Foundation
import Testing
import ForgeMasteryEngine
import Models
@testable import Services

/// DialogueQuest's `ForgeMasteryEngine` adoption (Priority B). Covers the
/// per-pillar attempt recording on publish, the subtext / 3+-character
/// gating, FSRS-driven mastery scoring, recommendation surfacing, and the
/// UserDefaults persistence round-trip.
@MainActor
@Suite("DialogueCraftMasteryService")
struct DialogueCraftMasteryServiceTests {

    private func makeSuite(name: String = UUID().uuidString) -> UserDefaults {
        let suite = UserDefaults(suiteName: name)!
        suite.removePersistentDomain(forName: name)
        return suite
    }

    // MARK: - Fresh state

    @Test func freshServiceHasZeroMastery() {
        let service = DialogueCraftMasteryService(defaults: makeSuite())
        for topic in DialogueCraftTopic.allCases {
            #expect(service.masteryScore(for: topic) == 0)
            #expect(service.state(for: topic) == nil)
        }
        #expect(service.masteredTopics().isEmpty)
    }

    // MARK: - Recording + scoring

    @Test func highScorePublishMastersVoiceConsistency() {
        let service = DialogueCraftMasteryService(defaults: makeSuite())
        service.recordPublishedTree(
            averageVoiceMatch: 0.95,
            reflectionRatio: 0.95,
            dominantTagAbsent: true,
            subtextConfirmed: true,
            characterCount: 3
        )
        #expect(service.masteryScore(for: .voiceConsistency) >= 0.85)
        #expect(service.masteredTopics().contains(.voiceConsistency))
        #expect(service.state(for: .voiceConsistency)?.attemptCount == 1)
    }

    @Test func subtextRecordedOnlyWhenConfirmed() {
        let withoutSubtext = DialogueCraftMasteryService(defaults: makeSuite())
        withoutSubtext.recordPublishedTree(
            averageVoiceMatch: 0.9,
            reflectionRatio: 0.9,
            dominantTagAbsent: true,
            subtextConfirmed: false,
            characterCount: 2
        )
        #expect(withoutSubtext.state(for: .subtextDetection) == nil)

        let withSubtext = DialogueCraftMasteryService(defaults: makeSuite())
        withSubtext.recordPublishedTree(
            averageVoiceMatch: 0.9,
            reflectionRatio: 0.9,
            dominantTagAbsent: true,
            subtextConfirmed: true,
            characterCount: 2
        )
        #expect(withSubtext.state(for: .subtextDetection)?.attemptCount == 1)
    }

    @Test func triangleAndMultiListenerGatedByCharacterCount() {
        let twoChars = DialogueCraftMasteryService(defaults: makeSuite())
        twoChars.recordPublishedTree(
            averageVoiceMatch: 0.9,
            reflectionRatio: 0.9,
            dominantTagAbsent: true,
            subtextConfirmed: true,
            characterCount: 2
        )
        #expect(twoChars.state(for: .triangleDynamics) == nil)
        #expect(twoChars.state(for: .multiListenerSubtext) == nil)

        let threeChars = DialogueCraftMasteryService(defaults: makeSuite())
        threeChars.recordPublishedTree(
            averageVoiceMatch: 0.9,
            reflectionRatio: 0.9,
            dominantTagAbsent: true,
            subtextConfirmed: true,
            characterCount: 3
        )
        #expect(threeChars.state(for: .triangleDynamics)?.attemptCount == 1)
        #expect(threeChars.state(for: .multiListenerSubtext)?.attemptCount == 1)
    }

    @Test func attemptCountAccumulatesAcrossPublishes() {
        let service = DialogueCraftMasteryService(defaults: makeSuite())
        service.recordPublishedTree(
            averageVoiceMatch: 0.7, reflectionRatio: 0.7,
            dominantTagAbsent: true, subtextConfirmed: false, characterCount: 2
        )
        service.recordPublishedTree(
            averageVoiceMatch: 0.6, reflectionRatio: 0.6,
            dominantTagAbsent: false, subtextConfirmed: false, characterCount: 2
        )
        #expect(service.state(for: .voiceConsistency)?.attemptCount == 2)
        #expect(service.state(for: .tagBalance)?.attemptCount == 2)
    }

    // MARK: - Recommendations

    @Test func lowScorePublishSurfacesAFocusRecommendation() {
        let service = DialogueCraftMasteryService(defaults: makeSuite())
        // A weak publish leaves the foundation pillars mid-mastery (in the
        // edge-of-competence extend band), so the picker should surface a
        // focus topic rather than nothing.
        service.recordPublishedTree(
            averageVoiceMatch: 0.3, reflectionRatio: 0.3,
            dominantTagAbsent: false, subtextConfirmed: false, characterCount: 2
        )
        #expect(service.nextFocusTopic() != nil)
        #expect(!service.recommendations().isEmpty)
    }

    // MARK: - Persistence

    @Test func masteryPersistsAcrossInstantiation() {
        let suite = makeSuite()
        let first = DialogueCraftMasteryService(defaults: suite)
        first.recordPublishedTree(
            averageVoiceMatch: 0.9, reflectionRatio: 0.9,
            dominantTagAbsent: true, subtextConfirmed: true, characterCount: 3
        )
        let firstScore = first.masteryScore(for: .voiceConsistency)
        #expect(firstScore > 0)

        let second = DialogueCraftMasteryService(defaults: suite)
        #expect(second.state(for: .voiceConsistency)?.attemptCount == 1)
        #expect(second.masteryScore(for: .voiceConsistency) > 0)
    }

    // MARK: - Reset

    @Test func resetClearsState() {
        let service = DialogueCraftMasteryService(defaults: makeSuite())
        service.recordPublishedTree(
            averageVoiceMatch: 0.9, reflectionRatio: 0.9,
            dominantTagAbsent: true, subtextConfirmed: true, characterCount: 3
        )
        #expect(service.state(for: .voiceConsistency) != nil)
        service.reset()
        for topic in DialogueCraftTopic.allCases {
            #expect(service.state(for: topic) == nil)
            #expect(service.masteryScore(for: topic) == 0)
        }
    }

    // MARK: - Dashboard readouts (B-follow)

    @Test func masteryReadoutsCoverAllSixPillarsInCanonicalOrder() {
        let service = DialogueCraftMasteryService(defaults: makeSuite())
        let readouts = service.masteryReadouts()
        #expect(readouts.map(\.topic) == DialogueCraftTopic.allCases)
        // Fresh install — every bar reads 0, none mastered.
        #expect(readouts.allSatisfy { $0.score == 0 && !$0.isMastered })
    }

    @Test func masteryReadoutReflectsRecordedScoreAndMasteryFlag() {
        let service = DialogueCraftMasteryService(defaults: makeSuite())
        service.recordPublishedTree(
            averageVoiceMatch: 0.95, reflectionRatio: 0.95,
            dominantTagAbsent: true, subtextConfirmed: true, characterCount: 3
        )
        // NB: `masteryScore` derives from FSRS retrievability (time-decayed), so
        // two reads microseconds apart differ at ~1e-9 — assert the meaningful
        // invariant (a high-quality publish lands the pillar above threshold +
        // flips the mastered flag), not bit-exact equality across reads.
        let voice = service.masteryReadouts().first { $0.topic == .voiceConsistency }
        #expect((voice?.score ?? 0) >= 0.85)
        #expect(voice?.isMastered == true)
    }

    @Test func recommendationReadoutsAreBoundedAndOnePerKind() {
        // A fresh install surfaces a gentle starting suggestion (the picker's
        // `.stretch` into an unblocked, unattempted pillar) — NOT empty. After a
        // weak publish the picker may surface up to three (extend/consolidate/
        // stretch). In both cases the readout is bounded at three with at most
        // one card per kind, and every card carries non-empty reader copy.
        let fresh = DialogueCraftMasteryService(defaults: makeSuite())
        assertBoundedOnePerKind(fresh.recommendationReadouts())

        let weak = DialogueCraftMasteryService(defaults: makeSuite())
        weak.recordPublishedTree(
            averageVoiceMatch: 0.3, reflectionRatio: 0.3,
            dominantTagAbsent: false, subtextConfirmed: false, characterCount: 2
        )
        let readouts = weak.recommendationReadouts()
        #expect(!readouts.isEmpty)
        assertBoundedOnePerKind(readouts)
    }

    private func assertBoundedOnePerKind(
        _ readouts: [DialogueCraftMasteryService.CraftRecommendationReadout]
    ) {
        #expect(readouts.count <= 3)
        // `recommendations()` appends at most one per rationale, so no kind
        // repeats across the readout.
        #expect(Set(readouts.map(\.kind)).count == readouts.count)
        for readout in readouts {
            #expect(!readout.headline.isEmpty)
            #expect(!readout.detail.isEmpty)
        }
    }

    @Test func recommendationReadoutCopyIsRegisterStoplistClean() {
        let service = DialogueCraftMasteryService(defaults: makeSuite())
        service.recordPublishedTree(
            averageVoiceMatch: 0.3, reflectionRatio: 0.3,
            dominantTagAbsent: false, subtextConfirmed: false, characterCount: 2
        )
        // Engineering / framework jargon must never reach the parent surface
        // (per .claude/rules/distributed-narrative.md § R-CHAPTER-REGISTER).
        let forbidden = [
            "load-bearing", "codified", "fsrs", "mastery score", "rationale",
            "forgekit", "primitive", "samhsa", "phase ", "extend", "consolidate",
            "retrievability", "vygotsky", "frontier"
        ]
        for readout in service.recommendationReadouts() {
            let text = (readout.headline + " " + readout.detail).lowercased()
            for token in forbidden {
                #expect(!text.contains(token), "register leak '\(token)' in: \(text)")
            }
        }
    }

    // MARK: - Patter-bubble focus nudge (B-follow)

    @Test func focusNudgeThresholdAndProbabilityContracts() {
        // Locked constants the WriteTabView publish path + tests both rely on.
        #expect(DialogueCraftMasteryService.minimumPublishedForFocusNudge == 3)
        #expect(DialogueCraftMasteryService.focusNudgeProbability == 0.08)
    }

    @Test func freshInstallStillOffersAFocusNudge() {
        // Documents the gotcha that drives the WriteTabView gate: a brand-new
        // install surfaces a `.stretch` recommendation immediately, so the
        // nudge line is non-nil from launch. That is exactly why the publish
        // path gates on `publishedTreeCount`, NOT on `nextFocusNudge() != nil`.
        let service = DialogueCraftMasteryService(defaults: makeSuite())
        #expect(service.nextFocusNudge() != nil)
    }

    @Test func focusNudgeLineNamesARecommendedPillar() throws {
        // A fresh service reliably surfaces a `.stretch` (the FSRS frontier
        // always offers a starting suggestion), so the line is deterministic
        // here — unlike a post-publish state, where the picker can legitimately
        // return no recommendation (nothing at the edge, decayed, or newly
        // unblocked) and the nudge is nil.
        let service = DialogueCraftMasteryService(defaults: makeSuite())
        let nudge = try #require(service.nextFocusNudge())
        // The line weaves in the lower-cased display name of SOME pillar.
        let names = DialogueCraftTopic.allCases.map { $0.displayName.lowercased() }
        #expect(names.contains { nudge.lowercased().contains($0) })
    }

    @Test func shouldShowFocusNudgeRespectsProbabilityBounds() {
        var rng = SeedableRandom(seed: 7)
        // Probability 0 never fires; probability 1 always fires (both
        // short-circuit before consuming the generator).
        #expect(DialogueCraftMasteryService.shouldShowFocusNudge(probability: 0, rng: &rng) == false)
        #expect(DialogueCraftMasteryService.shouldShowFocusNudge(probability: 1, rng: &rng) == true)
    }

    @Test func focusNudgeIsDeterministicForASeed() {
        // Same seed → same sequence of fires, so the bubble decision is
        // reproducible in tests.
        var rngA = SeedableRandom(seed: 4242)
        var rngB = SeedableRandom(seed: 4242)
        for _ in 0..<20 {
            let a = DialogueCraftMasteryService.shouldShowFocusNudge(rng: &rngA)
            let b = DialogueCraftMasteryService.shouldShowFocusNudge(rng: &rngB)
            #expect(a == b)
        }
    }

    @Test func focusNudgeLineVoicesTheEmbodyingCastMember() {
        // Each pillar with a cast embodiment is voiced by that member (Pattern B
        // distributed narrative) so the nudge composes with the cameo system.
        let cases: [(DialogueCraftTopic, String)] = [
            (.voiceConsistency, "Brogue"),
            (.subtextDetection, "Glance"),
            (.tagBalance, "Weigh"),
            (.branchMeaningfulness, "Sprig"),
            (.multiListenerSubtext, "Glance")
        ]
        for (topic, inviter) in cases {
            let line = DialogueCraftMasteryService.focusNudgeLine(for: topic)
            #expect(line.hasPrefix("\(inviter) "), "expected \(inviter) to voice \(topic): \(line)")
            #expect(line.lowercased().contains(topic.displayName.lowercased()))
        }
    }

    @Test func focusNudgeLineFallsBackToPatterWhenNoEmbodiment() {
        // Triangle dynamics emerges from the trio — no single embodiment, so
        // Patter speaks.
        #expect(DialogueCraftTopic.triangleDynamics.castEmbodiment == nil)
        let line = DialogueCraftMasteryService.focusNudgeLine(for: .triangleDynamics)
        #expect(line.hasPrefix("Patter "))
        #expect(line.lowercased().contains("triangle dynamics"))
    }

    @Test func startNudgeLineNamesThePillarAndIsDistinctFromFocusLine() {
        // The empty-state "start here" line names the pillar + is worded for a
        // kid who has not published yet (not "next time").
        let start = DialogueCraftMasteryService.startNudgeLine(for: .voiceConsistency)
        #expect(start.hasPrefix("Brogue "))
        #expect(start.lowercased().contains("voice consistency"))
        #expect(start.lowercased().contains("starting"))
        #expect(start != DialogueCraftMasteryService.focusNudgeLine(for: .voiceConsistency))
    }

    @Test func startAndFocusNudgeLinesAreRegisterStoplistClean() {
        // Both cast-voiced lines must stay free of engineering / framework
        // jargon across every pillar.
        let forbidden = [
            "load-bearing", "codified", "fsrs", "mastery score", "rationale",
            "forgekit", "primitive", "samhsa", "phase ", "extend", "consolidate",
            "stretch", "retrievability", "vygotsky", "frontier", "pillar"
        ]
        for topic in DialogueCraftTopic.allCases {
            for line in [
                DialogueCraftMasteryService.focusNudgeLine(for: topic),
                DialogueCraftMasteryService.startNudgeLine(for: topic)
            ] {
                let text = line.lowercased()
                for token in forbidden {
                    #expect(!text.contains(token), "register leak '\(token)' in: \(text)")
                }
            }
        }
    }

    @Test func focusNudgeCopyIsRegisterStoplistClean() {
        let service = DialogueCraftMasteryService(defaults: makeSuite())
        service.recordPublishedTree(
            averageVoiceMatch: 0.4, reflectionRatio: 0.4,
            dominantTagAbsent: false, subtextConfirmed: false, characterCount: 2
        )
        // The kid-facing bubble must never leak engineering / framework jargon.
        let forbidden = [
            "load-bearing", "codified", "fsrs", "mastery score", "rationale",
            "forgekit", "primitive", "samhsa", "phase ", "extend", "consolidate",
            "stretch", "retrievability", "vygotsky", "frontier", "pillar"
        ]
        let text = (service.nextFocusNudge() ?? "").lowercased()
        #expect(!text.isEmpty)
        for token in forbidden {
            #expect(!text.contains(token), "register leak '\(token)' in: \(text)")
        }
    }

    // MARK: - Topic value-type smoke

    @Test func topicSlugsMatchSkillGraphNodeIDs() {
        // The mastery topic slugs must match the knowledge-graph node IDs so
        // the static (prerequisite) and dynamic (mastery) graphs stay joinable.
        #expect(DialogueCraftTopic.voiceConsistency.rawValue == DialogueCraftSkillGraph.NodeID.voiceConsistency)
        #expect(DialogueCraftTopic.branchMeaningfulness.rawValue == DialogueCraftSkillGraph.NodeID.branchMeaningfulness)
        #expect(DialogueCraftTopic.triangleDynamics.castEmbodiment == nil)
        #expect(DialogueCraftTopic.voiceConsistency.castEmbodiment == "brogue")
    }
}
