import Foundation
import ForgeModels

/// Target marker for `Models`. Domain types ship in sibling files under this
/// target — `DialogueNode.swift`, `DialogueTree.swift`, `DialogueTag.swift`,
/// `DialogueCharacterRef.swift`, `DialogueMood.swift`.
public nonisolated enum ModelsTarget {
    public static let bundleIdentifier: String = "com.sparkanvil.dialoguequest.models"
}
