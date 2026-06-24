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

    @Test("Phase 2 inventory ships kits 05–09")
    func phase2KitLoadsAndHasExpectedTheme() throws {
        #expect(QuestionKitLoader.phase2Kits == [
            "kit_05_triangle_voices",
            "kit_06_voice_crucible",
            "kit_07_subtext_crucible",
            "kit_08_branch_consequences",
            "kit_09_action_beats"
        ])
        // Kits 05 + 06 sit on the voice-consistency surface; 07 on
        // subtext_detection; 08 on branching; 09 on tag_balance.
        let expectedThemes: [String: QuestionKit.Theme] = [
            "kit_05_triangle_voices": .voiceConsistency,
            "kit_06_voice_crucible": .voiceConsistency,
            "kit_07_subtext_crucible": .subtextDetection,
            "kit_08_branch_consequences": .branching,
            "kit_09_action_beats": .tagBalance
        ]
        for kitID in QuestionKitLoader.phase2Kits {
            let kit = try QuestionKitLoader.load(id: kitID)
            #expect(kit.theme == expectedThemes[kitID])
            #expect(kit.questions.count >= 5)
        }
    }

    @Test("Kit 08 (Branch consequences) prompts reference branching vocabulary")
    func kit08ReferencesBranchVocabulary() throws {
        let kit = try QuestionKitLoader.load(id: "kit_08_branch_consequences")
        #expect(kit.theme == .branching)
        #expect(kit.questions.count == 5)
        let body = kit.questions.map(\.prompt).joined(separator: " ").lowercased()
        #expect(body.contains("branch") || body.contains("choice") || body.contains("consequence"))
    }

    @Test("Kit 09 (Action beats) prompts reference body / beat / silence")
    func kit09ReferencesBeatVocabulary() throws {
        let kit = try QuestionKitLoader.load(id: "kit_09_action_beats")
        #expect(kit.theme == .tagBalance)
        #expect(kit.questions.count == 5)
        let body = kit.questions.map(\.prompt).joined(separator: " ").lowercased()
        #expect(
            body.contains("beat") ||
            body.contains("said") ||
            body.contains("silence") ||
            body.contains("tag")
        )
    }

    @Test("Phase 2 inventory has 5 kits total")
    func phase2KitCount() {
        #expect(QuestionKitLoader.phase2Kits.count == 5)
    }

    @Test("allKits is Phase 1 + Phase 2 + Phase 3 + Phase 4 in order")
    func allKitsContainsEveryPhaseInCanonicalOrder() {
        // Phase 4 row 161 closure (kits 14-16) lifts the canonical
        // inventory to 16. Per FEATURE_PLAN exit-criterion "full 16-kit
        // set". The prefix/suffix asserts here both anchor the canonical
        // ordering (Phase 1 → 2 → 3 → 4) AND surface a regression if a
        // future phase reorders the slices.
        #expect(QuestionKitLoader.allKits.count == 16)
        #expect(QuestionKitLoader.allKits.prefix(4) == QuestionKitLoader.phase1Kits[...])
        let phase2Slice = QuestionKitLoader.allKits.dropFirst(4).prefix(5)
        #expect(Array(phase2Slice) == QuestionKitLoader.phase2Kits)
        let phase3Slice = QuestionKitLoader.allKits.dropFirst(9).prefix(4)
        #expect(Array(phase3Slice) == QuestionKitLoader.phase3Kits)
        #expect(QuestionKitLoader.allKits.suffix(3) == QuestionKitLoader.phase4Kits[...])
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

    @Test("Kit 07 (Subtext Crucible) prompts reference multi-listener / silence / two-layer cues")
    func kit07ReferencesSubtextVocabulary() throws {
        let kit = try QuestionKitLoader.load(id: "kit_07_subtext_crucible")
        #expect(kit.theme == .subtextDetection)
        #expect(kit.questions.count == 5)
        let body = kit.questions.map(\.prompt).joined(separator: " ").lowercased()
        // The crucible kit's surface area is multi-listener subtext +
        // silence-as-subtext + body-vs-words layered honesty.
        #expect(
            body.contains("silence") ||
            body.contains("listener") ||
            body.contains("triangle") ||
            body.contains("layer")
        )
        let postScripts = kit.questions.map(\.mentorPostScript).joined(separator: " ").lowercased()
        #expect(
            postScripts.contains("subtext") ||
            postScripts.contains("silence") ||
            postScripts.contains("layer") ||
            postScripts.contains("pressure") ||
            postScripts.contains("truth")
        )
    }

    @Test("Kit 07 IDs follow the canonical kit_07_q_NN pattern")
    func kit07QuestionIDsAreCanonical() throws {
        let kit = try QuestionKitLoader.load(id: "kit_07_subtext_crucible")
        for (index, question) in kit.questions.enumerated() {
            let expectedSuffix = String(format: "q_%02d", index + 1)
            #expect(
                question.id == "kit_07_\(expectedSuffix)",
                "Kit 07 question \(index) ID '\(question.id)' deviates from canonical kit_07_\(expectedSuffix)"
            )
        }
    }
}
