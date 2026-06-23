import Testing
import Foundation
import Models
import AIMentor
import AppFeature

/// Tests for the `CharacterCameoInvitations` easter-egg picker. Pure
/// value-type API so the suite stays UserDefaults-free + seed-driven.
@Suite("CharacterCameoInvitations")
struct CharacterCameoInvitationsTests {

    @Test func everyCastMemberHasAtLeastOneInvitation() {
        let registeredCastIDs = Set(
            CastVoiceRegistry.lessonsLayerProfiles.map(\.id)
        )
        // Every LESSONS-layer cast member must surface in the cameo pool —
        // they are Patter's craft friends and the cameo is their entry
        // surface back into the kid's loop. WORLD + META layers stay out
        // (they need the kit-5+ / kit-11+ minimums per Pattern B).
        for castID in registeredCastIDs {
            #expect(
                CharacterCameoInvitations.coveredCastIDs.contains(castID),
                "Cast member \(castID) missing from cameo pool"
            )
        }
    }

    @Test func allInvitationsBelongToRegisteredLessonsCast() {
        let lessonsCastIDs = Set(
            CastVoiceRegistry.lessonsLayerProfiles.map(\.id)
        )
        for invitation in CharacterCameoInvitations.allInvitations {
            #expect(
                lessonsCastIDs.contains(invitation.castID),
                "Invitation cites \(invitation.castID) — not a LESSONS cast member; would surface as an unattributed bubble"
            )
        }
    }

    @Test func displayNameMatchesCastVoiceProfile() {
        for invitation in CharacterCameoInvitations.allInvitations {
            let profile = CastVoiceRegistry.profile(id: invitation.castID)
            let expected = profile?.displayName
            #expect(
                expected == invitation.displayName,
                "Cast \(invitation.castID) display mismatch: invitation has '\(invitation.displayName)' but registry has '\(expected ?? "<nil>")'"
            )
        }
    }

    @Test func pickInvitationIsDeterministicForSeededRNG() {
        var rngA = SeedableRandom(seed: 12345)
        var rngB = SeedableRandom(seed: 12345)
        let first = CharacterCameoInvitations.pickInvitation(rng: &rngA)
        let second = CharacterCameoInvitations.pickInvitation(rng: &rngB)
        let firstUnwrapped = try? #require(first)
        let secondUnwrapped = try? #require(second)
        #expect(firstUnwrapped?.castID == secondUnwrapped?.castID)
        #expect(firstUnwrapped?.message == secondUnwrapped?.message)
    }

    @Test func shouldShowInvitationCollapsesAtBoundaries() {
        var rng = SeedableRandom(seed: 99)
        #expect(
            CharacterCameoInvitations.shouldShowInvitation(probability: 0.0, rng: &rng) == false,
            "Zero probability must never fire"
        )
        #expect(
            CharacterCameoInvitations.shouldShowInvitation(probability: 1.0, rng: &rng) == true,
            "Full probability must always fire"
        )
    }

    @Test func shouldShowInvitationAtDefaultProbabilityApproximatesTwelvePercent() {
        // Verify the gate rate at the default probability over 1000 rolls —
        // gives the cameo cadence a sanity bound even with deterministic
        // seed drift across Swift toolchain versions.
        var rng = SeedableRandom(seed: 4242)
        var hits = 0
        let trials = 1_000
        for _ in 0..<trials {
            if CharacterCameoInvitations.shouldShowInvitation(rng: &rng) {
                hits += 1
            }
        }
        let rate = Double(hits) / Double(trials)
        // Default is 0.12 — guard band ±0.05 keeps the test deterministic
        // across LCG drift. If the band starts flaking, lift the seed
        // count to 5000 + tighten the band.
        #expect(
            rate > 0.07 && rate < 0.18,
            "Default cameo rate fell outside [0.07, 0.18] band — got \(rate)"
        )
    }

    @Test func minimumPublishedTreeCountProtectsAhaMoment() {
        // The aha-moment seed publish (count 0 → 1) MUST NOT be diluted
        // by a cameo. The contract is enforced at call-site (WriteTabView
        // checks `publishedTreeCount >= minimumPublishedTreeCount`); this
        // test pins the value so the contract doesn't drift.
        #expect(CharacterCameoInvitations.minimumPublishedTreeCount == 2)
    }

    @Test func bubbleMessagePrependsDisplayName() {
        let invitation = CharacterCameoInvitations.Invitation(
            castID: "glance",
            displayName: "Glance",
            message: "Write a layered line."
        )
        #expect(invitation.bubbleMessage == "Glance: Write a layered line.")
    }

    /// Register-stoplist guard — every invitation message MUST pass the
    /// chapter content register stoplist per
    /// `.claude/rules/distributed-narrative.md` § R-CHAPTER-REGISTER. The
    /// list mirrors the audit-scrubber's severity-3 tokens (engineering
    /// + project-management + reviewer-framework + meta-pedagogy jargon).
    @Test func everyInvitationPassesChapterRegisterStoplist() {
        let stoplistTokens: [String] = [
            "load-bearing", "soft-collision", "hard-collision",
            "single source of truth", "codified", "codify",
            "superseded by", "graduation criteria", "kill criteria",
            "regression class", "canonical", "downstream", "upstream",
            "first-class", "in-band", "out-of-band", "gating", "ungated",
            "ADR-", "(per ADR-", "per ADR-", "per user-direct",
            "Phase A", "Phase B", "Phase C", "Phase D",
            "R0 reviewer", "PR #", "SHIPPED", "MERGED",
            "WIP", "TODO", "in-flight", "Round ",
            "SAMHSA", "TIP 57", "validate-then-inform",
            "trauma-gated", "hold-space", "refer-up", "off-ramp",
            "embody the primitive", "the cast IS the curriculum",
            "distributed-narrative", "anchoring phenomena",
            "anchoring phenomenon", "curricular primitive"
        ]
        for invitation in CharacterCameoInvitations.allInvitations {
            let lowercase = invitation.message.lowercased()
            for token in stoplistTokens {
                #expect(
                    !lowercase.contains(token.lowercased()),
                    "Invitation '\(invitation.message)' contains forbidden register token '\(token)'"
                )
            }
        }
    }

    @Test func invitationMessagesAreShortEnoughForOneBubble() {
        // MentorBubbleView is single-message; long lines cause visual
        // overflow on iPhone 13/14 + accessibility5 Dynamic Type. Cap at
        // 220 chars to stay one-glance-readable.
        for invitation in CharacterCameoInvitations.allInvitations {
            #expect(
                invitation.message.count <= 220,
                "Invitation too long for MentorBubbleView: \(invitation.message.count) chars"
            )
        }
    }

    @Test func defaultProbabilityIsLowerThanVariableReward() {
        // Cameos MUST be rarer than the variable-reward voice-craft tip
        // (default 0.20) so they feel special when they hit. The
        // mutually-exclusive wiring in WriteTabView assumes this ordering.
        #expect(CharacterCameoInvitations.defaultProbability < 0.20)
    }
}
