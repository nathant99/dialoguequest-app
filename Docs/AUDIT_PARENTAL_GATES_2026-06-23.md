---
status: ACTIVE
date: 2026-06-23
audience: App Store reviewer / KIDSAFE reviewer / future submission session
intent: enumerate every parental-control / age-gate surface in DialogueQuest with file + line + firing condition
freshness-horizon: 60 days
---

# Parental Gates Audit — DialogueQuest

> **TL;DR**: DialogueQuest ships **9 distinct parental-control / age-gate surfaces**. Every external-link surface is gate-protected (math challenge); crisis resources are intentionally gate-exempt per Apple's emergency-assistance carve-out. No surface allows the kid to bypass parental control on any data-egress action (there is no data-egress).

## Why this doc exists

App Store reviewers (and KIDSAFE Seal / Common Sense Privacy Seal auditors when we pursue them) ask for a single artifact mapping every parental-control surface. This is that artifact.

Audit methodology: `grep` for each gate keyword + read every match in context + verify the firing condition + write the row. Re-run when a new gate is added or when an existing gate's firing condition changes.

## Gate inventory

The 9 gate surfaces (anchor → firing condition → user behavior on success / failure).

### 1. Parental handoff (onboarding step 1)

| Field | Value |
|---|---|
| Anchor | `Libraries/Sources/AppFeature/Onboarding/OnboardingFlow.swift:24` |
| Surface | First-launch onboarding |
| Firing condition | First-ever launch OR `dq.hasCompletedOnboarding` is false |
| What the kid sees | `ForgeOnboardingFlow` renders the "Ask a parent or guardian to continue" prompt (per portfolio convention) on step 1 of 6 |
| What success looks like | Kid hands device to a parent who taps "Continue" → onboarding proceeds to step 2 |
| What failure looks like | No kid-blocking enforcement — the page is informational. Parent can choose to skip the handoff |
| Anti-pattern check | The handoff is intentionally informational rather than enforced. Apple HIG explicitly does NOT require enforcing handoff for Kids-Category apps; the spirit is "show the parent first" |

### 2. Parental consent record (Settings → Parental controls)

| Field | Value |
|---|---|
| Anchor | `Libraries/Sources/AppFeature/Settings/SettingsView.swift:43-51` + `Libraries/Sources/Services/Privacy/ParentalConsentService.swift` |
| Surface | Settings → Parental controls section |
| Firing condition | Parent taps "Record parental consent" button |
| What the kid sees | A sheet with a single-digit multiplication challenge (e.g., "What is 6 × 7?") |
| What success looks like | Correct answer → `ParentalConsentService.grant()` writes `dq.parentalConsentGrantedAt` UserDefaults key with current date |
| What failure looks like | Wrong answer / dismissed sheet → no consent recorded; UI shows "Consent not recorded" row |
| Renewal | 12-month expiry per FTC 2026 COPPA amendment. `ParentalConsentService.isCurrentlyValid` checks expiry; expired consent shows "Renew parental consent" CTA |
| Revocation | Parent can tap "Revoke parental consent" (destructive role); writes nil to the UserDefaults key |

### 3. Parental Gate Challenge (shared math gate)

| Field | Value |
|---|---|
| Anchor | `Libraries/Sources/Services/Privacy/ParentalGateChallenge.swift` |
| Surface | Reusable component; current consumer is `SettingsView`'s ParentalConsentGateView |
| Firing condition | Any surface that calls `ParentalGateChallenge.random()` and presents the resulting prompt |
| What the kid sees | Single-digit multiplication problem (6×6 through 9×9) — adult-friction by design |
| What success looks like | `challenge.accepts(input)` returns true → caller's `onGranted` closure fires |
| What failure looks like | Returns false → caller can issue a new challenge or dismiss |
| Future consumers | Studio-site external link (planned); donate flow (planned); any future external-link surface |

### 4. Declared Age Range Gate (iOS 26+ Family Controls)

