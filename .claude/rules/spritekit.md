# SpriteKit Patterns

## Scene Architecture

- Subclass `SKScene` for each distinct game mode/screen
- Initialize scenes as **computed properties** with explicit size configuration
- Match `SpriteView` frame dimensions to scene size to prevent distortion
- Use `SKSceneDelegate` when sharing logic across multiple scenes
- Organize complex scenes with **layer nodes** (background, gameplay, HUD layers)
- Use a **single root `SKNode`** as scene graph container — add children to it, not directly to the scene

## Performance

- Set `view.ignoresSiblingOrder = true` on `SKView` to enable draw-call batching; use explicit `zPosition` instead
- Group textures into **texture atlases by usage context** (one atlas per scene/level), not one giant atlas
- Call `SKTexture.preload(_:withCompletionHandler:)` before scene transitions to avoid mid-gameplay hitches
- Keep `SKPhysicsBody` shapes simple — use `circleOfRadius` or `rectangleOf` over `init(texture:)` which generates per-pixel bodies
- Switch `preferredFramesPerSecond` between 60 (gameplay) and 30 (menus/pause) to reduce energy impact
- Use `blendMode = .replace` on fully opaque sprites to skip alpha compositing

## Dark Mode & Colors

- Use `SKColor.label`/`.secondaryLabel` for text colors (auto-adapt to dark mode)
- Never use hardcoded `SKColor(white:)` for text

## Lazy Visual Setup (SPM Testability)

SpriteKit nodes that create child `SKShapeNode`/`SKLabelNode`/`SKSpriteNode` in `init()` crash in headless SPM test targets (no GPU context). Use the `configureVisuals()` pattern:

```swift
class MyNode: SKNode {
    private var hasSetupVisuals = false

    func configureVisuals() {
        guard !hasSetupVisuals else { return }
        hasSetupVisuals = true
        // Create child nodes here, not in init()
        let shape = SKShapeNode(rectOf: CGSize(width: 100, height: 50))
        addChild(shape)
    }
}
```

Call `configureVisuals()` AFTER `addChild(node)` in the scene — never in the node's `init()`. This allows unit tests to instantiate and test node logic without GPU access.

## SwiftUI + SpriteKit Bridge

- **Weak delegates require stored references** — `SKScene` delegate properties are typically `weak`. When bridging SpriteKit scenes to SwiftUI via a bridge object, hold the bridge in `@State` or it deallocates immediately:
```swift
@State private var sceneBridge = SceneBridge() // Must be @State, not a local
```
- **SpriteView does not reactively swap scenes** — create the scene once and mutate it, or use `.id()` to force recreation
- **Pause offscreen scenes** — SpriteKit physics/actions continue running when `SpriteView` is offscreen unless explicitly paused

## SpriteView layout cascade — safe area, scaleMode, overlay collisions (R168 #601; lifted from CQ PR #147 2026-05-29)

When a SpriteKit scene's content renders crammed at the top with empty space below, sliders clip the left edge, or controls overlap a SwiftUI floating header, the cause is usually **3 shared-layer bugs**, NOT N per-scene issues. Fix the 3 layer files → all inheriting scenes inherit the correction.

### Symptom

| What you see | Layer responsible |
|---|---|
| SpriteKit-drawn title overlaps SwiftUI floating header / close button | SwiftUI overlay container — needs `safeAreaInset` |
| Scene reflows wrong on orientation change / split view | `SpriteView`'s scene `scaleMode` defaults to `.fill` — needs `.resizeFill` + `didChangeSize(_:)` hook |
| Sliders clipped on left edge / controls render in top portion | Base-scene `topMargin` / `bottomMargin` pixel literals too small for modern Liquid Glass chrome (~80pt floating header + safe area) |

### Root cause #1 — SwiftUI overlay collision (use `safeAreaInset` not `ZStack` overlay)

```swift
// ❌ Anti-pattern — SpriteView extends UNDER the floating header
ZStack {
    LinearGradient(...).ignoresSafeArea()
    VStack { simulationView }    // ← SpriteView edge-to-edge

    if !showResult {
        VStack {                 // ← Floating overlay
            HStack { topicCapsule; lumenButton; closeButton }
        }
    }
}

// ✅ Canonical — overlay reserves space via safeAreaInset
ZStack {
    LinearGradient(...).ignoresSafeArea()

    if showResult {
        resultView
    } else {
        simulationView
            .safeAreaInset(edge: .top, spacing: 0) {
                // floating header now lives in a reserved inset.
                // SpriteView no longer extends under it.
                floatingHeader
            }
    }
}
```

