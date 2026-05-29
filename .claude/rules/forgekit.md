# ForgeKit Integration

Shared SPM framework at `../forgekit/`. Apps import only the modules they need.

## Versioning

ForgeKit uses **semantic versioning** with annotated git tags (current: **0.99.1** shipped 2026-05-26, pre-1.0). Breaking changes are expected before 1.0. **`forgekit/Docs/CHANGELOG.md` is authoritative** — labsmith rule/CLAUDE.md text drifts; verify CHANGELOG before quoting a specific version.

**0.99.1 — patch-only** test rewrite (`ForgeAIGeneratorTests` → `ForgeAIContentCachePublicAPITests`).

**0.99.0 — `ReflectionPromptModifier` + `ReflectionPromptStorage` shipped** (ForgeUI + ForgePersistence; closes Move R2 — journal hooks / structured reflection prompts for ~22 Reflect-pillar apps).

**0.98.0 — `CastEncounter` primitive shipped** (`ForgePersistence`; SwiftData `@Model` + `CastEncounterStore` actor; closes DN-D12 longitudinal cast progression for ~37 high-priority adopters).

**0.97.0 — `CastDialog` primitive shipped** (`ForgeAI`; FoundationModels-backed cast voice with reviewer-signoff gating + ForgeServerSafety moderation pipeline; closes DN-D3 for ~26 non-trauma + ~25-30 trauma-adjacent apps).

**0.96.0 — `ForgeServerLeaderboard` module shipped** (NEW 11th server module; zero-dep `LeaderboardStore` protocol + `InMemoryLeaderboardStore` reference impl; PostgresLeaderboardStore deferred to forgesync Phase 6; closes Move T8 async leaderboard for ~31 apps).

**0.95.0 — `HubContributionConfig.togetherMode` field shipped** + `TogetherMode.Archetype` enum (5 cases: passAndPlay / cooperativePair / bystanderRoleplay / classroomLive / asyncLeaderboard; closes Move T10 for 4 aggregator + ~30 source apps).

**0.94.0 — `ForgeClassroom` module shipped** (LiveKit-Cloud-backed v1 live classroom). 0.86→0.94 added 7 new client modules: `ForgeAvatar` / `ForgeBranding` / `ForgeClassroom` / `ForgeColoringMode` / `ForgeManagedConfiguration` / `ForgeMiniGames` / `ForgePuzzles` + 1 new server module: `ForgeClassroomServer`. Module count post-0.99: **58 total** (45 client + 11 server + 2 shared).

**0.89.0 — `DyadicPair` API shipped** (unblocks MindForge / SafetyForge / CardForge / GrammarForge pass-and-play retrofits; lives in `ForgePassAndPlay`).

**0.86.0 — DIR/FEDC API gap closure** — 7 new affect-aware types in `ForgeDevelopmental` + `ForgeModels`: `EmotionSnapshot`, `AffectCalibrator`, `CoRegulationEngine`, `SensoryRamp`, `FEDCDemonstrationRecord`, `UserFEDCProfile`, `FEDCPromptContext` + `StreakManager.recordSession(emotionSnapshot:...)` overload + new `StreakResult.heldUnderDistress` case. Apps switching exhaustive `StreakResult` switches must add `.heldUnderDistress` arm OR `@unknown default` — `ExtendedStreakManager` forwards as `.sameDay` so apps using the wrapper are unaffected.

**0.85.0** added Linux platform support via `#if canImport(CoreGraphics)` guard in `AvatarLayer`.

- **Runtime check**: `ForgeKitVersion.version` / `.major` / `.minor` / `.patch` in ForgeModels
- **CHANGELOG**: `forgekit/Docs/CHANGELOG.md` — Keep a Changelog format
- **Release checklist**: Update `ForgeKitVersion.swift` → update `CHANGELOG.md` → commit → `git tag -a X.Y.Z -m "message"` → `git push origin main --tags`

## Source Layout (0.57.0 soft-split)

```
forgekit/Sources/
├── Client/   45 modules — UI, gameplay, persistence, on-device AI, accessibility, avatars, classroom, reflection
├── Server/   11 modules — Hummingbird 2 actors, middleware, matchmaking, email, classroom, leaderboard
└── Shared/    2 modules — ForgeModels, ForgeServerDTOs (consumed by both)
```

