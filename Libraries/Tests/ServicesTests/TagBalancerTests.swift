import Foundation
import Testing
@testable import Models
@testable import Services

@Suite("TagBalancer — 70% imbalance threshold")
struct TagBalancerTests {

    @Test("All-said dialogue flags 'said' as dominant")
    func allSaidIsDominant() {
        let a = DialogueCharacterRef(name: "A", voiceRegister: "", sampleLines: [])
        let lines = (0..<10).map { _ in
            DialogueNode(speakerID: a.id, surfaceText: "x", tag: .said("said"), children: [])
        }
        let tree = DialogueTree(
            title: "t",
            characters: [a],
            nodes: lines,
            rootNodeID: lines[0].id
        )
        let report = TagBalancer().report(for: tree)
        #expect(report.dominant == .saidVerb)
        #expect(report.hasImbalance)
        #expect(report.perCharacter.first?.dominant == .saidVerb)
    }

    @Test("Balanced dialogue has no dominant tag")
    func balancedTreeHasNoDominant() {
        let a = DialogueCharacterRef(name: "A", voiceRegister: "", sampleLines: [])
        let said = DialogueNode(speakerID: a.id, surfaceText: "x", tag: .said("said"), children: [])
        let action = DialogueNode(speakerID: a.id, surfaceText: "y", tag: .action("nods"), children: [])
        let bare = DialogueNode(speakerID: a.id, surfaceText: "z", tag: .unattributed, children: [])
        let tree = DialogueTree(
            title: "t",
            characters: [a],
            nodes: [said, action, bare],
            rootNodeID: said.id
        )
        let report = TagBalancer().report(for: tree)
        #expect(report.dominant == nil)
        #expect(report.perCharacter.first?.dominant == nil)
        #expect(!report.hasImbalance)
    }

    @Test("Threshold is at 70% — 7-of-10 said triggers dominant; 6-of-10 does not")
    func thresholdBoundary() {
        let a = DialogueCharacterRef(name: "A", voiceRegister: "", sampleLines: [])
        func tree(saidCount: Int) -> DialogueTree {
            let said = (0..<saidCount).map { _ in
                DialogueNode(speakerID: a.id, surfaceText: "x", tag: .said("said"), children: [])
            }
            let action = (saidCount..<10).map { _ in
                DialogueNode(speakerID: a.id, surfaceText: "y", tag: .action("nods"), children: [])
            }
            let all = said + action
            return DialogueTree(
                title: "t",
                characters: [a],
                nodes: all,
                rootNodeID: all[0].id
            )
        }
        #expect(TagBalancer().report(for: tree(saidCount: 6)).dominant == nil)
        #expect(TagBalancer().report(for: tree(saidCount: 7)).dominant == .saidVerb)
    }
}
