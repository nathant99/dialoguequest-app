import Foundation

/// The emotional register of a dialogue tree as a whole. Used to seed
/// AI mentor coaching (different moods coach different lines differently)
/// and to tag completed trees for the anthology gallery.
public nonisolated enum DialogueMood: String, Codable, Sendable, CaseIterable, Identifiable {
    case warmReunion
    case quietConflict
    case playfulRivalry
    case awkwardSilence
    case openingCuriosity

    public var id: String { rawValue }

    /// Human-readable label for SwiftUI surfaces. Localized via the string
    /// catalog at `Bundle.module` when SharedUI consumes this value.
    public var displayName: String {
        switch self {
        case .warmReunion: return "Warm reunion"
        case .quietConflict: return "Quiet conflict"
        case .playfulRivalry: return "Playful rivalry"
        case .awkwardSilence: return "Awkward silence"
        case .openingCuriosity: return "Opening curiosity"
        }
    }
}
