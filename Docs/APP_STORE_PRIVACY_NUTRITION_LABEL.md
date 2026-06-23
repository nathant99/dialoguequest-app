---
status: ACTIVE
date: 2026-06-23
audience: App Store Connect submission session + external privacy reviewer
intent: canonical crib sheet for the App Store Connect privacy nutrition label questionnaire
freshness-horizon: 60 days
---

# App Store Privacy Nutrition Label — DialogueQuest

> **TL;DR**: DialogueQuest's nutrition label answer is **"Data Not Collected"** for every data type Apple lists. Every claim below is anchored to a specific code location so an external reviewer can verify.

## Why this doc exists

App Store Connect's "App Privacy" form is one of the gating screens for any TestFlight Public + App Store submission. The questionnaire requires per-data-type answers that, once published, are user-visible on the App Store listing AND legally binding. Authoring the canonical answer mapping in advance prevents a rushed mis-answer at submission time and gives the future submission session a verbatim crib sheet.

This doc is the source of truth for what gets entered in App Store Connect. Update this doc if any of the underlying code paths change.

## Data type matrix

The 14 categories Apple surfaces in the App Privacy form. For each, our answer is "**Not collected**" and the row anchors the claim to code.

| Apple data type | Collected? | Anchor in code | Note |
|---|---|---|---|
| **Contact Info** (name, email, phone, address, other user contact info) | ❌ No | `OnboardingFlow` collects a free-text display name kept in `@AppStorage("dq.profile.name")` only — never transmitted; not tied to identity | The display name is a local-only kid handle (`displayName`); no email / phone / address surface anywhere |
| **Health & Fitness** | ❌ No | No HealthKit imports; `Libraries/Package.swift` no `import HealthKit` | — |
| **Financial Info** | ❌ No | No StoreKit/IAP surface; no payment intents | App is free; no IAP, no donate, no subscription |
| **Location** | ❌ No | No `CoreLocation` imports anywhere in `Libraries/` or `DialogueQuest/` | — |
| **Sensitive Info** (race / religion / sexual orientation / political opinion / etc.) | ❌ No | Free-text dialogue stays in SwiftData on-device; no analyzer projects free-text into categorical PII | Pattern check: `DialogueQuestAnalytics.Event` vocabulary is closed-set categorical only |
| **Contacts** | ❌ No | No `Contacts.framework` imports | — |
| **User Content** (emails, messages, photos, videos, audio, gameplay, customer support, other) | ❌ No | All writing (dialogue trees / characters / anthology entries) persists to local SwiftData via `DialoguePersistenceService`. No outbound network surface; no cloud backup of content. `DialogueAudioExporter` writes AIFF to a user-initiated `ShareLink`; the export is OS-mediated and never auto-uploads | The TWO-PART rule: writing is local; export is user-initiated and goes to OS share sheet (which we don't classify as "collected" — it's a user-triggered out-of-process operation) |
| **Browsing History** | ❌ No | No web view; no URL tracking | The only `Link` surfaces are: 988 / Childhelp / Crisis Text Line phone+text (`CrisisResourcesView`) and external Spark & Anvil studio site (`SettingsView`, parental-gate-locked) |
| **Search History** | ❌ No | App has no search surface | — |
| **Identifiers** (User ID, Device ID, IDFA) | ❌ No | `ForgeAnalytics` uses an on-device-only `AnalyticsEngine` actor; no IDFV / IDFA / advertising-identifier surface; no `ASIdentifierManager` import | Confirmed: `grep -r "ASIdentifierManager\|IDFA\|advertisingIdentifier" Libraries/ DialogueQuest/` returns 0 |
| **Purchases** | ❌ No | No StoreKit imports | — |
| **Usage Data** (product interaction, advertising data, other) | ❌ No | `DialogueQuestAnalytics` records categorical events to **on-device** UserDefaults via ForgeKit's `AnalyticsEngine` actor (PII-blocklist + retention-pruned + COPPA-safe). No outbound transmission of any kind | The on-device event store is for parent dashboard rendering ONLY — never network-egressed |
| **Diagnostics** (crash data, performance data, other diagnostic data) | ❌ No | Apple's standard MetricKit / crash reporting is OS-mediated and opt-in by the user at the OS level — outside the app's scope. We do not ingest crash data ourselves | If/when we wire MetricKit explicitly, this row flips to "Linked to user → Diagnostics → Crash" and we update this doc |
| **Surroundings / Body / Hands / Head (visionOS)** | ❌ No | iOS app; no visionOS target | — |
| **Other Data Types** | ❌ No | — | Catch-all reviewed; nothing applies |

