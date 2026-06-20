import Foundation
import Models

/// Target marker for `Services`. Files organize under per-responsibility
/// subfolders per `CLAUDE.md` § "SPM File Layout Convention":
///   `Persistence/` — `DialoguePersistenceService` (encode + decode + save)
///   `Analyzers/`   — `BranchMeaningfulnessScorer` + `VoiceConsistencyAnalyzer`
///                    + `TagBalancer` (pure value types; AI-availability-safe
///                    fallback baselines)
public nonisolated enum ServicesTarget {
    public static let bundleIdentifier: String = "com.sparkanvil.dialoguequest.services"
}
