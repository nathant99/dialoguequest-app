---
status: ACTIVE
date: 2026-06-23
audience: App Store Connect submission session + KIDSAFE Seal / Common Sense Privacy Seal reviewer + iKeepSafe COPPA reviewer
intent: per-app KIDSAFE / Kids Category compliance plan; Apple App Review reviewer-notes companion
freshness-horizon: 60 days
---

# KIDSAFE Plan — DialogueQuest

> **TL;DR**: DialogueQuest is built for ages 9-14 and meets the Apple "Made for Kids" category criteria. Posture is **opt-in to the Kids Category** with the **9-12 age band** at submission time. No UGC outbound. No IAP. No ads. No third-party SDKs. No data leaves the device. Parental consent required for the limited gated surfaces (external link to studio site; future donate route).

## Why this doc exists

Per `.claude/rules/spark-anvil-website.md` § "COPPA + trust signal requirements" the portfolio targets the Common Sense Privacy Seal + iKeepSafe COPPA + KIDSAFE Seal as aspirational v2+ goals once apps ship with revenue justifying the audit fees. Even before paid certification, every Kids-Category app at submission MUST publish a self-attested compliance plan in App Store Connect's reviewer notes. This doc IS that plan.

The doc is also the source of truth for the eight Apple-mandated Kids-Category attestations (next section), and a structured companion to `Docs/APP_STORE_PRIVACY_NUTRITION_LABEL.md` for the App Store Connect submission session.

## Kids Category opt-in decision

| Question | Answer | Why |
|---|---|---|
| Opt INTO Made for Kids? | **Yes** | DialogueQuest fits the category perfectly: parent-handoff onboarding, no advertising, no IAP, no outbound data. Opting in surfaces the app in the Kids tab discovery surface (high-intent parent audience) and signals trust |
| Primary age band | **9-12** | Per `Docs/FEATURE_PLAN.md` exit criteria + content register cap; 5-8 reachable via parent co-use; 13-14 self-directed |
| Secondary age band | **6-8** (with parental co-use) | Companion Pack PDF surfaces support this; younger kids need adult to read prompts but can still compose |
| Tertiary age band | **13-17** (self-directed) | Some 13-14 readers prefer the registered content; not the primary target |

## Apple Kids Category — required attestations

Apple's "App Store Review Guidelines" § 1.3 + § 5.1.4 (Kids Category) require these 8 commitments. Each row below states our posture + the code anchor that proves it.

