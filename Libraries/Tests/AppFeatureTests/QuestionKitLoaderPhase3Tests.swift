import Foundation
import Testing
@testable import AppFeature

@Suite("QuestionKitLoader Phase 3")
struct QuestionKitLoaderPhase3Tests {

    @Test func phase3KitsAreRegisteredInCanonicalOrder() {
        #expect(QuestionKitLoader.phase3Kits == [
            "kit_10_read_aloud_register",
            "kit_11_pause_pacing",
            "kit_12_voice_acting_choices",
            "kit_13_audio_export_craft",
        ])
    }

    @Test func allKitsConcatenatesAllPhases() {
        // allKits spans Phase 1 + 2 + 3 + 4 (kits 01–16). Phase 4
        // (kits 14–16; synthesis / cross-craft / writing process) shipped
        // after this test was first authored — the count + last-kit
        // assertions are kept in lockstep with the phase arrays so adding
        // a phase fails here loudly rather than silently drifting.
        let total = QuestionKitLoader.phase1Kits.count
            + QuestionKitLoader.phase2Kits.count
            + QuestionKitLoader.phase3Kits.count
            + QuestionKitLoader.phase4Kits.count
        #expect(QuestionKitLoader.allKits.count == total)
        #expect(QuestionKitLoader.allKits.last == "kit_16_writing_process")
    }

    @Test func phase3KitsLoadAndDecode() throws {
        for id in QuestionKitLoader.phase3Kits {
            let kit = try QuestionKitLoader.load(id: id)
            #expect(kit.id == id)
            #expect(!kit.title.isEmpty)
            #expect(kit.questions.count == 5, "Kit \(id) should have 5 questions")
            for question in kit.questions {
                #expect(!question.prompt.isEmpty)
                #expect(!question.options.isEmpty)
                #expect(question.correctOptionID != nil, "Phase 3 kits are quiz-format; freeText not supported yet")
            }
        }
    }

    @Test func loadAllPhasesIncludesPhase3() {
        let result = QuestionKitLoader.loadAllPhases()
        #expect(result.failures.isEmpty)
        #expect(result.kits.contains { $0.id == "kit_10_read_aloud_register" })
        #expect(result.kits.contains { $0.id == "kit_13_audio_export_craft" })
    }

    @Test func phase3KitContentSticksToReaderRegisterStoplist() throws {
        // Forbidden engineering jargon in kid-facing content. Per
        // `@.claude/rules/distributed-narrative.md` § "Chapter content
        // register stoplist" — apply to kit content too (it's reader-facing).
        let forbiddenTokens = [
            "load-bearing",
            "codified",
            "ADR-",
            "SAMHSA",
            "Phase A",
            "Phase B",
            "Phase C",
            "Phase D",
            "PR #",
        ]
        for id in QuestionKitLoader.phase3Kits {
            let kit = try QuestionKitLoader.load(id: id)
            for question in kit.questions {
                let surface = question.prompt + question.options.map(\.label).joined() + question.mentorPostScript
                let lowercased = surface.lowercased()
                for token in forbiddenTokens {
                    #expect(
                        !lowercased.contains(token.lowercased()),
                        "Kit \(id) contains forbidden engineering token: \(token)"
                    )
                }
            }
        }
    }
}
