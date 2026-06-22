import Foundation
import ForgeSensory

/// DialogueQuest's juice-layer coordinator. Wraps `ForgeSensory.SensoryPalette`
/// + exposes 4 domain-shaped fire-and-forget surfaces aligned with the writing
/// loop:
///
/// - `treePublished()` — kid completes a tree → `.challengeComplete` (1.0
///   visual intensity, achievement-tier haptic).
/// - `achievementEarned()` — badge unlocks → `.achievement` (mirrors the
///   `ForgeAchievementPopup` overlay so the haptic lands the same beat).
/// - `streakAdvanced(_:)` — broadcast streak count after a `StreakManager`
///   advance → `.streakMilestone(streak)` (palette already scales intensity
///   on every-5th milestone via the FK haptic library).
/// - `subtextRevealed()` — kid confirms a subtext layer → `.reveal` (soft
///   tactile click + reveal SFX cue; matches the SubtextPanel confirm beat).
///
/// `SensoryPalette` internally respects:
/// - `SensoryPreferences.hapticIntensity` (system-wide haptic strength)
/// - `AccessibilityConfig.HapticIntensity` override (Reduce-Motion-aligned)
///
/// We hand the palette the default `SensoryPaletteConfig()` so the FK 0.99
/// haptic library defaults apply across all 4 sites. Custom DialogueQuest
/// SFX is currently off-axis — `SensoryPalette` only fires haptics when no
/// `sfxPlayer` closure is supplied (the default for DialogueQuest).
///
/// Phase 2+ can extend this surface to wire SFX once the DialogueQuest
/// audio bundle ships.
@MainActor
public final class DialogueSensoryService {
    public static let shared = DialogueSensoryService()

    private let palette: SensoryPalette

    public init(palette: SensoryPalette = SensoryPalette()) {
        self.palette = palette
    }

    public func treePublished() {
        palette.fire(.challengeComplete)
    }

    public func achievementEarned() {
        palette.fire(.achievement)
    }

    public func streakAdvanced(_ streak: Int) {
        palette.fire(.streakMilestone(streak))
    }

    public func subtextRevealed() {
        palette.fire(.reveal)
    }

    /// Test seam — surfaces the most recently fired event so unit tests
    /// can verify wiring without poking at private state. Returns `nil`
    /// until the first `fire` call lands.
    public var lastEvent: SensoryEvent? {
        palette.lastEvent
    }
}
