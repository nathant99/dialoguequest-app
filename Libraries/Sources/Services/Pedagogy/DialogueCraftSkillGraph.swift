import Foundation
import ForgeKnowledgeGraph
import ForgeModels

/// Dialogue-craft curriculum modeled as a `ForgeKnowledgeGraph` DAG.
///
/// Each node is one of the five dialogue-craft primitives the kid
/// learns across Phase 1 + Phase 2: voice consistency, subtext, tag
/// balance, branch meaningfulness, multi-listener subtext + triangle
/// dynamics. Edges encode "you should land this before that lands
/// fully" prerequisite relations. CCSS / NCAS alignment is baked in
/// per-node via `StandardAlignment` so any future `ForgeReporting`
/// surface inherits the mapping for free.
///
/// **Why a graph?** The 5 primitives are NOT linear. A kid can land
/// "tag balance" before "voice consistency" but won't fully feel
/// "branch meaningfulness" without "stakes" + "subtext" in place.
/// The graph lets `PathRecommender` + `GapAnalyzer` pick the next
/// primitive to scaffold based on what the kid has demonstrated
/// (via `StreakService` + `AchievementService` evidence).
///
/// **Consumer surface**: `DDAEngine` consults the graph to pick the
/// next primitive to nudge; `ParentProgressDashboardView` (Phase 4)
/// surfaces standards-mapped reporting via `node.standards`. Both
/// downstream consumers land in future rounds.
public nonisolated enum DialogueCraftSkillGraph {

    /// Stable node identifiers — the primitive slugs. These also map
    /// onto `CastVoiceRegistry.lessonsLayerProfiles` IDs where the
    /// cast embodies the primitive (per Pattern B), so the graph can
    /// recommend a cast member to coach the next primitive.
    public enum NodeID {
        public static let voiceConsistency       = "voice_consistency"
        public static let subtextDetection       = "subtext_detection"
        public static let tagBalance             = "tag_balance"
        public static let branchMeaningfulness   = "branch_meaningfulness"
        public static let multiListenerSubtext   = "multi_listener_subtext"
        public static let triangleDynamics       = "triangle_dynamics"
    }

    /// Cast member who embodies a given primitive — used by callers
    /// that want to surface a "Sprig recommends working on branch
    /// meaningfulness next" hint. Returns `nil` for primitives without
    /// a single cast embodiment (currently `triangleDynamics` —
    /// emerges from the trio, not any one character).
    public static func castEmbodiment(for nodeID: String) -> String? {
        switch nodeID {
        case NodeID.voiceConsistency:     return "brogue"
        case NodeID.subtextDetection:     return "glance"
        case NodeID.tagBalance:           return "weigh"
        case NodeID.branchMeaningfulness: return "sprig"
        case NodeID.multiListenerSubtext: return "glance"  // Glance extends to multi-listener
        case NodeID.triangleDynamics:     return nil       // Emergent from 3-character authoring
        default:                          return nil
        }
    }

    /// Build the canonical DialogueQuest skill graph. Pure factory —
    /// callers retain the result (it's a value type) and pass it to
    /// `GraphTraversal` / `GapAnalyzer` / `PathRecommender`.
    public static func build() -> KnowledgeGraph {
        let nodes: [KnowledgeNode] = [
            KnowledgeNode(
                id: NodeID.voiceConsistency,
                title: "Voice consistency",
                bloomLevel: .analyze,
                topic: "dialogue_craft",
                subtopic: "voice_register",
                gradeBand: "middle",
                standards: [
                    StandardAlignment(standard: .ccss, code: "CCSS.ELA-Literacy.W.6-8.3.B",
                                      description: "Use narrative techniques, such as dialogue, pacing, description, and reflection."),
                    StandardAlignment(standard: .ccss, code: "CCSS.ELA-Literacy.RL.6-8.6",
                                      description: "Explain how an author develops the point of view of the narrator or speaker.")
                ],
                contentKitIDs: ["kit_01_voice_consistency", "kit_05_triangle_voices", "kit_06_voice_crucible"]
            ),
            KnowledgeNode(
                id: NodeID.subtextDetection,
                title: "Subtext detection",
                bloomLevel: .analyze,
                topic: "dialogue_craft",
                subtopic: "subtext",
                gradeBand: "middle",
                standards: [
                    StandardAlignment(standard: .ccss, code: "CCSS.ELA-Literacy.RL.6-8.6",
                                      description: "Explain how an author develops the point of view of the narrator or speaker."),
                    StandardAlignment(standard: .ncas, code: "NCAS.TH:Cr3",
                                      description: "Refine and complete artistic work in theatre, attending to subtext and revision.")
                ],
                contentKitIDs: ["kit_02_subtext_detection"]
            ),
            KnowledgeNode(
                id: NodeID.tagBalance,
                title: "Tag balance + action beats",
                bloomLevel: .apply,
                topic: "dialogue_craft",
                subtopic: "attribution_rhythm",
                gradeBand: "middle",
                standards: [
                    StandardAlignment(standard: .ccss, code: "CCSS.ELA-Literacy.W.6-8.3.B",
                                      description: "Use narrative techniques, such as dialogue, pacing, description, and reflection.")
                ],
                contentKitIDs: ["kit_03_tag_balance", "kit_09_action_beats"]
            ),
            KnowledgeNode(
                id: NodeID.branchMeaningfulness,
                title: "Branch meaningfulness",
                bloomLevel: .create,
                topic: "dialogue_craft",
                subtopic: "branch_stakes",
                gradeBand: "middle",
                standards: [
                    StandardAlignment(standard: .ccss, code: "CCSS.ELA-Literacy.W.6-8.3.B",
                                      description: "Use narrative techniques, such as dialogue, pacing, description, and reflection."),
                    StandardAlignment(standard: .ncas, code: "NCAS.TH:Cr3",
                                      description: "Refine and complete artistic work in theatre.")
                ],
                contentKitIDs: ["kit_04_branching", "kit_08_branch_consequences"]
            ),
            KnowledgeNode(
                id: NodeID.multiListenerSubtext,
                title: "Multi-listener subtext",
                bloomLevel: .evaluate,
                topic: "dialogue_craft",
                subtopic: "subtext",
                gradeBand: "middle",
                standards: [
                    StandardAlignment(standard: .ccss, code: "CCSS.ELA-Literacy.RL.6-8.6",
                                      description: "Explain how an author develops the point of view of the narrator or speaker."),
                    StandardAlignment(standard: .ncas, code: "NCAS.LA:Cr2",
                                      description: "Organize and develop artistic ideas and work in language arts.")
                ],
                contentKitIDs: ["kit_07_subtext_crucible"]
            ),
            KnowledgeNode(
                id: NodeID.triangleDynamics,
                title: "Triangle dynamics",
                bloomLevel: .create,
                topic: "dialogue_craft",
                subtopic: "triangle_authoring",
                gradeBand: "middle",
                standards: [
                    StandardAlignment(standard: .ccss, code: "CCSS.ELA-Literacy.W.6-8.3.B",
                                      description: "Use narrative techniques in 3-character dialogue (alliance / arbitration / triangle dynamics)."),
                    StandardAlignment(standard: .ncas, code: "NCAS.TH:Cr3",
                                      description: "Refine and complete artistic work in theatre.")
                ],
                contentKitIDs: ["kit_05_triangle_voices"]
            )
        ]

        // Edges encode "kid should feel X before Y fully lands"
        // prerequisite relations. Strength `.required` = the
        // downstream primitive really doesn't make sense without the
        // upstream; `.recommended` = the kid can engage with the
        // downstream but the upstream sharpens the work.
        let edges: [KnowledgeEdge] = [
            // Voice consistency is the foundation — without consistent
            // characters, subtext / tag balance / branch stakes feel
            // arbitrary.
            KnowledgeEdge(from: NodeID.voiceConsistency,
                          to: NodeID.subtextDetection,
                          strength: .required),
            KnowledgeEdge(from: NodeID.voiceConsistency,
                          to: NodeID.tagBalance,
                          strength: .recommended),
            KnowledgeEdge(from: NodeID.voiceConsistency,
                          to: NodeID.branchMeaningfulness,
                          strength: .required),

            // Subtext sharpens branch stakes — a branch that hides what
            // the speaker isn't saying feels heavier than one that
            // doesn't.
            KnowledgeEdge(from: NodeID.subtextDetection,
                          to: NodeID.branchMeaningfulness,
                          strength: .recommended),

            // Multi-listener subtext extends single-listener subtext,
            // and triangle dynamics is what makes multi-listener
            // subtext rich (a third character changes what each line
            // means to each listener).
            KnowledgeEdge(from: NodeID.subtextDetection,
                          to: NodeID.multiListenerSubtext,
                          strength: .required),
            KnowledgeEdge(from: NodeID.voiceConsistency,
                          to: NodeID.triangleDynamics,
                          strength: .required),
            KnowledgeEdge(from: NodeID.triangleDynamics,
                          to: NodeID.multiListenerSubtext,
                          strength: .recommended)
        ]

        return KnowledgeGraph(nodes: nodes, edges: edges)
    }

    // MARK: - Mastery-based recommendation

    /// Pick the next primitive to nudge the kid toward, given the set
    /// of primitives they've already mastered. Uses `GapAnalyzer` to
    /// surface the lowest-distance unmastered prerequisite for the
    /// "frontier" of currently-unreachable primitives. Returns `nil`
    /// when the kid has mastered every node (or when no path exists).
    public static func nextPrimitive(mastered: Set<String>) -> String? {
        let graph = build()
        // Skip primitives the kid already has.
        let unmastered = graph.nodes.keys.filter { !mastered.contains($0) }
        guard !unmastered.isEmpty else { return nil }

        // For each unmastered primitive, find its unmastered required
        // prerequisites. Recommend the one whose prerequisites are
        // already fully landed — that's the next achievable lift.
        let traversal = GraphTraversal()
        let analyzer = GapAnalyzer(traversal: traversal)
        let candidates: [(String, Int)] = unmastered.compactMap { nodeID -> (String, Int)? in
            let gaps = analyzer.findGaps(for: nodeID, in: graph, mastered: mastered)
            // Skip primitives still blocked by required prerequisites.
            guard gaps.isEmpty else { return nil }
            // Score by Bloom level — prefer .analyze (foundation) over
            // .create (latest) when multiple primitives are unblocked.
            let level = graph.node(nodeID)?.bloomLevel ?? .remember
            return (nodeID, level.rawValue)
        }

        // Sort by ascending Bloom rawValue so the earliest-Bloom
        // primitive is recommended first.
        return candidates.sorted { $0.1 < $1.1 }.first?.0
    }
}
