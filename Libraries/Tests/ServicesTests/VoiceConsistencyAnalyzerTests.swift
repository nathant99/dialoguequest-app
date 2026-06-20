import Foundation
import Testing
@testable import Models
@testable import Services

@Suite("VoiceConsistencyAnalyzer — token-overlap baseline")
struct VoiceConsistencyAnalyzerTests {

    @Test("Empty tree returns zero-score per character")
    func emptyTree() {
        let iris = DialogueCharacterRef(
            name: "Iris",
            voiceRegister: "",
            sampleLines: ["Whatever", "Fine"]
        )
        let tree = DialogueTree(
            title: "empty",
            characters: [iris],
            nodes: [],
            rootNodeID: iris.id
        )
        let reports = VoiceConsistencyAnalyzer().report(for: tree)
        #expect(reports.count == 1)
        #expect(reports.first?.lineCount == 0)
        #expect(reports.first?.averageVoiceMatchScore == 0)
    }

    @Test("Line that matches sample tokens scores higher than mismatched line")
    func matchedLineScoresHigher() {
        let iris = DialogueCharacterRef(
            name: "Iris",
            voiceRegister: "",
            sampleLines: ["I guess that works fine", "Whatever you say I guess"]
        )
        let matched = DialogueNode(
            speakerID: iris.id,
            surfaceText: "I guess that works",
            children: []
        )
        let off = DialogueNode(
            speakerID: iris.id,
            surfaceText: "Whoa, banana zebra!",
            children: []
        )
        let tree = DialogueTree(
            title: "mix",
            characters: [iris],
            nodes: [matched, off],
            rootNodeID: matched.id
        )
        let report = VoiceConsistencyAnalyzer().report(for: tree).first!
        #expect(report.lineCount == 2)
        #expect(report.averageVoiceMatchScore > 0)
        #expect(report.outOfVoiceLineIDs.contains(off.id))
        #expect(!report.outOfVoiceLineIDs.contains(matched.id))
    }

    @Test("Jaccard helper is symmetric + bounded 0...1")
    func jaccardBounds() {
        let a: Set<String> = ["one", "two", "three"]
        let b: Set<String> = ["two", "three", "four"]
        let score = VoiceConsistencyAnalyzer.jaccard(a, b)
        #expect(score == VoiceConsistencyAnalyzer.jaccard(b, a))
        #expect(score > 0 && score < 1)
        #expect(VoiceConsistencyAnalyzer.jaccard(a, a) == 1)
        #expect(VoiceConsistencyAnalyzer.jaccard(a, []) == 0)
    }
}
