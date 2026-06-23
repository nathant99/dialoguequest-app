import Testing
import Foundation
@testable import Services
import Models

@Suite("AnthologyCollectionService — value-type codable helpers")
struct AnthologyCollectionServiceTests {

    @Test("encodeEntryIDs / decodeEntryIDs roundtrip preserves order")
    func entryIDsRoundtrip() throws {
        let ids = (0..<5).map { _ in UUID() }
        let data = try AnthologyCollectionService.encodeEntryIDs(ids)
        let decoded = try AnthologyCollectionService.decodeEntryIDs(from: data)
        #expect(decoded == ids)
    }

    @Test("decodeEntryIDs tolerates empty Data and returns []")
    func decodeEntryIDsEmptyTolerant() throws {
        let decoded = try AnthologyCollectionService.decodeEntryIDs(from: Data())
        #expect(decoded.isEmpty)
    }

    @Test("encodeArchive roundtrips a non-empty trees list")
    func encodeArchiveRoundtrip() throws {
        let rootID = UUID()
        let tree = DialogueTree(
            title: "Quiet hallway",
            characters: [],
            nodes: [],
            rootNodeID: rootID,
            mood: .quietConflict
        )
        let data = try AnthologyCollectionService.encodeArchive(
            title: "First conversations",
            themeHint: .firstConversations,
            trees: [tree]
        )
        let archive = try JSONDecoder().decode(AnthologyCollectionService.CollectionArchive.self, from: data)
        #expect(archive.title == "First conversations")
        #expect(archive.themeHint == AnthologyCollectionThemeHint.firstConversations.rawValue)
        #expect(archive.trees.count == 1)
        #expect(archive.trees.first?.title == "Quiet hallway")
        #expect(archive.schemaVersion == 1)
    }

    @Test("CollectionArchive shape preserves an empty trees list")
    func encodeArchiveEmptyTrees() throws {
        let data = try AnthologyCollectionService.encodeArchive(
            title: "Empty collection",
            themeHint: .whatTheyDidntSay,
            trees: []
        )
        let archive = try JSONDecoder().decode(AnthologyCollectionService.CollectionArchive.self, from: data)
        #expect(archive.trees.isEmpty)
        #expect(archive.themeHint == AnthologyCollectionThemeHint.whatTheyDidntSay.rawValue)
    }

    @Test("AnthologyCollectionThemeHint has 5 cases")
    func themeHintCount() {
        #expect(AnthologyCollectionThemeHint.allCases.count == 5)
    }

    @Test("AnthologyCollectionThemeHint displayName + coachingLine register-clean")
    func themeHintRegister() {
        let stoplist = [
            "load-bearing", "codified", "SAMHSA", "TIP 57",
            "phase A", "phase B", "ADR-", "PR #"
        ]
        for theme in AnthologyCollectionThemeHint.allCases {
            let combined = (theme.displayName + " " + theme.coachingLine).lowercased()
            for token in stoplist {
                #expect(!combined.contains(token.lowercased()),
                        "Theme \(theme) leaks '\(token)': \(combined)")
            }
            #expect(!theme.displayName.isEmpty)
            #expect(!theme.coachingLine.isEmpty)
        }
    }

    @Test("AnthologyCollectionThemeHint rawValues are stable identifiers")
    func themeHintRawValuesStable() {
        let expected: Set<String> = [
            "first_conversations",
            "quiet_conflicts",
            "what_they_didnt_say",
            "branching_moments",
            "three_voice_scenes"
        ]
        let actual = Set(AnthologyCollectionThemeHint.allCases.map(\.rawValue))
        #expect(actual == expected)
    }

    @Test("CollectionSnapshot init preserves every field")
    func snapshotInitPreservesFields() {
        let id = UUID()
        let entryID = UUID()
        let created = Date(timeIntervalSince1970: 1_700_000_000)
        let edited = Date(timeIntervalSince1970: 1_700_001_000)
        let snapshot = AnthologyCollectionService.CollectionSnapshot(
            id: id,
            title: "Test",
            themeHint: .branchingMoments,
            entryIDs: [entryID],
            createdAt: created,
            lastEditedAt: edited
        )
        #expect(snapshot.id == id)
        #expect(snapshot.title == "Test")
        #expect(snapshot.themeHint == .branchingMoments)
        #expect(snapshot.entryIDs == [entryID])
        #expect(snapshot.createdAt == created)
        #expect(snapshot.lastEditedAt == edited)
    }

    @Test("decodeEntryIDs rejects malformed JSON")
    func decodeEntryIDsRejectsMalformed() {
        let malformed = Data("not valid json".utf8)
        #expect(throws: Error.self) {
            try AnthologyCollectionService.decodeEntryIDs(from: malformed)
        }
    }
}
