import Testing
import Foundation
@testable import AppFeature

/// Wave 2 (2026-08-02) — Dialogue Punctuation Fix-It drill
/// (`Docs/HANDOFF_FROM_HUB_DIALOGUE_PUNCTUATION_FIXIT_WEB_BACKPORT.md`).
///
/// Two axes: (1) the bundled bank invariants (catches a wrong-answer /
/// missing-diagnostic content bug — the "builds green, ships wrong" class),
/// and (2) the pure `CraftDrillMachine` transitions (first-try scoring,
/// advance, complete, reset).
@Suite("Craft drill — bank + machine")
struct CraftDrillTests {

    // MARK: - Bank invariants

    @Test("Punctuation deck loads with all 7 drills")
    func punctuationDeckLoads() throws {
        let deck = try CraftDrillLoader.load(id: CraftDrillLoader.punctuationFixIt)
        #expect(deck.id == "punctuation_fixit")
        #expect(deck.drills.count == 7)
        #expect(!deck.title.isEmpty)
        #expect(!deck.subtitle.isEmpty)
    }

    @Test("Every drill has exactly one correct option and ≥2 options")
    func exactlyOneCorrect() throws {
        let deck = try CraftDrillLoader.load(id: CraftDrillLoader.punctuationFixIt)
        for drill in deck.drills {
            #expect(drill.options.count >= 2, "\(drill.id) needs ≥2 options")
            let correct = drill.options.filter(\.correct)
            #expect(correct.count == 1, "\(drill.id) must have exactly one correct option, has \(correct.count)")
            #expect(drill.correctOption != nil)
        }
    }

    @Test("Every wrong option carries an anti-shame 'why'; every drill teaches")
    func antiShameDiagnostics() throws {
        let deck = try CraftDrillLoader.load(id: CraftDrillLoader.punctuationFixIt)
        for drill in deck.drills {
            #expect(!drill.teach.trimmingCharacters(in: .whitespaces).isEmpty, "\(drill.id) missing teach")
            #expect(!drill.setup.isEmpty && !drill.prompt.isEmpty, "\(drill.id) missing setup/prompt")
            for option in drill.options where !option.correct {
                let why = option.why?.trimmingCharacters(in: .whitespaces) ?? ""
                #expect(!why.isEmpty, "\(drill.id)/\(option.id): a wrong option must explain why (anti-shame)")
            }
        }
    }

    @Test("Option ids are unique within a drill")
    func uniqueOptionIDs() throws {
        let deck = try CraftDrillLoader.load(id: CraftDrillLoader.punctuationFixIt)
        for drill in deck.drills {
            let ids = drill.options.map(\.id)
            #expect(Set(ids).count == ids.count, "\(drill.id) has duplicate option ids")
        }
    }

    @Test("An unknown deck id throws deckNotFound")
    func unknownDeckThrows() {
        #expect(throws: CraftDrillLoader.LoaderError.self) {
            _ = try CraftDrillLoader.load(id: "not-a-real-deck")
        }
    }

    // MARK: - Machine transitions

    private func loadedMachine() throws -> CraftDrillMachine {
        var m = CraftDrillMachine()
        m.load(try CraftDrillLoader.load(id: CraftDrillLoader.punctuationFixIt))
        return m
    }

    @Test("First-try scoring counts a correct pick, ignores a wrong pick")
    func firstTryScoring() throws {
        var m = try loadedMachine()
        let firstCorrect = try #require(m.currentDrill?.correctOption)
        m.select(firstCorrect.id)
        m.revealCurrent()
        #expect(m.correctCount == 1)
        m.advance()

        // Second drill: pick a wrong option → no score bump.
        let wrong = try #require(m.currentDrill?.options.first(where: { !$0.correct }))
        m.select(wrong.id)
        m.revealCurrent()
        #expect(m.correctCount == 1, "A wrong pick must not increment the score.")
    }

    @Test("Selection is locked after reveal")
    func selectionLockedAfterReveal() throws {
        var m = try loadedMachine()
        let drill = try #require(m.currentDrill)
        m.select(drill.options[0].id)
        m.revealCurrent()
        m.select(drill.options[1].id) // should be ignored
        #expect(m.selectedOptionID == drill.options[0].id)
    }

    @Test("Reveal is a no-op without a selection")
    func revealNoOpWithoutSelection() throws {
        var m = try loadedMachine()
        m.revealCurrent()
        #expect(!m.hasRevealed)
        #expect(m.correctCount == 0)
    }

    @Test("Walking the whole deck marks it complete")
    func completeAfterLastDrill() throws {
        var m = try loadedMachine()
        let total = m.drillCount
        for _ in 0..<total {
            let correct = try #require(m.currentDrill?.correctOption)
            m.select(correct.id)
            m.revealCurrent()
            m.advance()
        }
        #expect(m.isComplete)
        #expect(m.correctCount == total)
        #expect(m.progressFraction == 1.0)
    }

    @Test("reset() clears all state")
    func resetClears() throws {
        var m = try loadedMachine()
        m.select(m.currentDrill!.options[0].id)
        m.revealCurrent()
        m.reset()
        #expect(m.deck == nil)
        #expect(m.currentIndex == 0)
        #expect(m.correctCount == 0)
        #expect(!m.hasRevealed)
        #expect(!m.isComplete)
    }

    // MARK: - Write It in Character deck (Wave 3)

    @Test("Write-in-character deck loads with all 8 items")
    func inCharacterDeckLoads() throws {
        let deck = try CraftDrillLoader.load(id: CraftDrillLoader.writeInCharacter)
        #expect(deck.id == "write_in_character")
        #expect(deck.drills.count == 8)
    }

    /// Runs the same content invariants over BOTH shipped decks — a wrong
    /// answer / missing diagnostic in either bank fails here.
    @Test("Both decks satisfy the content invariants", arguments: [
        CraftDrillLoader.punctuationFixIt,
        CraftDrillLoader.writeInCharacter,
    ])
    func deckInvariants(deckID: String) throws {
        let deck = try CraftDrillLoader.load(id: deckID)
        #expect(!deck.drills.isEmpty)
        for drill in deck.drills {
            #expect(drill.options.count >= 2, "\(deckID)/\(drill.id) needs ≥2 options")
            #expect(drill.options.filter(\.correct).count == 1, "\(deckID)/\(drill.id) needs exactly one correct")
            let ids = drill.options.map(\.id)
            #expect(Set(ids).count == ids.count, "\(deckID)/\(drill.id) has duplicate option ids")
            #expect(!drill.teach.trimmingCharacters(in: .whitespaces).isEmpty, "\(deckID)/\(drill.id) missing teach")
            #expect(!drill.setup.isEmpty && !drill.prompt.isEmpty, "\(deckID)/\(drill.id) missing setup/prompt")
            for option in drill.options where !option.correct {
                let why = option.why?.trimmingCharacters(in: .whitespaces) ?? ""
                #expect(!why.isEmpty, "\(deckID)/\(drill.id)/\(option.id): wrong option must explain why")
            }
        }
    }

    @Test("In-character answers are not all in the same position (no positional tell)")
    func inCharacterAnswerSpread() throws {
        let deck = try CraftDrillLoader.load(id: CraftDrillLoader.writeInCharacter)
        let positions = deck.drills.compactMap { drill in
            drill.options.firstIndex(where: \.correct)
        }
        #expect(Set(positions).count >= 2, "The correct answer should not always be in the same slot.")
    }
}
