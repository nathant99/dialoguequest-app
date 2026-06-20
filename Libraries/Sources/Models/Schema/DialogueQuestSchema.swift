import Foundation
import SwiftData

/// Versioned schema for DialogueQuest. Starting V1 from day one per
/// `.claude/rules/swiftdata.md` rule #9 — retrofitting `VersionedSchema`
/// after launch is expensive; doing it now costs nothing.
///
/// All future `@Model` additions land inside a new `SchemaV<N>` enum and
/// a corresponding `MigrationStage` in `DialogueQuestMigrationPlan`.
public enum DialogueQuestSchemaV1: VersionedSchema {
    public static let versionIdentifier: Schema.Version = .init(1, 0, 0)

    public static var models: [any PersistentModel.Type] {
        [PersistentDialogueTree.self]
    }
}

/// Currently-canonical type aliases. App code references these instead of
/// the version-prefixed types so the migration story stays readable.
public typealias CurrentSchema = DialogueQuestSchemaV1

/// Migration plan stub. V1 has no predecessors so no `MigrationStage`s
/// ship today; the type exists so future versions slot in without an
/// app-shell churn.
public enum DialogueQuestMigrationPlan: SchemaMigrationPlan {
    public static var schemas: [any VersionedSchema.Type] {
        [DialogueQuestSchemaV1.self]
    }

    public static var stages: [MigrationStage] { [] }
}