## Tracking declaration

| Question | Answer | Anchor |
|---|---|---|
| Do you use data from this app to track the user? | **No** | No third-party SDKs; no advertising network; no analytics partner; no ASIdentifierManager surface |
| Are any data types linked to user identity? | **No** | Per the matrix above — no data types are collected |

## Age bracket

| Question | Answer |
|---|---|
| App contains content suitable for children? | **Yes** |
| Target age range | **9-12** (with parent / educator co-use for 5-8 and self-directed for 13-14) |
| Made for Kids category opt-in? | **TBD** — see `Docs/APP_STORE_KIDSAFE_PLAN.md` for the Kids Category posture |

If we opt INTO the Made for Kids category, Apple enforces the same "Data Not Collected" posture we already maintain. If we opt OUT (and just ship as a "Kids" age bracket within the Education category), the posture is identical but Apple's category-level moderation differs.

## COPPA-2026 confirmation

Per `.claude/rules/age-assurance.md` § "2026 FTC COPPA Rule Amendments" (effective 2026-04-22):

- ✅ **Opt-in default for ad data sharing** — we don't share. Anchor: no `IDFA` surface; no third-party SDK.
- ✅ **Separate verifiable parental consent flows** — `ParentalConsentService` with 12-month expiry; `ParentalGateChallenge` shared math gate.
- ✅ **Defined data retention periods** — SwiftData is on-device; no server retention. UserDefaults flags (`dq.profile.name`, `dq.publishedTreeCount`, `dq.parentalConsentGrantedAt`, `dq.streak.*`, `dq.scaffolding.*`, `dq.retention.*`, `dq.analytics.*`) are all local-only and tied to app installation.
- ✅ **Written security program** — anchored to `Libraries/Sources/AppFeature/Settings/PrivacyPolicyView.swift` plain-language summary + this doc.

## App Privacy form — recommended answers

When the App Store Connect submission session opens the "App Privacy" form, the recommended answers are:

1. **"Do you or your third-party partners collect data from this app?"** → **No**
2. The form skips all data-type detail screens after a top-level No.
3. **"Do you use data to track the user?"** → **No**
4. Privacy policy URL → external Spark & Anvil studio site privacy page (when shipped; for now, link to the in-app `PrivacyPolicyView` rendered as an external HTML mirror).

## What this doc does NOT cover

- The KIDSAFE / Kids Category opt-in decision — see `Docs/APP_STORE_KIDSAFE_PLAN.md`
- The per-feature parental gate inventory — see `Docs/AUDIT_PARENTAL_GATES_2026-06-23.md`
- The trauma-informed content posture — see `.claude/rules/trauma-informed-content.md` (portfolio rule)
- Apple's standard at-the-OS-level diagnostics opt-in (handled by iOS Settings → Privacy & Security → Analytics, outside the app's control)

## Cross-references

- `Libraries/Sources/AppFeature/Settings/PrivacyPolicyView.swift` — in-app plain-language policy
- `Libraries/Sources/Services/Privacy/ParentalConsentService.swift` — consent record + 12-month expiry
- `Libraries/Sources/Services/Privacy/ParentalGateChallenge.swift` — shared math-challenge gate
- `Libraries/Sources/Services/Analytics/DialogueQuestAnalytics.swift` — on-device-only event vocabulary (closed-set categorical)
- `Libraries/Sources/Services/Analytics/RetentionMetricsService.swift` — local D1/D7/D30 booleans, no outbound
- `.claude/rules/age-assurance.md` — portfolio age-assurance + COPPA rules
- `Docs/APP_STORE_KIDSAFE_PLAN.md` — Made for Kids category compliance plan (companion doc)
- `Docs/AUDIT_PARENTAL_GATES_2026-06-23.md` — parental gate inventory (companion doc)