Public API and product names are unchanged — apps still write `.product(name: "ForgeIllustrations", package: "forgekit")` and `import ForgeIllustrations`. The split is internal-only. When reading ForgeKit source, find files with `find /Volumes/Data/Projects/GitHub/forgekit/Sources -ipath "*<ModuleName>*" -name "*.swift"`.

## Remote GitHub Dependency (Default)

`Libraries/Package.swift` uses `.package(url: "https://github.com/nathant99/forgekit.git", from: "0.99.0")` — pin to minimum version, allows multiple app workspaces open simultaneously. After a ForgeKit release, `File > Packages > Update to Latest Package Versions` in each consuming workspace.

**Migration from `branch: "main"`**: Replace `branch: "main"` with `from: "0.99.0"` in `Libraries/Package.swift`. This pins to the current release and auto-resolves compatible updates (up to 1.0.0).

### Local Development Fallback

Temporarily switch to `.package(path: "../../forgekit")` for active ForgeKit development — enables edit-build-test without pushing. **Only one workspace can claim a local path dependency** — close other workspaces using ForgeKit locally. Switch back to the remote URL with `from:` when done.

## Module Catalog (50 modules — 39 client + 9 server + 2 shared)

For the authoritative list, run `ls ../forgekit/Sources/{Client,Server,Shared}`. The catalog below names every module and gives a one-line purpose; full APIs are documented in each module's `Tests/` and inline `///` doc-comments.

### Shared (2) — `Sources/Shared/<Module>/`

| Module | Purpose |
|---|---|
| `ForgeModels` | Foundational domain types: `StudentProfile`, `AchievementDefinition`, `BloomLevel`, `GradeLevel`, `ProgressRecord`, `ContentItem`, `CurriculumStandard`, `ForgeKitVersion` |
| `ForgeServerDTOs` | Typed JSON payloads on the wire — clients decode these, servers emit them. Reclassified to Shared in 0.57.0 |

### Client (38) — `Sources/Client/<Module>/`

