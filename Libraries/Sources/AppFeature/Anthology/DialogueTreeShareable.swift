import Foundation
import CoreTransferable
import UniformTypeIdentifiers
import Models
import Services

/// `Transferable` wrapper that lets the kid export a published
/// `DialogueTree` via SwiftUI's `ShareLink`. Phase 2 seed for the
/// TaleForge anthology-export hook (`Docs/FEATURE_PLAN.md` § Phase 2 —
/// "Wire anthology export hook to TaleForge"): the JSON shape is the
/// portable canonical form — TaleForge will consume the same shape when
/// the hub-side import lands.
///
/// On-device only. The kid initiates the share via the standard iOS
/// share sheet (AirDrop / Files / Mail / Messages). No outbound network
/// from this app; the share sheet is system-provided.
public struct DialogueTreeShareable: Sendable, Transferable {
    public let tree: DialogueTree

    public init(tree: DialogueTree) {
        self.tree = tree
    }

    public static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .json) { value in
            try DialoguePersistenceService.encode(value.tree)
        }
        .suggestedFileName { value in
            let safeTitle = sanitizeFilename(value.tree.title)
            return "\(safeTitle).dialoguequest.json"
        }
    }

    /// Trim a tree title to a filename-safe form. Keeps alphanumerics
    /// + dashes + underscores; collapses other characters to "_"; clamps
    /// the result to 60 chars. Empty + whitespace titles fall back to a
    /// stable "dialogue" prefix so the share sheet always has a name.
    static func sanitizeFilename(_ title: String) -> String {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "dialogue" }
        let allowed = Set("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_")
        let scrubbed = trimmed.map { ch -> Character in
            allowed.contains(ch) ? ch : "_"
        }
        var collapsed: [Character] = []
        var lastUnderscore = false
        for ch in scrubbed {
            if ch == "_" {
                if !lastUnderscore { collapsed.append(ch) }
                lastUnderscore = true
            } else {
                collapsed.append(ch)
                lastUnderscore = false
            }
        }
        let result = String(collapsed).trimmingCharacters(in: CharacterSet(charactersIn: "_"))
        if result.isEmpty { return "dialogue" }
        return String(result.prefix(60))
    }
}
