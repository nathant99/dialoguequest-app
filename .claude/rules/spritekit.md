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

## Resource Management

- Limit `SKEmitterNode` particle counts; remove finished emitters to prevent memory leaks
- Check `size.width > 0` before creating `SKScene` to avoid zero-size scene initialization (GeometryReader guard)

## Platform Status

- **SpriteKit is in maintenance mode** — no new API since ~iOS 10. Plan for GateForge/Godot contingency for future portfolio apps
- **iOS 26 SpriteKit framerate regression** — fixed in 26.2, regressed in 26.3/26.4. Monitor release notes for fixes