| Module | Depends On | Purpose |
|---|---|---|
| `ForgeUI` | ForgeModels | SwiftUI components: buttons, progress bars, HUD, feedback modifiers, onboarding, theming |
| `ForgeAccessibility` | ForgeUI | COPPA compliance (parental consent with 12-month expiry), session timer, haptics, ADHD mode |
| `ForgeAdventure` | ForgeModels | Adventure mode framework: 13 game mode engines, map progression, mode availability, multiplayer config. **Hub subdirectory (0.79.0)**: `HubContribution`, `HubContributionRegistry` (actor), `HubContributionConfig` (Codable snake_case + Int `BloomLevel`), `HubGenericChallengeView`, `HubMentorOrchestrator` (+ `HubMentorSession` protocol + `NoOpHubMentorSession`), value types (`ZoneID`, `HubPresentation`, `MentorPersona`, `AudioVoiceProfile`, `HubKitResource`, `EngineCopy`, `HubChallengeResult`, `HubQuestion`/`HubQuestionKit`, `HubChallengeContext`), `Color(hex:)` extension |
| `ForgeAI` | ForgeModels | FoundationModels helpers: session management, availability gating |
| `ForgeAnalytics` | ForgeModels | Analytics events, session tracking, engagement metrics |
| `ForgeAvatar` (0.82.0) | ForgeModels (0.83.0+) | Composable avatar system. `AvatarConfig` + `AvatarLayer` live in `ForgeModels` since 0.83.0 (single source of truth, no WebP-asset drag on ForgeSync). Other public types: `AvatarAssetCatalog` (actor, multi-bundle resolution), `AvatarRenderer` (SwiftUI, renderer-masking clips layers to `anchorRect`), `AvatarSpriteNode` (SKNode w/ lazy visual setup). Bundles 128 WebP assets (6.8 MB): 20 anchors + 40 layers + 68 cosmetics. Toca-Boca-style chunky-cartoon aesthetic per `labsmith/Docs/DESIGN_AVATAR_AESTHETIC.md`. **Edit authority**: see Avatar Edit Authority section below |
| `ForgeAudio` | ForgeModels | Audio playback, SFX management |
| `ForgeCelebration` | ForgeModels, ForgeIllustrations | Celebration *orchestration* (`CelebrationCoordinator`, `CelebrationOverlayModifier`); separate from `ForgeIllustrations.CelebrationCatalog` which owns the assets |
| `ForgeContent` | ForgeModels, ForgeNetworking | Content loading, question kit parsing |
| `ForgeDevelopmental` | ForgeModels | DIR/FEDC developmental scaffolding — 16 levels, capacity-based support |
| `ForgeEmotionAware` | ForgeModels | Emotion-aware adaptive features |
| `ForgeEvents` | ForgeModels | Seasonal event lifecycle, 41 built-in holidays, celebration packs |
| `ForgeExperiments` | ForgeModels | On-device A/B testing, COPPA-compliant experimentation |
| `ForgeGameCenter` | ForgeModels | GameCenter integration: leaderboards, achievements, turn-based matchmaking |
| `ForgeGameEngine` | ForgeModels | SpriteKit helpers: scene management, node extensions |
| `ForgeGamification` | ForgeModels, ForgePersistence | XP, streaks, achievements, economy, spaced repetition |
| `ForgeIllustrations` | ForgeModels | Illustration registry/loader/resolver, prebuilt SwiftUI views, `CelebrationCatalog` (8 Lottie celebrations), on-device generation bridge |
| `ForgeIntents` | ForgeModels | App Intents framework integration for Siri / Shortcuts |
| `ForgeKnowledgeGraph` | ForgeModels | Knowledge-graph traversal for adaptive content suggestion |
| `ForgeLiveActivities` | ForgeModels | Dynamic Island + Lock Screen Live Activity support |
| `ForgeLocalization` | — | String catalog management, pluralization, brand guard, date formatting |
| `ForgeMath` | ForgeModels | Math utilities, expression evaluation, number formatting |
| `ForgeMultipeerKit` | ForgeModels | MultipeerConnectivity wrapper (distinct from ForgeMultiplayer) |
| `ForgeMultiplayer` | ForgeModels | Multiplayer session management, turn-based and real-time modes |
| `ForgeNavigation` | ForgeModels, ForgeUI | Navigation patterns, tab/sidebar coordination |
| `ForgeNetworking` | ForgeModels | Network layer, API client |
| `ForgePartyGames` | ForgeModels | Local-multiplayer mini-game engines: ForbiddenWords, ForeheadReveal, HotPotato, RapidRecall |
| `ForgePassAndPlay` | ForgeModels | Pass-and-play state machine + 4-stage privacy curtain |
| `ForgePedagogy` | ForgeModels | Pedagogical strategies, bloom-level targeting, hint scaffolding |
| `ForgePersistence` | ForgeModels | SwiftData helpers: container configuration, migration utilities |
| `ForgeProgression` | ForgeModels | Session-based content gating, calendar-aware session counting, debug bypass |
| `ForgeReporting` | ForgeModels | Progress reports, standards-mapped analytics dashboards |
| `ForgeSensory` | ForgeModels | Multi-modal feedback coordination (visual + audio + haptic) |
| `ForgeSettings` | ForgeModels | Settings / preferences storage |
| `ForgeSocial` | ForgeModels | Social features (leaderboards, friend codes — COPPA-bound) |
| `ForgeSpotlight` | ForgeModels | Spotlight search integration via `ForgeSpotlightIndexer` actor |
| `ForgeStateMachine` | ForgeModels | Generic finite state machine helpers |
| `ForgeSync` | ForgeModels | Cross-app progression sync, XP tracking, streak tracking, achievements |
| `ForgeWidgets` | ForgeModels | Home-screen widget support (WidgetKit) |

### Server (9) — `Sources/Server/<Module>/`

For Hummingbird 2 microservices (`CuriosityQuestServer`, `forgesync`, etc.). See `Docs/TEMPLATE_IMPLEMENTATION_HANDOFF_SERVER.md` (in any server-bearing app repo) for verified APIs. See `@Docs/GUIDE_FORGESERVER_ADOPTION.md` for the thin-wrapper adoption playbook.

