---
status: SHIPPED
date: 2026-06-23
round: 2026-06-23 mid-session
freshness-horizon: 60 days
direction: in-session review → future Claude Code sessions
---

# Trauma-Informed Gate Review — DialogueQuest

Closes the Phase Accessibility & Trauma-Informed Polish checkbox in `@Docs/FEATURE_PLAN.md`:

> Trauma-informed gate review for advanced dialogue topics — flag conflict / loss / identity-shame themes before exposing to kid (SAMHSA TIP 57 register; off-ramps)

## The decision

Ship a narrow, ADVISORY-ONLY gate that surfaces a soft banner when the kid's authored text crosses one of two bands:

- `.crisisCue` — near-explicit crisis signals (suicide ideation / self-harm / abuse disclosure). Surfaces 988 / Childhelp / Crisis Text Line with foregrounded resource access.
- `.tenderTheme` — heavy themes (death of a loved one / family rupture / despair / worthlessness). Surfaces a softer "take a breath" banner; resources reachable in one tap but not foregrounded.

The gate NEVER blocks publication, NEVER rewrites the kid's words, and NEVER moralizes "concerning content." Per the SAMHSA TIP 57 register (validate-then-inform / hold-space / refer-up), the banner validates the weight + offers a pause + surfaces resources.

## Why advisory-only

DialogueQuest is a **dialogue-craft app** — exploring conflict, loss, and emotional weight through dialogue IS the curriculum. Patter explicitly coaches the kid INTO emotional weight, not away from it:

- *"You branched here. What does each side cost the speaker?"* — coaches stakes
- *".quietConflict"* and *".awkwardSilence"* are first-class moods
- The streak system explicitly routes hard scenes through ForgeKit 0.86 `.heldUnderDistress` so the streak HOLDS instead of breaking on emotional material

A blocking moderation gate would break the app. A grading "this is concerning" gate would shame creative work. The advisory model — surface the resource list without commenting on the draft — is the only posture that preserves craft AND keeps the safety surface in place when a real signal lands.

## Lexical surface review

### Crisis cues (band: `.crisisCue`)

These are multi-word phrases curated against SAMHSA TIP 57's strongest-signal list. Each is an explicit near-verbatim self-harm / suicide / abuse-disclosure cue. Single-word verbs (`kill`, `die`, `hurt`) are **deliberately excluded** because they're common in dialogue craft (a character kills time, a plant dies, a feeling hurts).

| Cue phrase | Why it's a crisis signal |
|---|---|
| `kill myself` / `kill himself` / `kill herself` / `kill themself` | Verbatim suicide ideation |
| `end my life` / `end it all` | Suicide ideation (synonym surface) |
| `want to die` / `wish i was dead` / `wish i were dead` | Suicide ideation (declarative) |
| `no point living` / `no reason to live` | Despair → suicide-risk indicator |
| `hurt myself` / `cutting myself` | Self-harm disclosure |
| `took the pills` / `took all the pills` | Method-named self-harm |
| `running away from home` / `ran away from home` | Runaway / unsafe-environment cue |
| `he hits me` / `she hits me` / `they hit me` | Abuse disclosure |

### Tender themes (band: `.tenderTheme`)

Heavy themes that warrant a soft check-in without crossing the crisis threshold.

| Cue phrase | Why it warrants a soft pause |
|---|---|
| `gone forever` / `never coming back` | Loss / death framing |
| `she died` / `he died` / `they died` | Explicit death framing |
| `lost my mom` / `lost my dad` / `lost my grandma` / `lost my grandpa` | Family loss disclosure |
| `my parents are gone` | Family rupture |
| `i miss her so much it hurts` / `i miss him so much it hurts` | Grief intensity marker |
| `everyone leaves me` | Abandonment schema |
| `no one cares about me` / `nobody listens` | Despair adjacent |
| `i'm worthless` | Identity-shame schema |

## What's deliberately NOT in the surface

These were considered + REJECTED to avoid breaking craft:

| Considered | Why rejected |
|---|---|
| Single-word `kill` / `die` / `dead` | Common dialogue craft surface (idioms, hypotheticals, narrative voice) |
| `cry` / `sob` / `tears` | Healthy emotional expression; surfacing would shame |
| `pushed her away` / `pushed him away` | Standard relationship-craft language |
| `lost` (single-word) | Sports, games, items, jobs — too many false positives |
| `hate` / `hated` | Common conflict-craft, especially in protagonist/antagonist dialogue |
| `alone` / `lonely` | Standard emotional vocabulary; surfacing would over-flag |
| `scared` / `afraid` | Fear is craft material, not a crisis signal |
| `gun` / `knife` / `blade` | Could be drama / historical / metaphorical; without the self-harm phrase form, surfacing would over-flag |
| Mood-alone path (`.quietConflict` / `.awkwardSilence`) | The whole point of the mood markers is to TAG hard scenes; surfacing on mood alone would fire on every quiet-conflict tree |

