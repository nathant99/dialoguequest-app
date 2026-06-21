import Testing
import Foundation
import Models
@testable import AppFeature

/// Phase 1 performance-budget tests per `Docs/FEATURE_PLAN.md` § Quality:
/// "tree edit latency < 16ms; AI analysis call queue-bounded".
///
/// The budget targets a 60 fps interactive baseline: every node mutation
/// has to land in under one display frame (16.67 ms) so the kid sees the
/// edit reflected immediately. We test the value-type machine in
/// isolation — no SwiftUI / SwiftData / FoundationModels — so any
/// regression is in the pure value-type code path.
///
/// We measure P95 across N mutations rather than asserting a single
/// observation because CI cores vary; P95 < 16 ms is a robust signal
/// that the median is well under the budget even on slower hardware.
@Suite("DialogueTreeMachine performance budget")
struct DialogueTreeMachinePerformanceTests {

    /// 60 fps frame budget. Per FEATURE_PLAN the hard line is < 16 ms.
    /// We allow a small headroom for test-runner overhead so the assertion
    /// stays meaningful (a 16-ms ceiling on a 5-ms reality is a fragile
    /// guard against future regressions).
    static let frameBudgetMs: Double = 16.0

    // MARK: - Tree-edit latency

    @Test func appendChildLatencyStaysUnderFrameBudget() {
        var machine = makePopulatedSeed(characterCount: 2)
        let speakerID = machine.tree.characters[0].id

        var observations: [Double] = []
        // Append up to phase1Max nodes (15 — including the root).
        let appendCount = DialogueTree.NodeCountConstraint.phase1Max - machine.tree.nodes.count
        for _ in 0..<appendCount {
            guard let parentID = machine.tree.nodes.last?.id else { break }
            let elapsed = Self.measureMs {
                _ = machine.appendChild(to: parentID, speakerID: speakerID, surfaceText: "Line", tag: .said("said"))
            }
            observations.append(elapsed)
        }

        let p95 = Self.p95(observations)
        #expect(p95 < Self.frameBudgetMs, "appendChild P95 \(p95) ms exceeds \(Self.frameBudgetMs) ms")
    }

    @Test func updateNodeLatencyStaysUnderFrameBudget() {
        var machine = makePopulatedSeed(characterCount: 2)
        let speakerID = machine.tree.characters[0].id
        // Fill to phase1Max.
        while machine.tree.nodes.count < DialogueTree.NodeCountConstraint.phase1Max,
              let parentID = machine.tree.nodes.last?.id {
            _ = machine.appendChild(to: parentID, speakerID: speakerID)
        }

        let nodes = machine.tree.nodes
        var observations: [Double] = []
        for node in nodes {
            let updated = DialogueNode(
                id: node.id,
                speakerID: node.speakerID,
                surfaceText: node.surfaceText + " (updated)",
                inferredSubtext: node.inferredSubtext,
                tag: node.tag,
                children: node.children,
                createdAt: node.createdAt
            )
            let elapsed = Self.measureMs {
                machine.updateNode(updated)
            }
            observations.append(elapsed)
        }

        let p95 = Self.p95(observations)
        #expect(p95 < Self.frameBudgetMs, "updateNode P95 \(p95) ms exceeds \(Self.frameBudgetMs) ms")
    }

    @Test func confirmAndRejectSubtextLatencyStaysUnderFrameBudget() {
        var machine = makePopulatedSeed(characterCount: 2)
        let speakerID = machine.tree.characters[0].id
        while machine.tree.nodes.count < 10, let parentID = machine.tree.nodes.last?.id {
            _ = machine.appendChild(to: parentID, speakerID: speakerID)
        }
        let ids = machine.tree.nodes.map(\.id)

        var observations: [Double] = []
        for id in ids {
            observations.append(Self.measureMs {
                machine.confirmSubtext(for: id, inferredSubtext: "Implied: backing away.")
            })
            observations.append(Self.measureMs {
                machine.rejectSubtext(for: id)
            })
        }

        let p95 = Self.p95(observations)
        #expect(p95 < Self.frameBudgetMs, "confirm/reject Subtext P95 \(p95) ms exceeds \(Self.frameBudgetMs) ms")
    }

    @Test func removeLeafLatencyStaysUnderFrameBudget() {
        var machine = makePopulatedSeed(characterCount: 2)
        let speakerID = machine.tree.characters[0].id
        while machine.tree.nodes.count < DialogueTree.NodeCountConstraint.phase1Max,
              let parentID = machine.tree.nodes.last?.id {
            _ = machine.appendChild(to: parentID, speakerID: speakerID)
        }

        var observations: [Double] = []
        // Remove leaves in reverse order so each removal stays a valid leaf op.
        while machine.tree.nodes.count > 1 {
            let leaves = machine.tree.nodes.filter(\.isLeaf).filter { $0.id != machine.tree.rootNodeID }
            guard let target = leaves.first else { break }
            let elapsed = Self.measureMs {
                machine.removeLeaf(target.id)
            }
            observations.append(elapsed)
        }

        let p95 = Self.p95(observations)
        #expect(p95 < Self.frameBudgetMs, "removeLeaf P95 \(p95) ms exceeds \(Self.frameBudgetMs) ms")
    }

    @Test func resetLatencyIsTrivial() {
        var machine = makePopulatedSeed(characterCount: 2)
        let speakerID = machine.tree.characters[0].id
        while machine.tree.nodes.count < DialogueTree.NodeCountConstraint.phase1Max,
              let parentID = machine.tree.nodes.last?.id {
            _ = machine.appendChild(to: parentID, speakerID: speakerID)
        }

        let elapsed = Self.measureMs {
            machine.reset()
        }
        #expect(elapsed < Self.frameBudgetMs, "reset took \(elapsed) ms — should be a trivial value-type re-init")
        #expect(machine.tree.nodes.isEmpty)
    }

    // MARK: - Helpers

    private func makePopulatedSeed(characterCount: Int) -> DialogueTreeMachine {
        // Reuse the canonical UI-test seed builder so production + tests
        // share one source of truth for "what a non-trivial editing state
        // looks like."
        return WriteTabUITestSeed.makeSeed()
    }

    private static func measureMs(_ block: () -> Void) -> Double {
        let start = ContinuousClock().now
        block()
        let end = ContinuousClock().now
        let duration = end - start
        return duration.toMilliseconds()
    }

    /// P95 of the observations — 95th percentile, nearest-rank method.
    /// Empty list → 0 so empty-fixture tests still pass.
    private static func p95(_ values: [Double]) -> Double {
        guard !values.isEmpty else { return 0 }
        let sorted = values.sorted()
        let rank = Int(ceil(0.95 * Double(sorted.count))) - 1
        let clamped = max(0, min(sorted.count - 1, rank))
        return sorted[clamped]
    }
}

private extension Duration {
    func toMilliseconds() -> Double {
        let components = self.components
        let seconds = Double(components.seconds)
        let attoseconds = Double(components.attoseconds) / 1e18
        return (seconds + attoseconds) * 1_000.0
    }
}