| Module | Purpose |
|---|---|
| `ForgeServerActors` | `HTTPRateLimiter`, `WebSocketRateLimiter`, `HistoryStore`, `VerificationCodeStore` (0.58.0 `issue(_:for:)` overload), `PeriodicCleanupService`, `RoomCodeAlphabet`, `RoomManager`, `MessageWriter`, **`ConnectionRegistry<Writer>` (0.60.0)**, **`SingleFlightJobQueue<Key,Value>` (0.63.0)**, **`RoomRegistry<Room: ForgeRoom>` (0.68.0)** |
| `ForgeServerMatchmaking` | Skill-based queue, match formation |
| `ForgeServerMiddleware` | `APIKeyValidator` (nonisolated struct), `CORSPolicy`, `HeaderTokenValidator`, **`SecurityHeaders` (0.60.1)** |
| `ForgeServerMultiplayer` | Anti-cheat heuristics, elimination brackets, server-authoritative content |
| `ForgeServerRealTime` | `CountdownService`, game-state anchor primitives |
| `ForgeServerSafety` | `InputSafetyService` (`nonisolated struct` since 0.59.1), `OutputModerationService`, `CrisisResource.description` (0.59.0), **`SSEStreamModerator` + `SyntheticSSEResponseBuilder` (0.61.0)**, `SafetyConfig` output-side fields (0.66.0) |
| `ForgeServerTracking` | `APIUsageTracker` + `CallRecord` grouped summary (0.66.0), `EventStore<Event>` + `.remove(where:)/.remove(for:where:)` (0.66.0), **`APIQuotaTracker` (0.62.0)** |
| `ForgeServerWebSocket` | `BroadcastService` fan-out (+ stored-encoder init in 0.74.0), `GameMessageProtocol` envelope, **`FloorController<Speaker>` (0.64.0; `.pause()/.resume()` in 0.66.0)**, **`MessageRelay` static helpers (0.68.0)** |
| **`ForgeServerEmail` (0.65.0)** | `EmailMessage` / `EmailSender` protocol / `InMemoryEmailSender` / `VerificationEmailBuilder`. Vendor-agnostic — apps ship concrete Mailgun/SES/etc. adapters |

## ForgeUI Quick Reference

### Theming

Implement `ForgeTheme` protocol and inject via `.environment(\.forgeTheme, MyTheme())`:

```swift
protocol ForgeTheme: Sendable {
    var primaryColor: Color { get }
    var accentColor: Color { get }
    var backgroundColor: Color { get }
    var fontFamily: String? { get }
    var cornerRadius: CGFloat { get }
}
```

### Components

| Component | Init Parameters | Notes |
|---|---|---|
| `ForgePrimaryButton` | `title: String`, `isLoading: Bool = false`, `action: () -> Void` | Liquid Glass material, auto-disables when loading |
| `ForgeXPBar` | `currentXP: Int`, `xpForNextLevel: Int`, `level: Int` | Gradient fill, numeric text transitions |
| `ForgeProgressBar` | `value: Double`, `total: Double`, `label: String? = nil`, `showPercentage: Bool = true` | Generic progress, capsule shape |
| `ForgeScoreHUD` | `score: Int`, `totalQuestions: Int`, `streak: Int? = nil`, `currency: Int? = nil` | Composable game HUD overlay |
| `ForgeCurrencyHUD` | `amount: Int`, `label: String = ""` | Coin display with glass capsule |
| `ForgeStreakBadge` | `streak: Int`, `isActive: Bool` | Flame icon, pulse at milestones (5/10/25/50/100) |
| `ForgeTimerRing` | `remaining: TimeInterval`, `total: TimeInterval`, `warningThreshold: TimeInterval = 60` | Color shifts orange→red |
| `ForgeEmptyState` | `systemImage: String`, `title: String`, `description: String`, `action: (() -> Void)? = nil`, `actionTitle: String? = nil` | Wraps `ContentUnavailableView` |
| `ForgeCard` | `@ViewBuilder content: () -> Content` | Material card with theme corner radius |
| `ForgeOnboardingFlow` | `pages: [Page]`, `onComplete: () -> Void` | Multi-step with skip, parent handoff support |
| `ForgeAchievementPopup` | `badge: BadgeDisplayData`, `onDismiss: () -> Void` | Auto-dismisses after 3s, spring animation |

### View Modifiers

| Modifier | Parameter | Notes |
|---|---|---|
| `.correctFeedback(isActive:)` | `isActive: Bool` | Green flash + bounce. **NOT `trigger:`** |
| `.incorrectFeedback(isActive:)` | `isActive: Bool` | Red flash + shake |
| `.hudOverlay(alignment:content:)` | `alignment: Alignment`, `@ViewBuilder content` | Safe area-aware HUD positioning |

## ForgeGamification Quick Reference

### XPEngine

Pure value type — replaces custom level threshold arrays:

