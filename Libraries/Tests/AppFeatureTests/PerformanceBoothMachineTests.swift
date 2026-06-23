import Testing
import Foundation
@testable import AppFeature

@Suite("PerformanceBoothMachine — pure value-type machine")
struct PerformanceBoothMachineTests {

    @Test("Default stage is .choosingTree with zero counters")
    func defaultStage() {
        let machine = PerformanceBoothMachine()
        #expect(machine.stage == .choosingTree)
        #expect(machine.exportCount == 0)
        #expect(machine.hasListenedThisRound == false)
        #expect(machine.selectedTreeID == nil)
        #expect(machine.currentExportURL == nil)
    }

    @Test("selectTree transitions to .performing with the supplied id")
    func selectTreeTransitions() {
        var machine = PerformanceBoothMachine()
        let id = UUID()
        machine.selectTree(id: id)
        #expect(machine.stage == .performing(treeID: id))
        #expect(machine.selectedTreeID == id)
        #expect(machine.hasListenedThisRound == false)
    }

    @Test("markListened only flips the flag when in .performing")
    func markListenedGate() {
        var machine = PerformanceBoothMachine()
        machine.markListened()
        #expect(machine.hasListenedThisRound == false)

        machine.selectTree(id: UUID())
        machine.markListened()
        #expect(machine.hasListenedThisRound == true)
    }

    @Test("markListened is idempotent")
    func markListenedIdempotent() {
        var machine = PerformanceBoothMachine()
        machine.selectTree(id: UUID())
        machine.markListened()
        machine.markListened()
        machine.markListened()
        #expect(machine.hasListenedThisRound == true)
    }

    @Test("markExported transitions to .exported and bumps exportCount")
    func markExportedTransitions() {
        var machine = PerformanceBoothMachine()
        let treeID = UUID()
        let audioURL = URL(fileURLWithPath: "/tmp/dialogue.aiff")
        machine.selectTree(id: treeID)
        machine.markExported(audioURL: audioURL)
        #expect(machine.stage == .exported(treeID: treeID, audioURL: audioURL))
        #expect(machine.exportCount == 1)
        #expect(machine.currentExportURL == audioURL)
    }

    @Test("markExported is a no-op when not in .performing")
    func markExportedFromChoosingNoOp() {
        var machine = PerformanceBoothMachine()
        machine.markExported(audioURL: URL(fileURLWithPath: "/tmp/x.aiff"))
        #expect(machine.stage == .choosingTree)
        #expect(machine.exportCount == 0)
    }

    @Test("reselectTree drops back to .choosingTree and clears listened flag")
    func reselectTreeFromExported() {
        var machine = PerformanceBoothMachine()
        machine.selectTree(id: UUID())
        machine.markListened()
        machine.markExported(audioURL: URL(fileURLWithPath: "/tmp/y.aiff"))
        machine.reselectTree()
        #expect(machine.stage == .choosingTree)
        #expect(machine.hasListenedThisRound == false)
        #expect(machine.selectedTreeID == nil)
        // exportCount persists across reselects — it's a session-scoped counter.
        #expect(machine.exportCount == 1)
    }

    @Test("reset returns a fresh machine — every field cleared")
    func resetClearsEverything() {
        var machine = PerformanceBoothMachine()
        machine.selectTree(id: UUID())
        machine.markListened()
        machine.markExported(audioURL: URL(fileURLWithPath: "/tmp/z.aiff"))
        machine.reset()
        #expect(machine.stage == .choosingTree)
        #expect(machine.exportCount == 0)
        #expect(machine.hasListenedThisRound == false)
        #expect(machine.selectedTreeID == nil)
        #expect(machine.currentExportURL == nil)
    }

    @Test("Two performances bump exportCount to 2")
    func twoPerformancesBumpCount() {
        var machine = PerformanceBoothMachine()
        machine.selectTree(id: UUID())
        machine.markExported(audioURL: URL(fileURLWithPath: "/tmp/a.aiff"))
        machine.reselectTree()
        machine.selectTree(id: UUID())
        machine.markExported(audioURL: URL(fileURLWithPath: "/tmp/b.aiff"))
        #expect(machine.exportCount == 2)
    }

    @Test("selectedTreeID resolves across all 3 stages")
    func selectedTreeIDResolvesAcrossStages() {
        var machine = PerformanceBoothMachine()
        #expect(machine.selectedTreeID == nil)
        let id = UUID()
        machine.selectTree(id: id)
        #expect(machine.selectedTreeID == id)
        machine.markExported(audioURL: URL(fileURLWithPath: "/tmp/c.aiff"))
        #expect(machine.selectedTreeID == id)
    }

    @Test("currentExportURL is only non-nil in .exported stage")
    func currentExportURLOnlyInExported() {
        var machine = PerformanceBoothMachine()
        #expect(machine.currentExportURL == nil)
        machine.selectTree(id: UUID())
        #expect(machine.currentExportURL == nil)
        let url = URL(fileURLWithPath: "/tmp/d.aiff")
        machine.markExported(audioURL: url)
        #expect(machine.currentExportURL == url)
    }
}
