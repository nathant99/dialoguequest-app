import Foundation
import Testing
@testable import Models

@Suite("DialogueMood — display names + Codable")
struct DialogueMoodTests {

    @Test("Every mood case has a non-empty display name")
    func everyCaseHasDisplayName() {
        for mood in DialogueMood.allCases {
            #expect(!mood.displayName.isEmpty, "mood \(mood) missing displayName")
        }
    }

    @Test("Mood round-trips through Codable")
    func roundTrip() throws {
        for mood in DialogueMood.allCases {
            let data = try JSONEncoder().encode(mood)
            let decoded = try JSONDecoder().decode(DialogueMood.self, from: data)
            #expect(decoded == mood)
        }
    }
}
