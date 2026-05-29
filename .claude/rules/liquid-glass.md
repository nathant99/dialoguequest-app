# Liquid Glass Patterns

## Automatic Adoption

Apps compiled against iOS 26 SDK automatically get Liquid Glass on: NavigationBar, TabBar, Toolbar, Sheets, Popovers, Menus, Alerts, Search bars, Toggles, Sliders, Pickers. No code changes required.

**⚠️ What can BLOCK automatic adoption** (audit these in every app):

- `.toolbarBackground(Color..., for: .tabBar)` / `.toolbarBackground(.thinMaterial, ...)` — explicit override replaces auto-glass
- `.toolbarColorScheme(.dark, for: .tabBar)` — color-scheme override
- `UITabBar.appearance().backgroundColor = ...` — UIKit-level override (often left over from pre-iOS-26 styling)
- `UITabBar.appearance().standardAppearance = ...` — same
- Custom `tabViewStyle` overrides
- `.background(Color...)` on a parent View that the system can't render through

**Audit grep** (run from app root):

```bash
grep -rn "toolbarBackground\|toolbarColorScheme\|UITabBar.appearance" Packages/Libraries/Sources/
```

Zero hits on app root TabView descendants is the canonical state. If you must tint tabs, use `.tint(palette.color)` on Tab destinations — this tints icons THROUGH the glass material rather than replacing it.

## New APIs

| API | Purpose |
|---|---|
| `.glassEffect(.regular, in: RoundedRectangle())` | Glass material on custom views |
| `.glassEffect(.regular.tint(.color))` | Tinted glass material |
| `.glassEffect(.regular.interactive())` | Interactive glass with lensing on tap |
| `.glassEffect(.regular.tint(.color).interactive())` | Tinted + interactive (most common nav-grid + button pattern) |
| `.buttonStyle(.glass)` | Glass-styled buttons |
| `.buttonStyle(.glassProminent)` | Prominent (filled-tint) glass button |
| `.glassEffectID(_:in:)` | Link elements for morphing animations |
| `GlassEffectContainer(spacing:)` | Group views for visual merging |
| `.glassEffectUnion` | Merge two views into single glass shape |
| `.glassEffectTransition` | Reduce Animations-respecting transition |

## Portfolio Hybrid Liquid Glass policy (R158 #590 generalization from ADR-015)

**4-category decision matrix** for portfolio apps. The load-bearing rule is **FUNCTION not visual style** — categorize each surface by what it DOES, not how it looks today.

### Load-bearing categorization rule

- **Content-display card** = the card IS the content. You READ/VIEW it; it's not a tap-to-drill-in affordance. KEEP SOLID.
- **Nav-grid card** = the card LINKS to deeper content. You TAP it to navigate. → GLASS.

If a card SHOWS information you read = solid fill. If a card LINKS to deeper content = interactive glass.

### Per-surface decision matrix

| Category | Surfaces | Treatment | Rationale |
|---|---|---|---|
| **A. Chrome / system** | TabBar / NavigationBar / Sheets / Popovers / Menus / Alerts / Search bars / Toggles / Sliders / Pickers | ✅ Glass — REMOVE any `toolbarBackground` / `toolbarColorScheme` / `UITabBar.appearance` / custom `tabViewStyle` override. Let iOS 26 SDK auto-render. | Apple HIG canonical; auto-adoption is FREE; opaque chrome reads as an override mistake |
| **B. Interactive controls** | Action buttons ("Tap to start" / "Submit" / "Continue" / Settings rows); active selector pills (grade chips / tab pills / filter chips); CTA cards | ✅ Glass via `.glassEffect(.regular.tint(palette).interactive())` or `.buttonStyle(.glassProminent)` | Interactive controls benefit from glass refraction signal; matches WWDC25 demo register |
| **C. Nav-grid cards** | Category grids that drill into deeper content (region/zone/subject pickers; 2×N nav grids; topic-list rows; collection rows; activity rows; lesson grids) | ✅ Glass via `.glassEffect(.regular.tint(palette).interactive(), in: .rect(cornerRadius: ...))` | These are navigation affordances per HIG "glass = nav layer" — NOT content display |
| **D. Content-display cards** | Hero cards (level + progress); joke/quote prompts; "Today's featured X" cards; stat cards (XP / Gold / Streak / Badges); article/topic body cards; result/score cards | ❌ KEEP solid fills using app's canonical palette tokens | HIG: "glass = nav, NOT content"; kid-readability + WCAG AA; brand register; dark-mode legibility |
| **E. Imagery** | Cast portraits / mascot illustrations / topic illustrations / joke illustrations / backdrops / icons | ❌ Not surfaces — no glass treatment | N/A |

### Code patterns

**TabBar restoration** (most common fix when chrome looks opaque):

```swift
// ❌ Anti-pattern — explicit override blocks Liquid Glass auto-adoption
TabView(selection: $selectedTab) {
    Tab(...) { ... }
}
.toolbarBackground(Color.brown, for: .tabBar)
.toolbarColorScheme(.dark, for: .tabBar)

// ✅ Canonical
TabView(selection: $selectedTab) {
    Tab(...) { ... }
    // no toolbarBackground / toolbarColorScheme / appearance overrides
}

// Tint tab icons through glass (OK):
Tab(QuestLanguage.profileTab, ...) {
    ProfileView(...)
        .tint(AppPalette.primary)  // tints icons through glass; doesn't replace material
}
```

