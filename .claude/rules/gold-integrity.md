# Gold-Integrity (Anti-Farming) Rule

Portfolio-wide rule for apps that ship a gold-currency system. Codified Round 469 (2026-06-01) after CuriosityQuest's gold-integrity fix (PRs #194-#197, 2026-06-01) closed 4 gold-farming loopholes (campfire focus / multiplayer mini-game / trickster mode / single-player mini-game) by routing all flat-gold award sites through a per-activity diminishing curve that mirrors the existing XP-integrity curve.

## The principle

**Every flat gold-award site MUST share the per-activity diminishing curve already applied to XP.** A user who repeats the same activity should NOT earn the full base reward each time. The curve makes the first completion most rewarding (engagement + retention) while structurally preventing grinding (anti-farming).

| Repeat # | Multiplier |
|---|---|
| 1st (today) | 100% |
| 2nd (today) | 50% |
| 3rd (today) | 25% |
| 4th+ (today) | 10% |
| During activity cooldown | 0% |

Tracking is per-activity-key (e.g., `"math.fraction.quiz.kit3"`), not global. Each distinct activity has its own counter that resets at local-day rollover.

## API contract

The integrity service exposes two helpers. Apps must wire BOTH to close the loophole properly.

| Helper | Purpose | When to call |
|---|---|---|
| `adjustedGold(_:activity:settings:) -> Int` | Returns the curve-adjusted gold for a given base amount + activity key. Does NOT consume the daily XP cap (gold and XP share the per-activity counter but not the daily XP ceiling). | Wrap EVERY flat-gold-award expression. Replace `profile.goldCoins += 10` with `profile.goldCoins += integrityService.adjustedGold(10, activity:"...", settings:settings)`. |
| `recordAuxiliaryAward(activity:settings:)` | Bumps per-activity cooldown timestamp + daily repeat counter WITHOUT touching `dailyXPEarned`. | Call AFTER a gold-only award (no XP earned alongside) so the diminishing-returns curve advances. For activities that ALSO award XP via the canonical `recordCompletion`, do NOT also call this — `recordCompletion` already advances the counter. |

## Wiring patterns

### Pattern A — Gold awarded alongside XP

The activity already calls `recordCompletion` for the XP path. Add `adjustedGold` for the gold path; do NOT also call `recordAuxiliaryAward`:

```swift
let xpAwarded = integrityService.adjustedXP(baseXP, activity: activityKey, settings: settings)
let goldAwarded = integrityService.adjustedGold(baseGold, activity: activityKey, settings: settings)
profile.xpTotal += xpAwarded
profile.goldCoins += goldAwarded
integrityService.recordCompletion(activity: activityKey, xpAwarded: xpAwarded, settings: settings)
// Do NOT call recordAuxiliaryAward — recordCompletion already advanced the counter.
```

### Pattern B — Gold-only award (no XP earned)

Some activities award only gold (campfire focus minutes; multiplayer mini-game wins; trickster-mode discoveries). Use both helpers:

```swift
let goldAwarded = integrityService.adjustedGold(baseGold, activity: activityKey, settings: settings)
profile.goldCoins += goldAwarded
integrityService.recordAuxiliaryAward(activity: activityKey, settings: settings)
// The recordAuxiliaryAward call advances the diminishing-returns curve so the
// next repeat of this activity sees the 50% / 25% / 10% multiplier.
```

## Audit grep (run on every gold-currency-bearing app)

```bash
grep -rEn '\.goldCoins\s*\+=|earnGold|profile\.gold|currency\.gold' \
  Packages/Libraries/Sources/ \
  Sources/
```

Every hit MUST be a call routed through `adjustedGold(...)` or `recordAuxiliaryAward(...)`. Any naked `goldCoins +=` without the integrity helper is a farming vector. Resolution: wire the flat award through `adjustedGold` per pattern A or B above.

## Reference impl

CuriosityQuest, `Packages/Libraries/Sources/Services/XPIntegrityService.swift:97-128`:
- `adjustedGold(_:activity:settings:)` — mirrors `adjustedXP`, returns 0 during cooldown, applies diminishing curve
- `recordAuxiliaryAward(activity:settings:)` — bumps cooldown + repeat counter without consuming daily XP

CQ wired this in 4 sites via PRs #194-#197 (2026-06-01); pattern is verbatim-portable.

## ForgeKit promotion path

The helpers currently live in the app-local `XPIntegrityService` in CQ. Portfolio-wide they should be lifted to `ForgeGamification.XPIntegrityService` (or equivalent) so any app importing the module gets them for free. **Promotion deferred to a dedicated ForgeKit-release round.** Trigger to expedite: 2nd portfolio app adopts the gold-currency pattern + hits the same farming exposure.

Until promotion: each app duplicates the helpers into its own integrity service (verbatim from CQ reference impl). The DUPLICATION IS ACCEPTABLE because the API is small (two methods, ~40 lines) and the canonical version once it lands in ForgeKit will be a drop-in replacement.

## What this rule is NOT

- NOT about preventing players from earning gold over time. Players who play many DIFFERENT activities can earn substantial gold. The curve is per-activity, so variety is rewarded; grinding the same activity is the failure mode being closed.
- NOT about preventing gameplay. Cooldowns are SHORT (typically 5-15 minutes per activity) and intentional. The kid playing in flow STILL gets full or near-full rewards as long as they vary their play.
- NOT about XP daily caps. Gold has NO daily ceiling. The diminishing-returns curve replaces the need for a hard ceiling because the 10% floor at 4th+ repeats already structurally limits farming.

## Why the rule lives at the portfolio scale (not per-app)

Every Spark & Anvil app that ships a currency system has this exposure. Per-app fixes don't scale — the next app to ship currency would re-discover the same loophole. Lifting the principle + canonical helpers means new apps get gold-integrity by default (when ForgeKit promotion lands) or by recipe (until then).

## Cross-references

- `curiosityquest-app/docs/HANDOFF_FROM_APP_LIFT_GOLD_INTEGRITY_RULE.md` (origin handoff; Round 469 #855)
- `curiosityquest-app/Packages/Libraries/Sources/Services/XPIntegrityService.swift:97-128` (reference impl)
- CQ PRs #194-#197 (2026-06-01) — the 4 wiring sites that closed the loopholes
- `.claude/rules/forgekit.md` § ForgeGamification (where the helpers will land post-promotion)
<!-- END LABSMITH-SYNCED CONTENT -->
