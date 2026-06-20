import SwiftUI
import ForgeUI

/// DialogueQuest's `ForgeTheme` conformance. Hero color is Conversation
/// Rust (`#A05A4B`) per `Docs/TECHNICAL_DESIGN.md` § Delight & Emotional
/// Design.
public struct DialogueQuestTheme: ForgeTheme {
    public init() {}

    public var primaryColor: Color { Color(red: 160/255, green: 90/255, blue: 75/255) }      // #A05A4B
    public var accentColor: Color { Color(red: 233/255, green: 196/255, blue: 106/255) }     // warm gold
    public var backgroundColor: Color { Color(red: 250/255, green: 245/255, blue: 240/255) } // cream
    public var fontFamily: String? { nil }                                                    // system
    public var cornerRadius: CGFloat { 14 }
}

/// Convenience access points scoped to DialogueQuest. Mood-aware tints
/// land in Phase 2 when the mood-tag dashboard surfaces.
public enum DialoguePalette {
    public static let rust: Color = DialogueQuestTheme().primaryColor
    public static let warmGold: Color = DialogueQuestTheme().accentColor
    public static let cream: Color = DialogueQuestTheme().backgroundColor
    public static let inkBlue: Color = Color(red: 42/255, green: 31/255, blue: 26/255)
}
