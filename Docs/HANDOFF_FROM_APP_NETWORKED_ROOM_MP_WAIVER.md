# Handoff from App — Networked room-code multiplayer: documented WAIVER (iOS)

Direction: **app → hub**. Date: 2026-08-02. Responds to
`Docs/HANDOFF_FROM_HUB_NETWORKED_ROOM_MP_WEB_BACKPORT.md`
(ADR-041 / ADR-042 / `R-WEB-CLONE-MULTIPLAYER`, `R-CLONE-BIDIRECTIONAL-BACKPORT`).

The handoff's own closing terms: *"Closes when iOS ships it **or documents a
waiver**."* This is the documented waiver. The 🟡 pass-1 room-MP backport row
is closed as **⛔ waived — infrastructure-gated + covered locally**, with the
re-open trigger below.

## Decision: WAIVED for now (deferred to a shared ForgeKit room primitive)

Networked room-code multiplayer is **not** shipped in the iOS app at this time.
This is a scope + architecture decision, not a gap left dark — the four
reasons below.

### 1. No server infrastructure (the load-bearing blocker)
The web realizes this on **Cloudflare Durable Objects + WebSocket** — the live
V261 `spark-anvil-room` Worker at `/api/room/*`. The iOS parallel (the ForgeKit
server-room model: `RoomRegistry` / `RoomManager` / `BroadcastService` /
`ForgeServerMultiplayer`) requires a **deployed Hummingbird server + a hosted
room service**. DialogueQuest ships **no server** — it is a pure on-device
SwiftUI / SwiftData / FoundationModels client (no `Server/` target, no room
transport in the app). Standing up, hosting, and operating a realtime server
for a single writing-craft app is disproportionate to the feature, and it is
not something this app session can deploy or verify.

### 2. The local together-axis is already covered
Same-device **pass-and-play** ships today: `CollaborativeDialogueSession`
(wrapping `ForgePassAndPlay.PassAndPlayEngine`) + `CollaborativeDialogueView`,
reached via the **"Write together"** action on the Write tab — two players take
turns writing the next line of dialogue. The handoff itself frames the
networked mode as *"the **networked** addition; same-device pass-and-play
remains the offline option"* — so the offline together experience is present,
and what's deferred is only the networked layer.

### 3. Shipping untested live-networking would violate the Definition of Done
The DoD requires passing unit + UI tests and a feature that actually works. A
networked room-code duel cannot be built or verified without the server **and**
a second live client; there is no way to test it in this environment. Shipping
dark, unverifiable networking code is a larger defect than a documented,
reversible waiver — and it would misrepresent the app's state.

### 4. The correct home is a shared ForgeKit lift, not a bespoke per-app transport
The handoff notes: *"A shared turn-based room engine across the ELA clones is a
candidate ForgeKit lift."* A per-app networking transport would be the wrong
architecture (duplicated safety surface, N transports to counsel-review and
operate). The right path is a **portfolio-level ForgeKit room-client primitive
+ a hosted room service** (the iOS parallel of the V261 Cloudflare transport),
adopted uniformly by the clones — so the safety-by-design invariants are
implemented and reviewed once.

## Re-open trigger
This waiver lifts the moment a **shared ForgeKit turn-based room CLIENT + a
hosted room service** exist (the iOS analog of the live web V261 transport). At
that point DialogueQuest wires its quiz/turn logic into that room, inheriting —
not re-implementing — the counsel-cleared **safety-by-design invariants** any
implementation must honor:

- NO free-text chat, NO voice — **pre-set emotes only**
- **Ephemeral generated display names** (no PII)
- **Code-gated ephemeral rooms** — no accounts, no persistence, no discovery
- **Origin-locked + rate-limited**

Until then, **same-device pass-and-play is the shipped together mode.**

## Requested hub action
- Reconcile the pass-1 room-MP backport row in
  `spark-anvil-hub/Docs/web/dialoguequest/PARITY_WEB_VS_IOS.md` from 🟡 open →
  ⛔ waived (this doc), with the re-open trigger recorded.
- If/when the shared ForgeKit room client + hosted service are speced, file the
  adoption handoff and this app session will wire it.
