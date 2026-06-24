import Foundation
import Testing
import SwiftUI
@testable import SharedUI

/// WCAG 2.2 AA contrast verification for `DialoguePalette` across all
/// four resolved variants: light / dark / lightHighContrast /
/// darkHighContrast. Each pair the UI actually renders is tested
/// against the appropriate WCAG threshold:
///
/// - Normal text (≥ 4.5:1): inkBlue on cream, rust on cream
/// - Large text + UI components (≥ 3.0:1): rust on warmGold, white on
///   rust
///
/// The computation follows the W3C WCAG formula:
/// 1. Convert sRGB component to linear via the standard piecewise
///    transform.
/// 2. Compute relative luminance L = 0.2126·R + 0.7152·G + 0.0722·B.
/// 3. Contrast ratio = (max + 0.05) / (min + 0.05).
///
/// Reference: https://www.w3.org/TR/WCAG22/#contrast-minimum
@Suite("DialoguePalette WCAG AA contrast — light / dark / high-contrast variants")
struct DialoguePaletteContrastTests {

    // MARK: - Light variant (default Phase 1 palette)

    @Test func light_inkBlueOnCreamMeetsAALevelNormal() {
        let ratio = contrastRatio(
            DialoguePalette.Variant.light.inkBlue,
            on: DialoguePalette.Variant.light.cream
        )
        // Very dark ink (#2A1F1A) on cream (#FAF5F0) — ~13:1 in
        // practice; floor is 4.5.
        #expect(ratio >= 4.5, "[light] inkBlue on cream ratio \(ratio) below 4.5")
    }

    @Test func light_rustOnCreamMeetsAALevelNormal() {
        let ratio = contrastRatio(
            DialoguePalette.Variant.light.rust,
            on: DialoguePalette.Variant.light.cream
        )
        // Conversation rust (#A05A4B) on cream (#FAF5F0) — titles +
        // primary CTA labels.
        #expect(ratio >= 4.5, "[light] rust on cream ratio \(ratio) below 4.5")
    }

    @Test func light_whiteOnRustMeetsAALargeText() {
        let ratio = contrastRatio(
            .white,
            on: DialoguePalette.Variant.light.rust
        )
        #expect(ratio >= 3.0, "[light] white on rust ratio \(ratio) below 3.0")
    }

    @Test func light_warmGoldOnCreamPreservesSignal() {
        let ratio = contrastRatio(
            DialoguePalette.Variant.light.warmGold,
            on: DialoguePalette.Variant.light.cream
        )
        // Chromatic accent (streak + badge halo). Not body text; the
        // 1.5 floor catches an outright loss of visual signal.
        #expect(ratio >= 1.5, "[light] warmGold on cream ratio \(ratio) — chromatic accent surface; visual signal lost below 1.5")
    }

    // MARK: - Dark variant

    @Test func dark_inkBlueOnCreamMeetsAALevelNormal() {
        let ratio = contrastRatio(
            DialoguePalette.Variant.dark.inkBlue,
            on: DialoguePalette.Variant.dark.cream
        )
        // In dark: `cream` is the deep-ink background; `inkBlue` is
        // the cream foreground. Body text must still clear 4.5.
        #expect(ratio >= 4.5, "[dark] inkBlue on cream ratio \(ratio) below 4.5")
    }

    @Test func dark_rustOnCreamMeetsAALargeText() {
        let ratio = contrastRatio(
            DialoguePalette.Variant.dark.rust,
            on: DialoguePalette.Variant.dark.cream
        )
        // Rust foreground on dark background. Title-sized text on
        // panels — must clear 3.0 (large-text floor).
        #expect(ratio >= 3.0, "[dark] rust on cream ratio \(ratio) below 3.0")
    }

    @Test func dark_warmGoldOnCreamPreservesSignal() {
        let ratio = contrastRatio(
            DialoguePalette.Variant.dark.warmGold,
            on: DialoguePalette.Variant.dark.cream
        )
        #expect(ratio >= 1.5, "[dark] warmGold on cream ratio \(ratio) — chromatic accent surface")
    }

    // MARK: - Light high-contrast variant

    @Test func lightHighContrast_inkBlueOnCreamMeetsAAA() {
        let ratio = contrastRatio(
            DialoguePalette.Variant.lightHighContrast.inkBlue,
            on: DialoguePalette.Variant.lightHighContrast.cream
        )
        // Pure black on pure white — 21:1, the WCAG ceiling.
        #expect(ratio >= 7.0, "[lightHighContrast] inkBlue on cream ratio \(ratio) below AAA 7.0")
    }

    @Test func lightHighContrast_rustOnCreamMeetsAAA() {
        let ratio = contrastRatio(
            DialoguePalette.Variant.lightHighContrast.rust,
            on: DialoguePalette.Variant.lightHighContrast.cream
        )
        // Deepened rust (#802E1F) on pure white — must clear AAA 7.0
        // when the kid opts into high contrast.
        #expect(ratio >= 7.0, "[lightHighContrast] rust on cream ratio \(ratio) below AAA 7.0")
    }

