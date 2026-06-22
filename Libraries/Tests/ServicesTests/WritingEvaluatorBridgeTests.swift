import Foundation
import Testing
@testable import Models
@testable import Services

@Suite("WritingEvaluator analyzer bridge")
struct WritingEvaluatorBridgeTests {

    @Test("Empty tree returns nil treeAverage + empty drift list")
    func emptyTreeSummary() {
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
        let summary = VoiceConsistencyAnalyzer().summary(for: tree)
        #expect(summary.treeAverage == nil)
        #expect(summary.driftingLineIDs.isEmpty)
        #expect(summary.perCharacterAverage.isEmpty)
    }

    @Test("voiceChecks returns one VoiceCheck per speaking line")
    func voiceChecksPerLine() {
        let iris = DialogueCharacterRef(
            name: "Iris",
            voiceRegister: "",
            sampleLines: ["I guess that works fine"]
        )
        let line1 = DialogueNode(speakerID: iris.id, surfaceText: "I guess", children: [])
        let line2 = DialogueNode(speakerID: iris.id, surfaceText: "Yes I guess", children: [])
        let tree = DialogueTree(
            title: "tree",
            characters: [iris],
            nodes: [line1, line2],
            rootNodeID: line1.id
        )
        let checks = VoiceConsistencyAnalyzer().voiceChecks(for: tree)
        #expect(checks.count == 2)
        #expect(checks.allSatisfy { $0.speakerID == iris.id })
    }

    @Test("Drifting lines are flagged in the summary")
    func driftingLinesFlagged() {
        let iris = DialogueCharacterRef(
            name: "Iris",
            voiceRegister: "",
            sampleLines: ["Whisper soft small quiet hush"]
        )
        let drifty = DialogueNode(
            speakerID: iris.id,
            surfaceText: "Loud thunderous boom enormous explosion",
            children: []
        )
        let tree = DialogueTree(
            title: "drift",
            characters: [iris],
            nodes: [drifty],
            rootNodeID: drifty.id
        )
        let summary = VoiceConsistencyAnalyzer().summary(for: tree)
        #expect(summary.driftingLineIDs.contains(drifty.id))
    }

    @Test("VoiceBand thresholds map correctly")
    func bandThresholds() {
        #expect(WritingEvaluator.VoiceBand.band(for: 0.1) == .drifting)
        #expect(WritingEvaluator.VoiceBand.band(for: 0.39999) == .drifting)
        #expect(WritingEvaluator.VoiceBand.band(for: 0.4) == .acceptable)
        #expect(WritingEvaluator.VoiceBand.band(for: 0.65) == .acceptable)
        #expect(WritingEvaluator.VoiceBand.band(for: 0.7) == .strong)
        #expect(WritingEvaluator.VoiceBand.band(for: 1.0) == .strong)
    }

    @Test("VoiceCheck clamps score to 0...1 + recomputes band")
    func voiceCheckClampsScore() {
        let high = WritingEvaluator.VoiceCheck(
            surfaceText: "test",
            voiceMatchScore: 1.5
        )
        #expect(high.voiceMatchScore == 1.0)
        #expect(high.band == .strong)
        let low = WritingEvaluator.VoiceCheck(
            surfaceText: "test",
            voiceMatchScore: -0.2
        )
        #expect(low.voiceMatchScore == 0.0)
        #expect(low.band == .drifting)
    }
}
