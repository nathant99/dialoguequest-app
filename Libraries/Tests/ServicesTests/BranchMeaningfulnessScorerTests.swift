import Foundation
import Testing
@testable import Models
@testable import Services

@Suite("BranchMeaningfulnessScorer — structural rules")
struct BranchMeaningfulnessScorerTests {

    @Test("Tree with zero branch points scores 0 reflectionRatio")
    func zeroBranchPoints() {
        let speaker = DialogueCharacterRef(name: "A", voiceRegister: "", sampleLines: [])
        let a = DialogueNode(speakerID: speaker.id, surfaceText: "1", children: [])
        let tree = DialogueTree(
            title: "linear",
            characters: [speaker],
            nodes: [a],
            rootNodeID: a.id
        )
        let report = BranchMeaningfulnessScorer().score(tree: tree, reflectedBranchPointIDs: [])
        #expect(report.branchPointCount == 0)
        #expect(report.reflectionRatio == 0)
    }

    @Test("Branch point is recognized when node has 2+ children")
    func recognizesBranchPoint() {
        let speaker = DialogueCharacterRef(name: "A", voiceRegister: "", sampleLines: [])
        let leafA = DialogueNode(speakerID: speaker.id, surfaceText: "L1", children: [])
        let leafB = DialogueNode(speakerID: speaker.id, surfaceText: "L2", children: [])
        let branch = DialogueNode(
            speakerID: speaker.id,
            surfaceText: "Choose",
            children: [leafA.id, leafB.id]
        )
        let tree = DialogueTree(
            title: "branched",
            characters: [speaker],
            nodes: [branch, leafA, leafB],
            rootNodeID: branch.id
        )
        let report = BranchMeaningfulnessScorer().score(tree: tree, reflectedBranchPointIDs: [])
        #expect(report.branchPointCount == 1)
        #expect(report.leafCount == 2)
        #expect(report.meetsLeafTarget)
    }

    @Test("Reflection ratio reflects passed-in reflection set")
    func reflectionRatioReflectsSet() {
        let speaker = DialogueCharacterRef(name: "A", voiceRegister: "", sampleLines: [])
        let leafA = DialogueNode(speakerID: speaker.id, surfaceText: "L1", children: [])
        let leafB = DialogueNode(speakerID: speaker.id, surfaceText: "L2", children: [])
        let leafC = DialogueNode(speakerID: speaker.id, surfaceText: "L3", children: [])
        let leafD = DialogueNode(speakerID: speaker.id, surfaceText: "L4", children: [])
        let branch1 = DialogueNode(
            speakerID: speaker.id,
            surfaceText: "B1",
            children: [leafA.id, leafB.id]
        )
        let branch2 = DialogueNode(
            speakerID: speaker.id,
            surfaceText: "B2",
            children: [leafC.id, leafD.id]
        )
        let root = DialogueNode(
            speakerID: speaker.id,
            surfaceText: "root",
            children: [branch1.id, branch2.id]
        )
        let tree = DialogueTree(
            title: "deep",
            characters: [speaker],
            nodes: [root, branch1, branch2, leafA, leafB, leafC, leafD],
            rootNodeID: root.id
        )
        let report = BranchMeaningfulnessScorer().score(
            tree: tree,
            reflectedBranchPointIDs: [root.id, branch1.id]
        )
        #expect(report.branchPointCount == 3)
        #expect(report.reflectedBranchPointCount == 2)
        #expect(abs(report.reflectionRatio - (2.0 / 3.0)) < 0.001)
    }
}
