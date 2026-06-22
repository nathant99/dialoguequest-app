import Foundation
import Testing
@testable import Models
@testable import AIMentor

@Suite("DialogueLineAnalysis → WritingEvaluator.VoiceCheck bridge")
struct DialogueLineAnalysisBridgeTests {

    @Test("toVoiceCheck preserves surfaceText + score + ID + speaker")
    func bridgeProjects() {
        let analysis = DialogueLineAnalysis(
            surfaceText: "I'm fine.",
            inferredSubtext: "She's not fine.",
            voiceMatchScore: 0.82
        )
        let lineID = UUID()
        let speakerID = UUID()
        let check = analysis.toVoiceCheck(lineID: lineID, speakerID: speakerID)
        #expect(check.id == lineID)
        #expect(check.speakerID == speakerID)
        #expect(check.surfaceText == "I'm fine.")
        #expect(check.voiceMatchScore == 0.82)
        #expect(check.band == .strong)
    }

    @Test("Drifting score lands in .drifting band")
    func driftingBand() {
        let analysis = DialogueLineAnalysis(
            surfaceText: "out of voice",
            inferredSubtext: "",
            voiceMatchScore: 0.15
        )
        let check = analysis.toVoiceCheck(lineID: UUID(), speakerID: nil)
        #expect(check.band == .drifting)
    }

    @Test("nil speakerID is allowed (per-line analysis without character context)")
    func nilSpeaker() {
        let analysis = DialogueLineAnalysis(
            surfaceText: "anonymous",
            inferredSubtext: "",
            voiceMatchScore: 0.5
        )
        let check = analysis.toVoiceCheck(lineID: UUID(), speakerID: nil)
        #expect(check.speakerID == nil)
        #expect(check.band == .acceptable)
    }
}
