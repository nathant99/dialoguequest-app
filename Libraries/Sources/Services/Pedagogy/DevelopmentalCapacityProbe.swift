import Foundation
import ForgeDevelopmental

/// Phase Delight follow-up wrapper around ForgeKit's `ForgeDevelopmental`
/// DIR/FEDC capacity ladder. Surfaces a parent-readable descriptor for
/// the kid's likely developmental band given a declared age.
///
/// **Why this seam exists**: DialogueQuest's `DialogueScaffoldingService`
/// + `PatterMentor` make pedagogical decisions per-line; both could
/// eventually use the kid's developmental capacity band as a soft input.
/// The probe is the value-type entry point that maps `age → FEDCLevel →
/// DevelopmentalCapacityDescriptor`. The mapping is static today; a
/// future enhancement can incorporate behavioral signals (tag balance,
/// branch meaningfulness over time) to refine the suggested band.
///
/// **What this probe does NOT do** (intentional):
/// - It does NOT activate any GUI surface today. The probe is a pure
///   value-type seam; the parent-progress dashboard + scaffolding
///   service can adopt it in a future round once the kid's
///   age/declared band is captured.
/// - It does NOT depend on the `DeclaredAgeRangeGate` Family Controls
///   path (still pending user GUI). The probe takes a numeric age
///   directly; callers can wire `DeclaredAgeRangeGate` later when the
///   entitlement lands.
/// - It does NOT touch persistence. Stateless static helpers.
///
/// **DialogueQuest-relevant range**: per the chapter authoring rule
/// `.claude/rules/distributed-narrative.md`, the target audience is
/// ages 9-14. The probe uses BEST-FIT-BY-MIDPOINT-DISTANCE: for an age
/// `A`, pick the FEDC level whose `typicalAgeRange` midpoint is
/// closest to `A`. Ties resolve to the LOWER level (conservative
/// scaffolding bias).
///
/// | Age | Best-fit FEDCLevel | Kid-friendly name |
/// |---|---|---|
/// | 9   | `buildingBridgesBetweenIdeas` (range 6...12, midpoint 9) | Bridge Builder |
/// | 10  | `buildingBridgesBetweenIdeas` (mid=9) / `multiCausalThinking` (mid=10) → ties to lower | Bridge Builder |
/// | 11  | `multiCausalThinking` (range 7...13, midpoint 10) | Cause Explorer |
/// | 12  | `multiCausalThinking` (mid=10) / `comparativeThinking` (mid=11) → ties to lower | Cause Explorer |
/// | 13  | `comparativeThinking` (range 8...14, midpoint 11) | Pattern Finder |
/// | 14  | `comparativeThinking` (mid=11) / `reflectiveThinking` (mid=12) → ties to lower | Pattern Finder |
///
/// Best-fit-by-midpoint is the standard pedagogical pick for
/// development bands: the typical-age-range is broad on purpose
/// (acknowledging individual variation); the midpoint is the
/// modal point. Pure-lowest under-targets older kids; pure-highest
/// over-targets younger kids. Best-fit lands in the right band.
///
/// **Why `nonisolated public enum`**: pure value-typed namespace so
/// callers across MainActor / nonisolated boundaries reach it without
/// an actor hop. Mirrors the `DialogueQuestDebugLog` shape.
public nonisolated enum DevelopmentalCapacityProbe {

    /// Lowest age the probe accepts. Returns `.regulationAndInterest` for
    /// anything below this. Out-of-band kids are out of scope for
    /// DialogueQuest's writing surface; this is a safety floor.
    public static let minimumAgeYears: Int = 3

    /// Highest age the probe accepts. Caps at the upper FEDC band
    /// since DialogueQuest stops being the right tool past adolescence.
    public static let maximumAgeYears: Int = 18

    /// Suggest the best-fit FEDC level for a declared age. The
    /// algorithm finds every level whose `typicalAgeRange` contains
    /// the age, then picks the one whose midpoint is closest to the
    /// declared age. Ties resolve to the LOWER level (conservative
    /// scaffolding bias).
    public static func suggestedLevel(forAgeYears age: Int) -> FEDCLevel {
        let clamped = max(minimumAgeYears, min(maximumAgeYears, age))
        let matching = FEDCLevel.allCases.filter { $0.typicalAgeRange.contains(clamped) }
        guard !matching.isEmpty else { return .regulationAndInterest }
        // Best fit by midpoint distance; ties resolve to lower raw value.
        return matching.min { lhs, rhs in
            let lhsMid = midpoint(of: lhs.typicalAgeRange)
            let rhsMid = midpoint(of: rhs.typicalAgeRange)
            let lhsDistance = abs(lhsMid - clamped)
            let rhsDistance = abs(rhsMid - clamped)
            if lhsDistance != rhsDistance { return lhsDistance < rhsDistance }
            return lhs.rawValue < rhs.rawValue
        } ?? .regulationAndInterest
    }

    /// Integer midpoint of an inclusive age range. Stable for `Identifiable`
    /// raw-value math + min/max comparisons.
    private static func midpoint(of range: ClosedRange<Int>) -> Int {
        (range.lowerBound + range.upperBound) / 2
    }

    /// Parent-readable descriptor for the suggested level. The four
    /// strings on `DevelopmentalCapacityDescriptor` (parentSummary /
    /// whatThisMeans / howWeSupport / nextMilestone) render directly
    /// into the parent-progress dashboard without further copy editing.
    public static func descriptor(forAgeYears age: Int) -> DevelopmentalCapacityDescriptor {
        let level = suggestedLevel(forAgeYears: age)
        return DevelopmentalCapacityDescriptor.descriptor(for: level)
    }

    /// Kid-friendly title for the suggested level. Mirrors
    /// `FEDCLevel.childFriendlyName` but routed through the probe so
    /// callers don't import ForgeDevelopmental directly. Used by future
    /// kid-side surfaces (badges, progress chips).
    public static func childFriendlyTitle(forAgeYears age: Int) -> String {
        suggestedLevel(forAgeYears: age).childFriendlyName
    }

    /// The DialogueQuest audience band (ages 9-14) expressed as the
    /// 6-tier ladder the writing surface optimizes for. Returned in
    /// ascending order so callers can iterate the band without manual
    /// FEDC raw-value math. The list is the best-fit set for the
    /// audience-age range: bridging ideas (age 9), causal thinking
    /// (10), comparative thinking (11), reflective thinking (12),
    /// expanded triangular thinking (13), and extended gray-area
    /// thinking (14).
    public static let dialogueQuestAudienceBand: [FEDCLevel] = [
        .buildingBridgesBetweenIdeas,
        .multiCausalThinking,
        .comparativeThinking,
        .reflectiveThinking,
        .expandedTriangularThinking,
        .extendedGrayAreaThinking,
    ]

    /// `true` if the suggested level for the given age falls inside
    /// the DialogueQuest audience band. Useful for the parent-progress
    /// dashboard to render a "writing-craft ready" / "writing-craft
    /// stretching" cue without exposing FEDC jargon directly.
    public static func isInDialogueQuestAudienceBand(ageYears: Int) -> Bool {
        dialogueQuestAudienceBand.contains(suggestedLevel(forAgeYears: ageYears))
    }
}
