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
