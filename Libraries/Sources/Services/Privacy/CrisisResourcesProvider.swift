import Foundation

/// Static crisis-resource list surfaced from Settings → "Need help?"
/// per `@Docs/FEATURE_PLAN.md` § Accessibility & Trauma-Informed Polish.
/// Phase 1 ships the US-resident list; locale-specific expansion lands
/// in a Phase 2 handoff once translation pipeline is established.
///
/// **Do NOT remove**: these are load-bearing for any future app-review
/// trauma-axis carve-out per `.claude/rules/distributed-narrative.md`
/// § "Trauma-safety per-page surface". The lines are also referenced
/// from `ParentalConsentService` documentation as the canonical
/// escalation path.
public nonisolated struct CrisisResourcesProvider: Sendable {
    public struct Resource: Sendable, Hashable, Identifiable {
        public let id: String
        public let title: String
        public let oneLineDescription: String
        public let phoneNumber: String?
        public let textInstructions: String?
        public let url: URL?

        public init(
            id: String,
            title: String,
            oneLineDescription: String,
            phoneNumber: String? = nil,
            textInstructions: String? = nil,
            url: URL? = nil
        ) {
            self.id = id
            self.title = title
            self.oneLineDescription = oneLineDescription
            self.phoneNumber = phoneNumber
            self.textInstructions = textInstructions
            self.url = url
        }
    }

    public init() {}

    public static let resources: [Resource] = [
        Resource(
            id: "988",
            title: "988 Suicide & Crisis Lifeline",
            oneLineDescription: "Free, confidential 24/7 support — call or text 988.",
            phoneNumber: "988",
            textInstructions: "Text 988",
            url: URL(string: "https://988lifeline.org")
        ),
        Resource(
            id: "childhelp",
            title: "Childhelp National Hotline",
            oneLineDescription: "Crisis intervention + child-abuse counseling, 24/7.",
            phoneNumber: "1-800-422-4453",
            textInstructions: nil,
            url: URL(string: "https://www.childhelp.org")
        ),
        Resource(
            id: "crisis-text-line",
            title: "Crisis Text Line",
            oneLineDescription: "Text HOME to 741741 to reach a trained crisis counselor.",
            phoneNumber: nil,
            textInstructions: "Text HOME to 741741",
            url: URL(string: "https://www.crisistextline.org")
        )
    ]
}
