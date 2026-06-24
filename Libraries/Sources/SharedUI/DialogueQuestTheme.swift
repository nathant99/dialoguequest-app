import SwiftUI
import ForgeUI
#if canImport(UIKit)
import UIKit
#endif

/// DialogueQuest's `ForgeTheme` conformance. Hero color is Conversation
/// Rust (`#A05A4B`) per `Docs/TECHNICAL_DESIGN.md` § Delight & Emotional
/// Design.
///
/// The theme's `primaryColor` / `accentColor` / `backgroundColor` mirror
/// the light-variant `DialoguePalette` tokens so existing ForgeUI
/// surfaces (buttons, HUDs) inherit the same hero hue. The adaptive
/// (dark / high-contrast) resolution lives on `DialoguePalette` itself
/// via `UIColor(dynamicProvider:)`; downstream views just keep reading
/// `DialoguePalette.rust` and the trait collection drives the swap.
public struct DialogueQuestTheme: ForgeTheme {
    public init() {}

    public var primaryColor: Color { DialoguePalette.Variant.light.rust }
    public var accentColor: Color { DialoguePalette.Variant.light.warmGold }
    public var backgroundColor: Color { DialoguePalette.Variant.light.cream }
    public var fontFamily: String? { nil }                                                    // system
    public var cornerRadius: CGFloat { 14 }
}

/// Convenience access points scoped to DialogueQuest. The four canonical
/// tokens (`rust`, `warmGold`, `cream`, `inkBlue`) resolve adaptively:
///
/// - **Light, standard contrast** — the original Phase 1 palette
/// - **Dark, standard contrast** — flipped foreground / background so
///   `cream` reads as the dark surface and `inkBlue` reads as the light
///   foreground text
/// - **Light, high contrast** — deeper rust + pure black ink + pure
///   white cream so kid-readable surfaces clear WCAG AAA where
///   practical
/// - **Dark, high contrast** — lighter rust on pure black; pure white
///   inkBlue
///
/// Every existing call site keeps using `DialoguePalette.rust` etc.; the
/// trait-collection-aware dynamic provider drives the swap. Tests verify
/// per-variant WCAG AA contrast against the static `Variant` snapshots.
public enum DialoguePalette {

    // MARK: - Static variant snapshots (deterministic, non-adaptive)

    /// The four kid-readable surfaces resolved as static SRGB `Color`s
    /// for a given (`UIUserInterfaceStyle`, `UIAccessibilityContrast`)
    /// pairing. Tests use these snapshots to compute WCAG contrast
    /// ratios; production views consume the dynamic tokens below.
    nonisolated public struct Variant: Sendable, Hashable {
        public let rust: Color
        public let warmGold: Color
        public let cream: Color
        public let inkBlue: Color

        public init(rust: Color, warmGold: Color, cream: Color, inkBlue: Color) {
            self.rust = rust
            self.warmGold = warmGold
            self.cream = cream
            self.inkBlue = inkBlue
        }

        /// Original Phase 1 palette — the rust-on-cream register
        /// codified in `Docs/TECHNICAL_DESIGN.md`.
        public static let light = Variant(
            rust: Color(red: 160/255, green: 90/255, blue: 75/255),       // #A05A4B
            warmGold: Color(red: 233/255, green: 196/255, blue: 106/255), // #E9C46A
            cream: Color(red: 250/255, green: 245/255, blue: 240/255),    // #FAF5F0
            inkBlue: Color(red: 42/255, green: 31/255, blue: 26/255)       // #2A1F1A
        )

        /// Dark-mode variant. `cream` (the background slot) becomes a
        /// deep ink so panels read solid; `inkBlue` (the body-text
        /// slot) becomes a near-cream so text stays warm + legible on
        /// dark. `rust` brightens to keep the rust-on-cream foreground
        /// register recognizable. `warmGold` brightens slightly.
        public static let dark = Variant(
            rust: Color(red: 216/255, green: 128/255, blue: 117/255),     // #D88075
            warmGold: Color(red: 240/255, green: 212/255, blue: 131/255), // #F0D483
            cream: Color(red: 31/255, green: 24/255, blue: 20/255),       // #1F1814
            inkBlue: Color(red: 250/255, green: 245/255, blue: 240/255)   // #FAF5F0
        )

        /// Light-mode + high-contrast accessibility setting. Deepens
        /// rust / inkBlue, brightens cream to pure white so foreground
        /// surfaces clear WCAG AAA where practical.
        public static let lightHighContrast = Variant(
            rust: Color(red: 128/255, green: 46/255, blue: 31/255),       // #802E1F
            warmGold: Color(red: 181/255, green: 134/255, blue: 22/255),  // #B58616
            cream: Color(red: 1.0, green: 1.0, blue: 1.0),                // #FFFFFF
            inkBlue: Color(red: 0.0, green: 0.0, blue: 0.0)               // #000000
        )

        /// Dark-mode + high-contrast accessibility setting. Brightens
        /// rust for high contrast on a pure-black background; pure
        /// white `inkBlue` for body text.
        public static let darkHighContrast = Variant(
            rust: Color(red: 1.0, green: 160/255, blue: 142/255),         // #FFA08E
            warmGold: Color(red: 1.0, green: 216/255, blue: 61/255),      // #FFD83D
            cream: Color(red: 0.0, green: 0.0, blue: 0.0),                // #000000
            inkBlue: Color(red: 1.0, green: 1.0, blue: 1.0)               // #FFFFFF
        )
    }

    // MARK: - Dynamic tokens (resolve per trait collection)

    public static let rust: Color = adaptiveColor(\.rust)
    public static let warmGold: Color = adaptiveColor(\.warmGold)
    public static let cream: Color = adaptiveColor(\.cream)
    public static let inkBlue: Color = adaptiveColor(\.inkBlue)

    // MARK: - Variant resolution helpers

    /// Resolve the right variant for a given trait collection. Pure
    /// function — `nonisolated` so the dynamic-provider closure can
    /// call it from the system's color-resolution context without a
    /// MainActor hop.
    nonisolated public static func variant(
        for colorScheme: ColorScheme,
        accessibilityContrast: ColorSchemeContrast
    ) -> Variant {
        switch (colorScheme, accessibilityContrast) {
        case (.dark, .increased): return .darkHighContrast
        case (.dark, _):          return .dark
        case (_, .increased):     return .lightHighContrast
        default:                  return .light
        }
    }

    // MARK: - UIKit-backed adaptive provider

    nonisolated private static func adaptiveColor(_ keyPath: KeyPath<Variant, Color>) -> Color {
        #if canImport(UIKit)
        return Color(uiColor: UIColor { traits in
            let scheme: ColorScheme = traits.userInterfaceStyle == .dark ? .dark : .light
            let contrast: ColorSchemeContrast = traits.accessibilityContrast == .high ? .increased : .standard
            let variant = DialoguePalette.variant(for: scheme, accessibilityContrast: contrast)
            return UIColor(variant[keyPath: keyPath])
        })
        #else
        return Variant.light[keyPath: keyPath]
        #endif
    }
}
