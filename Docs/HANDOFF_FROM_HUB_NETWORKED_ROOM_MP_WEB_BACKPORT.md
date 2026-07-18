# Handoff to DialogueQuest — Networked room-code multiplayer (web-pioneered → iOS backport)

Direction: **hub → app**. Date: 2026-07-18. Filed per **R-CLONE-BIDIRECTIONAL-BACKPORT** (the web clone
pioneered the surfaced networked mode; the iOS session decides implementation — hub never writes Swift).
ADR-041 / ADR-042 / R-WEB-CLONE-MULTIPLAYER.

## The feature

**Networked room-code multiplayer** — a host mints a short room code, a peer joins by code, and the two play a
turn-based DialogueQuest quiz-duel over a live connection (an "Online room" tab inside the clone's versus surface).
This is web parity for the iOS ForgeKit server-room model, realized on **Cloudflare Durable Objects + WebSocket**
(the DO name = the room code = the room's single authority + server-authoritative fan-out; Hibernation-cheap).

**Safety by design (hard, non-waivable invariants — counsel-cleared on this basis, ADR-041):** NO free-text chat,
NO voice (pre-set emotes only) · ephemeral generated display names (no PII) · code-gated ephemeral rooms (no
accounts, no persistence, no discovery) · origin-locked + rate-limited. Same-device **pass-and-play** remains the
offline option; this is the *networked* addition.

## Web reference implementation

- `spark-anvil-site/src/lib/play/_shared/roomMode.ts` — the shared networked alternating-turn quiz over the LIVE
  V261 room transport (`spark-anvil-room` Worker + `Room` Durable Object at `/api/room/*`).
- `spark-anvil-site/src/lib/play/dialoguequest/roomVersus.ts` + the flag-gated "Online room" tab inside the clone's
  `versus` route (`ROOM_MODE_ENABLED`, LIVE since site PR #786).
- Shared question set derived deterministically from stable ids on both peers (no seed on the wire).

## Proposed iOS surface

The iOS app already has the ForgeKit server-room primitives (`RoomRegistry`/`RoomManager`/`BroadcastService`/
`ForgeServerMultiplayer`). If DialogueQuest does not yet surface a networked room-code duel, add one wrapping its
quiz/turn logic in a ForgeKit room, inheriting the safety-by-design invariants (no chat/voice, ephemeral names,
code-gated rooms). A shared turn-based room engine across the ELA clones is a candidate ForgeKit lift.

## Status
🟡 open — built web-first + handoff filed. Closes when iOS ships it or documents a waiver. Tracked in
`spark-anvil-hub/Docs/web/dialoguequest/PARITY_WEB_VS_IOS.md` (pass-1 room-MP backport row).