```swift
let engine = XPEngine(config: GamificationConfig())
engine.level(for: totalXP)         // Int
engine.xpRequired(forLevel: 5)    // Int (total XP needed)
engine.xpProgress(currentXP: xp)  // Double (0.0–1.0 within current level)
```

XP curves: `.standard` (level = sqrt(xp/100)), `.accelerated` (sqrt(xp/50)), `.custom((Int) -> Int)`.

### StreakManager

Actor — pure in-memory state, callers handle persistence:

```swift
let manager = StreakManager(currentStreak: 0, availableFreezes: 2)
let result = await manager.recordSession()  // StreakResult enum
```

Returns `.continued(streak:)`, `.frozenAndContinued(streak:freezesRemaining:)`, `.reset(previousStreak:)`, or `.sameDay(streak:)`.

### AchievementEngine

```swift
let engine = AchievementEngine()
let newBadges = engine.evaluate(definitions: defs, earnedIDs: earned) { def in
    // App-specific criteria check
}
```

### EconomyEngine

```swift
let engine = EconomyEngine(pricingCurve: ExponentialPricingCurve())
let newBalance = try engine.earn(amount: 50, currentBalance: balance)
let newBalance = try engine.spend(amount: 30, currentBalance: balance)
let (balance, upgrade) = try engine.purchaseUpgrade(upgrade: state, currentBalance: balance)
```

### SpacedRepetitionEngine (FSRS-6)

```swift
let srs = SpacedRepetitionEngine(desiredRetention: 0.9)
let newState = srs.reviewItem(state: fsrsState, quality: 4)  // quality 1-5
let isDue = srs.isItemDue(state)
let nextDate = srs.nextReviewDate(for: state)
```

### GamificationConfig

Central config passed to engines:

```swift
GamificationConfig(
    sessionTargetMinutes: 10...15,
    streakFreezeCount: 2,
    desiredRetention: 0.9,
    xpCurve: .standard,
    achievementDefinitions: [...]
)
```

## ForgeModels Quick Reference

| Type | Properties | Notes |
|---|---|---|
| `StudentProfile` | `id`, `displayName`, `gradeLevel`, `avatarAssetName?`, `createdAt` | Value type, not SwiftData — apps bridge to `@Model` |
| `AchievementDefinition` | `id`, `title`, `description`, `iconAssetName`, `xpValue`, `standard?` | Used by `AchievementEngine.evaluate()` |
| `BloomLevel` | `.remember` through `.create` | `Comparable` by cognitive complexity |
| `GradeLevel` | Grade band enum | Controls DDA difficulty |
| `BadgeDisplayData` | `id`, `title`, `iconAssetName`, `earnedAt` | UI display struct from `AchievementEngine.displayData()` |
| `FSRSState` | `stability`, `difficulty`, `lastReview`, `repetitions` | Spaced repetition memory state |

## Avatar Edit Authority (ForgeAvatar + ForgeSync, 0.85.0+)

Locked-in portfolio policy — see `labsmith/Docs/DECISION_AVATAR_EDIT_AUTHORITY.md` for full rationale (**R3** revision: universal full editor + hub-as-cross-portfolio-manager). `AvatarStudioView` **shipped in ForgeKit 0.85.0** (2026-05-17).

