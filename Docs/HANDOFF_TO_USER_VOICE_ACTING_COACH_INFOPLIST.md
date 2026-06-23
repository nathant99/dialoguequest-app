---
status: ACTIVE
date: 2026-06-23
direction: agent → user
audience: Nghi (Xcode operator)
intent: add `NSMicrophoneUsageDescription` + `NSSpeechRecognitionUsageDescription` Info.plist keys so the voice-acting coach can listen to a kid reading a line and score the read against a character's voice baseline
freshness-horizon: 60 days
---

# Handoff to User — Voice-Acting Coach Info.plist usage descriptions

The agent cannot author or edit `Apps/DialogueQuest/DialogueQuest/Info.plist` (or any synthesized Info.plist surface via Xcode's project editor) per `@.claude/rules/xcode-agent-safety.md`. The voice-acting coach feature requires TWO Info.plist usage descriptions before the active path can be wired without iOS hard-crashing the process on first use.

## Why this matters

Per `@.claude/rules/warnings.md` § "Privacy-Gated Frameworks": iOS hard-crashes the process with `"This app has crashed because it attempted to access privacy-sensitive data without a usage description"` the moment any of these APIs is invoked without the matching Info.plist key:

- `AVAudioApplication.requestRecordPermission()` / `AVAudioEngine.inputNode` (microphone)
- `SFSpeechRecognizer.requestAuthorization()` (speech recognition)

The crash is not a Swift exception and cannot be caught. The Swift-side scaffold (`Libraries/Sources/Services/Audio/VoiceActingCoachService.swift`) gates every entry point on a static-let probe of both keys — when missing, the service stays in `.notWired` and every public surface is a safe no-op. So the feature ships dark today; this handoff turns it on.

## What you need to do in Xcode (~5 min)

### Step 1 — Add the microphone usage description

1. Open `DialogueQuest.xcworkspace` in Xcode
2. Select the `DialogueQuest` project in the Project Navigator
3. Select the `DialogueQuest` app target
4. **Info** tab (Xcode 26 surfaces Info keys as a target-level table, not a separate file)
5. Click the **+** at the bottom of the Custom iOS Target Properties section
6. Add this key:

| Key | Type | Value |
|---|---|---|
| `NSMicrophoneUsageDescription` | String | `DialogueQuest listens to you reading a character's line so it can show how close your voice sounded to that character. Recordings stay on this device and are deleted after each session.` |

### Step 2 — Add the speech-recognition usage description

Same target → **Info** tab → **+** again:

| Key | Type | Value |
|---|---|---|
| `NSSpeechRecognitionUsageDescription` | String | `DialogueQuest converts your voice to text on this device so it can score how close your read matched the character's voice. The text never leaves this device.` |

### Step 3 — (Future) Add the on-device-only recognition opt-in

Apple's HIG recommends declaring on-device-only speech recognition explicitly for kid apps. This isn't gated by an Info.plist key — the agent will set `SFSpeechRecognizer.requiresOnDeviceRecognition = true` in code when the active path lands in a follow-up PR. No GUI work needed for this step.

### Step 4 — Verify

After saving the Info tab, `git status` should show `M Apps/DialogueQuest/DialogueQuest.xcodeproj/project.pbxproj` (Xcode 26 stores Info keys in the pbxproj's `INFOPLIST_KEY_*` build-setting form). The agent can `git add` + `git commit` per the Xcode-safety carve-out (staging GUI diffs is fine — the rule is about authoring content from disk).

Once committed, the next agent session can:

1. Re-run `VoiceActingCoachServiceTests.isWiredMatchesAvailability` — it will assert `availability != .notWired`.
2. File a follow-up PR that wires the active path: `AVAudioApplication.requestRecordPermission()` + `SFSpeechRecognizer` + the AVAudioNodeTap TWO-PART rule per `@.claude/rules/concurrency.md`.
3. Add the live UI surface (record button + scored result) under the existing `PerformanceBoothView` or as a sheet from `WriteTabView`.

## Why this is a handoff and not an agent edit

- The Xcode 26 Info-key table is a project-editor surface. The on-disk representation is `Apps/DialogueQuest/DialogueQuest.xcodeproj/project.pbxproj` (build-setting form) which is in the agent's forbidden-globs list per `@.claude/rules/xcode-agent-safety.md`. Writing the pbxproj from disk risks the External-Changes dialog or workspace reload that terminates the agent session.
- The active speech-recognition path also benefits from a parent-pinned opt-in checkbox that lives next to the existing parental-consent UI. That UX work can land in code (agent-author OK) once the Info.plist work above is complete.

## Scope boundary

This handoff covers ONLY the Info.plist usage description strings. It does NOT cover:

- App Sandbox / hardened runtime entitlements (microphone access on iOS doesn't require an entitlement; macOS would).
- Family Controls entitlement — separately handled by `@Docs/HANDOFF_TO_USER_DECLARED_AGE_RANGE_API.md`.
- Privacy nutrition label updates — separately tracked under Phase 4 § App Store submission.

## Cross-references

- `Libraries/Sources/Services/Audio/VoiceActingCoachService.swift` — Swift scaffold
- `Libraries/Tests/ServicesTests/VoiceActingCoachServiceTests.swift` — 9 tests covering the privacy-gated probe + Jaccard scoring + reader-register stoplist
- `@.claude/rules/warnings.md` § Privacy-Gated Frameworks — the rule that drove the static-let probe pattern
- `@.claude/rules/concurrency.md` § "AVAudioNodeTap closures — TWO-PART rule" — pattern the future active path will follow
- `@Docs/FEATURE_PLAN.md` Phase 3 row 144 — checkbox closed by the scaffold; active path lands as a follow-up
