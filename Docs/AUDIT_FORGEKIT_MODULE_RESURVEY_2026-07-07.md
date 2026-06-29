---
status: CHECKPOINT
date: 2026-07-07
round: 2026-07-07 mid-session (Track D of a 5-PR auto-cycle)
freshness-horizon: 30 days
audience: future Claude Code sessions evaluating ForgeKit module adoption candidates
intent: codify the per-module held-verdict + trigger criteria so the next session can skim one doc instead of re-surveying the same 35 unconsumed modules
supersedes: none (first formal re-survey audit for DialogueQuest)
---

# Audit — ForgeKit module re-survey (2026-07-07)

> **PARTIALLY SUPERSEDED 2026-07-09**: the pin bumped to 1.0.0-rc.3 (PR #180, 2026-07-08), and on 2026-07-09 **`ForgeMasteryEngine` + `PolyaScaffold` were ADOPTED** (PRs #183/#184) — module count is now **25 of ~58 consumed**, not 23. Of the 3 modules this audit listed as "held behind user-GUI handoffs," only **`ForgeLocalization`** remains held (behind `Localizable.xcstrings`, Priority C). The per-module held-verdict criteria for the OTHER unconsumed modules still stand.

> **TL;DR**: **23 of 58 ForgeKit modules consumed.** The remaining 35 split into **3 categories**: 11 server-only (N/A — DialogueQuest has no server), 3 handoff-blocked (`ForgeMasteryEngine` / `PolyaScaffold` / `ForgeLocalization` — pin bump + xcstrings catalog), 21 held with documented trigger criteria. **Zero incremental adoption candidates pass the trigger criteria this round** — the catalog is at structural equilibrium until either the pin bump lands or a new feature requirement maps cleanly onto a held module.

## How to use this doc

When the next session asks "should we adopt more ForgeKit modules?", read the per-module rows below. Each held module has an explicit **Trigger** column — the condition under which adoption becomes worth the integration cost. If any condition is now true, the module moves from "held" to "candidate" without re-surveying.

When a held verdict changes (the trigger fires; we adopt the module), update the row's status + this doc's status line + add the canonical reference impl path. Don't delete the row — the audit trail is the value.

## Consumed modules (23 — baseline)

Per `Libraries/Package.swift` as of `4e82fd2` (2026-07-06 main):

| Category | Modules | Count |
|---|---|---|
| Shared | `ForgeModels` | 1 |
| Client/Services | `ForgePersistence` + `ForgeAI` + `ForgeAnalytics` + `ForgeContent` + `ForgeDevelopmental` + `ForgeEmotionAware` + `ForgeEvents` + `ForgeExperiments` + `ForgeGamification` + `ForgeKnowledgeGraph` + `ForgeLiveActivities` + `ForgePedagogy` + `ForgeReporting` + `ForgeSensory` + `ForgeSpotlight` + `ForgeModels` | 15 (+1 dup with Shared) |
| Client/SharedUI | `ForgeUI` + `ForgeAccessibility` | 2 |
| Client/AIMentor | `ForgeAI` | 1 (dup) |
| Client/AppFeature | `ForgeUI` + `ForgeNavigation` + `ForgeAdventure` + `ForgeAvatar` + `ForgeCelebration` + `ForgeGamification` + `ForgeIllustrations` + `ForgeIntents` + `ForgePassAndPlay` + `ForgePedagogy` + `ForgeProgression` + `ForgeStateMachine` + `ForgeSync` | 13 (some dup) |
| **Unique total** | | **23** |

## Held-pending pin bump (3 modules)

These can't land until `Libraries/Package.swift` line 26 moves off `from: "0.99.0"` to a 1.0.0-rc.x-aware constraint. User-GUI handoff `Docs/HANDOFF_TO_USER_FORGEKIT_PIN_BUMP.md` filed 2026-06-26 — still pending after 264h as of this audit.

| Module | Where it would land | Why deferred behind pin bump | Trigger to re-evaluate |
|---|---|---|---|
| `ForgeMasteryEngine` | `Services/Pedagogy/` — `MasteryGraph<DialogueCraftTopic>` over 4 craft pillars (voice / subtext / tag balance / branching); wire to `WriteTabView.recordTreeOutcome` | Shipped in ForgeKit 1.0.0-rc.2 per `forgekit/Docs/CHANGELOG.md` (not available at pin 0.99.0) | Pin bump lands — adopt immediately; ~3-4h |
| `PolyaScaffold` (sub-API of `ForgePedagogy`) | `Services/Pedagogy/DialogueScaffoldingService.swift` — replace the existing wrapper around `ScaffoldingEngine` + `HintTier` with a `PolyaMachine` | Same — sub-API of `ForgePedagogy` in 1.0.0-rc.x | Pin bump lands — adopt immediately; ~3-4h |
| `ForgeLocalization` | `AppFeature/` — `Text(...)` sweep across views; brand-guard for "DialogueQuest" + "Patter" | Requires `Libraries/Sources/AppFeature/Resources/Localizable.xcstrings` to exist; user-GUI handoff `Docs/HANDOFF_TO_USER_LOCALIZABLE_XCSTRINGS.md` filed 2026-06-26 — still pending after 264h | xcstrings catalog file lands at the documented path — adopt immediately; ~6-8h |

## Server-only modules (11 — N/A)

DialogueQuest is a single-app iOS target — no Hummingbird server, no `Sources/Server/<App>Server/` directory. The 11 server modules (`ForgeServerActors` + `ForgeServerMatchmaking` + `ForgeServerMiddleware` + `ForgeServerMultiplayer` + `ForgeServerRealTime` + `ForgeServerSafety` + `ForgeServerTracking` + `ForgeServerWebSocket` + `ForgeServerEmail` + `ForgeServerLeaderboard` + `ForgeServerClassroom`) are out of scope.

**Trigger to re-evaluate**: any future round opens an `Apps/DialogueQuestServer/` or `Server/` target with a Hummingbird scheme. Until then, this category stays N/A.

## Held with documented trigger criteria (21 — the active surface)

Each row carries its current verdict + the specific condition that would flip it. Future sessions re-check the trigger column instead of re-evaluating the verdict.

| Module | Verdict | Reason held | Trigger to adopt |
|---|---|---|---|
| `ForgeAudio` | HELD | `DialogueReadAloudService` + `DialogueAudioExporter` already use `AVSpeechSynthesizer` directly; the existing surface is mature + a16-test-covered + has the realtime-safe `OSAllocatedUnfairLock` accumulator pattern per `.claude/rules/concurrency.md` § AVAudioNodeTap rule. Rewriting through `ForgeAudio` would be a refactor without functional gain — same wrappers, different module name. | (a) `ForgeAudio` ships a multi-character voice-variant API that meaningfully exceeds the current per-character voice pool, OR (b) a new feature requires the SFX dispatch hook (`SensoryPalette.sfxPlayer`) that DialogueQuest deferred per the technical-design audio policy. |
| `ForgeMath` | HELD | DialogueQuest is a writing tool — zero math-expression / equation / number-formatting surface. The progress dashboard uses `Int` displays only. | A future Phase ships a math-craft cross-reference quiz kit OR adopts numeric-percentile parental reporting that needs locale-aware formatters. Neither on the roadmap. |
| `ForgeMultipeerKit` | HELD | `CollaborativeDialogueSession` uses `ForgePassAndPlay` (single-device pass-and-play). DialogueQuest's privacy posture (no PII on device, no peer discovery) deliberately excludes peer-to-peer transport. | Founder explicitly requests cross-device live collaboration (would also reopen `NSLocalNetworkUsageDescription` Info.plist work + `NSBonjourServices` array). |
| `ForgeWidgets` | HELD | Blocked on `Docs/HANDOFF_TO_USER_WIDGET_EXTENSION.md` — Widget Extension target doesn't exist in the xcodeproj; `NSSupportsLiveActivities` Info.plist key not set. Adopting `ForgeWidgets` before the target exists is dead code. | User completes the Widget Extension target wiring per the handoff. The existing `DialogueWritingSessionActivity` scaffold (`Services/Sensory/`) is already wired to activate once `ForgeWidgets` lands. |
| `ForgeSocial` | HELD | Leaderboards / friend codes — DialogueQuest's distributed-narrative methodology is anti-competitive by design (per `.claude/rules/distributed-narrative.md` § "What the cast is NOT"). Surfacing "your tree got 3 likes" or per-kid leaderboards would directly violate the curricular intent (writing IS the reward; subtext IS the audience). | Never — this is a design boundary, not a held verdict. Remove from re-survey horizon. |
| `ForgeGameCenter` | HELD | Same as `ForgeSocial` — anti-competitive design boundary. | Never. Remove from re-survey horizon. |
| `ForgeSettings` | HELD | Every settings surface uses `@AppStorage` directly (Settings tab daily-session stepper / `dq.experiments.*` flags / `dq.parentalConsentGrantedAt` / `dq.weeklySummaryOptIn` / etc.). Adopting `ForgeSettings` would be a rewrite for parity gains — no new functionality. | `ForgeSettings` 1.x ships a feature that meaningfully exceeds `@AppStorage` (e.g., automatic per-key telemetry / parent-controlled keychain sync / typed schema validation). Doesn't exist today per the 0.99.x catalog. |
| `ForgeGameEngine` | HELD | `CLAUDE.md` § Tech Stack: "**No SpriteKit, no SceneKit, no AnyView** — DialogueQuest is pure SwiftUI". The tree editor uses `Canvas` not `SKScene`. | Never — explicit project-level architectural constraint. Remove from re-survey horizon. |
| `ForgePartyGames` | HELD | Mini-game engines (ForbiddenWords, ForeheadReveal, HotPotato, RapidRecall). DialogueQuest's "Together" surface is `CollaborativeDialogueSession` — a dialogue-craft pass-and-play, not a party game. | A future Phase ships a party-mode mini-game with dialogue-craft framing (e.g., "Guess The Subtext" hot-potato). Not on the roadmap. |
| `ForgeAvatar` | CONSUMED (already in `AppFeature`) — but `Patter` palette personalization variant NOT shipped | Carrying "explore-then-decide" verdict per prior session handoff (Priority O). Risk surface is Patter identity drift — Patter IS the protagonist mentor; even a palette tweak wants a design pass. | Founder approves a Patter-personalization design spec OR a sensory-need carve-out surfaces (high-contrast skin palette / cognitive-load-reduction theme variant). |

## Why no incremental adoption this round

Each candidate above is either:
1. **Blocked on user-GUI work** (pin bump / xcstrings catalog / Widget Extension) — already filed
2. **Out of scope by design boundary** (anti-competitive register / no-SpriteKit / no-server)
3. **Rewrite without functional gain** (parity-only rewrites at module boundary)
4. **No matching feature requirement** (no math / no party games / no cross-device transport on the roadmap)

The next-incremental-adoption ceiling is **the pin bump landing**. Once `Libraries/Package.swift` moves to a 1.0.0-rc.x-aware constraint, two clean adoptions (`ForgeMasteryEngine` + `PolyaScaffold`) sit ready behind it, both with already-published spec docs. Test count goes from ~660 → ~720 once those land.

## What this audit explicitly is NOT

- Not a recommendation to deprecate any held module — held modules can flip to adopted at any time when the trigger fires.
- Not a justification to lower the ForgeKit pin floor — `from: "0.99.0"` is the canonical minimum until the user lands the pin bump handoff.
- Not a green-light to scaffold premature integration code for held modules — write nothing until the trigger fires per the user's "don't add features beyond what the task requires" preference.

## Cross-references

- `.claude/rules/forgekit.md` § Module Catalog — canonical 58-module surface + per-module API summary
- `Libraries/Package.swift` — 23-module consumer manifest as of this audit
- `Docs/HANDOFF_TO_USER_FORGEKIT_PIN_BUMP.md` — the gate to `ForgeMasteryEngine` + `PolyaScaffold` adoption
- `Docs/HANDOFF_TO_USER_LOCALIZABLE_XCSTRINGS.md` — the gate to `ForgeLocalization` adoption
- `Docs/HANDOFF_TO_USER_WIDGET_EXTENSION.md` — the gate to `ForgeWidgets` adoption
- `Docs/SESSION_HANDOFF_2026-07-06_ROUND_CLOSE.md` § "Priority I (carried; explore-then-decide) — Survey additional ForgeKit modules for adoption potential" — prior session's terse held-list (replaced by this doc's structured trigger criteria)
- `.claude/rules/distributed-narrative.md` § "What the cast is NOT" — the design-boundary reason `ForgeSocial` + `ForgeGameCenter` are NEVER candidates
