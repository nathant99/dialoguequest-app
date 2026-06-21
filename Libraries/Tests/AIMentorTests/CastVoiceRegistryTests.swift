import Testing
import ForgeAI
@testable import AIMentor

@Suite("CastVoiceRegistry")
struct CastVoiceRegistryTests {

    // MARK: - Inventory

    @Test func registryShipsFiveProfiles() {
        #expect(CastVoiceRegistry.allProfiles.count == 5)
    }

    @Test func profileIDsAreDistinct() {
        let ids = CastVoiceRegistry.allProfiles.map(\.id)
        #expect(Set(ids).count == ids.count)
    }

    @Test func canonicalSlugsArePresent() {
        let ids = Set(CastVoiceRegistry.allProfiles.map(\.id))
        #expect(ids == ["brogue", "glance", "rest", "sprig", "weigh"])
    }

    @Test func voicingPriorityOrderMatchesHandoff() {
        // Per HANDOFF_FROM_LABSMITH_DN_S_AI_MENTOR_VOICING.md — lead with the
        // most-formal-register character so the LM commits to a clearly
        // distinct voice baseline first.
        let ids = CastVoiceRegistry.allProfiles.map(\.id)
        #expect(ids == ["brogue", "glance", "rest", "sprig", "weigh"])
    }

    // MARK: - Profile shape

    @Test func everyProfileMeetsCatchphraseMinimum() {
        for profile in CastVoiceRegistry.allProfiles {
            #expect(profile.catchphrases.count >= 3)
        }
    }

    @Test func everyProfileShipsAntiPatternGuards() {
        for profile in CastVoiceRegistry.allProfiles {
            #expect(!profile.antiPatterns.isEmpty)
        }
    }

    @Test func noneReviewerGated() {
        // DialogueQuest is trauma-gating: NONE per handoff.
        for profile in CastVoiceRegistry.allProfiles {
            #expect(profile.reviewerGated == false)
        }
    }

    @Test func everyEmbodimentNamesThePrimitive() {
        // Sanity check: each embodiment string should call out the primitive
        // that distinguishes the character (loose match — keyword presence).
        #expect(CastVoiceRegistry.brogue.embodiment.lowercased().contains("voice"))
        #expect(CastVoiceRegistry.glance.embodiment.lowercased().contains("subtext"))
        #expect(CastVoiceRegistry.rest.embodiment.lowercased().contains("pause"))
        #expect(CastVoiceRegistry.sprig.embodiment.lowercased().contains("branch"))
        #expect(CastVoiceRegistry.weigh.embodiment.lowercased().contains("tag"))
    }

    // MARK: - Lookup

    @Test func profileLookupReturnsKnownSlugs() {
        #expect(CastVoiceRegistry.profile(id: "brogue") != nil)
        #expect(CastVoiceRegistry.profile(id: "weigh") != nil)
    }

    @Test func profileLookupReturnsNilForUnknownSlug() {
        #expect(CastVoiceRegistry.profile(id: "patter") == nil)
        #expect(CastVoiceRegistry.profile(id: "") == nil)
    }

    // MARK: - CastDialog integration

    @Test func castDialogRegistersAllProfiles() async throws {
        let dialog = try await CastVoiceRegistry.makeCastDialog()
        let count = await dialog.registeredCount
        #expect(count == 5)
    }

    @Test func castDialogReportsEachKnownSlugAsRegistered() async throws {
        let dialog = try await CastVoiceRegistry.makeCastDialog()
        for id in ["brogue", "glance", "rest", "sprig", "weigh"] {
            let isRegistered = await dialog.isRegistered(id)
            #expect(isRegistered, "\(id) should be registered")
        }
    }

    @Test func castDialogFallbackReturnsACatchphraseForRegisteredCast() async throws {
        // When FoundationModels is unavailable in the test environment,
        // CastDialog.respond(...) falls back to one of the registered
        // catchphrases. We assert non-empty, non-placeholder ("…") output.
        let dialog = try await CastVoiceRegistry.makeCastDialog()
        let utterance = await dialog.respond(
            as: "brogue",
            trigger: .greeting,
            context: CastDialogContext(
                appIdentifier: "dialoguequest",
                kitNumber: 1
            )
        )
        #expect(!utterance.isEmpty)
        #expect(utterance != "…")
    }

    @Test func castDialogReturnsPlaceholderForUnregisteredCast() async {
        // Kit-author bug surface — does NOT crash; returns "…".
        let dialog = CastDialog()
        let utterance = await dialog.respond(
            as: "unknown-cast",
            trigger: .greeting,
            context: CastDialogContext(
                appIdentifier: "dialoguequest",
                kitNumber: 1
            )
        )
        #expect(utterance == "…")
    }
}
