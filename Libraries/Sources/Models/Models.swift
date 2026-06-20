import Foundation
import ForgeModels

/// Target marker for `Models`. Files organize under per-responsibility
/// subfolders per `CLAUDE.md` § "SPM File Layout Convention":
///   `ValueTypes/` — `DialogueNode`, `DialogueTree`, `DialogueTag`,
///                   `DialogueCharacterRef`, `DialogueMood`
///   `Schema/`     — `DialogueQuestSchemaV1`, `PersistentDialogueTree`,
///                   `DialogueQuestMigrationPlan`
public nonisolated enum ModelsTarget {
    public static let bundleIdentifier: String = "com.sparkanvil.dialoguequest.models"
}
