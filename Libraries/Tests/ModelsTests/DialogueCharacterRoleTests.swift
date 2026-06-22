import Foundation
import Testing
@testable import Models

@Suite("DialogueCharacterRole — Phase 2 archetype + Codable backwards-compat")
struct DialogueCharacterRoleTests {

    @Test func defaultRoleIsUnspecified() {
        let ref = DialogueCharacterRef(
            name: "Iris",
            voiceRegister: "Clipped, deflects.",
            sampleLines: ["I'm fine."]
        )
        #expect(ref.role == .unspecified)
    }

    @Test func everyRoleHasDistinctDisplayName() {
        let names = DialogueCharacterRole.allCases.map(\.displayName)
        #expect(Set(names).count == names.count)
    }

    @Test func everyRoleHasNonEmptyCoachingHint() {
        for role in DialogueCharacterRole.allCases {
            #expect(!role.coachingHint.isEmpty)
        }
    }

    // MARK: - Codable backwards compat

    @Test func decodesLegacyTwoCharacterPayloadWithoutRoleField() throws {
        // Phase 1 trees serialized DialogueCharacterRef without a `role`
        // field. The Codable shape must keep round-tripping those trees.
        let legacy = """
        {
            "id": "00000000-0000-0000-0000-000000000001",
            "name": "Iris",
            "voiceRegister": "Clipped, deflects.",
            "sampleLines": ["I'm fine.", "Whatever."]
        }
        """
        let data = try #require(legacy.data(using: .utf8))
        let decoded = try JSONDecoder().decode(DialogueCharacterRef.self, from: data)
        #expect(decoded.name == "Iris")
        #expect(decoded.role == .unspecified)
        #expect(decoded.sampleLines.count == 2)
    }

    @Test func roundTripsRolePayloadIntact() throws {
        let original = DialogueCharacterRef(
            name: "Arbie",
            voiceRegister: "Steady, names what's happening, names what's missing.",
            sampleLines: ["Let's pause.", "What just happened?"],
            role: .arbiter
        )
        let encoded = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DialogueCharacterRef.self, from: encoded)
        #expect(decoded == original)
        #expect(decoded.role == .arbiter)
    }

    // MARK: - NodeCountConstraint phase 2 ceiling

    @Test func phase2CeilingAppliesToTriangleExperiencedTier() {
        let ceiling = DialogueTree.NodeCountConstraint.maxNodes(
            for: .experienced,
            characterCount: 3
        )
        #expect(ceiling == DialogueTree.NodeCountConstraint.phase2Max)
        #expect(ceiling == 24)
    }

    @Test func phase2CeilingDoesNotApplyToTwoCharacterTrees() {
        let ceiling = DialogueTree.NodeCountConstraint.maxNodes(
            for: .experienced,
            characterCount: 2
        )
        #expect(ceiling == DialogueTree.NodeCountConstraint.phase1Max)
        #expect(ceiling == 15)
    }

    @Test func phase2CeilingDoesNotApplyAtEarlyTiers() {
        for tier in [DialogueTree.NodeCountConstraint.SessionTier.firstSession,
                     .earlySessions] {
            let triangleCeiling = DialogueTree.NodeCountConstraint.maxNodes(
                for: tier,
                characterCount: 3
            )
            let baseCeiling = DialogueTree.NodeCountConstraint.maxNodes(for: tier)
            #expect(triangleCeiling == baseCeiling, "tier \(tier) should not get the phase 2 ceiling")
        }
    }
}
