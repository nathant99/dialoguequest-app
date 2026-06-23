import Testing
import Foundation
@testable import AppFeature
import Models

/// Closes Phase Delight micro-delight § Agency — proves the kid's
/// "Save as sketch" toolbar surface flips the persisted draft flag
/// without disturbing other tree state.
@Suite("DialogueTreeMachine draft toggle")
struct DialogueTreeMachineDraftTests {

    @Test("toggleDraft flips the flag on the active tree")
    func toggleDraftFlips() {
        var machine = DialogueTreeMachine()
        #expect(machine.tree.isDraft == false)
        machine.toggleDraft()
        #expect(machine.tree.isDraft == true)
        machine.toggleDraft()
        #expect(machine.tree.isDraft == false)
    }

    @Test("setDraft pushes state idempotently (no churn on no-op)")
    func setDraftIdempotent() {
        var machine = DialogueTreeMachine()
        let originalID = machine.tree.id
        machine.setDraft(false)
        #expect(machine.tree.id == originalID, "no-op set should not rebuild the tree")
        machine.setDraft(true)
        #expect(machine.tree.isDraft == true)
        // The second set to the same value also shouldn't churn.
        machine.setDraft(true)
        #expect(machine.tree.isDraft == true)
    }

    @Test("Tree mutations preserve isDraft (no accidental clearing)")
    func mutationsPreserveDraft() {
        var machine = DialogueTreeMachine()
        machine.setDraft(true)
        machine.updateTitle("New title")
        #expect(machine.tree.isDraft == true, "updateTitle should preserve isDraft")
        machine.updateMood(.quietConflict)
        #expect(machine.tree.isDraft == true, "updateMood should preserve isDraft")
        machine.addCharacter(
            DialogueCharacterRef(
                name: "Iris",
                voiceRegister: "Short, clipped sentences.",
                sampleLines: ["I'm fine."]
            )
        )
        #expect(machine.tree.isDraft == true, "addCharacter should preserve isDraft")
    }
}