- **Any app MAY write `ForgeID.avatar`** via `appGroupStore.setAvatar(_:editedAt:)` — but apps using `ForgeAvatar.AvatarStudioView` don't call `setAvatar` directly; the view does it for them on Save. Last-write-wins on `avatarEditedAt`. If you must call `setAvatar` directly (hand-rolled paths are disallowed but the LWW rule still applies), pass `editedAt: .now`. The single-arg overload clears the timestamp; never use it
- **Render the editor via `ForgeAvatar.AvatarStudioView`, not hand-rolled UI.** Public `Presentation` enum:
  - **`.lite`** — default entry point in source apps. Skin tone + hair / outfit / eyes tint pickers
  - **`.full`** — adds background, frame, and accessories pickers. **Every app MAY offer both** (R3). Three adoption patterns observed in production (per `Docs/AUDIT_AVATAR_STUDIO_ADOPTION_RANKS_5_20_2026-05-28.md`):
    - **`.lite`-only** — recommended for Play-PRIMARY apps (curiosityquest reference impl: `Packages/Libraries/Sources/SharedUI/Onboarding/ForgeAvatarStudioShell.swift`). Profile/Settings entry; "More customization" affordance can re-present `.full` if added later
    - **`.full`-only** — recommended for Create-PRIMARY + Together-PRIMARY apps where accessory picker is part of identity loop (cubesensei reference impl: `Packages/Libraries/Sources/CubeUI/Tabs/ProfileTabView.swift:201`). Single tap → `.full` directly
    - **`.lite`+`.full` segmented toggle** — best-in-class R3 "both surfaces" pattern; lets player switch in-view without dismiss/reopen (**creaturecare reference impl**: `Libraries/Sources/AppFeature/AvatarStudioSheet.swift:62-68` — segmented picker with `@State presentation: AvatarStudioView.Presentation`; **quillspell reference impl** verified R141 #572: `Packages/Libraries/Sources/AppFeature/AvatarStudioSheet.swift` — same pattern, themed "Word Wizard" + 8 app-bundle accessories via `AvatarAssetCatalog(appBundles:)` + `.id(presentation)` for clean rebuild on toggle). Use this pattern when both presentations are equally relevant to the app's UX
- **AdventureHub differentiates by being the cross-portfolio identity manager**, NOT by exclusive access to `.full`. M7 wrapper features (multi-look save slots + badge-driven cosmetic unlock grid) live on top of `AvatarStudioView(.full)` and remain hub-exclusive. The editor itself is universal
- **Re-read `currentForgeID()?.avatar` when opening the editor** — not just at app launch. Player may have edited in another app since last open. `AvatarStudioView` does this automatically via `baselineEditedAt:` — pass it from your latest snapshot
- **Concurrent-edit conflict alerts are built into `AvatarStudioView`** — it observes `AppGroupStoreNotification.forgeIDUpdated` while open and surfaces a two-CTA alert (Discard & reload | Save and overwrite). Apps don't wire this themselves
- **Local cosmetics still OK for things outside the avatar** — apps MAY add in-app-only personalization (mascot tint, username color, app-only sticker pack, HUD palette) stored in their own SwiftData — three rules: (1) in-app only / no `AppGroupStore` writes, (2) no portfolio propagation, (3) no `AvatarLayer` overlap (no hair / face / outfit / eyes / mouth / accessories / background / frame)
- **Naming**: keep local cosmetics out of the `Avatar*` namespace — use `AppMascot…`, `AppNamePlate…`, `AppHUDPalette…`. Reserve `Avatar*` for the canonical types in `ForgeModels` + `ForgeAvatar`
- **No hand-rolled avatar editors** — don't build a per-app skin/hair/outfit picker that bypasses `AvatarStudioView`. Fragments the portfolio look and doubles maintenance

### Play-cluster 8-accessory convention (R147 #578; surfaced via Wave A R141/R144/R145 audits 2026-05-29)

Play-PRIMARY apps consistently ship **8 themed accessories** with a uniform `lowercase_underscore` naming convention. Codified after R141 (QuillSpell) + R144 (GrammarForge) + R145 (ReadQuest) Wave A audits all surfaced the same 8-accessory pattern with `Resources/AvatarShared/accessories/` bundle location.

**Per-app reference packs** (cluster: Play; theme: app-specific writing/language craft):

| App | Theme | 8 accessories |
|---|---|---|
| QuillSpell | Word Wizard | (8 themed accessories surfaced via `AvatarAssetCatalog(appBundles: [Bundle.module])`) |
| GrammarForge | Grammar | `comma_charm` / `editing_pen` / `editor_satchel` / `grammar_book` / `parts_of_speech_pin` / `punctuation_pendant` / `scholar_cap_red` / `syntax_scarf` |
| ReadQuest | Reading | `bookmark_charm` / `comprehension_pendant` / `library_satchel` / `narrative_scarf` / `open_book` / `page_marker_pin` / `reading_glasses` / `story_beanie_blue` |

**Convention rules**:
- **Bundle location**: `Libraries/Sources/SharedUI/Resources/AvatarShared/accessories/` (flat-bundle for `AvatarAssetCatalog(appBundles:)` resolution)
- **File format**: `.webp` at 256×256 with alpha
- **Naming**: `lowercase_underscore.webp`; no app-prefix (the bundle scope provides per-app uniqueness)
- **Pack size**: target 8 per app for visual variety + balanced picker layout in `.full` mode (8 fits cleanly in 2×4 or 4×2 grid)
- **Theme cohesion**: all 8 should reflect the app's curricular surface area (writing-craft / reading-craft / etc.) so picker selections feel like identity-curation, not random cosmetics

**Why 8 not other counts**: 8 is the empirical convergent count across 3 independent Play-PRIMARY apps. Provides visual balance (2×4 / 4×2 grids), enough variety for personalization, small enough to fit in `~0.36 cost` accessory-generation pipeline ceiling per `portfolio.md` § Asset generation ownership.

**Adoption pattern for new Play-PRIMARY apps**: when scaffolding, plan for 8 themed accessories from day one. Generate via standard accessory pipeline (~$0.36 ceiling). Wire through R3 both-surfaces `AvatarStudioSheet.swift` (per R147 #578 plan template). Reference template impl: `quillspell-app/Packages/Libraries/Sources/AppFeature/AvatarStudioSheet.swift`.

**Extension to non-Play clusters**: optional. Science / Adventure / Together / Create / Reflect PRIMARY apps MAY ship themed accessories if the app's identity loop justifies cosmetics (e.g., CubeSensei Create-PRIMARY ships rubik-themed accessories). The 8-count convention is a *recommendation*, not a *requirement*, outside the Play cluster.

## Cast asset filename convention (DN methodology)

For apps with a DN cast bundled via `ForgeIllustrations`, cast assets MUST use a **flat-bundle filename convention** with a `cast_` prefix:

```
Packages/Libraries/Sources/AppFeature/Resources/Illustrations/
├── cast_<character_slug>_<pose>.webp
├── cast_etyma_demonstrating.webp
├── cast_lexa_thinking.webp
```

**Why**:
- `ForgeIllustrations.IllustrationRegistry` resolves via `Bundle.module` flat lookup; subdirectory paths fail silently
- The `cast_` prefix disambiguates cast members from existing mascot files (`<mascot_name>_<pose>.webp`)
- Per-character poses share the prefix so registry filtering can group by character (`registry.assets(prefix: "cast_etyma_")`)

Codified per QuillSpell `HANDOFF_FROM_APP_CAST_FILENAME_CONVENTION.md` (Round 93 #479-A42, 2026-05-27). Applies to all DN-cast retrofit apps.

## Common Gotchas

- **`ForgeUI.CorrectFeedbackModifier`**: parameter is `isActive:`, **NOT** `trigger:`
- **All ForgeKit types are `public`** — app code imports them directly
- **`ForgeModels` types are value types** — not `@Model`. Apps create their own SwiftData models and convert to/from ForgeModels types
- **`StreakManager` is an actor** — all access is `async`
- **`XPEngine`/`EconomyEngine`/`AchievementEngine` are pure structs** — no internal state, callers manage persistence
- **Theme injection is required** — components use `@Environment(\.forgeTheme)`. Inject a custom theme at the app root or `DefaultForgeTheme` applies
- **`nonisolated` required on Sendable value types** — `InferIsolatedConformances` causes protocol conformances on value types to inherit MainActor isolation. All ForgeKit Sendable structs/enums are marked `nonisolated`. Exception: `@MainActor` SpriteKit types (`ForgeFeedback`, `ForgeCelebration`, `ForgeNodeFactory`) must NOT be `nonisolated`
- **`ForgeProgressionManager` debug bypass** — use `debugUnlockAllGates()` / `debugRestoreGateEvaluation()` for testing; constructor parameter for permanent bypass
- **ForgeKit path from `Libraries/Package.swift`** — use `../../forgekit` (two levels up), not `../forgekit`. Package.swift is inside `Libraries/`, one level deeper than the app repo root
- **Type name collisions** — qualify fully when both app modules and ForgeKit define the same type name (e.g., `Models.Expression` vs `Foundation.Expression`, `AppFeature.AppPhase` vs `ForgeNavigation.AppPhase`)
- **`@retroactive` not needed within same package** — conformances to ForgeKit protocols from targets in the same `Libraries` package are NOT retroactive. `@retroactive` in this case is a compile error
- **Fix isolation in ForgeKit, not in app code** — if a ForgeKit value type causes "call to main actor-isolated initializer in nonisolated context", mark it `nonisolated struct` IN the ForgeKit repo. Don't work around it in app code
<!-- END LABSMITH-SYNCED CONTENT -->
