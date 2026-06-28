import Testing
import Foundation
@testable import Models

@Suite("PublishedTreeSnapshot")
struct PublishedTreeSnapshotTests {

    // MARK: - Fixtures

    private func makeCharacter(name: String) -> DialogueCharacterRef {
        DialogueCharacterRef(
            id: UUID(),
            name: name,
            voiceRegister: "test register",
            sampleLines: ["sample"],
            role: .protagonist
        )
    }

    private func makeNode(speaker: UUID) -> DialogueNode {
        DialogueNode(speakerID: speaker, surfaceText: "Hello.")
    }

    private func makeTree(
        title: String,
        characters: [DialogueCharacterRef],
        nodeCount: Int,
        mood: DialogueMood?
    ) -> DialogueTree {
        let speaker = characters.first?.id ?? UUID()
        let nodes = (0..<nodeCount).map { _ in makeNode(speaker: speaker) }
        return DialogueTree(
            title: title,
            characters: characters,
            nodes: nodes,
            rootNodeID: nodes.first?.id ?? UUID(),
            mood: mood
        )
    }

    // MARK: - Factory

    @Test("from(tree:summary:) maps every scored character with its name")
    func factoryMapsCharacters() {
        let sprig = makeCharacter(name: "Sprig")
        let brogue = makeCharacter(name: "Brogue")
        let tree = makeTree(title: "Bridge talk", characters: [sprig, brogue], nodeCount: 7, mood: .quietConflict)
        let summary = WritingEvaluator.VoiceSummary(
            perCharacterAverage: [sprig.id: 0.9, brogue.id: 0.3],
            treeAverage: 0.6,
            driftingLineIDs: []
        )

        let snapshot = PublishedTreeSnapshot.from(tree: tree, summary: summary, now: Date(timeIntervalSince1970: 1000))

        #expect(snapshot.id == tree.id)
        #expect(snapshot.title == "Bridge talk")
        #expect(snapshot.nodeCount == 7)
        #expect(snapshot.mood == .quietConflict)
        #expect(snapshot.treeAverageVoiceMatch == 0.6)
        #expect(snapshot.characterVoices.count == 2)
    }

    @Test("characterVoices sort alphabetically by name")
    func characterVoicesSorted() {
        let sprig = makeCharacter(name: "Sprig")
        let brogue = makeCharacter(name: "Brogue")
        let tree = makeTree(title: "T", characters: [sprig, brogue], nodeCount: 5, mood: nil)
        let summary = WritingEvaluator.VoiceSummary(
            perCharacterAverage: [sprig.id: 0.5, brogue.id: 0.5],
            treeAverage: 0.5,
            driftingLineIDs: []
        )

        let snapshot = PublishedTreeSnapshot.from(tree: tree, summary: summary, now: Date())

        #expect(snapshot.characterVoices.map(\.name) == ["Brogue", "Sprig"])
    }

    @Test("characters with no scored line are omitted")
    func unscoredCharactersOmitted() {
        let sprig = makeCharacter(name: "Sprig")
        let silent = makeCharacter(name: "Silent")
        let tree = makeTree(title: "T", characters: [sprig, silent], nodeCount: 5, mood: nil)
        let summary = WritingEvaluator.VoiceSummary(
            perCharacterAverage: [sprig.id: 0.7],  // silent not present
            treeAverage: 0.7,
            driftingLineIDs: []
        )

        let snapshot = PublishedTreeSnapshot.from(tree: tree, summary: summary, now: Date())

        #expect(snapshot.characterVoices.count == 1)
        #expect(snapshot.characterVoices.first?.name == "Sprig")
    }

    @Test("band derives from voice-match score")
    func bandDerivation() {
        let strong = makeCharacter(name: "Aaa")    // 0.9 -> strong
        let acc = makeCharacter(name: "Bbb")        // 0.5 -> acceptable
        let drift = makeCharacter(name: "Ccc")      // 0.2 -> drifting
        let tree = makeTree(title: "T", characters: [strong, acc, drift], nodeCount: 5, mood: nil)
        let summary = WritingEvaluator.VoiceSummary(
            perCharacterAverage: [strong.id: 0.9, acc.id: 0.5, drift.id: 0.2],
            treeAverage: 0.53,
            driftingLineIDs: []
        )

        let snapshot = PublishedTreeSnapshot.from(tree: tree, summary: summary, now: Date())
        let byName = Dictionary(uniqueKeysWithValues: snapshot.characterVoices.map { ($0.name, $0.band) })

        #expect(byName["Aaa"] == .strong)
        #expect(byName["Bbb"] == .acceptable)
        #expect(byName["Ccc"] == .drifting)
    }

    @Test("nil treeAverage round-trips as nil")
    func nilTreeAverage() {
        let sprig = makeCharacter(name: "Sprig")
        let tree = makeTree(title: "T", characters: [sprig], nodeCount: 5, mood: nil)
        let summary = WritingEvaluator.VoiceSummary(
            perCharacterAverage: [:],
            treeAverage: nil,
            driftingLineIDs: []
        )

        let snapshot = PublishedTreeSnapshot.from(tree: tree, summary: summary, now: Date())

        #expect(snapshot.treeAverageVoiceMatch == nil)
        #expect(snapshot.characterVoices.isEmpty)
    }

    // MARK: - Codable

    @Test("Codable round-trips every field")
    func codableRoundTrip() throws {
        let id = UUID()
        let charID = UUID()
        let snapshot = PublishedTreeSnapshot(
            id: id,
            title: "Roundtrip",
            nodeCount: 9,
            mood: .playfulRivalry,
            treeAverageVoiceMatch: 0.72,
            characterVoices: [
                PublishedTreeSnapshot.CharacterVoice(id: charID, name: "Weigh", voiceMatch: 0.72)
            ],
            publishedAt: Date(timeIntervalSince1970: 42_000)
        )

        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(PublishedTreeSnapshot.self, from: data)

        #expect(decoded == snapshot)
        #expect(decoded.characterVoices.first?.name == "Weigh")
        #expect(decoded.characterVoices.first?.band == .strong)
    }

    @Test("voiceMatch is clamped to 0...1")
    func voiceMatchClamped() {
        let over = PublishedTreeSnapshot.CharacterVoice(id: UUID(), name: "Over", voiceMatch: 1.5)
        let under = PublishedTreeSnapshot.CharacterVoice(id: UUID(), name: "Under", voiceMatch: -0.5)
        #expect(over.voiceMatch == 1.0)
        #expect(under.voiceMatch == 0.0)
    }
}
