# Warning Prevention Conventions

Learned from CuriosityQuest. Maintain zero-warning builds.

## Swift Concurrency Warnings

1. **`@Model` + Codable isolation** — Never call `JSONDecoder.decode()`/`JSONEncoder.encode()` inside `@Model` computed properties. Add `nonisolated static func decode(from:)` and `nonisolated func encode()` helpers on the Codable struct instead. Mark the struct `Sendable`
2. **Captured `self` in Tasks** — Use `Task { @MainActor [weak self] in }` (capture list on Task, not just outer closure)
3. **Captured vars in Tasks** — Create a local `let` before the Task: `let currentScene = scene; Task { @MainActor in currentScene?.method() }`
4. **`VersionedSchema.versionIdentifier`** — Must be `static let`, not `static var` — global mutable state is a concurrency error
5. **`nonisolated` on `@MainActor` class members** — Don't annotate `static let` as `nonisolated` if the closure captures `@MainActor`-isolated types — let it inherit the class isolation
6. **Unnecessary `await`** — Don't `await` synchronous methods even on `@MainActor` classes when already on the main actor

## Bundle Size

### Audio SFX (.caf files)

- **Mono, sub-1-second, 44.1 kHz, 16-bit PCM** — SFX clips must be short mono sounds (10–80 KB). Never ship the full source track as a CAF
- **No duplicate formats** — `SFXPlayer` loads `.caf` only. Never include `.mp3` copies of the same SFX in the bundle
- **Pipeline**: Python wave synthesis → WAV (44100 Hz, mono, 16-bit) → `afconvert -f caff -d LEI16` → `.caf`
- **Size budget**: Individual SFX ≤ 100 KB. Total SFX folder ≤ 2 MB

### Image Assets

- **Size images for max display resolution** — Check the largest `frame(width:height:)` in code, multiply by 3 for @3x. Don't ship 1024x1024 images that display at 140pt (420px @3x max)
- **Avatar backgrounds/frames**: max 512x512 (displayed at ≤140pt = 420px @3x)
- **Avatar accessories**: max 256x256 (displayed at ≤70pt = 210px @3x via `size * 0.5`)
- **Accessories need alpha** — Accessories overlay the avatar face, so PNGs must have transparent backgrounds. Verify with `sips -g hasAlpha`
- **Before adding new image assets**: check dimensions with `sips -g pixelWidth -g pixelHeight` and verify they match the size budget above

## Type-Check Performance (100ms limit)

1. **Long SwiftUI modifier chains** — Split into separate computed properties
2. **Large struct literals with inline closures** — Pre-compute array maps as local variables before the init call
3. **`#Predicate` macros** — Extract to a separate `let predicate = #Predicate<T> { ... }` line
4. **General rule** — If a single expression has >3 chained method calls or >5 arguments with closures, break it up
5. **Adding imports to complex views** — Adding a new `import` (e.g., `import CQModels` during SPM migration) increases the type resolution search space. Views with large `body` expressions that were previously within the 100ms limit may start timing out. Fix: extract sub-expressions into computed properties (`private var mainTabView: some View`, `private var startupOverlayContent: some View`, etc.)

## Deprecated APIs

- **`UIScreen.main`** (deprecated iOS 26) — Use `UITraitCollection.current.displayScale` for `ImageRenderer.scale`

## Non-Obvious Import Requirements

- **`import Foundation`** — Required for `String.replacingOccurrences(of:with:)` and other `NSString`-bridged methods. Compiler error is misleading ("value of type 'String' has no member...")
- **`import UniformTypeIdentifiers`** — Required for `.png`/`.jpeg` content types in `Transferable` conformance

## Platform Availability

- **`fullScreenCover` unavailable on macOS** — Use `#if os(iOS) || os(visionOS)` guard, fall back to `.sheet` on macOS
- **`.keyboardType(.numberPad)` is iOS-only** — guard with `#if os(iOS)` for multi-platform builds
- **`.navigationBarTitleDisplayMode(.inline)` is iOS-only** — guard with `#if os(iOS)` for multi-platform builds
- **`.xcstrings` symbol collision** — Two localization keys differing only in capitalization (e.g., "New Personal Best!" vs "New personal best!") generate the same symbol — use identical casing or remove one

## Name Collisions