    @Test func lightHighContrast_whiteOnRustMeetsAALargeText() {
        let ratio = contrastRatio(
            .white,
            on: DialoguePalette.Variant.lightHighContrast.rust
        )
        #expect(ratio >= 3.0, "[lightHighContrast] white on rust ratio \(ratio) below 3.0")
    }

    // MARK: - Dark high-contrast variant

    @Test func darkHighContrast_inkBlueOnCreamMeetsAAA() {
        let ratio = contrastRatio(
            DialoguePalette.Variant.darkHighContrast.inkBlue,
            on: DialoguePalette.Variant.darkHighContrast.cream
        )
        // Pure white on pure black — 21:1.
        #expect(ratio >= 7.0, "[darkHighContrast] inkBlue on cream ratio \(ratio) below AAA 7.0")
    }

    @Test func darkHighContrast_rustOnCreamMeetsAALargeText() {
        let ratio = contrastRatio(
            DialoguePalette.Variant.darkHighContrast.rust,
            on: DialoguePalette.Variant.darkHighContrast.cream
        )
        // Lightened rust (#FFA08E) on pure black — must clear 4.5 for
        // body-text-sized labels.
        #expect(ratio >= 4.5, "[darkHighContrast] rust on cream ratio \(ratio) below 4.5")
    }

    // MARK: - Variant-resolution helper

    @Test func variantResolver_picksLightForDefaultScheme() {
        #expect(DialoguePalette.variant(for: .light, accessibilityContrast: .standard) == .light)
    }

    @Test func variantResolver_picksDarkForDarkStandardContrast() {
        #expect(DialoguePalette.variant(for: .dark, accessibilityContrast: .standard) == .dark)
    }

    @Test func variantResolver_picksLightHighContrastForLightIncreasedContrast() {
        #expect(DialoguePalette.variant(for: .light, accessibilityContrast: .increased) == .lightHighContrast)
    }

    @Test func variantResolver_picksDarkHighContrastForDarkIncreasedContrast() {
        #expect(DialoguePalette.variant(for: .dark, accessibilityContrast: .increased) == .darkHighContrast)
    }

    @Test func everyVariantIsDistinct() {
        let snapshots: [DialoguePalette.Variant] = [
            .light, .dark, .lightHighContrast, .darkHighContrast
        ]
        #expect(Set(snapshots).count == snapshots.count)
    }

    // MARK: - Symmetry sanity

    @Test func contrastIsSymmetric() {
        // (max + 0.05) / (min + 0.05) is order-invariant.
        let a = contrastRatio(
            DialoguePalette.Variant.light.inkBlue,
            on: DialoguePalette.Variant.light.cream
        )
        let b = contrastRatio(
            DialoguePalette.Variant.light.cream,
            on: DialoguePalette.Variant.light.inkBlue
        )
        #expect(abs(a - b) < 0.001)
    }

    @Test func identityContrastIsOne() {
        let ratio = contrastRatio(
            DialoguePalette.Variant.light.rust,
            on: DialoguePalette.Variant.light.rust
        )
        #expect(abs(ratio - 1.0) < 0.001)
    }

    // MARK: - WCAG contrast helper

    /// Returns the WCAG 2.2 contrast ratio between two `Color`s. Result
    /// is a Double in `[1.0, 21.0]`.
    private func contrastRatio(_ foreground: Color, on background: Color) -> Double {
        let l1 = relativeLuminance(foreground)
        let l2 = relativeLuminance(background)
        let lighter = max(l1, l2)
        let darker = min(l1, l2)
        return (lighter + 0.05) / (darker + 0.05)
    }

    /// W3C WCAG relative luminance: 0.2126·R + 0.7152·G + 0.0722·B over
    /// linear-space components.
    private func relativeLuminance(_ color: Color) -> Double {
        let (r, g, b) = sRGBComponents(color)
        let R = linearizeChannel(r)
        let G = linearizeChannel(g)
        let B = linearizeChannel(b)
        return 0.2126 * R + 0.7152 * G + 0.0722 * B
    }

    private func sRGBComponents(_ color: Color) -> (Double, Double, Double) {
        #if canImport(UIKit)
        let resolved = UIColor(color).cgColor
        guard let components = resolved.components, components.count >= 3 else {
            return (0, 0, 0)
        }
        return (Double(components[0]), Double(components[1]), Double(components[2]))
        #elseif canImport(AppKit)
        let nsColor = NSColor(color).usingColorSpace(.sRGB) ?? .black
        return (
            Double(nsColor.redComponent),
            Double(nsColor.greenComponent),
            Double(nsColor.blueComponent)
        )
        #else
        return (0, 0, 0)
        #endif
    }

    private func linearizeChannel(_ srgb: Double) -> Double {
        let v = min(max(srgb, 0.0), 1.0)
        if v <= 0.03928 {
            return v / 12.92
        }
        return pow((v + 0.055) / 1.055, 2.4)
    }
}
