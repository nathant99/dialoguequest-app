---
status: ACTIVE
date: 2026-06-24
audience: TestFlight Beta upload session + App Store Connect submission session
intent: step-by-step checklist for cutting the first TestFlight Beta build; cribs from APP_STORE_PRIVACY_NUTRITION_LABEL.md + APP_STORE_KIDSAFE_PLAN.md + AUDIT_PARENTAL_GATES_2026-06-23.md
freshness-horizon: 30 days
---

# TestFlight Beta — Pre-Upload Checklist

> **TL;DR**: With Phase 4 row 163 (App Store submission prep docs) closed, this checklist walks the next session through cutting the first TestFlight Beta archive. Sections 1-3 are pre-archive verification; sections 4-5 are App Store Connect entry; section 6 is the reviewer-notes paste block. Total session time: ~1.5h on first pass once user does the GUI work.

## Why this doc exists

The Phase 4 close-out shipped three App-Store-prep docs (PRs #107 / #108 / #109). They cover the WHAT (privacy nutrition label answers, KIDSAFE attestations, parental gates inventory). This doc covers the HOW — the sequence of build + GUI + paste steps the user runs to actually get a TestFlight Beta in front of testers.

This is a pure-docs checklist. The agent cannot run Archive builds (the GUI build action is user-driven per `@.claude/rules/xcode-agent-safety.md`). What the agent CAN do is restate the verbatim attestations + answers + reviewer notes so the user is not toggling between docs while filling forms.

## 1. Pre-archive code verification

The current `main` branch state must be ready before Archive:

- [ ] **Build clean**: MCP `BuildProject` returns "The project built successfully" with 0 errors + 0 warnings (`-Wall` equivalents enabled by the project's Swift settings)
- [ ] **Full test suite green**: `xcodebuild test -workspace DialogueQuest.xcworkspace -scheme DialogueQuest -destination 'platform=iOS Simulator,name=iPhone 17' -parallel-testing-enabled YES` returns 0 failures across all 5 test targets (Models / Services / AIMentor / AppFeature / ForgeKitIntegration) AND all 4 UI test targets (DialogueQuestUITests / RootTabNavigationUITests / SubtextConfirmationUITests / PhaseThreeFourSurfacesUITests / VoiceCrucibleUITests)
- [ ] **ForgeKit pin frozen**: `Libraries/Package.swift` pins `forgekit` at `from: "0.99.0"` (or later — check current state). Pre-archive is NOT the time to update; lock the pin until after first Beta upload
- [ ] **`xcode-select -p` returns `/Applications/Xcode.app/Contents/Developer`** (NOT the Command Line Tools path) — otherwise SPM manifest compilation will silently fall back to the old Swift toolchain (per `.claude/rules/spm-architecture.md`)
- [ ] **No `.build/` artifacts under `Libraries/`** — these are CLI build artifacts that conflict with Xcode's package loading. If present, `rm -rf Libraries/.build` and re-open Xcode

## 2. Release configuration verification (Xcode GUI)

User opens `DialogueQuest.xcworkspace` and verifies these per-target build settings via Edit Scheme → Run → Info AND Edit Scheme → Archive → Info AND Target → Build Settings:

- [ ] **Scheme → Archive → Build Configuration: Release** (NOT Debug)
- [ ] **`SWIFT_OPTIMIZATION_LEVEL` = `-O`** for Release (whole-module optimization) — per `.claude/rules/build-optimization.md` § Release Build Settings
- [ ] **`SWIFT_COMPILATION_MODE` = `wholemodule`** for Release
- [ ] **`DEBUG_INFORMATION_FORMAT` = `dwarf-with-dsym`** for Release (so crash reports symbolicate)
- [ ] **`ONLY_ACTIVE_ARCH` = `NO`** for Release (build all architectures for distribution)
- [ ] **`STRIP_SWIFT_SYMBOLS` = `YES`** for Release (reduce binary size)
- [ ] **`DEAD_CODE_STRIPPING` = `YES`** for Release
- [ ] **Code-signing identity = Apple Distribution (managed by Xcode)** — the team certificate must already exist in the keychain; Xcode handles re-issue automatically when the cert nears expiry
- [ ] **Provisioning profile = App Store** (NOT Development / Ad Hoc / Enterprise)
- [ ] **iOS Deployment Target = 26.0** (matches `Libraries/Package.swift` `.iOS(.v26)`)

## 3. Privacy / capability state verification (Xcode GUI)

User verifies these in Target → Signing & Capabilities and Target → Info:

- [ ] **App Group entitlement**: `group.spark-anvil.dialoguequest` (or the matching ForgeSync app-group) wired so `ForgeSync.AppGroupStore` reaches its identity surface. If not yet wired, `AvatarStudioView` will throw `forgeIDMissing` on Save — that is the existing R489 gotcha + the only entitlement DialogueQuest actually requires for v1
- [ ] **No FamilyControls entitlement yet** (per `HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md`, still open; `DeclaredAgeRangeGate` stays `.notWired` and surfaces "not yet enabled" copy — this is the EXPECTED state for first Beta)
- [ ] **No `NSMicrophoneUsageDescription` / `NSSpeechRecognitionUsageDescription` yet** (per `HANDOFF_TO_USER_VOICE_ACTING_COACH_INFOPLIST.md`, still open; `VoiceActingCoachService.availability` stays `.notWired`. Performance Booth "Coach my voice" affordance shows the scaffold explainer instead of the live recording surface — this is the EXPECTED state for first Beta)
- [ ] **No `NSSupportsLiveActivities` yet** (per `HANDOFF_TO_USER_WIDGET_EXTENSION.md`, still open; `DialogueWritingSessionActivity` stays `.notWired` — this is the EXPECTED state for first Beta)
- [ ] **No `NSLocalNetworkUsageDescription`** (DialogueQuest has no multipeer / Bonjour surface; this stays absent)
- [ ] **No `NSCameraUsageDescription`** (no camera surface)
- [ ] **No `NSLocationWhenInUseUsageDescription`** (no location surface)
- [ ] **Info.plist `LSApplicationCategoryType` = `public.app-category.education`** (matches Apple's Kids Category education subcategory)

## 4. Privacy Nutrition Label entry (App Store Connect)

User opens App Store Connect → DialogueQuest → App Privacy and pastes the answers below. Source of truth: `Docs/APP_STORE_PRIVACY_NUTRITION_LABEL.md`.

### Data Linked To User: NONE

For each of the 14 data types, select "Not Collected":

- [ ] Contact Info → Not collected
- [ ] Health & Fitness → Not collected
- [ ] Financial Info → Not collected
- [ ] Location → Not collected
- [ ] Sensitive Info → Not collected
- [ ] Contacts → Not collected
- [ ] User Content → Not collected (free-text dialogue trees stay in on-device SwiftData; never transmitted)
- [ ] Browsing History → Not collected
- [ ] Search History → Not collected
- [ ] Identifiers → Not collected (no IDFV / IDFA / persistent ID outbound)
- [ ] Purchases → Not collected (no StoreKit)
- [ ] Usage Data → Not collected (`ForgeAnalytics` is on-device only; closed-set categorical events never leave the device)
- [ ] Diagnostics → Not collected (no MetricKit subscriber that forwards outbound; if one is added later, this row updates)
- [ ] Other Data → Not collected

### Tracking declaration

- [ ] **Tracking: NO** — the app does NOT use data to track users across other companies' apps or websites

### Third-party SDKs

- [ ] **No third-party SDK ships**. All ForgeKit modules are first-party. No ad SDK, no analytics SDK (Firebase / Mixpanel / Amplitude / etc.), no attribution SDK, no crash reporting SDK

### Age band

- [ ] **Primary age band: 9-12** (per `KIDSAFE_PLAN.md` § Kids Category opt-in decision)

## 5. Made for Kids Category opt-in (App Store Connect)

User opens App Store Connect → DialogueQuest → App Information → Made for Kids and answers each prompt. Source of truth: `Docs/APP_STORE_KIDSAFE_PLAN.md` § Apple Kids Category attestations.

- [ ] **Opt INTO Made for Kids**: YES
- [ ] **Primary age band**: 9-12
- [ ] **Secondary age band**: 6-8 (with parental co-use)

### 8 Apple-mandated attestations (each requires YES + per-anchor support)

- [ ] **1.3.1 — No links out of app / IAP behind unverified gates**: YES. The 3 external link surfaces are gated by `ParentalGateChallenge`. Crisis resources gate-exempt per the "emergency assistance" carve-out
- [ ] **1.3.2 — No behavioral or contextual advertising**: YES. Zero advertising SDKs ship
- [ ] **1.3.3 — Privacy policy provided**: YES. In-app at Settings → Privacy via `PrivacyPolicyView`
- [ ] **1.3.4 — COPPA / GDPR-K compliance**: YES. 12-month consent expiry per FTC 2026. No data crosses borders because no data leaves the device
- [ ] **5.1.4(i) — No PII / device info to third parties**: YES. All ForgeKit modules are first-party; no third-party SDKs
- [ ] **5.1.4(ii) — Analytics not used to collect data about children**: YES. `ForgeAnalytics` is on-device only; closed-set categorical events; zero outbound
- [ ] **5.1.4(iii) — No collection / transmit / store of PII without verified consent**: YES (vacuously — we collect nothing)
- [ ] **5.1.4(iv) — Verifiable Parental Consent**: YES. `ParentalConsentService` records consent locally with 12-month expiry

## 6. Reviewer-notes paste block

Paste verbatim into App Store Connect → DialogueQuest → App Review Information → Notes. Source: `Docs/APP_STORE_KIDSAFE_PLAN.md` § Reviewer-notes block.

```
DialogueQuest is a kid-safe dialogue-craft writing tool for ages 9-14.

Privacy posture:
- No data collected from the user (see App Privacy form)
- No third-party SDKs; no advertising; no IAP
- All content stays on device (SwiftData + UserDefaults only)
- AI writing mentor (Patter) runs on-device via Apple FoundationModels
- No outbound network surface in the app

Kids Category compliance:
- External links (studio site + crisis resources) are behind a math
  parental gate; crisis resources are exempt per Apple's "emergency
  assistance" carve-out in 1.3.1
- Parental consent recorded locally with 12-month expiry per FTC 2026
  COPPA amendment
- All free-text the kid writes stays in on-device SwiftData; never
  transmitted; never moderated by a server (no moderation server exists)

Content register:
- Age 9-14 with parent co-use track for 5-8
- No violence, sexual content, drugs, gambling, or UGC outbound
- Crisis resources surfaced as Resource (988 / Childhelp / Crisis Text
  Line) — phone+text contacts only, never logs taps

Test account: not needed (the app has no login). Demo flow:
1. Open the app; complete the 6-page onboarding (parent handoff +
   5 kid pages)
2. Tap Write → tap +Character twice → add a dialogue line → tap Publish
3. Tap Adventure → Performance Booth → premiere any published tree
4. Tap Profile → Anthology → view published trees
```

## 7. Archive + upload (Xcode GUI)

- [ ] **Product → Archive** (Xcode 26 runs this on the connected scheme + selected destination = Any iOS Device (arm64))
- [ ] **Wait for Organizer** — when Archive completes, Xcode opens Organizer with the new archive selected
- [ ] **Validate App** — clicks through to App Store Connect; checks signing + entitlements + asset catalog + Info.plist consistency. Fix any reported issues + re-archive
- [ ] **Distribute App → App Store Connect → Upload** — pick the previously-validated archive. Wait ~5-15 min for Apple's processing (the email "Your build is now available for testing" arrives when processing completes)

## 8. TestFlight Beta surface (App Store Connect)

After upload + processing:

- [ ] **App Store Connect → DialogueQuest → TestFlight tab** — find the newly-uploaded build
- [ ] **Manage Compliance** — answer "Does your app use encryption?" → NO (we use Apple's built-in `OSAllocatedUnfairLock` + on-device crypto only via system frameworks; no custom encryption surface)
- [ ] **What to Test** — author a 1-paragraph release note covering: Phase 4 row 163 close + the 5 still-active user-GUI handoffs that stay `.notWired` in this build (declared age range / app icon / voice-acting coach / widget extension / aimentortests test plan)
- [ ] **Add Internal Group testers** (Spark & Anvil team accounts) for first round
- [ ] **Send the invitation** — testers receive email + can install via TestFlight app

## 9. Post-upload follow-ups

Once first Beta is in testers' hands, the next session can:

- [ ] Watch for crash reports in App Store Connect → DialogueQuest → TestFlight → Crashes (no automated MetricKit forwarding yet; rely on TestFlight's built-in surface)
- [ ] Watch for feedback in TestFlight Feedback (tester sends in-app feedback)
- [ ] Continue Hub-blocked work — once the 3 hub asks ship (HubContribution Level 1 + Patter app icon PNG + Curating Together PDF), file follow-on PRs to consume them
- [ ] Continue user-GUI-blocked work — when the user lands any of the 5 active handoffs, the agent stages + commits the resulting Xcode-managed-file diff + lands the follow-on Swift PR that flips the relevant `.notWired` → `.notRequested` / `.ready`

## What this doc does NOT cover

- **App Store Production submission** — TestFlight Beta is a prerequisite; full Production submission requires screenshots + preview videos which are still blocked on hub (Phase 4 row 164)
- **App Icon variants** — still blocked on Patter PNG + Icon Composer GUI (Phase 4 row 165)
- **Common Sense Privacy Seal / iKeepSafe COPPA / KIDSAFE Seal** — aspirational v2+ per `.claude/rules/spark-anvil-website.md`; first paid certification cycle starts once the app has revenue or grant funding to justify the audit fee
- **Crash reporting via MetricKit + a server uplink** — out of scope for v1; portfolio rule is "no server uplink"; TestFlight's built-in crash surface is enough for the first Beta

## Cross-references

- `Docs/APP_STORE_PRIVACY_NUTRITION_LABEL.md` — verbatim privacy answers
- `Docs/APP_STORE_KIDSAFE_PLAN.md` — verbatim KIDSAFE attestations + reviewer-notes
- `Docs/AUDIT_PARENTAL_GATES_2026-06-23.md` — verbatim parental-gate inventory
- `Docs/HANDOFF_TO_USER_APP_ICON.md` — blocking row 165
- `Docs/HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md` — blocking the FamilyControls active path
- `Docs/HANDOFF_TO_USER_VOICE_ACTING_COACH_INFOPLIST.md` — blocking voice-acting coach active path
- `Docs/HANDOFF_TO_USER_WIDGET_EXTENSION.md` — blocking Live Activity active path
- `Docs/HANDOFF_TO_HUB_HUBCONTRIBUTION_LEVEL_1.md` — blocking AdventureHub Word Workshop tile
- `Docs/HANDOFF_TO_HUB_PATTER_APP_ICON_PNG.md` — blocking app icon Patter PNG
- `Docs/HANDOFF_TO_HUB_CURATING_TOGETHER_PDF.md` — blocking 4th Companion Pack PDF
- `.claude/rules/age-assurance.md` — COPPA-2026 + iOS 26.2+ Declared Age Range API
- `.claude/rules/spark-anvil-website.md` § COPPA + trust signal requirements
- `.claude/rules/build-optimization.md` § Release Build Settings
- `.claude/rules/xcode-agent-safety.md` § "Xcode Agent Safety" — why the user runs Archive, not the agent
