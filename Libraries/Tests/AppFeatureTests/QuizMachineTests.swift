import Foundation
import Testing
@testable import AppFeature

@Suite("QuizMachine — load / select / reveal / advance / reset")
struct QuizMachineTests {

    @Test("Loading a kit resets state and sets currentIndex to 0")
    func loadKitResetsState() throws {
        var machine = QuizMachine()
        let kit = try QuestionKitLoader.load(id: "kit_01_voice_consistency")
        machine.load(kit)
        #expect(machine.kit?.id == kit.id)
        #expect(machine.currentIndex == 0)
        #expect(machine.correctCount == 0)
        #expect(machine.isComplete == false)
    }

    @Test("revealCurrent counts a correct selection and a wrong selection")
    func revealCountsCorrectly() throws {
        var machine = QuizMachine()
        let kit = try QuestionKitLoader.load(id: "kit_01_voice_consistency")
        machine.load(kit)
        let q0 = try #require(machine.currentQuestion)
        let correctOption = try #require(q0.correctOptionID)
        machine.select(correctOption)
        machine.revealCurrent()
        #expect(machine.hasRevealedAnswer)
        #expect(machine.correctCount == 1)

        machine.advance()
        let q1 = try #require(machine.currentQuestion)
        let wrongOption = try #require(q1.options.first { $0.id != q1.correctOptionID })
        machine.select(wrongOption.id)
        machine.revealCurrent()
        #expect(machine.correctCount == 1, "Wrong answer should not increment count")
    }

    @Test("advance after last question marks isComplete and stops counting")
    func advanceTerminatesAtEnd() throws {
        var machine = QuizMachine()
        let kit = try QuestionKitLoader.load(id: "kit_01_voice_consistency")
        machine.load(kit)
        for _ in 0..<kit.questions.count {
            if let q = machine.currentQuestion, let correct = q.correctOptionID {
                machine.select(correct)
                machine.revealCurrent()
                machine.advance()
            }
        }
        #expect(machine.isComplete)
        #expect(machine.correctCount == kit.questions.count)
    }

    @Test("reset returns to initial state")
    func resetIsTotal() throws {
        var machine = QuizMachine()
        let kit = try QuestionKitLoader.load(id: "kit_01_voice_consistency")
        machine.load(kit)
        machine.select("a")
        machine.revealCurrent()
        machine.reset()
        #expect(machine.kit == nil)
        #expect(machine.currentIndex == 0)
        #expect(machine.correctCount == 0)
        #expect(machine.isComplete == false)
        #expect(machine.selectedOptionID == nil)
    }
}
