import Foundation
import Testing
@testable import Models

@Suite("MultiListenerCandidates — Phase 2 multi-listener pair selection")
struct MultiListenerCandidatesTests {

    // Stable UUIDs so the deterministic primary/secondary ordering is
    // reproducible across test runs.
    private static let irisID = UUID(uuidString: "00000000-0000-0000-0000-000000000001")!
    private static let calID = UUID(uuidString: "00000000-0000-0000-0000-000000000002")!
    private static let boID = UUID(uuidString: "00000000-0000-0000-0000-000000000003")!

    private static func makeRef(id: UUID, name: String) -> DialogueCharacterRef {
        DialogueCharacterRef(
            id: id,
            name: name,
            voiceRegister: "Reg for \(name).",
            sampleLines: ["Sample for \(name)."]
        )
    }

    @Test func twoCharacterCastReturnsNil() {
        let cast = [
            Self.makeRef(id: Self.irisID, name: "Iris"),
            Self.makeRef(id: Self.calID, name: "Cal"),
        ]
        let pair = MultiListenerCandidates.pair(
            speakerID: Self.irisID,
            characters: cast
        )
        #expect(pair == nil)
    }

    @Test func threeCharacterCastReturnsPairForKnownSpeaker() throws {
        let cast = [
            Self.makeRef(id: Self.irisID, name: "Iris"),
            Self.makeRef(id: Self.calID, name: "Cal"),
            Self.makeRef(id: Self.boID, name: "Bo"),
        ]
        let pair = try #require(
            MultiListenerCandidates.pair(speakerID: Self.irisID, characters: cast)
        )
        #expect(pair.speaker.id == Self.irisID)
        #expect(Set([pair.primaryListener.id, pair.secondaryListener.id]) == Set([Self.calID, Self.boID]))
    }

    @Test func primarySecondaryOrderingIsDeterministicByUUIDStringSort() throws {
        let cast = [
            Self.makeRef(id: Self.irisID, name: "Iris"),
            Self.makeRef(id: Self.calID, name: "Cal"),
            Self.makeRef(id: Self.boID, name: "Bo"),
        ]
        // Speaker = Iris. Remaining = [Cal, Bo]. UUID-string sort:
        // Cal (...0002) < Bo (...0003). So primary = Cal, secondary = Bo.
        let pair = try #require(
            MultiListenerCandidates.pair(speakerID: Self.irisID, characters: cast)
        )
        #expect(pair.primaryListener.id == Self.calID)
        #expect(pair.secondaryListener.id == Self.boID)
    }

    @Test func speakerNotInCastReturnsNil() {
        let cast = [
            Self.makeRef(id: Self.irisID, name: "Iris"),
            Self.makeRef(id: Self.calID, name: "Cal"),
            Self.makeRef(id: Self.boID, name: "Bo"),
        ]
        let pair = MultiListenerCandidates.pair(
            speakerID: UUID(),
            characters: cast
        )
        #expect(pair == nil)
    }

    @Test func fourCharacterCastPicksTwoListenersOnlySorted() throws {
        let dID = UUID(uuidString: "00000000-0000-0000-0000-000000000004")!
        let cast = [
            Self.makeRef(id: Self.irisID, name: "Iris"),
            Self.makeRef(id: Self.calID, name: "Cal"),
            Self.makeRef(id: Self.boID, name: "Bo"),
            Self.makeRef(id: dID, name: "Dee"),
        ]
        // Speaker = Iris (...0001). Remaining sorted by UUID string:
        // Cal (...0002) < Bo (...0003) < Dee (...0004). So pair = (Cal, Bo).
        let pair = try #require(
            MultiListenerCandidates.pair(speakerID: Self.irisID, characters: cast)
        )
        #expect(pair.primaryListener.id == Self.calID)
        #expect(pair.secondaryListener.id == Self.boID)
    }

    @Test func emptyCastReturnsNil() {
        let pair = MultiListenerCandidates.pair(
            speakerID: Self.irisID,
            characters: []
        )
        #expect(pair == nil)
    }

    @Test func pairResultIsValueTypeAndHashable() throws {
        let cast = [
            Self.makeRef(id: Self.irisID, name: "Iris"),
            Self.makeRef(id: Self.calID, name: "Cal"),
            Self.makeRef(id: Self.boID, name: "Bo"),
        ]
        let a = try #require(
            MultiListenerCandidates.pair(speakerID: Self.irisID, characters: cast)
        )
        let b = try #require(
            MultiListenerCandidates.pair(speakerID: Self.irisID, characters: cast)
        )
        #expect(a == b)
        #expect(a.hashValue == b.hashValue)
    }
}
