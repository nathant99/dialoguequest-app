import Foundation
import Testing
@testable import Models
@testable import AppFeature

@MainActor
@Suite("CollaborativeDialogueSession")
struct CollaborativeDialogueSessionTests {

    private func makeCharacters() -> (DialogueCharacterRef, DialogueCharacterRef) {
        let a = DialogueCharacterRef(
            name: "Iris",
            voiceRegister: "quiet",
            sampleLines: ["I'm fine."]
        )
        let b = DialogueCharacterRef(
            name: "Cal",
            voiceRegister: "bright",
            sampleLines: ["Try again."]
        )
        return (a, b)
    }

    @Test("Fresh session starts in .notStarted")
    func freshSessionIdle() {
        let session = CollaborativeDialogueSession()
        if case .notStarted = session.phase { /* ok */ }
        else { Issue.record("Expected .notStarted on fresh session") }
        #expect(session.authoredLines.isEmpty)
    }

    @Test("start(...) advances to .authoring with player A and a cast prompt")
    func startAdvancesToAuthoring() async {
        let (a, b) = makeCharacters()
        let session = CollaborativeDialogueSession()
        await session.start(
            playerA: "Alex",
            playerB: "Sam",
            characterA: a,
            characterB: b,
            roundsPerPlayer: 2
        )
        if case .authoring(let player, let prompt) = session.phase {
            #expect(player == "Alex")
            #expect(!prompt.castDisplayName.isEmpty)
            #expect(!prompt.promptText.isEmpty)
        } else {
            Issue.record("Expected .authoring after start, got \(session.phase)")
        }
    }

    @Test("recordLine appends and triggers the handoff curtain")
    func recordLineAdvancesCurtain() async {
        let (a, b) = makeCharacters()
        let session = CollaborativeDialogueSession()
        await session.start(
            playerA: "Alex",
            playerB: "Sam",
            characterA: a,
            characterB: b,
            roundsPerPlayer: 2
        )
        await session.recordLine("Hi there.")
        #expect(session.authoredLines.count == 1)
        #expect(session.authoredLines.first?.surfaceText == "Hi there.")
        // After recordLine, the engine awaits handoff and the curtain
        // is in `.passToNext`, so the session reports `.handoff`.
        switch session.phase {
        case .handoff(let toName):
            #expect(toName == "Sam")
        default:
            Issue.record("Expected .handoff after recordLine, got \(session.phase)")
        }
    }

    @Test("Full session of 4 lines (2 per player) produces a 4-node tree")
    func fullSessionProducesTree() async {
        let (a, b) = makeCharacters()
        let session = CollaborativeDialogueSession()
        await session.start(
            playerA: "Alex",
            playerB: "Sam",
            characterA: a,
            characterB: b,
            roundsPerPlayer: 2
        )
        let lines = ["Line 1", "Line 2", "Line 3", "Line 4"]
        for line in lines {
            await session.recordLine(line)
            // Advance the curtain through both stages so the next player's turn begins.
            await session.acceptHandoff()
            await session.revealAndBegin()
        }
        if case .complete(let tree) = session.phase {
            #expect(tree.nodes.count == 4)
            #expect(tree.nodes.map(\.surfaceText) == lines)
            // The tree is linearly stitched — every non-leaf has exactly one child.
            let nonLeaves = tree.nodes.dropLast()
            #expect(nonLeaves.allSatisfy { $0.children.count == 1 })
        } else {
            Issue.record("Expected .complete after 4 lines, got \(session.phase)")
        }
    }

    @Test("endEarly surfaces .complete with whatever was authored so far")
    func endEarlyArchivesPartial() async {
        let (a, b) = makeCharacters()
        let session = CollaborativeDialogueSession()
        await session.start(
            playerA: "Alex",
            playerB: "Sam",
            characterA: a,
            characterB: b,
            roundsPerPlayer: 3
        )
        await session.recordLine("Just one line.")
        session.endEarly()
        if case .complete(let tree) = session.phase {
            #expect(tree.nodes.count == 1)
        } else {
            Issue.record("Expected .complete after endEarly, got \(session.phase)")
        }
    }

    @Test("Alternating speakers across the linear tree")
    func alternatingSpeakers() async {
        let (a, b) = makeCharacters()
        let session = CollaborativeDialogueSession()
        await session.start(
            playerA: "Alex",
            playerB: "Sam",
            characterA: a,
            characterB: b,
            roundsPerPlayer: 2
        )
        for line in ["L1", "L2", "L3", "L4"] {
            await session.recordLine(line)
            await session.acceptHandoff()
            await session.revealAndBegin()
        }
        if case .complete(let tree) = session.phase {
            let speakerIDs = tree.nodes.map(\.speakerID)
            #expect(speakerIDs == [a.id, b.id, a.id, b.id])
        } else {
            Issue.record("Expected .complete")
        }
    }
}
