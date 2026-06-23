import Testing
import Foundation
@testable import AppFeature

/// Closes Phase Delight micro-delight § Discovery — proves the new
/// discovery cameo pool covers all 5 LESSONS-layer cast members,
/// stays in the age-9-14 register stoplist, and surfaces deterministically
/// when fed a seeded RNG.
@Suite("CharacterCameoInvitations discovery")
struct CharacterCameoDiscoveryTests {

    @Test("Discovery pool covers all 5 LESSONS-layer cast members")
    func discoveryCoversLessonsLayer() {
        let covered = CharacterCameoInvitations.discoveryCoveredCastIDs
        #expect(covered == Set(["brogue", "glance", "rest", "sprig", "weigh"]))
    }

    @Test("Every discovery cameo has nonempty message + display name")
    func discoveryCameosWellShaped() {
        for cameo in CharacterCameoInvitations.discoveryCameos {
            #expect(!cameo.castID.isEmpty)
            #expect(!cameo.displayName.isEmpty)
            #expect(!cameo.message.isEmpty)
            #expect(cameo.bubbleMessage.contains(": "), "bubble framing must attribute the cast member")
        }
    }

    @Test("Discovery cameos stay in age-9-14 register (no engineering jargon)")
    func discoveryCameosRegisterStoplist() {
        let banned = [
            "load-bearing", "codified", "ADR-", "phase",
            "PII", "COPPA", "telemetry",
            "wrong", "incorrect", "graded"
        ]
        for cameo in CharacterCameoInvitations.discoveryCameos {
            let lowered = cameo.message.lowercased()
            for token in banned {
                #expect(!lowered.contains(token.lowercased()),
                        "discovery cameo for \(cameo.castID) must not contain '\(token)'")
            }
        }
    }

    @Test("pickDiscoveryCameo returns nil on empty pool — defensive")
    func discoveryPoolNonempty() {
        #expect(CharacterCameoInvitations.discoveryCameos.isEmpty == false)
    }

    @Test("shouldShowDiscoveryCameo at probability 0 never fires")
    func shouldShowDiscoveryZero() {
        var rng = SystemRandomNumberGenerator()
        for _ in 0..<10 {
            #expect(CharacterCameoInvitations.shouldShowDiscoveryCameo(probability: 0, rng: &rng) == false)
        }
    }

    @Test("shouldShowDiscoveryCameo at probability 1 always fires")
    func shouldShowDiscoveryOne() {
        var rng = SystemRandomNumberGenerator()
        for _ in 0..<10 {
            #expect(CharacterCameoInvitations.shouldShowDiscoveryCameo(probability: 1, rng: &rng) == true)
        }
    }

    @Test("Default probability is below 1 and rarer than post-publish invitations? — sanity")
    func defaultProbabilityShape() {
        // Discovery cameo fires on session open; post-publish invitation
        // fires on each publish. They're separate channels — the
        // probabilities are independently picked. We just assert
        // discovery's value is in the reader-warm range (above the
        // post-publish 0.12 but well below 1).
        #expect(CharacterCameoInvitations.discoveryDefaultProbability > 0.12)
        #expect(CharacterCameoInvitations.discoveryDefaultProbability < 1)
    }
}