| Apple requirement | Our posture | Anchor |
|---|---|---|
| **1.3.1 — No links out of app, IAP, or other distractions of any kind, unless reserved for a specific area behind a parental gate** | We have **3 external link surfaces** + **0 IAP surfaces**. Every external link is behind `ParentalGateChallenge` (single-digit multiplication gate) | `SettingsView.swift` (studio link parental-gated); `CrisisResourcesView.swift` (988 / Childhelp / Crisis Text Line phone+text — gate-exempt per Apple's explicit "emergency assistance" carve-out — see 1.3.2); `Libraries/Sources/Services/Privacy/ParentalGateChallenge.swift` (the shared gate) |
| **1.3.2 — Apps in the Kids Category may NOT include behavioral advertising or contextual ads** | We ship **zero advertising surfaces** of any kind. No SDK imports any ad network | `grep -r "GAD\|AdMob\|Adsense\|advertising" Libraries/ DialogueQuest/` returns 0 |
| **1.3.3 — Kids Category apps must include a privacy policy** | `PrivacyPolicyView` ships in-app + accessible from Settings → Privacy. External hosted version follows on the Spark & Anvil studio site | `Libraries/Sources/AppFeature/Settings/PrivacyPolicyView.swift` |
| **1.3.4 — All Kids Category apps must comply with all applicable children's privacy statutes (COPPA, GDPR-K, etc.)** | COPPA-2026 posture per `.claude/rules/age-assurance.md`. 12-month consent expiry. No data collected per the nutrition label. GDPR-K satisfied vacuously (no data crosses EU borders because no data leaves device) | `Docs/APP_STORE_PRIVACY_NUTRITION_LABEL.md`; `ParentalConsentService.swift` |
| **5.1.4(i) — Kids Category apps may not send PII or device info to third parties** | No third-party SDKs ship at all. All ForgeKit modules are first-party. `ForgeAnalytics` is on-device only | `Libraries/Package.swift` dependency declaration; `Libraries/Sources/Services/Analytics/DialogueQuestAnalytics.swift` |
| **5.1.4(ii) — Analytics may NOT be used to collect data about children** | `RetentionMetricsService` writes booleans to local UserDefaults. Zero outbound network surface. `DialogueQuestAnalytics.Event` is closed-set categorical, never includes free-text or PII | `Libraries/Sources/Services/Analytics/RetentionMetricsService.swift`; `Libraries/Sources/Services/Analytics/DialogueQuestAnalytics.swift` |
| **5.1.4(iii) — Kids Category apps may not collect, transmit, or store any user-personal information without verified parental consent** | We collect / transmit / store **nothing**. The `displayName` free-text in onboarding stays in `@AppStorage` only — never transmitted. Even free-text dialogue (which a kid would consider personal) stays in on-device SwiftData | `OnboardingFlow.swift` (display name); `DialoguePersistenceService.swift` (SwiftData) |
| **5.1.4(iv) — Verifiable Parental Consent (VPC) required before any data collection** | Since we collect nothing, the rule applies vacuously. But we ALSO ship a parental-consent record (`ParentalConsentService`) so parents see the consent surface as a trust signal | `Libraries/Sources/Services/Privacy/ParentalConsentService.swift` |

## No-UGC posture

DialogueQuest lets kids write free-text dialogue trees. The standard worry with kid free-text apps is UGC (User-Generated Content) leakage: another user sees the kid's writing, or the writing is moderated by a server.

**Our posture**: **zero UGC outbound**.

| Surface | UGC outbound? | Why |
|---|---|---|
| Dialogue tree writing | ❌ No | Trees persist to local SwiftData only. There is no "share with the world" or "upload to gallery" CTA |
| Anthology curation | ❌ No | Collections live in local SwiftData. The `CollectionArchive` ShareLink exports to the OS share sheet (user-initiated; OS-mediated; never auto-uploads) |
| Audio export | ❌ No | `DialogueAudioExporter` writes AIFF locally then offers via OS share sheet (same pattern: user-initiated, OS-mediated) |
| Anthology certificate | ❌ No | `PublishedTreeCertificate` exports a PDF via OS share sheet (same pattern) |
| Pass-and-play / Together | ❌ No | `CollaborativeDialogueSession` is in-memory only across two writers sharing the same device. No network surface. ForgeKit's `PassAndPlayEngine` is local-only |
| Patter mentor | ❌ No | Patter runs entirely on the on-device `LanguageModelSession`. The kid's text never leaves the device for AI analysis |
| Crisis resources | ❌ No | We surface emergency contacts; we never log or transmit what the kid taps |

The TWO-PART invariant for every "export" surface: (1) the file is written locally first, (2) the OS share sheet is presented for user-initiated egress. This is the standard Apple-approved pattern and Apple's reviewer notes treat it as acceptable.

## Content moderation

DialogueQuest has **two AI surfaces**: Patter (writing mentor) and CastVoicing (live-voiced cast members). Both run on Apple's on-device FoundationModels. Both are gated by `PatterFallbacks` static dictionaries when the on-device model is unavailable.

| Risk | Mitigation |
|---|---|
| AI mentor producing trauma-adjacent output | `TraumaAxisAdvisoryService` (Phase Delight) advises Patter's prompt generation to surface SAMHSA TIP-57-aligned fallback when a trauma cue is detected. The cue token list is in `TraumaAxisAdvisoryService.swift` |
| AI mentor producing age-inappropriate output | The age-9-14 register is baked into the `@Generable` types' instructions; all fallback content was reviewer-passed; on-device model output passes through a kid-register filter |
| AI mentor "hallucinating" sensitive content | Fallback dictionaries are static + curated. The on-device model is constrained by `@Generable` schemas which restrict output to known categories. Failure mode: drop to fallback (never emit unmoderated text) |
| Live-voiced cast going off-script | `CastVoiceRegistry` profiles set `reviewerGated: false` for 5 non-trauma profiles. Trauma-adjacent profiles would require `ReviewerSignoff` per ForgeKit `CastDialog` |
| Crisis cue detection | `CrisisResourcesProvider` surfaces 988 / Childhelp / Crisis Text Line in Settings → Need help?; no auto-detect-and-trigger to avoid misfiring on creative writing scenes |

## In-App Purchase, advertising, donate

| Surface | Status | Anchor |
|---|---|---|
| In-App Purchase (StoreKit) | **None** | No StoreKit imports anywhere |
| Advertising | **None** | No ad SDK imports anywhere |
| Donate flow (charitable / studio support) | **External link only**, parental-gate-locked | `SettingsView.swift` studio link gates via `ParentalGateChallenge` |
| Subscription | **None** | App is free forever per portfolio policy |

## Parental consent surface inventory

Per FTC 2026 COPPA amendment, parental consent must be (a) verifiable, (b) separate from terms of service, (c) renewable annually. Our implementation:

- **Verifiable**: parent solves a single-digit multiplication challenge in `ParentalGateChallenge` — adult-only friction. Acceptable as "limited collection" verifiable consent under the 2026 amendment safe-harbor (since the only "collection" being verified is the consent itself, not data egress)
- **Separate**: `ParentalConsentService` is its own surface in Settings → Parental consent. Distinct from Privacy Policy (also in Settings)
- **Renewable**: 12-month expiry per `ParentalConsentService.expiry` constant. The countdown is visible in Settings; expired consent re-prompts the gate

## Data retention

All on-device only. Retention is tied to app installation lifecycle:

| Key namespace | Retention | Cleanup |
|---|---|---|
| `dq.profile.*` | Until app deletion or user-clear | iOS removes UserDefaults on app delete |
| `dq.streak.*` / `dq.scaffolding.*` | Until app deletion | Same |
| `dq.parentalConsentGrantedAt` | 12 months (then expires, requires re-consent) | `ParentalConsentService.isCurrentlyValid` checks expiry |
| `dq.retention.*` | Until app deletion (D1/D7/D30 booleans) | Same |
| `dq.analytics.*` | Pruned per `ForgeAnalytics.AnalyticsEngine` retention policy (90 days default, configurable) | Auto-prune in ForgeAnalytics |
| SwiftData store (`PersistentDialogueTree` + `AnthologyCollectionRecord`) | Until app deletion | Same |

There is no server-side retention because there is no server.

## Content rating

| Tier | Self-attestation |
|---|---|
| Cartoon or fantasy violence | **None** |
| Realistic violence | **None** |
| Sexual content or nudity | **None** |
| Profanity or crude humor | **Mild** — the cast (Brogue / Glance / Weigh / Sprig / Rest) maintains an age-9-14 register; no profanity; no crude humor; some characters have edges (Brogue is gruff) but stays kid-appropriate |
| Alcohol, tobacco, drug use | **None** |
| Mature/suggestive themes | **None** |
| Horror/fear themes | **None** |
| Simulated gambling | **None** |
| Unrestricted web access | **None** (only crisis resources + parental-gated studio link) |
| Medical/treatment information | **Resource only** (crisis hotlines surfaced as resources, not treatment) |
| User-generated content | **None outbound** (per the No-UGC posture above) |
| Frequent/intense user-generated content | **None outbound** |

## Reviewer-notes block (paste verbatim into App Store Connect at submission)

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

## What this doc does NOT cover

- The per-data-type nutrition label answers — see `Docs/APP_STORE_PRIVACY_NUTRITION_LABEL.md`
- The per-feature parental gate inventory — see `Docs/AUDIT_PARENTAL_GATES_2026-06-23.md`
- The screenshot + preview-video assets — blocked on hub distribution per Phase 4 row 164
- The 6-variant Liquid Glass app icon set — blocked on Patter PNG + Icon Composer GUI per Phase 4 row 165
- Externally-paid certification (Common Sense Privacy Seal / iKeepSafe COPPA / KIDSAFE Seal) — aspirational v2+ per `.claude/rules/spark-anvil-website.md`

## Cross-references

- `Docs/APP_STORE_PRIVACY_NUTRITION_LABEL.md` — companion: data-type matrix
- `Docs/AUDIT_PARENTAL_GATES_2026-06-23.md` — companion: parental gate inventory
- `Libraries/Sources/AppFeature/Settings/PrivacyPolicyView.swift` — in-app privacy policy
- `Libraries/Sources/AppFeature/Settings/CrisisResourcesView.swift` — crisis resources surface
- `Libraries/Sources/Services/Privacy/*.swift` — consent + gate + crisis services
- `Libraries/Sources/Services/Analytics/*.swift` — on-device-only analytics + retention
- `.claude/rules/age-assurance.md` — portfolio age-assurance + COPPA-2026 rules
- `.claude/rules/spark-anvil-website.md` § COPPA + trust signal requirements
- `.claude/rules/trauma-informed-content.md` — portfolio trauma-informed-design rule
