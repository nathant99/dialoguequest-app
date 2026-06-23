import Foundation
import Testing
@testable import AppFeature

@Suite("QuestionKitLoader — Phase 4 kits 14-16")
struct QuestionKitLoaderPhase4Tests {

    @Test func phase4HasThreeKitIDs() {
        #expect(QuestionKitLoader.phase4Kits.count == 3)
    }

    @Test func phase4KitIDsAreStable() {
        let expected: [String] = [
            "kit_14_synthesis",
            "kit_15_cross_craft",
            "kit_16_writing_process",
        ]
        #expect(QuestionKitLoader.phase4Kits == expected)
    }

    @Test func allKitsCountReachesSixteen() {
        // Phase 4 exit criterion: "full 16-kit set". The 16-kit set must
        // come from concatenating phase1 (4) + phase2 (5) + phase3 (4) +
        // phase4 (3) — guards against forgetting to wire one of the
        // phases into `allKits`.
        #expect(QuestionKitLoader.allKits.count == 16)
    }

    @Test func phase4KitsLoadCleanlyViaBundle() {
        let (kits, failures) = QuestionKitLoader.loadAllPhases()
        let phase4Decoded = kits.filter { QuestionKitLoader.phase4Kits.contains($0.id) }
        #expect(phase4Decoded.count == 3, "Expected 3 phase-4 kits to decode, got \(phase4Decoded.count). Failures: \(failures.map(\.0))")
        for kit in phase4Decoded {
            #expect(!kit.title.isEmpty)
            #expect(kit.questions.count >= 4, "Kit \(kit.id) has \(kit.questions.count) questions; expected 5")
        }
    }

    @Test func phase4KitsPassReaderRegisterStoplist() {
        // R-CHAPTER-REGISTER stoplist guard. Phase 4 kit copy stays in
        // the age-9-14 register; no engineering jargon leaks through.
        let stoplist = [
            "codified",
            "SAMHSA",
            "ADR-",
            "Phase A",
            "Phase B",
            "Phase C",
            "Phase D",
            "ForgeKit",
            "PR #",
        ]
        let (kits, _) = QuestionKitLoader.loadAllPhases()
        for kit in kits where QuestionKitLoader.phase4Kits.contains(kit.id) {
            for question in kit.questions {
                let combined = (question.prompt + " " +
                                question.options.map(\.label).joined(separator: " ") + " " +
                                (question.mentorPostScript ?? "")).lowercased()
                for token in stoplist {
                    #expect(!combined.contains(token.lowercased()),
                            "Kit \(kit.id) question \(question.id) leaks '\(token)' in: \(combined.prefix(120))")
                }
            }
        }
    }

    @Test func phase4KitsHaveCanonicalCorrectOption() {
        // Each multiple-choice question must have a `correctOptionID` that
        // matches one of the option IDs.
        let (kits, _) = QuestionKitLoader.loadAllPhases()
        for kit in kits where QuestionKitLoader.phase4Kits.contains(kit.id) {
            for question in kit.questions {
                if let correctID = question.correctOptionID {
                    let ids = question.options.map(\.id)
                    #expect(ids.contains(correctID),
                            "Kit \(kit.id) question \(question.id) correctOptionID \(correctID) not in options \(ids)")
                }
            }
        }
    }

    @Test func allKitsConcatenatesAllFourPhases() {
        let total = QuestionKitLoader.phase1Kits.count
            + QuestionKitLoader.phase2Kits.count
            + QuestionKitLoader.phase3Kits.count
            + QuestionKitLoader.phase4Kits.count
        #expect(QuestionKitLoader.allKits.count == total)
    }
}
