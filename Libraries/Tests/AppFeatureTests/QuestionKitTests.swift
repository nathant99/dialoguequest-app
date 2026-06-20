import Foundation
import Testing
@testable import AppFeature

@Suite("QuestionKit — JSON decode + Phase 1 inventory")
struct QuestionKitTests {

    @Test("All 4 Phase 1 kits load from Bundle.module without errors")
    func phase1KitsAllLoad() {
        let result = QuestionKitLoader.loadAll()
        #expect(result.failures.isEmpty, "Failures: \(result.failures.map { $0.0 })")
        #expect(result.kits.count == 4)
    }

    @Test("Each kit has at least 3 questions and the expected theme",
          arguments: zip(
            QuestionKitLoader.phase1Kits,
            [
                QuestionKit.Theme.voiceConsistency,
                QuestionKit.Theme.subtextDetection,
                QuestionKit.Theme.tagBalance,
                QuestionKit.Theme.branching,
            ]
          ))
    func kitInventory(kitID: String, expectedTheme: QuestionKit.Theme) throws {
        let kit = try QuestionKitLoader.load(id: kitID)
        #expect(kit.theme == expectedTheme)
        #expect(kit.questions.count >= 3, "\(kitID) has \(kit.questions.count) questions")
        for question in kit.questions {
            #expect(!question.prompt.isEmpty, "\(question.id) has empty prompt")
            #expect(!question.mentorPostScript.isEmpty, "\(question.id) has empty mentor post-script")
        }
    }

    @Test("Multiple-choice questions reference a real option ID")
    func correctOptionIDIsValid() throws {
        for kitID in QuestionKitLoader.phase1Kits {
            let kit = try QuestionKitLoader.load(id: kitID)
            for question in kit.questions {
                guard let correctID = question.correctOptionID else { continue }
                let optionIDs = Set(question.options.map(\.id))
                #expect(optionIDs.contains(correctID),
                        "\(question.id) correctOptionID '\(correctID)' not in option list")
            }
        }
    }
}
