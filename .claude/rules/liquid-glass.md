# Liquid Glass Patterns

## Automatic Adoption

Apps compiled against iOS 26 SDK automatically get Liquid Glass on: NavigationBar, TabBar, Toolbar, Sheets, Popovers, Menus, Alerts, Search bars, Toggles, Sliders, Pickers. No code changes required.

## New APIs

| API | Purpose |
|---|---|
| `.glassEffect(.regular, in: RoundedRectangle())` | Glass material on custom views |
| `.glassEffect(.regular.interactive())` | Interactive glass with lensing |
| `.buttonStyle(.glass)` | Glass-styled buttons |
| `.glassEffectID(_:in:)` | Link elements for morphing animations |
| `GlassEffectContainer(spacing:)` | Group views for visual merging |
| `.glassEffectUnion` | Merge two views into single glass shape |

## Tab Bar Behavior

Tab bars shrink on scroll to focus content, expand on scroll-back. Verify navigation layouts still work with collapsing behavior.

## ForgeUI Integration

- `ForgePrimaryButton` supports `.buttonStyle(.glass)` — use for primary actions
- `ForgeCard` has glass variant via `.glassEffect()` — use for quiz cards, score displays
- Game HUD overlays should use `.glassEffect(.regular)` for visual consistency

## Guidelines

- Use glass effects on floating overlays, HUDs, and interactive cards
- Don't apply glass to backgrounds or full-screen content — it's for elevated elements
- Glass morphing (`.glassEffectID`) works between navigation transitions — use for seamless tab/nav animations
- Respect `.glassEffectTransition` for Reduce Animations accessibility setting
- Icon Composer (standalone app) creates Liquid Glass icons with light/dark/tinted/clear variants
<!-- END LABSMITH-SYNCED CONTENT -->