| Field | Value |
|---|---|
| Anchor | `Libraries/Sources/Services/Privacy/DeclaredAgeRangeGate.swift` + `Libraries/Sources/AppFeature/Settings/SettingsView.swift:130-140` (ageBandRow) |
| Surface | Settings → Privacy section; renders `Label(...)` with `isWired` adornment |
| Firing condition | App initialization probes Family Controls entitlement + `NSChildUseDescription` Info.plist key |
| What the kid sees | A "Declared age range" row showing either "Not wired" (current) or the actual category from Apple's Declared Age Range API (Under 13 / 13-15 / 16-17 / Over 18) — once entitlement lands |
| What success looks like | API returns the age category. App uses it to inform DDA difficulty + scaffolding tier (already accepts the band; doesn't gate content on it) |
| What failure looks like | API unavailable → app behaves as if no age info is available → conservative defaults |
| Status | **Scaffold-only**. Active path BLOCKED on `HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md` (Family Controls entitlement + `NSChildUseDescription` Info.plist key) |

### 5. Crisis Resources surface (Settings → Need help?)

| Field | Value |
|---|---|
| Anchor | `Libraries/Sources/AppFeature/Settings/CrisisResourcesView.swift` + `Libraries/Sources/Services/Privacy/CrisisResourcesProvider.swift` |
| Surface | Settings → Need help? → "Crisis resources" NavigationLink |
| Firing condition | Kid (or parent) taps the NavigationLink |
| What the kid sees | List of: 988 Suicide & Crisis Lifeline (tap-to-call + tap-to-text), Childhelp (1-800-422-4453), Crisis Text Line (text HOME to 741741) |
| Gate status | **Intentionally exempt from parental gate** per Apple App Review Guidelines § 1.3.1 carve-out for "emergency assistance" |
| Privacy posture | We provide the contact info only; we never log or transmit which resource the kid taps |
| Mirrored on | `TenderThemeBannerView` invites kids to pause + access these resources when a tender theme is detected in their writing |

### 6. Crisis Resources surface (Trauma-axis advisory branch)

| Field | Value |
|---|---|
| Anchor | `Libraries/Sources/AppFeature/Tabs/WriteTabView.swift:32` + `:319` + `:327-328` |
| Surface | Write tab; `TenderThemeBannerView` slides in when the trauma-axis advisory fires; "Need help?" CTA opens `CrisisResourcesView` as a sheet |
| Firing condition | `TraumaAxisAdvisoryService` flags a tender/distress cue in the kid's writing |
| What the kid sees | Gentle banner inviting a pause + a "Need help?" link that surfaces the crisis resources |
| Gate status | Intentionally gate-exempt (same Apple 1.3.1 carve-out) |
| Privacy posture | Banner appears in-app only; trigger is on-device cue detection; no outbound signal |

### 7. Cast voicing reviewer-signoff gate

| Field | Value |
|---|---|
| Anchor | `Libraries/Sources/AIMentor/CastVoicing/CastVoiceRegistry.swift:238` + `:260` + `:282` + `:304` + `:325` + `:349` + `:372` + `:393` + `:414` + `:444` (all 10 profile registrations) |
| Surface | ForgeKit `CastDialog.register(_:signoff:)` call sites for each cast member |
| Firing condition | Patter's live-voiced cast layer surfaces a generated line through the on-device model |
| What the kid sees | Patter or the cast member's bubble with text from the on-device model OR the static fallback |
| Gate status | **All 10 profiles set `reviewerGated: false`** — the cast is age-9-14 and stays within the kid-register; no trauma-axis embedding requires `ReviewerSignoff` |
| Reviewer-signoff trigger | If any future profile sets `reviewerGated: true`, ForgeKit requires a `ReviewerSignoff` value before the model can respond as that character. The 10 current profiles don't need this |

### 8. AI mentor on-device fallback gate

| Field | Value |
|---|---|
| Anchor | `Libraries/Sources/AIMentor/PatterMentor.swift` (lazy session) + `Libraries/Sources/AIMentor/Fallbacks/PatterFallbacks.swift` |
| Surface | Anywhere `PatterMentor.analyze(...)` / `.branchCheck(...)` / `.tagBalanceTip(...)` is called |
| Firing condition | Always — every call routes through `try? await session.respond(...)` with a fallback path on failure |
| What the kid sees | On-device-generated tip when the model is available; static fallback when it's not |
| Gate status | This is a **content-safety gate**, not a parental gate. Static fallbacks are pre-curated; on-device generation respects the `@Generable` schemas which constrain output. Apple's on-device FoundationModels enforces content-safety at the OS layer |

### 9. External-link surfaces (Privacy policy off-app + studio site)

| Field | Value |
|---|---|
| Anchor | `Libraries/Sources/AppFeature/Settings/PrivacyPolicyView.swift` (in-app only currently); `SettingsView` reserved future studio link |
| Surface | Settings → Privacy (in-app summary); future external study/donate links will be parental-gated |
| Firing condition | When the future studio-link surface ships, it will present `ParentalGateChallenge` before opening any external URL |
| What the kid sees | Currently: in-app `PrivacyPolicyView` only. Future: the gate fires before any external URL opens |
| Compliance | Per Apple Kids Category 1.3.1 — all out-of-app links MUST be parental-gated. We comply when the surface ships |

## Parental gate flow diagram

```
[Kid taps "external link"]
         ↓
[ParentalGateChallenge.random()]  ← single-digit multiplication
         ↓
   ┌─────┴─────┐
   ↓           ↓
 Pass         Fail
   ↓           ↓
 Open URL    Dismiss (new challenge or close)
```

```
[First launch]
       ↓
[OnboardingFlow page 1 — isParentHandoff: true]
       ↓
[ForgeOnboardingFlow: "Ask a parent or guardian to continue"]
       ↓
[Parent taps Continue]
       ↓
[Pages 2-6 — kid onboarding]
       ↓
[dq.hasCompletedOnboarding = true]
```

```
[Trauma-axis cue detected in writing]
       ↓
[TenderThemeBannerView in Write tab]
       ↓
[Kid taps "Need help?"]
       ↓
[CrisisResourcesView (gate-exempt)]
       ↓
[988 / Childhelp / Crisis Text Line tap-to-call / tap-to-text]
```

## Surfaces verified NOT to require a gate

These were considered + intentionally NOT gated, with rationale:

| Surface | Why no gate |
|---|---|
| Crisis resources (988 / Childhelp / Crisis Text Line) | Apple 1.3.1 emergency-assistance carve-out — explicit |
| Anthology curation (Profile → Anthology / Curate collections) | All in-app, no external surface; no data egress; kid agency over their own writing |
| ShareLink for anthology archive / audio export | OS-mediated user-initiated share — Apple's standard pattern; gate would frustrate the kid without protecting anything (no data egress beyond what the OS share sheet allows) |
| Settings → Daily session limit / Weekly summary toggle | Parental control surfaces ARE the gate — they configure the gate, not behind one |
| Labs toggles (third character, cast voicing) | Inside Settings already (parent-gated by social convention); both surfaces are content-toggles, not data-egress |
| Voice-acting coach (when wired) | Requires microphone — iOS enforces its own per-permission prompt at first use, which is a parental-decision surface |
| Live Activity (when wired) | Lock-screen widget — no data egress; user-controlled by iOS Settings → Privacy → Live Activities at OS level |

## What this audit does NOT cover

- The on-device FoundationModels content-safety layer (Apple-managed)
- The OS-level Family Controls / Screen Time settings (managed in iOS Settings, not within the app)
- The `RootView`'s onboarding-completion gate (kid-progression gate, not parental)
- The Settings → Daily session limit ticker (gentle nudge + ending summary — a session-pacing surface, not a gate)
- Future server-side moderation (does not exist — no server)

## When this audit needs refreshing

- A new external-link surface lands (studio site / donate / external privacy page)
- A new cast voicing profile sets `reviewerGated: true`
- The Family Controls entitlement lands (then row 4 transitions from `notWired` → `notRequested` → `ready`)
- The Voice-acting Coach Info.plist keys land (then a new permission-gate row joins the inventory)
- The Widget Extension target ships with `NSSupportsLiveActivities` (then a new lock-screen-attestation row joins)
- Apple changes the App Review Guidelines § 1.3 or § 5.1.4 (next likely revision: 2027)

## Cross-references

- `Docs/APP_STORE_PRIVACY_NUTRITION_LABEL.md` — companion: data-type matrix
- `Docs/APP_STORE_KIDSAFE_PLAN.md` — companion: Kids Category compliance plan
- `Libraries/Sources/Services/Privacy/*.swift` — gate implementations
- `Libraries/Sources/AppFeature/Settings/*.swift` — gate-presenting UI surfaces
- `Libraries/Sources/AppFeature/Welcome/TenderThemeBannerView.swift` — trauma-axis advisory crisis-resource invite
- `Libraries/Sources/AppFeature/Onboarding/OnboardingFlow.swift` — parental-handoff first page
- `Libraries/Sources/AIMentor/CastVoicing/CastVoiceRegistry.swift` — 10 cast voicing profiles (all reviewerGated: false)
- `Docs/HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md` — entitlement + Info.plist GUI work
- `Docs/HANDOFF_TO_USER_VOICE_ACTING_COACH_INFOPLIST.md` — microphone + speech recognition Info.plist keys
- `Docs/HANDOFF_TO_USER_WIDGET_EXTENSION.md` — Widget Extension target + Live Activity Info.plist key
- `.claude/rules/age-assurance.md` — portfolio age-assurance + COPPA-2026 rules
