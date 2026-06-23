import Foundation
import Testing
@testable import Models
@testable import Services

@Suite("DialogueReadAloudService")
struct DialogueReadAloudServiceTests {

    // MARK: - Pure helpers

    @Test func depthFirstNodesWalksBranchesLeftToRight() {
        // root → [A, B]; A → [A1, A2]; B → []
        let root = makeNode(text: "root")
        let a = makeNode(text: "A")
        let b = makeNode(text: "B")
        let a1 = makeNode(text: "A1")
        let a2 = makeNode(text: "A2")
        let rootWithKids = root.withChildrenIDs([a.id, b.id])
        let aWithKids = a.withChildrenIDs([a1.id, a2.id])
        let tree = DialogueTree(
            title: "Walk",
            characters: [makeCharacter()],
            nodes: [rootWithKids, aWithKids, b, a1, a2],
            rootNodeID: rootWithKids.id
        )

        let walked = DialogueReadAloudService.depthFirstNodes(in: tree)
        #expect(walked.map(\.surfaceText) == ["root", "A", "A1", "A2", "B"])
    }

    @Test func depthFirstSkipsDanglingChildIDs() {
        let root = makeNode(text: "root").withChildrenIDs([UUID()])
        let tree = DialogueTree(
            title: "Dangling",
            characters: [makeCharacter()],
            nodes: [root],
            rootNodeID: root.id
        )
        let walked = DialogueReadAloudService.depthFirstNodes(in: tree)
        #expect(walked.count == 1)
        #expect(walked.first?.surfaceText == "root")
    }

    @Test func composedSpokenForSaidIsBareLine() {
        let node = DialogueNode(
            id: UUID(),
            speakerID: UUID(),
            surfaceText: "I'm fine.",
            inferredSubtext: nil,
            tag: .said("Iris"),
            children: [],
            createdAt: .now
        )
        #expect(DialogueReadAloudService.composedSpoken(for: node) == "I'm fine.")
    }

    @Test func composedSpokenForActionPrependsBeat() {
        let node = DialogueNode(
            id: UUID(),
            speakerID: UUID(),
            surfaceText: "I'm fine.",
            inferredSubtext: nil,
            tag: .action("Iris looks away."),
            children: [],
            createdAt: .now
        )
        #expect(DialogueReadAloudService.composedSpoken(for: node) == "Iris looks away. I'm fine.")
    }

    @Test func composedSpokenForUnattributedReturnsLine() {
        let node = DialogueNode(
            id: UUID(),
            speakerID: UUID(),
            surfaceText: "Why are you crying?",
            inferredSubtext: nil,
            tag: .unattributed,
            children: [],
            createdAt: .now
        )
        #expect(DialogueReadAloudService.composedSpoken(for: node) == "Why are you crying?")
    }

    // MARK: - Pace nudge

    @Test func paceNudgeDefaultsAreCalmReadingPace() {
        let nudge = DialogueReadAloudService.paceNudge(for: "neutral")
        #expect(nudge.pitch == 1.0)
        #expect(nudge.rate == DialogueReadAloudService.PaceNudge.default.rate)
    }

    @Test func paceNudgeFastRaisesRate() {
        let fast = DialogueReadAloudService.paceNudge(for: "fast and energetic")
        let baseline = DialogueReadAloudService.PaceNudge.default
        #expect(fast.rate > baseline.rate)
    }

    @Test func paceNudgeSlowLowersRateAndExtendsPause() {
        let slow = DialogueReadAloudService.paceNudge(for: "slow and measured")
        let baseline = DialogueReadAloudService.PaceNudge.default
        #expect(slow.rate < baseline.rate)
        #expect(slow.postDelay > baseline.postDelay)
    }

    @Test func paceNudgeLowVoiceLowersPitch() {
        let low = DialogueReadAloudService.paceNudge(for: "low brogue")
        #expect(low.pitch < 1.0)
    }

    @Test func paceNudgeHighVoiceRaisesPitch() {
        let high = DialogueReadAloudService.paceNudge(for: "high lilting")
        #expect(high.pitch > 1.0)
    }

    @Test func paceNudgeSoftAddsPostDelay() {
        let soft = DialogueReadAloudService.paceNudge(for: "soft and hushed")
        let baseline = DialogueReadAloudService.PaceNudge.default
        #expect(soft.postDelay > baseline.postDelay)
    }

    @Test func paceNudgePauseStacksPostDelay() {
        let pausey = DialogueReadAloudService.paceNudge(for: "thoughtful hesitant")
        let baseline = DialogueReadAloudService.PaceNudge.default
        #expect(pausey.postDelay >= baseline.postDelay + 0.18)
    }

    // MARK: - Service phase

    @MainActor
    @Test func playEmptyTreeCompletesImmediately() {
        let service = DialogueReadAloudService()
        let tree = DialogueTree(
            title: "Empty",
            characters: [],
            nodes: [],
            rootNodeID: UUID()
        )
        service.play(tree: tree)
        #expect(service.phase == .completed)
    }

    @MainActor
    @Test func stopReturnsToIdle() {
        let service = DialogueReadAloudService()
        let character = makeCharacter()
        let node = DialogueNode(
            id: UUID(),
            speakerID: character.id,
            surfaceText: "Hello.",
            inferredSubtext: nil,
            tag: .said(character.name),
            children: [],
            createdAt: .now
        )
        let tree = DialogueTree(
            title: "Single",
            characters: [character],
            nodes: [node],
            rootNodeID: node.id
        )
        service.play(tree: tree)
        if case .playing = service.phase {
            // expected
        } else {
            Issue.record("Expected service to be in playing state after play")
        }
        service.stop()
        #expect(service.phase == .idle)
    }

    // MARK: - Fixtures

    private func makeCharacter(
        name: String = "Iris",
        register: String = "warm, plain-spoken"
    ) -> DialogueCharacterRef {
        DialogueCharacterRef(
            id: UUID(),
            name: name,
            voiceRegister: register,
            sampleLines: ["Hello, world."]
        )
    }

    private func makeNode(text: String) -> DialogueNode {
        DialogueNode(
            id: UUID(),
            speakerID: UUID(),
            surfaceText: text,
            inferredSubtext: nil,
            tag: .said("Iris"),
            children: [],
            createdAt: .now
        )
    }
}

private extension DialogueNode {
    func withChildrenIDs(_ children: [UUID]) -> DialogueNode {
        DialogueNode(
            id: id,
            speakerID: speakerID,
            surfaceText: surfaceText,
            inferredSubtext: inferredSubtext,
            tag: tag,
            children: children,
            createdAt: createdAt
        )
    }
}
