---
status: ACTIVE
date: 2026-06-20
direction: app → hub
audience: hub session owning HubContributions/
intent: ship the Level-1 dialoguequest.json so the AdventureHub Word Workshop zone renders DialogueQuest's tile
freshness-horizon: 60 days
---

# Handoff to Hub — DialogueQuest Level-1 HubContribution JSON

Direction: **app → hub**. DialogueQuest has shipped a Level-2 `HubContribution` conformer (`DialogueQuestHubContribution` in `Libraries/Sources/AppFeature/Adventure/`). The Level-2 overlay sits on top of a Level-1 JSON config that hub owns. Without the Level-1, AdventureHub has no tile to layer the Level-2 view onto.

## What hub needs to ship

A new file at `spark-anvil-hub/Resources/HubContributions/dialoguequest.json` matching the `HubContributionConfig` Codable shape:

| Field | Value DialogueQuest expects |
|---|---|
| `sourceAppID` | `"dialoguequest"` |
| `sourceAppDisplayName` | `"DialogueQuest"` |
| `zone` | `"word-woods"` (matches `ZoneID.wordWoods`) |
| `supportedEngines` | `["quest", "builder"]` |
| `themeAccentHex` | `"#A05A4B"` — Conversation rust |
| `mentorPersona` | `{ id: "patter", displayName: "Patter", avatarAssetName: "patter_idle", voiceProfile: "warmMid", systemPromptHeader: "You are Patter from DialogueQuest. You listen for what isn't being said in a kid's dialogue tree. Speak warmly, never grade." }` |
| `kitResources` | 4 entries pointing at `kit_01_voice_consistency` / `kit_02_subtext_detection` / `kit_03_tag_balance` / `kit_04_branching` (all `bloomBand` analyze/apply/create; `gradeBand: middle`) |
| `preferredPresentation` | `"tileEmbedded"` |
| `engineCopy.quest.title` | `"Write a conversation"` |
| `engineCopy.quest.tagline` | `"Two characters. One scene. Every line counts."` |
| `engineCopy.builder.title` | `"Build a branching scene"` |
| `engineCopy.builder.tagline` | `"Two paths. Two truths. One reflection."` |

## What's already in place app-side

- `DialogueQuestHubContribution` — Level-2 conformer with the same persona + kits + accent
- `HubChallengeBridge` (private view) — wires the AdventureHub challenge slot to `QuizView` so kits resolve from Bundle.module
- AdventureTabView surfaces a friendly status surface while Level-1 is missing, with a copy nudge back to the Write tab

## What hub does NOT need to ship

- Per-question content — kits 01-04 live in `<dialoguequest-app>/Libraries/Sources/AppFeature/Resources/Questions/` as `Bundle.module` JSON. Hub's JSON only points at the kit IDs.
- Mascot illustration — Patter's PNG poses arrive via the standard mascot pipeline; not this handoff's concern.

## Cross-references

- `Libraries/Sources/AppFeature/Adventure/DialogueQuestHubContribution.swift` (Level-2 conformer)
- `Libraries/Sources/AppFeature/Resources/Questions/kit_*.json` (kit content)
- `@.claude/rules/forgekit.md` § ForgeAdventure Hub layer (protocol spec)
- `@Docs/TECHNICAL_DESIGN.md` § Adventure Mode Integration
