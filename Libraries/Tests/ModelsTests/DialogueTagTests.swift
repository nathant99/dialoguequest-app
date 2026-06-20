import Foundation
import Testing
@testable import Models

@Suite("DialogueTag round-trip + classification")
struct DialogueTagTests {

    @Test("Said tag round-trips through Codable")
    func saidRoundTrip() throws {
        let original: DialogueTag = .said("murmured")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DialogueTag.self, from: data)
        #expect(decoded == original)
    }

    @Test("Action tag round-trips through Codable")
    func actionRoundTrip() throws {
        let original: DialogueTag = .action("Iris closed the book.")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DialogueTag.self, from: data)
        #expect(decoded == original)
    }

    @Test("Unattributed tag round-trips through Codable")
    func unattributedRoundTrip() throws {
        let original: DialogueTag = .unattributed
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DialogueTag.self, from: data)
        #expect(decoded == original)
    }

    @Test(
        "Tag classification maps each case to its expected balance bucket",
        arguments: [
            (DialogueTag.said("said"), DialogueTag.Classification.saidVerb),
            (DialogueTag.action("opens the door"), .actionBeat),
            (DialogueTag.unattributed, .unattributed),
        ]
    )
    func classificationMapping(tag: DialogueTag, expected: DialogueTag.Classification) {
        #expect(tag.classification == expected)
    }
}