- **`Foundation.Expression`** (iOS 18+) collides with custom `Expression` types — in modules that import both Foundation and a module defining `Expression`, qualify as `ModuleName.Expression`

## Build System

- **Concurrent `xcodebuild` commands lock the build database** — Never run two `xcodebuild` commands in parallel against the same DerivedData. Use MCP `BuildProject`/`RunSomeTests` instead, or run sequentially

## Privacy-Gated Frameworks (Info.plist usage descriptions)

iOS hard-crashes the process with `"This app has crashed because it attempted to access privacy-sensitive data without a usage description"` the moment a privacy-gated API is invoked without the corresponding `Info.plist` key. The crash is not a Swift exception and cannot be caught. **Always** gate access via a cached `Bundle.main.object(forInfoDictionaryKey:) as? String` check — when empty/nil, every entry point becomes a no-op so the app doesn't crash. Reference impl (curiosityquest-app): `Packages/Libraries/Sources/Services/SpeechRecognitionService.swift` § `hasMicrophoneUsageDescription`. Per `xcode-agent-safety.md`, the agent cannot write `Info.plist` from disk — user must add the description via Xcode GUI (target → Info tab) when the gated feature is actually desired.

| Framework / API | Info.plist key | Notes |
|---|---|---|
| `AVAudioApplication.requestRecordPermission()`, `AVAudioSession(.record / .playAndRecord)`, `AVAudioEngine.inputNode` | `NSMicrophoneUsageDescription` | Voice input, audio capture. |
| `SFSpeechRecognizer`, `SFSpeechURLRecognitionRequest` | `NSSpeechRecognitionUsageDescription` | Add defensively alongside microphone even when using on-device alternatives (WhisperKit, etc.) — App Store review expects both keys when either framework is linked. |
| `NWBrowser`, `MultipeerConnectivity`, any Bonjour discovery | `NSLocalNetworkUsageDescription` + `NSBonjourServices` array | See `multipeer.md` for service-type naming rules. |
| `AVCaptureDevice` (camera) | `NSCameraUsageDescription` | Camera-based features. |
| `CLLocationManager` | `NSLocationWhenInUseUsageDescription` | Location. |
| `EKEventStore` (Calendar) | `NSCalendarsUsageDescription` | Calendar. |

Also: `@Observable` classes cannot use `lazy var` for stored properties — the macro rewrites `var` into accessor pairs which is incompatible with `lazy` storage. Use `@ObservationIgnored private lazy var` to opt the property out of observation tracking.

## Entitlement-Gated Frameworks

- **`NSUbiquitousKeyValueStore.default`** — Any access (read, write, or `.synchronize()`) traps the process with `BUG IN CLIENT OF KVS: Trying to initialize NSUbiquitousKeyValueStore without a store identifier` + `_dispatch_assert_queue_fail` + `EXC_BREAKPOINT` when the binary lacks the `com.apple.developer.ubiquity-kvstore-identifier` entitlement. The trap is from libdispatch and cannot be caught by Swift. **Always** gate access via a cached `static let` entitlement probe. The `SecTask*` C symbols are NOT bridged through Swift's `import Security` umbrella on iOS (`import Security.SecTask` also fails — "No such module"), so the working pattern is `dlsym(RTLD_DEFAULT /* (-2) */, "SecTaskCopyValueForEntitlement")` plus `dlsym(... "SecTaskCreateFromSelf")`, then `unsafeBitCast` to `@convention(c)` typealiases. When unavailable, make every public KV method a no-op so the app doesn't crash. Reference impl (curiosityquest-app): `Packages/Libraries/Sources/Services/PurchaseReceiptService.swift` § `isUbiquityKVStoreAvailable`. Per `xcode-agent-safety.md`, the agent cannot write `.entitlements` files from disk — user must wire the entitlement via Xcode GUI when iCloud-KV is actually desired.
- **`CKContainer`, `NSFileCoordinator` for iCloud Drive, HomeKit, HealthKit, App Groups** — same pattern: entitlement-gate access at the service singleton's static-let level; no-op when missing.

## Code Quality

- **Unused results** — Use `_ =` for intentionally discarded results; remove truly unused `let` bindings
- **Redundant nil coalescing** — Don't use `?? default` on non-optional values
- **Unused guard bindings** — `guard y != nil` not `guard let x = y` when x is unused
<!-- END LABSMITH-SYNCED CONTENT -->
