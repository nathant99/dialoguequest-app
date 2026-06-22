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
        for kitID in QuestionKitLoader.allKits {
            let kit = try QuestionKitLoader.load(id: kitID)
            for question in kit.questions {
                guard let correctID = question.correctOptionID else { continue }
                let optionIDs = Set(question.options.map(\.id))
                #expect(optionIDs.contains(correctID),
                        "\(question.id) correctOptionID '\(correctID)' not in option list")
            }
        }
    }

    // MARK: - Phase 2

    @Test("Phase 2 inventory ships kits 05 + 06 with the voice-consistency theme")
    func phase2KitLoadsAndHasExpectedTheme() throws {
        #expect(QuestionKitLoader.phase2Kits == ["kit_05_triangle_voices", "kit_06_voice_crucible"])
        for kitID in QuestionKitLoader.phase2Kits {
            let kit = try QuestionKitLoader.load(id: kitID)
            #expect(kit.theme == .voiceConsistency)
            #expect(kit.questions.count >= 5)
        }
    }

    @Test("Kit 06 (Voice Crucible) question prompts reference voice register vocabulary")
    func kit06ReferencesVoiceVocabulary() throws {
        let kit = try QuestionKitLoader.load(id: "kit_06_voice_crucible")
        let body = kit.questions.map(\.prompt).joined(separator: " ").lowercased()
        #expect(body.contains("voice") || body.contains("register") || body.contains("character"))
        let postScripts = kit.questions.map(\.mentorPostScript).joined(separator: " ").lowercased()
        #expect(postScripts.contains("voice") ||
                postScripts.contains("register") ||
                postScripts.contains("fingerprint") ||
                postScripts.contains("silence"))
    }

    @Test("loadAllPhases includes Phase 1 + Phase 2 kits")
    func loadAllPhasesIncludesBothPhases() {
        let result = QuestionKitLoader.loadAllPhases()
        #expect(result.failures.isEmpty, "Failures: \(result.failures.map { $0.0 })")
        #expect(result.kits.count == QuestionKitLoader.allKits.count)
    }

    @Test("Kit 05 question prompts reference triangle vocabulary")
    func kit05ReferencesTriangleVocabulary() throws {
        let kit = try QuestionKitLoader.load(id: "kit_05_triangle_voices")
        let body = kit.questions.map(\.prompt).joined(separator: " ").lowercased()
        // Kit content should call out the triangle-specific concepts so
        // the kid recognizes the connection to what they're authoring.
        #expect(body.contains("three") || body.contains("triangle"))
        let postScripts = kit.questions.map(\.mentorPostScript).joined(separator: " ").lowercased()
        #expect(postScripts.contains("alliance") ||
                postScripts.contains("arbiter") ||
                postScripts.contains("voice"))
    }
}
