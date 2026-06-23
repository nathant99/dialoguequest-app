import Foundation
import Testing
import Models
@testable import Services

@Suite("AnthologySpotlightIndexer — SpotlightEntry projection + identifier")
struct AnthologySpotlightIndexerTests {

    @Test("spotlightID is deterministic + prefixed for cross-app uniqueness")
    func spotlightIDIsPrefixedAndDeterministic() {
        let id = UUID()
        let one = AnthologySpotlightIndexer.spotlightID(for: id)
        let two = AnthologySpotlightIndexer.spotlightID(for: id)
        #expect(one == two)
        #expect(one.hasPrefix("dq.anthology."))
        #expect(one.contains(id.uuidString))
    }

    @Test("Different anthology IDs produce different Spotlight identifiers")
    func spotlightIDIsUniquePerEntry() {
        let a = UUID()
        let b = UUID()
        #expect(AnthologySpotlightIndexer.spotlightID(for: a)
                != AnthologySpotlightIndexer.spotlightID(for: b))
    }

    @Test("Domain identifier matches portfolio namespace convention")
    func domainIdentifierMatchesConvention() {
        #expect(AnthologySpotlightIndexer.domainIdentifier == "com.sparkandanvil.dialoguequest.anthology")
    }

    @Test("SpotlightEntry title falls back to friendly placeholder when empty")
    func spotlightEntryEmptyTitleFallback() {
        let entry = AnthologySpotlightIndexer.SpotlightEntry(
            id: UUID(),
            title: "",
            mood: nil,
            lineCount: 1,
            branchCount: 0,
            lastEditedAt: .now
        )
        #expect(entry.spotlightTitle == "Untitled dialogue")
    }

    @Test("SpotlightEntry preserves the kid's title when present")
    func spotlightEntryTitlePreserved() {
        let entry = AnthologySpotlightIndexer.SpotlightEntry(
            id: UUID(),
            title: "After the rain",
            mood: .quietConflict,
            lineCount: 6,
            branchCount: 2,
            lastEditedAt: .now
        )
        #expect(entry.spotlightTitle == "After the rain")
    }

    @Test("SpotlightEntry description includes mood + line / branch counts in reader-facing register")
    func spotlightEntryDescriptionIsReaderFacing() {
        let entry = AnthologySpotlightIndexer.SpotlightEntry(
            id: UUID(),
            title: "After the rain",
            mood: .quietConflict,
            lineCount: 6,
            branchCount: 2,
            lastEditedAt: .now
        )
        let description = entry.spotlightDescription
        #expect(description.contains("quiet conflict"))
        #expect(description.contains("6 lines"))
        #expect(description.contains("2 branch points"))
    }

    @Test("Singular line / branch counts render with singular nouns")
    func spotlightEntryDescriptionRespectsPluralization() {
        let entry = AnthologySpotlightIndexer.SpotlightEntry(
            id: UUID(),
            title: "Solo voice",
            mood: nil,
            lineCount: 1,
            branchCount: 1,
            lastEditedAt: .now
        )
        let description = entry.spotlightDescription
        #expect(description.contains("1 line"))
        #expect(!description.contains("1 lines"))
        #expect(description.contains("1 branch point"))
        #expect(!description.contains("1 branch points"))
    }

    @Test("Keywords include app name + mood name + title")
    func spotlightEntryKeywordsRollup() {
        let entry = AnthologySpotlightIndexer.SpotlightEntry(
            id: UUID(),
            title: "After the rain",
            mood: .quietConflict,
            lineCount: 6,
            branchCount: 2,
            lastEditedAt: .now
        )
        let keywords = Set(entry.spotlightKeywords)
        #expect(keywords.contains("DialogueQuest"))
        #expect(keywords.contains("dialogue"))
        #expect(keywords.contains("writing"))
        #expect(keywords.contains("conversation"))
        #expect(keywords.contains("After the rain"))
        #expect(keywords.contains("quiet conflict"))
    }

    @Test("Empty title is omitted from keywords (avoids empty-string keyword)")
    func spotlightEntryKeywordsOmitsEmptyTitle() {
        let entry = AnthologySpotlightIndexer.SpotlightEntry(
            id: UUID(),
            title: "",
            mood: nil,
            lineCount: 1,
            branchCount: 0,
            lastEditedAt: .now
        )
        for keyword in entry.spotlightKeywords {
            #expect(!keyword.isEmpty)
        }
    }

    @Test("SpotlightEntry's spotlightID matches the indexer helper")
    func spotlightEntryIDMatchesHelper() {
        let id = UUID()
        let entry = AnthologySpotlightIndexer.SpotlightEntry(
            id: id,
            title: "x",
            mood: nil,
            lineCount: 0,
            branchCount: 0,
            lastEditedAt: .now
        )
        #expect(entry.spotlightID == AnthologySpotlightIndexer.spotlightID(for: id))
    }

    @Test("Description is reader-register-clean (no engineering jargon)")
    func descriptionStaysInReaderRegister() {
        let stoplist = ["load-bearing", "codified", "canonical", "SAMHSA",
                        "Phase 1", "Phase 2", "ADR-", "primitive"]
        let allMoods: [DialogueMood?] = DialogueMood.allCases.map { Optional($0) } + [nil]
        for mood in allMoods {
            let entry = AnthologySpotlightIndexer.SpotlightEntry(
                id: UUID(),
                title: "Dialogue",
                mood: mood,
                lineCount: 4,
                branchCount: 1,
                lastEditedAt: .now
            )
            let body = entry.spotlightDescription.lowercased()
            for token in stoplist {
                #expect(!body.contains(token.lowercased()),
                        "Mood \(String(describing: mood)) description leaks token '\(token)': \(entry.spotlightDescription)")
            }
        }
    }
}
