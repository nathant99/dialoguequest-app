# Implementation Handoff — Humor Seeds (from Hub)

Hub authored and distributed this app's 70-joke humor seed bank. This doc tells the
implementing Claude Code session how to consume it at runtime. **Hub never writes Swift —
this handoff is the spec; the app's own session writes the loader + models.**

## What's in this repo now

```
Docs/CONTENT_HUMOR_SEEDS_DIALOGUEQUEST.md   # the hand-authored 70-joke markdown seed bank (source of truth)
```

**70 jokes**: 20 puns + 20 riddles + 15 absurd scenarios + 15 fun facts, domain-tied to
**Writing craft -- realistic dialogue, subtext (what's NOT said), dialogue tags and beats, each character's distinct voice, conflict in conversation, punctuation of speech**, at the 9–14 register, across grade bands 4-5 / 5-6 / 6-7 / 7-8. Boundary-placed
delight only (R-NARRATIVE-BETWEEN-NOT-DURING); never on the active solve loop.

## Step 1 — convert the markdown to the JSON bundle

Convert `Docs/CONTENT_HUMOR_SEEDS_DIALOGUEQUEST.md` → `Libraries/Sources/Services/Resources/Humor/jokes.json`
(create the `Humor/` resource dir under your Services SPM target once it exists). Shape:

```json
{{
  "appID": "dialoguequest",
  "version": "1.0",
  "jokes": [
    {{ "id": "UUID", "jokeType": "pun", "setup": "...", "punchline": "...",
       "emoji": "🎭", "relatedTopic": "...", "gradeBand": "5-6" }}
  ]
}}
```

`jokeType` is one of `pun`, `riddle`, `absurd`, `funFact` — matches `ForgeJokeData.JokeType`.
For puns/absurd/funFact the markdown `- **Joke**:` line is the `setup`; for riddles use the
explicit `- **Setup**:` / `- **Punchline**:`.

## Step 2 — Swift models + loader (the app session writes these; canonical shape)

```swift
// Libraries/Sources/Models/Joke.swift
public nonisolated struct Joke: Codable, Sendable, Identifiable {{
    public let id: UUID
    public let jokeType: JokeType
    public let setup: String
    public let punchline: String
    public let emoji: String
    public let relatedTopic: String
    public let gradeBand: String
    public nonisolated enum JokeType: String, Codable, Sendable, CaseIterable {{
        case pun, riddle, absurd, funFact
    }}
}}
public nonisolated struct HumorSeedBank: Codable, Sendable {{
    public let appID: String
    public let version: String
    public let jokes: [Joke]
}}
```

```swift
// Libraries/Sources/Services/HumorSeedLoader.swift
import Models; import Foundation
public actor HumorSeedLoader {{
    private let bundle: Bundle
    private var cached: HumorSeedBank?
    public init(bundle: Bundle = .module) {{ self.bundle = bundle }}
    public func load() async throws -> HumorSeedBank {{
        if let cached {{ return cached }}
        guard let url = bundle.url(forResource: "jokes", withExtension: "json", subdirectory: "Humor")
        else {{ throw HumorError.bankNotFound }}
        let bank = try JSONDecoder().decode(HumorSeedBank.self, from: Data(contentsOf: url))
        cached = bank; return bank
    }}
    public func random(of type: Joke.JokeType, gradeBand: String? = nil) async throws -> Joke? {{
        try await load().jokes
            .filter {{ $0.jokeType == type && (gradeBand == nil || $0.gradeBand == gradeBand!) }}
            .randomElement()
    }}
}}
public enum HumorError: Error, Sendable {{ case bankNotFound }}
```

## Step 3 — consumption

1. **Static fallback** when FoundationModels is `.unavailable`: serve `loader.random(of:gradeBand:)`.
2. **Few-shot exemplars** when FoundationModels IS available: seed the on-device joke prompt with
   3 shuffled same-type/same-band examples (kids-safe, boundary-placed).
3. **Pair with ForgeIllustrations** where a joke illustration exists.

## Definition of Done (app session)

- [ ] `jokes.json` bundles in the Services target (70 jokes, decodes to `HumorSeedBank`).
- [ ] A unit test asserts 70 jokes decode + every `jokeType` is valid + no empty `setup`.
- [ ] The joke surface is boundary-placed (results / brain-break), never mid-problem.
- [ ] The web clone (where it exists) ships the same bank via the `HumorBreak` island (parity, R-DN-PARITY).

---
*Distributed by hub (Program #72 humor coverage, R-RESOURCE-FIX-REDISTRIBUTE, q-f97cf1). The markdown
bank in `Docs/` is the source of truth; hub re-distributes any future fix. Hub owns the resource; the
app session owns the Swift.*