**Nav-grid cards** (category C):

```swift
// ❌ Before — solid fill
CategoryCard(...)
    .padding()
    .background(AppPalette.forestGreen)
    .clipShape(RoundedRectangle(cornerRadius: 16))

// ✅ After — interactive tinted glass
CategoryCard(...)
    .padding()
    .glassEffect(
        .regular.tint(AppPalette.forestGreen).interactive(),
        in: .rect(cornerRadius: 16)
    )
```

**Interactive controls** (category B):

```swift
// Action button
Button("Tap to start") { ... }
    .padding(.horizontal, 16).padding(.vertical, 8)
    .glassEffect(
        .regular.tint(AppPalette.primary).interactive(),
        in: .capsule
    )
    .foregroundStyle(.white)

// Active selector pill
.glassEffect(
    .regular.tint(AppPalette.primary).interactive(),
    in: .capsule
)
// Inactive pills stay subtle — no glass; just text + spacing
.foregroundStyle(.secondary)
```

**Content cards** (category D — DO NOT touch):

```swift
// ✅ Keep solid pop for content
HeroCard(...)
    .padding()
    .background(AppPalette.warmAmber)  // solid fill, brand register
    .clipShape(RoundedRectangle(cornerRadius: 16))
```

### Anti-criteria (DO NOT)

- DO NOT convert content-display cards (hero / joke / topic / stat / score / article body) to glass — violates HIG content-layer rule
- DO NOT convert cast portraits / illustrations to glass — they're imagery
- DO NOT replace app's canonical palette tokens with system colors in content cards
- DO NOT use `.glassEffect()` on SpriteKit `SKNode`s — doesn't apply to scene rendering
- DO NOT add tint-darkening on dark-mode content cards — saturated palette IS correct for OLED legibility

### Accessibility requirements

For every glass surface adoption:

- **WCAG AA contrast** ≥ 4.5:1 for text on glass (tint alpha matters — test against both light + dark backgrounds)
- **`@Environment(\.accessibilityReduceTransparency)`** check — when enabled, replace `.glassEffect(...)` with solid tint material (no transparency, no blur)
- **`@Environment(\.accessibilityReduceMotion)`** check — disable `.glassEffectTransition` morphing when enabled
- **Test in dark mode + light mode** — glass renders differently against black vs cream backgrounds

```swift
@Environment(\.accessibilityReduceTransparency) var reduceTransparency

var body: some View {
    CategoryCard(...)
        .background(reduceTransparency ? AppPalette.forestGreen : Color.clear)
        .glassEffect(
            reduceTransparency ? .regular : .regular.tint(AppPalette.forestGreen).interactive(),
            in: .rect(cornerRadius: 16)
        )
}
```

### Adoption phasing recipe (for any portfolio app session)

1. **Phase 1 — TabBar fix (highest priority; biggest visual win; ~30 min)** — grep + remove `toolbarBackground` / `toolbarColorScheme` / `UITabBar.appearance` / custom `tabViewStyle` overrides on root TabView
2. **Phase 2 — Nav-grid cards (~1.5h)** — convert category C surfaces to `.glassEffect(.regular.tint(palette).interactive())`
3. **Phase 3 — Interactive controls (~1h)** — action buttons + active selector pills → glass
4. **Phase 4 — DON'T-TOUCH content cards** — explicit non-action; category D stays as-is

Per-app effort: ~3-4h. Reversibility HIGH (per-surface; each `.glassEffect()` modifier is a 1-line revert).

### Reference impl + cross-references

- `labsmith/Docs/ADR-015_CQ_HYBRID_LIQUID_GLASS_NATIVE.md` — original CQ-specific decision (now generalized here)
- `labsmith/Docs/RESEARCH_CQ_LIQUID_GLASS_ADOPTION_2026-05-29.md` — 18-source research synthesis behind the policy
- `labsmith/Docs/ADR-014_HYBRID_LIQUID_GLASS_WEBSITE.md` — parallel decision for the website (same hybrid principle)
- `labsmith/Docs/TEMPLATE_HANDOFF_FROM_LABSMITH_LIQUID_GLASS_HYBRID_ADOPTION.md` — per-app adoption-nudge handoff template

## Tab Bar Behavior

Tab bars shrink on scroll to focus content, expand on scroll-back. Verify navigation layouts still work with collapsing behavior.

## ForgeUI Integration

- `ForgePrimaryButton` supports `.buttonStyle(.glass)` — use for primary actions
- `ForgeCard` has glass variant via `.glassEffect()` — use for nav-grid surfaces (category C); NOT for body-content cards
- Game HUD overlays should use `.glassEffect(.regular)` for visual consistency

## Guidelines (general)

- Use glass effects on floating overlays, HUDs, and interactive cards (chrome + interactive + nav-grid)
- Don't apply glass to backgrounds or full-screen content — it's for elevated elements
- Glass morphing (`.glassEffectID`) works between navigation transitions — use for seamless tab/nav animations
- Respect `.glassEffectTransition` for Reduce Animations accessibility setting
- Icon Composer (standalone app) creates Liquid Glass icons with light/dark/tinted/clear variants
<!-- END LABSMITH-SYNCED CONTENT -->
