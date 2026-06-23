import Foundation
import Testing
import ForgeKnowledgeGraph
@testable import Services

@Suite("DialogueCraftSkillGraph — DAG + recommendation")
struct DialogueCraftSkillGraphTests {

    @Test("Graph builds with 6 primitives + validates without issues")
    func graphValidatesClean() {
        let graph = DialogueCraftSkillGraph.build()
        #expect(graph.nodeCount == 6)
        let result = graph.validate()
        #expect(result.isValid, "Graph validation issues: \(result.issues)")
    }

    @Test("Every primitive maps to at least one shipped content kit")
    func everyPrimitiveBacksAtLeastOneKit() {
        let graph = DialogueCraftSkillGraph.build()
        for node in graph.nodes.values {
            #expect(!node.contentKitIDs.isEmpty,
                    "\(node.id) has no contentKitIDs")
        }
    }

    @Test("voiceConsistency is a root (no prerequisites)")
    func voiceConsistencyIsRoot() {
        let graph = DialogueCraftSkillGraph.build()
        let roots = Set(graph.roots().map(\.id))
        #expect(roots.contains(DialogueCraftSkillGraph.NodeID.voiceConsistency))
    }

    @Test("multiListenerSubtext requires subtext + (recommended) triangleDynamics")
    func multiListenerSubtextRequiresSubtext() {
        let graph = DialogueCraftSkillGraph.build()
        let prereqs = graph.prerequisites(
            for: DialogueCraftSkillGraph.NodeID.multiListenerSubtext,
            strength: .required
        ).map(\.id)
        #expect(prereqs.contains(DialogueCraftSkillGraph.NodeID.subtextDetection))
        // triangleDynamics is recommended, not required, so should NOT
        // appear in required-only prereqs.
        #expect(!prereqs.contains(DialogueCraftSkillGraph.NodeID.triangleDynamics))
    }

    @Test("triangleDynamics requires voiceConsistency")
    func triangleDynamicsRequiresVoiceConsistency() {
        let graph = DialogueCraftSkillGraph.build()
        let prereqs = graph.prerequisites(
            for: DialogueCraftSkillGraph.NodeID.triangleDynamics,
            strength: .required
        ).map(\.id)
        #expect(prereqs.contains(DialogueCraftSkillGraph.NodeID.voiceConsistency))
    }

    @Test("Cast embodiment maps each LESSONS primitive to a cast member")
    func castEmbodimentMappingCoversLessonsLayer() {
        let mappings: [(String, String)] = [
            (DialogueCraftSkillGraph.NodeID.voiceConsistency, "brogue"),
            (DialogueCraftSkillGraph.NodeID.subtextDetection, "glance"),
            (DialogueCraftSkillGraph.NodeID.tagBalance, "weigh"),
            (DialogueCraftSkillGraph.NodeID.branchMeaningfulness, "sprig")
        ]
        for (nodeID, expected) in mappings {
            #expect(DialogueCraftSkillGraph.castEmbodiment(for: nodeID) == expected,
                    "\(nodeID) should map to \(expected)")
        }
    }

    @Test("triangleDynamics has no single cast embodiment (emergent)")
    func triangleDynamicsHasNoCastEmbodiment() {
        #expect(DialogueCraftSkillGraph.castEmbodiment(for: DialogueCraftSkillGraph.NodeID.triangleDynamics) == nil)
    }

    @Test("Recommendation with zero mastery picks a primitive without required prereqs")
    func recommendationWithNothingMastered() {
        let next = DialogueCraftSkillGraph.nextPrimitive(mastered: [])
        // With nothing mastered, the unblocked primitives are
        // those without REQUIRED prereqs: voiceConsistency (root, .analyze)
        // and tagBalance (only recommended prereq, .apply).
        // The algorithm picks the lowest Bloom level — `.apply` (3)
        // beats `.analyze` (4), so tagBalance wins. That's a sensible
        // pedagogical choice: tag rhythm is mechanically simpler than
        // voice register.
        let unblocked: Set<String> = [
            DialogueCraftSkillGraph.NodeID.voiceConsistency,
            DialogueCraftSkillGraph.NodeID.tagBalance
        ]
        #expect(next.map(unblocked.contains) == true,
                "Expected an unblocked primitive, got \(String(describing: next))")
    }

    @Test("Recommendation with all mastered returns nil")
    func recommendationWithAllMastered() {
        let all: Set<String> = [
            DialogueCraftSkillGraph.NodeID.voiceConsistency,
            DialogueCraftSkillGraph.NodeID.subtextDetection,
            DialogueCraftSkillGraph.NodeID.tagBalance,
            DialogueCraftSkillGraph.NodeID.branchMeaningfulness,
            DialogueCraftSkillGraph.NodeID.multiListenerSubtext,
            DialogueCraftSkillGraph.NodeID.triangleDynamics
        ]
        #expect(DialogueCraftSkillGraph.nextPrimitive(mastered: all) == nil)
    }

    @Test("Recommendation prefers lower-Bloom primitive among unblocked")
    func recommendationPrefersLowerBloom() {
        // With voiceConsistency mastered, the graph now exposes
        // subtextDetection (.analyze=4), tagBalance (.apply=3), and
        // triangleDynamics (.create=6) as unblocked.
        // .apply (3) is the lowest, so tagBalance wins.
        let mastered: Set<String> = [DialogueCraftSkillGraph.NodeID.voiceConsistency]
        let next = DialogueCraftSkillGraph.nextPrimitive(mastered: mastered)
        #expect(next == DialogueCraftSkillGraph.NodeID.tagBalance)
    }

    @Test("Recommendation after voice + tag mastered surfaces subtext-detection")
    func recommendationAfterVoiceAndTagSurfacesSubtext() {
        // Build the next layer: with voice + tag mastered, subtextDetection
        // (.analyze=4) and triangleDynamics (.create=6) and
        // branchMeaningfulness (.create=6) are unblocked. Lowest Bloom
        // is subtextDetection.
        let mastered: Set<String> = [
            DialogueCraftSkillGraph.NodeID.voiceConsistency,
            DialogueCraftSkillGraph.NodeID.tagBalance
        ]
        let next = DialogueCraftSkillGraph.nextPrimitive(mastered: mastered)
        #expect(next == DialogueCraftSkillGraph.NodeID.subtextDetection)
    }

    @Test("Standards alignment surfaces CCSS + NCAS frameworks")
    func standardsCoverCCSSAndNCAS() {
        let graph = DialogueCraftSkillGraph.build()
        let frameworks = Set(graph.nodes.values.flatMap { $0.standards.map { $0.standard } })
        #expect(frameworks.contains(.ccss))
        #expect(frameworks.contains(.ncas))
    }

    @Test("Primary curriculum standard is W.6-8.3.B across multiple primitives")
    func primaryStandardSurfaceArea() {
        let graph = DialogueCraftSkillGraph.build()
        let primaryCode = "CCSS.ELA-Literacy.W.6-8.3.B"
        let primitivesWithPrimary = graph.nodes.values.filter { node in
            node.standards.contains(where: { $0.code == primaryCode })
        }
        // Primary standard should appear in at least 3 of the 6 primitives —
        // it's the load-bearing CCSS code for dialogue craft.
        #expect(primitivesWithPrimary.count >= 3)
    }
}