## SAMHSA TIP 57 mapping

The banner copy maps to TIP 57's validate-then-inform pattern:

| TIP 57 principle | Banner implementation |
|---|---|
| Recognize prevalence of trauma | Surface the banner only when a strong cue lands — no over-flagging |
| Recognize signs in self + others | Lexical surface above; tied to verbatim cues, not interpretation |
| Respond by integrating knowledge into policy | Surface resources WITHOUT a referral or judgment |
| Resist re-traumatization | Banner is dismissible; never auto-modal; never blocks draft |
| Promote safety | 988 / Childhelp / Crisis Text Line are one-tap reachable; opt-in always |
| Promote trustworthiness + transparency | Copy explicitly names "if anything is real and hard for you too" — no euphemism |
| Promote peer support | (Out of scope for this gate; lives at the CrisisResourcesView surface) |
| Promote empowerment | Kid chooses whether to open resources; banner never auto-dials |

## Per-session de-dup

Once the advisory has surfaced this session, the gate sets `traumaAdvisorySurfacedThisSession = true` and stops checking until the kid quits and re-opens. This:

- Avoids banner-spam on tender-themed trees (the kid writing a "she died" tree shouldn't see the banner on every node)
- Keeps the resource list reachable via the Settings → "Need help?" link at all times
- Preserves the kid's flow — once the resource is surfaced, the kid knows it's there

The next session resets the flag.

## What's NOT in this PR's scope

- **Server-side moderation pipeline** — DialogueQuest has no server; all moderation is on-device
- **AI-driven sentiment classification** — out of scope; lexical-only surface keeps the gate transparent + auditable
- **Crisis intervention escalation** — the app surfaces resources; trained humans answer. Never auto-dials, never auto-texts.
- **Parent notification** — out of scope; would require COPPA-compliant consent surface + privacy review. The Settings → ParentProgressDashboardView already surfaces session activity; a future parent-notification surface for crisis cues lands in a separate handoff if/when families want it.
- **Spotify-style "skip" suggestion** — out of scope; would moralize the kid's draft choice

## Test coverage

`Libraries/Tests/ServicesTests/TraumaAxisAdvisoryServiceTests.swift` — 10 tests covering:

- Common conflict-craft writing passes through silently (10 representative lines)
- Strong crisis cues fire `.crisisCue` band (5 representative lines)
- Tender themes fire `.tenderTheme` band, NOT `.crisisCue` (5 representative lines)
- Mood alone (without a line cue) never fires an advisory (every mood × no-cue line)
- Empty + whitespace line never fires an advisory
- Case-insensitive matching on crisis cues
- Crisis band foregrounds resources; tender band does not
- Banner copy stays in age-9-14 SAMHSA TIP 57 register stoplist (validate-then-inform)
- Lexical surface stays narrow — single-word adjacent verbs (`kill time`, `die if forgotten`, `it really hurt`) do NOT fire
- Banner titles + bodies are nonempty for every band

## UI integration

- `Libraries/Sources/AppFeature/Welcome/TenderThemeBannerView.swift` renders the soft banner
- `Libraries/Sources/AppFeature/Tabs/WriteTabView.swift` wires the inspection on tree-node-count changes (per-session de-duped) + surfaces the banner via `safeAreaInset(.top)`
- "Open crisis resources" button presents `CrisisResourcesView` as a sheet (already-shipped surface; 988 / Childhelp / Crisis Text Line)

## Cross-references

- `@.claude/rules/trauma-informed-content.md` — portfolio-wide trauma-informed content design rule (this gate adopts the SAMHSA TIP 57 anchor + the off-ramps pattern)
- `@.claude/rules/distributed-narrative.md` § Trauma-safety per-page surface — site-axis parallel
- `@Docs/FEATURE_PLAN.md` § Phase Accessibility & Trauma-Informed Polish — the closed checkbox
- `Libraries/Sources/Services/Privacy/CrisisResourcesProvider.swift` — the canonical resource list (US-locale; locale expansion handoff filed separately)
- `Libraries/Sources/AppFeature/Settings/CrisisResourcesView.swift` — the existing Settings → "Need help?" surface
- `Libraries/Sources/Services/Privacy/TraumaAxisAdvisoryService.swift` — the gate itself
- `Libraries/Tests/ServicesTests/TraumaAxisAdvisoryServiceTests.swift` — the test suite
