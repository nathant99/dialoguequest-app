import Foundation

/// A reusable tap-to-select craft drill — the shared shape behind the
/// Dialogue Punctuation Fix-It (Wave 2) and Write-It-in-Character (Wave 3)
/// modes. Each drill shows a `setup` (context) + `prompt`, a set of
/// candidate lines, and — on reveal — an anti-shame `why` for the wrong
/// pick plus a `teach` line that reframes the mistake as craft.
///
/// Deterministic + choice-graded (no free text, no AI evaluator) →
/// COPPA-safe. Content is bundled JSON (mirrors the web clone's
/// `studio.ts` / `inCharacter.ts` banks), decoded from `Bundle.module`.
public nonisolated struct CraftDrill: Codable, Sendable, Identifiable, Hashable {
    public let id: String
    /// Short mode label, e.g. "Punctuate the dialogue" / "Write it in character".
    public let kindLabel: String
    /// The situation/context framing.
    public let setup: String
    /// The question under study, e.g. "Which line is punctuated correctly?".
    public let prompt: String
    public let options: [Option]
    /// On-reveal coaching — the craft takeaway.
    public let teach: String

    public init(id: String, kindLabel: String, setup: String, prompt: String, options: [Option], teach: String) {
        self.id = id
        self.kindLabel = kindLabel
        self.setup = setup
        self.prompt = prompt
        self.options = options
        self.teach = teach
    }

    public nonisolated struct Option: Codable, Sendable, Identifiable, Hashable {
        public let id: String
        public let text: String
        public let correct: Bool
        /// Diagnostic shown when this wrong option is tapped (anti-shame —
        /// explains, never scolds). Required non-empty when `correct == false`.
        public let why: String?

        public init(id: String, text: String, correct: Bool, why: String?) {
            self.id = id
            self.text = text
            self.correct = correct
            self.why = why
        }
    }

    /// The single canonical answer. Banks are authored with exactly one.
    public var correctOption: Option? { options.first(where: \.correct) }
}

/// A named set of drills of one kind, loaded from a bundled JSON deck.
public nonisolated struct CraftDrillDeck: Codable, Sendable, Identifiable, Hashable {
    public let id: String
    /// Card title on the Adventure surface.
    public let title: String
    /// One-line card subtitle.
    public let subtitle: String
    /// SF Symbol for the card.
    public let symbolName: String
    public let drills: [CraftDrill]

    public init(id: String, title: String, subtitle: String, symbolName: String, drills: [CraftDrill]) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.symbolName = symbolName
        self.drills = drills
    }
}

/// Loads `CraftDrillDeck` JSON from the `AppFeature` bundle's
/// `Resources/Drills` directory. `.process` flattens the subtree to the
/// bundle root, so the flat `forResource:` lookup is the one that hits;
/// a subdirectory lookup is kept as a defensive fallback.
public enum CraftDrillLoader {
    public enum LoaderError: Error, Sendable, Equatable {
        case deckNotFound(String)
        case decodeFailed(String, String)
    }

    /// Canonical deck identifiers (JSON filenames without extension).
    public nonisolated static let punctuationFixIt = "punctuation_fixit"
    public nonisolated static let writeInCharacter = "write_in_character"

    public nonisolated static func load(id: String) throws -> CraftDrillDeck {
        let url = Bundle.module.url(forResource: id, withExtension: "json")
            ?? Bundle.module.url(forResource: id, withExtension: "json", subdirectory: "Drills")
        guard let url, let data = try? Data(contentsOf: url) else {
            throw LoaderError.deckNotFound(id)
        }
        do {
            return try JSONDecoder().decode(CraftDrillDeck.self, from: data)
        } catch {
            throw LoaderError.decodeFailed(id, String(describing: error))
        }
    }
}
