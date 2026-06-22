import Testing
import Foundation
import AIMentor
import AppFeature

/// DN-D layered-cast gating tests at the `CastVoicingService` boundary.
///
/// Covers the kit-number gate: WORLD-layer surfaces (kit 5+) and the
/// META-layer Audience Aria surface (kit 11+) MUST return `nil` when
/// the kid is too early in the 16-kit arc, even with the feature flag
/// ON. LESSONS-layer surfaces remain unrestricted. The test relies on
/// the `flagAccessor` injection so the suite stays UserDefaults-free.
@Suite("CastVoicingService layer gating")
struct CastVoicingServiceLayerGatingTests {

    @Test @MainActor func lessonsLayerFiresOnKitOne() async {
        let service = CastVoicingService(flagAccessor: { true })
        let voicing = await service.respond(
            to: .branchPointReached,
            topic: "branching",
            kitNumber: 1
        )
        #expect(voicing != nil)
        #expect(voicing?.castID == "sprig")
    }

    @Test @MainActor func worldLayerReturnsNilBelowKitFive() async {
        let service = CastVoicingService(flagAccessor: { true })
        for kit in 1...4 {
            let voicing = await service.respond(
                to: .voiceRegisterEpic,
                topic: "register",
                kitNumber: kit
            )
            #expect(voicing == nil, "kit \(kit) should NOT surface WORLD-layer Heralda")
        }
    }

    @Test @MainActor func worldLayerFiresAtKitFive() async {
        let service = CastVoicingService(flagAccessor: { true })
        let voicing = await service.respond(
            to: .voiceRegisterLyric,
            topic: "register",
            kitNumber: 5
        )
        #expect(voicing != nil)
        #expect(voicing?.castID == "murmur")
        #expect(voicing?.surface.layer == .world)
    }

    @Test @MainActor func metaLayerReturnsNilBelowKitEleven() async {
        let service = CastVoicingService(flagAccessor: { true })
        for kit in [1, 5, 8, 10] {
            let voicing = await service.respond(
                to: .audiencePerception,
                topic: "audience",
                kitNumber: kit
            )
            #expect(voicing == nil, "kit \(kit) should NOT surface META-layer Aria")
        }
    }

    @Test @MainActor func metaLayerFiresAtKitEleven() async {
        let service = CastVoicingService(flagAccessor: { true })
        let voicing = await service.respond(
            to: .audiencePerception,
            topic: "audience",
            kitNumber: 11
        )
        #expect(voicing != nil)
        #expect(voicing?.castID == "aria")
        #expect(voicing?.surface.layer == .meta)
    }

    @Test @MainActor func gatingHonoredEvenWhenFlagIsOn() async {
        // Sanity: gating is independent of the flag. Flag-off short-circuits
        // earlier; this test confirms gating ALSO blocks when the flag is on.
        let service = CastVoicingService(flagAccessor: { true })
        let voicing = await service.respond(
            to: .audiencePerception,
            topic: "audience",
            kitNumber: 1
        )
        #expect(voicing == nil)
    }
}
