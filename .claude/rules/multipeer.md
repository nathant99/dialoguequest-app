# MultipeerConnectivity / Local Multiplayer Patterns

Conventions for portfolio apps using local peer-to-peer multiplayer. Based on production patterns in CuriosityQuest, CubeSensei, and QuillSpell.

## Transport Choice

The portfolio has three local multiplayer transports in production:

| Transport | When To Use | Example |
|---|---|---|
| **MultipeerConnectivity** (MCSession) | True P2P mesh, kids playing together, Bluetooth fallback needed | CuriosityQuest, CubeSensei |
| **Network framework** (NWBrowser/NWListener) | Host-and-clients, LAN/Wi-Fi only, debugging visibility needed | QuillSpell |
| **SharePlay / GroupActivities** | FaceTime/Messages participants, Apple handles identity | CubeSensei, QuillSpell |

Use `ForgeMultipeerKit` (when extracted) with the appropriate backend. Never mix backends in a single app without a strong reason.

## MultipeerConnectivity (MCSession) Rules

### Threading

1. **MCSessionDelegate callbacks run on background threads** — Always use `DispatchQueue.main.async { [weak self] in ... }` to handle them. NOT `Task { @MainActor in ... }` — race condition with `@Observable` registrar.

```swift
public nonisolated func session(_ session: MCSession, didReceive data: Data,
                              fromPeer peerID: MCPeerID) {
    DispatchQueue.main.async { [weak self] in
        // safe to mutate @Observable state here
    }
}
```

### Service Type

2. **Service type must be lowercase, ≤15 chars, ASCII letters/numbers/hyphens only**:
   - Good: `"curiosityquest"`, `"cubequest"`, `"mathlore"`
   - Bad: `"CuriosityQuest"`, `"my-app-name-too-long"`

3. **Must match Info.plist**:
   ```xml
   <key>NSBonjourServices</key>
   <array>
       <string>_yourservice._tcp</string>
       <string>_yourservice._udp</string>
   </array>
   ```

### Permissions

4. **Always declare `NSLocalNetworkUsageDescription`**:
   ```xml
   <key>NSLocalNetworkUsageDescription</key>
   <string>{{ App }} uses the local network to find nearby players for multiplayer.</string>
   ```
   Without it, iOS 14+ refuses Bonjour discovery silently.

### Discovery Roles

5. **Enforce role asymmetry in app layer** — MCNearbyServiceBrowser + MCNearbyServiceAdvertiser see each other; without role rules, peers self-invite. Convention:
   - Host = browser only
   - Joiner = advertiser only
   - Never both simultaneously on same device

### Encryption

6. **Use `.optional` encryption for kids' LAN play** — `.required` adds CPU cost on older iPads. LAN is already isolated from internet.

### Session Lifecycle

7. **Store session in `@State` or view-model** — never inline:
   ```swift
   // ❌ Wrong: session deallocates before view body
   ForgeMultipeerLobby(session: ForgeMultipeerSession(...))

   // ✓ Right: session lives as long as view
   @State var session = ForgeMultipeerSession(...)
   ```

### Message Protocol

8. **Use tagged-union Codable enum with `{type, payload}` JSON envelope**:
   ```swift
   enum MyGameMessage: Codable, Sendable {
       case peerInfo(PeerInfoMessage)
       case answerEvent(AnswerEventMessage)
       // ...
       private enum CodingKeys: String, CodingKey { case type, payload }
   }
   ```

9. **Inject `senderId` post-decode from `MCPeerID.displayName`** — don't trust client-supplied senderId in payload.

10. **TaggedEvent wrapper for SwiftUI `onChange` reliability**:
    ```swift
    struct TaggedAnswerEvent: Equatable {
        let peerId: String
        let event: AnswerEventMessage
        let sequence: Int  // unique per message; SwiftUI requires for onChange to fire
    }
    ```

### Reconnect & Rematch

11. **Don't transition state on `battleSetup` while already `.inBattle`** — rematch reconnect path causes spurious state regression.

12. **Host rotation: use `connectedPeerNames` (filtered current state), NOT `peerInfoMap` (may contain stale entries)**.

## Network Framework (NWBrowser/NWListener) Rules

13. **Bonjour service type must match between host and browser**:
    ```swift
    let listener = try NWListener(using: params)
    listener.service = NWListener.Service(name: "Game", type: "_quillspell._tcp")

    let browser = NWBrowser(for: .bonjour(type: "_quillspell._tcp", domain: "local"), using: params)
    ```

14. **TCP is stream-based — frame messages with length prefix**:
    ```swift
    // 4-byte big-endian length + JSON payload
    func encode<T: Encodable>(_ msg: T) throws -> Data {
        let body = try JSONEncoder().encode(msg)
        var length = UInt32(body.count).bigEndian
        var packet = Data(bytes: &length, count: 4)
        packet.append(body)
        return packet
    }
    ```

15. **Enable peer-to-peer when needed**:
    ```swift
    let params = NWParameters.tcp
    params.includePeerToPeer = true  // allows P2P Wi-Fi without infrastructure
    ```

16. **Map errors to user-friendly messages**:
    - `POSIXErrorCode.ECONNREFUSED` → "Couldn't connect to host"
    - `PolicyDenied` (65555) → "Local Network permission required"
    - Generic timeout → "Took too long to find host"

## SharePlay (GroupActivities) Rules

17. **Conform to `GroupActivity` protocol** — `metadata` provides title/subtitle to FaceTime overlay.

18. **Use `GroupSession.messenger` for synchronized state** — built-in retry/ordering.

19. **No manual peer discovery needed** — Apple's GroupSession handles it. Participants are already on FaceTime/Messages.

20. **Document iOS 15+ requirement** — feature must gracefully degrade if pre-iOS 15.

## COPPA Compliance (All Transports)

21. **No PII in messages** — peer ID = displayName only (≤20 chars, no email patterns):
    ```swift
    public static func sanitize(_ name: String) -> String {
        return String(name.prefix(20))
            .replacingOccurrences(of: "@.*", with: "", options: .regularExpression)
    }
    ```

22. **No free text** — use enum-based message types only. Whitelist emotes (5 pre-defined max).

23. **Message buffers cleared on disconnect** — never persist past session end.

24. **Anonymize peer names option for child accounts**:
    ```swift
    config.anonymizePeerNames = true  // shows "Player 1" instead of real display name
    ```

## Anti-Cheat (Optional, From QuillSpell)

25. **Server-authoritative validation** — never trust client computation. Validate answers/scores on the host.

26. **Timing checks** — `< 0.3s per character` for spelling, similar heuristics for other types:
    ```swift
    let minPlausibleTime = Double(complexity) * 0.3
    if elapsed < minPlausibleTime { flagSuspicious() }
    ```

27. **Pattern checks** — perfect streaks >30 rounds are statistically unlikely; flag for review.

28. **Whitelisted display names** — reject Unicode tricks, profanity, full names.

## Known Issues to Watch

- **visionOS 26.0 betas**: iPad↔visionOS MultipeerConnectivity connection regression. Test on real hardware.
- **iOS 26.2+ GameCenter**: Leaderboard submission broken; turn-based matchmaker not showing existing matches. Implement local cache + retry.
- **MultipeerConnectivity opaque errors**: `MCSessionStateNotConnected` doesn't say why. Log raw error codes; don't show to kids.
<!-- END LABSMITH-SYNCED CONTENT -->