This is the canonical `safeAreaInset` use case per Apple's HIG: when SwiftUI overlay UI floats on top of another view, use `safeAreaInset(edge:alignment:spacing:)` to reserve the space. Without it, the underlying view doesn't know to stay clear.

### Root cause #2 — `scaleMode` defaults to `.fill` (use `.resizeFill` on iOS + `didChangeSize` hook)

```swift
// ❌ Anti-pattern — scaleMode never set on iOS → defaults to .fill
let created = sceneFactory(size)
#if os(macOS)
created.scaleMode = .aspectFit
#endif
scene = created   // iOS gets .fill — stretches scene coords on resize, mis-positions controls

// ✅ Canonical — explicit .resizeFill on iOS, scenes can re-layout
let created = sceneFactory(size)
#if os(macOS)
created.scaleMode = .aspectFit
#else
// .resizeFill keeps scene coords 1:1 with view + fires didChangeSize(_:)
// on resize so scenes can re-layout
created.scaleMode = .resizeFill
#endif
scene = created
```

Apple's `SKScene.scaleMode` docs explicitly recommend `.resizeFill` for SwiftUI integration when the scene calculates absolute positions based on `size.width` / `size.height`. With `.fill`, scene coordinates stretch on view resize — labels mis-position, sliders clip.

Add `didChangeSize(_:)` override on the base scene to recompute UI panel positions when the view resizes:

```swift
override func didChangeSize(_ oldSize: CGSize) {
    super.didChangeSize(oldSize)
    guard size != oldSize else { return }
    recomputeSimulationArea()
    repositionUIPanels()
}
```

### Root cause #3 — Base-scene margins too small for modern chrome

```swift
// ❌ Anti-pattern — pixel literals calibrated for pre-iOS-26 chrome
let topMargin: CGFloat = 60       // ← too small; ~80pt floating header + safe area clips content
let bottomMargin: CGFloat = 30    // ← OK if Liquid Glass TabBar lives below the SpriteView frame

// ✅ Canonical — accounts for SwiftUI floating overlays
let topMargin: CGFloat = 90       // clears typical SwiftUI floating header
let bottomMargin: CGFloat = 30    // unchanged if Fix #1 applied
```

Better still: receive insets from the SwiftUI wrapper (via scene userData or a setter) rather than hardcoding.

### "Look upstream before fixing N scenes" methodology rule

When a UI bug appears across "pretty much all" of a class of views, **look for the wrapper / base class / container before assuming N independent fixes**. A 5-minute audit of the SwiftUI wrappers (3 files) beats N per-scene tweaks.

**Rule for future sessions**: *Before fixing a visual issue in a scene, find the SwiftUI wrapper that presents it and the base class it inherits from. If the wrapper is reused or the base class is shared, the fix likely belongs there — not in the scene.*

CQ's reference impl (PR #147, 2026-05-29) fixed 3 files (SimulationContainerView + SceneContainer + PhysicsLabBaseScene) → propagated to 60+ physics labs. Per-scene fixes would have meant 208 PRs editing the same 3 numerical constants 208 times.

### Cross-references

- `labsmith/Docs/RESEARCH_SPRITEKIT_LAYOUT_SAFE_AREA_2026-05-29.md` — full CQ diagnostic trail + 7 external sources
- Apple Developer — [SpriteView](https://developer.apple.com/documentation/spritekit/spriteview) + [`SKScene.scaleMode`](https://developer.apple.com/documentation/spritekit/skscene/scalemode)
- `curiosityquest-app/Packages/Libraries/Sources/SharedUI/Lessons/SimulationContainerView.swift` (post-PR #147) — reference impl

## Resource Management

- Limit `SKEmitterNode` particle counts; remove finished emitters to prevent memory leaks
- Check `size.width > 0` before creating `SKScene` to avoid zero-size scene initialization (GeometryReader guard)

## Platform Status

- **SpriteKit is in maintenance mode** — no new API since ~iOS 10. Plan for GateForge/Godot contingency for future portfolio apps
- **iOS 26 SpriteKit framerate regression** — fixed in 26.2, regressed in 26.3/26.4. Monitor release notes for fixes
<!-- END LABSMITH-SYNCED CONTENT -->
