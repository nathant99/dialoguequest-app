# Handoff from Hub — "Voice Crucible" (voice-consistency; web-adapted → confirm the iOS backport)

Direction: **hub → app**. A forward-port feature shipped on the `/play/dialoguequest` clone, web-ADAPTED from the iOS `VoiceCrucibleMachine`; this records the bidirectional reconciliation per R-CLONE-BIDIRECTIONAL-BACKPORT.

## What shipped on web (V792 forward-port BUILD, Round-4 W36)
`/play/dialoguequest/voice-crucible` — **Voice Crucible**, a structured-choice character-voice-CONSISTENCY drill (site PR #1653). It web-adapts the iOS `VoiceCrucibleMachine`, which the clone's parity ledger had **mis-waived as "mic-only / platform-only."** It is not a mic feature — it is a text voice-consistency analyzer, and it adapts cleanly to a **COPPA-clean structured-choice** surface (no free text, no mic, on-device).

- The craft gold-standard: **recognizability WITHOUT a name tag** — a distinct voice is identifiable with no dialogue tag.
- The learner sees a character's **established voice fingerprint** (2-3 lines they have already said + a one-line voice summary naming their diction / rhythm / register / emotional default), then picks the **new line that still sounds like them**.
- Every wrong option **breaks one NAMED voice component** (e.g. "the register — that is a grown-up formal voice, not a shy kid"; "the rhythm — clipped bursts, not long sentences"), so the reveal teaches the specific slip.
- Distinct from "Write It in Character" (`inCharacter.ts`), which picks the best line for a MOMENT/scene. Voice Crucible tests **consistency** of an already-established voice across lines.

Reference impl (pure, deterministic, engine⇔bank Vitest-pinned): `spark-anvil-site/src/lib/play/dialoguequest/voiceCrucible.ts` + `.test.ts`. 6 invented characters, each with a distinct voice fingerprint.

## Bidirectional note (R-CLONE-BIDIRECTIONAL-BACKPORT)
The iOS `VoiceCrucibleMachine` already exists (text similarity). This handoff (a) corrects the web ledger's "mic-only" mis-waiver, and (b) offers the web's **structured-choice adaptation** as a candidate for the iOS surface where a mic/free-text approach is undesirable for the COPPA/on-device posture — a pick-the-in-voice-line choice is fully deterministic + kid-safe. The app session decides whether to adopt the structured form or keep the analyzer; if the iOS surface stays analyzer-based, keep the two conceptually in sync (both teach voice consistency).

## Suggested iOS shape (the app's own CC session writes the Swift — hub never writes Swift)
- A SwiftUI surface: the voice-fingerprint card (character + established lines + voice summary), then a pick-the-in-voice-line choice; reveal names the broken component on a wrong pick. Reuse the app's MC + feedback primitives.
- Port the `VOICE_DECK` content (6 characters) as the structured bank if adopting the choice form.
- Keep articulate-before-hint (no hint before a first wrong pick).

Filed 2026-08-04 · hub forward-port BUILD Round-4 W36 · tracked in `spark-anvil-hub/Docs/REGISTRY_WEB_CLONE_FORWARD_PORT_FEATURES.txt`.
