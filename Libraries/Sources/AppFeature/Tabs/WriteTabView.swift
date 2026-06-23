import SwiftUI
import Models
import Services
import AIMentor
import SharedUI
import ForgeUI

/// Phase 1 Write tab — orchestrates character authoring → tree editing →
/// review. Holds the `PatterMentor` instance + analyzer state and feeds
/// derived data into the Builder / Inspector / Panels / Dashboard.
struct WriteTabView: View {
    /// Progressive-disclosure: count of trees the kid has published. Maps
    /// to a `SessionTier` that caps the max tree size for early sessions
    /// (session 1 → 3 nodes; sessions 2-3 → 5; experienced → 15).
    @AppStorage("dq.publishedTreeCount") private var publishedTreeCount: Int = 0
    /// Phase 3 counters — feed the Phase 3 achievement criteria. Storage
    /// is `@AppStorage`-backed so the badge eligibility persists across
    /// launches with no extra service layer.
    @AppStorage("dq.readAloudCount") private var readAloudCount: Int = 0
    @AppStorage("dq.audioExportCount") private var audioExportCount: Int = 0

    @State private var machine = DialogueTreeMachine()
    @State private var mentor = PatterMentor()
    @State private var castVoicing = CastVoicingService()
    @State private var reactionService: PatterReactionService?
    @State private var activeBranchPointID: UUID?
    @State private var achievementService = AchievementService.shared
    @State private var rareVoiceCraftTip: String?
    @State private var showCollaborativeSession: Bool = false
    @State private var traumaAxisAdvisory: TraumaAxisAdvisoryService.Advisory?
    @State private var traumaAdvisorySurfacedThisSession: Bool = false
    @State private var showCrisisResourcesFromAdvisory: Bool = false
    @State private var discoveryCameoSurfacedThisSession: Bool = false
    @State private var readAloudService = DialogueReadAloudService()

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    private let scorer = BranchMeaningfulnessScorer()
    private let voiceAnalyzer = VoiceConsistencyAnalyzer()
    private let tagBalancer = TagBalancer()
    private let traumaAdvisor = TraumaAxisAdvisoryService()

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(navigationTitle)
                .toolbar {
                    if machine.stage != .authoringCharacters {
                        ToolbarItem(placement: .secondaryAction) {
                            Button {
                                machine.toggleDraft()
                                DialogueSensoryService.shared.subtextRevealed()
                            } label: {
                                Label(
                                    machine.tree.isDraft ? "Marked as sketch" : "Save as sketch",
                                    systemImage: machine.tree.isDraft ? "bookmark.fill" : "bookmark"
                                )
                            }
                            .accessibilityIdentifier("writeTab.draftToggle")
                            .accessibilityHint(
                                machine.tree.isDraft
                                ? Text("This conversation is marked as a sketch. Tap to un-mark it.")
                                : Text("Mark this conversation as a sketch so you can come back to it later. Sketches stay private to your anthology and skip the published-tree celebrations.")
                            )
                        }
                    }
                    if machine.stage != .authoringCharacters && machine.tree.nodes.count >= 1 {
                        ToolbarItem(placement: .secondaryAction) {
                            Button {
                                playReadAloud()
                            } label: {
                                Label(
                                    readAloudService.phase == .idle || readAloudService.phase == .completed
                                    ? "Listen"
                                    : "Stop",
                                    systemImage: readAloudService.phase == .idle || readAloudService.phase == .completed
                                    ? "play.circle"
                                    : "stop.circle"
                                )
                            }
                            .accessibilityIdentifier("writeTab.readAloud")
                            .accessibilityHint(
                                Text("Listen to your dialogue tree read aloud. Each character gets a different voice based on the register you wrote for them. The audio plays on this device only.")
                            )
                        }
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showCollaborativeSession = true
                        } label: {
                            Label("Write together", systemImage: "person.2.fill")
                        }
                        .accessibilityHint("Start a pass-and-play session where two players take turns writing the next line of dialogue. Optional — you can still write alone.")
                    }
                }
                .sheet(isPresented: $showCollaborativeSession) {
                    CollaborativeDialogueView(
                        onSessionComplete: { tree in
                            machine.replaceTree(tree)
                            showCollaborativeSession = false
                        },
                        onDismiss: {
                            showCollaborativeSession = false
                        }
                    )
                }
        }
        .task {
            // UI-test seed (no-op in production). Must run BEFORE the tier
            // sync so the seeded machine's tier doesn't get clobbered.
            if let seeded = WriteTabUITestSeed.seedIfRequested(), machine.tree.nodes.isEmpty {
                machine = seeded
            }
            // Sync the tier on initial appear so the machine's cap matches
            // the kid's experience even before they publish anything new.
            let tier = DialogueTree.NodeCountConstraint.SessionTier(
                publishedCount: publishedTreeCount
            )
            if machine.sessionTier != tier {
                machine.sessionTier = tier
            }
            // Lazy-build the reaction service so it captures the
            // `@State`-owned mentor + cast-voicing references. Built once
            // per Write-tab appear; idempotent on re-task fire.
            if reactionService == nil {
                reactionService = PatterReactionService(
                    mentor: mentor,
                    castVoicing: castVoicing
                )
            }
            // Discovery cameo — micro-delight § Discovery. A random
            // LESSONS-layer cast member says hello once per session,
            // gated by feature flag + minimum publish count. Reuses the
            // `rareVoiceCraftTip` MentorBubbleView slot so the bubble
            // dismisses on tap like the post-publish path.
            if !discoveryCameoSurfacedThisSession,
               publishedTreeCount >= CharacterCameoInvitations.discoveryMinimumPublishedTreeCount,
               CastVoicingFeatureFlag.isEnabled,
               rareVoiceCraftTip == nil {
                var rng = SystemRandomNumberGenerator()
                if CharacterCameoInvitations.shouldShowDiscoveryCameo(rng: &rng),
                   let cameo = CharacterCameoInvitations.pickDiscoveryCameo(rng: &rng) {
                    rareVoiceCraftTip = cameo.bubbleMessage
                    discoveryCameoSurfacedThisSession = true
                }
            }
        }
        .task(id: machine.selectedNodeID) {
            // Fire `onBranchPointSelected` whenever the kid lands on a
            // node that branches. Cast voicing (Sprig) wakes up via
            // `CastVoicingService` when the feature flag is on.
            guard let service = reactionService else { return }
            guard let selected = machine.selectedNode, selected.isBranchPoint else { return }
            await service.onBranchPointSelected(branchPointID: selected.id, mood: machine.tree.mood)
        }
        .task(id: machine.tree.nodes.count) {
            // Fire `onTreeChanged` after every mutation so Weigh's
            // tag-balance scaffold wakes up when the dominant tag-class
            // crosses a threshold. Tied to node-count so the task ID
            // changes on each append / remove (and not on cosmetic edits
            // that don't change topology — those don't move tag balance).
            guard let service = reactionService else { return }
            await service.onTreeChanged(machine.tree)
            // Trauma-axis advisory — inspect every line on append; gate
            // on per-session de-dup so a tender-themed tree doesn't get
            // a banner per node. Surfaces ONLY when a strong cue lands;
            // never blocks the kid's draft.
            if !traumaAdvisorySurfacedThisSession {
                updateTraumaAxisAdvisory()
            }
        }
        .onChange(of: machine.confirmedSubtextLineIDs) { oldSet, newSet in
            // The kid confirmed a subtext. Glance affirms via cast voicing.
            guard newSet.count > oldSet.count else { return }
            DialogueQuestAnalytics.shared.track(.subtextConfirmed)
            guard let service = reactionService else { return }
            Task { await service.onSubtextConfirmed(mood: machine.tree.mood) }
        }
        .onChange(of: machine.reflectedBranchPointIDs) { oldSet, newSet in
            // The kid completed a branch reflection. Sprig affirms.
            guard newSet.count > oldSet.count else { return }
            DialogueQuestAnalytics.shared.track(.branchReflected)
            guard let service = reactionService else { return }
            Task { await service.onBranchReflectionConfirmed(mood: machine.tree.mood) }
        }
        .onChange(of: machine.stage) { _, newStage in
            // Bump the published-tree counter when the kid ships a tree.
            // Pure side-effect; the AppStorage value is the source of truth
            // for the next session's tier — current session keeps its cap.
            if newStage == .published {
                publishedTreeCount += 1
                // On-device privacy-safe analytics: count + mood + character
                // count are categorical, no PII. ForgeAnalytics PII blocklist
                // is the last-line guard.
                DialogueQuestAnalytics.shared.track(
                    .treePublished,
                    properties: [
                        "mood": machine.tree.mood?.rawValue ?? "none",
                        "node_count_bucket": Self.nodeCountBucket(machine.tree.nodes.count),
                        "character_count": String(machine.tree.characters.count)
                    ]
                )
                // Advance the streak via ForgeGamification.StreakManager
                // (UserDefaults-backed; ProgressDashboardView picks the
                // new values up on next render via @AppStorage). Pass
                // the tree's mood so hard scenes (`.quietConflict` /
                // `.awkwardSilence`) route through ForgeKit 0.86's
                // `.heldUnderDistress` path — the streak holds instead
                // of breaking on a difficult piece.
                let publishedMood = machine.tree.mood
                Task { await StreakService.shared.recordPublishedTree(mood: publishedMood) }
                // Record the just-published mood + title in Patter's
                // rolling memory BEFORE the bubble decision below — the
                // callback path reads the freshest history.
                PatterCallbackService.shared.recordPublishedTree(
                    mood: machine.tree.mood,
                    title: machine.tree.title
                )
                // Three Patter-bubble paths share the rareVoiceCraftTip
                // slot, mutually exclusive (so the kid never sees two
                // bubbles): cameo (12%, flag-gated) → callback (8%,
                // history-gated) → voice-craft tip (20%, always
                // allowed). Lower-probability paths win first so they
                // feel special when they hit.
                var rewardRNG = SystemRandomNumberGenerator()
                var slotFilled = false
                if publishedTreeCount >= CharacterCameoInvitations.minimumPublishedTreeCount,
                   CastVoicingFeatureFlag.isEnabled,
                   CharacterCameoInvitations.shouldShowInvitation(rng: &rewardRNG),
                   let invitation = CharacterCameoInvitations.pickInvitation(rng: &rewardRNG) {
                    rareVoiceCraftTip = invitation.bubbleMessage
                    slotFilled = true
                }
                if !slotFilled,
                   PatterCallbackService.shouldShowCallback(rng: &rewardRNG),
                   let callback = PatterCallbackService.shared.nextCallback() {
                    rareVoiceCraftTip = callback
                    slotFilled = true
                }
                if !slotFilled, VariableReward.shouldShowBonus() {
                    rareVoiceCraftTip = VariableReward.pickVoiceCraftTip(rng: &rewardRNG)
                }
                // Feed the tree's outcome into DDA so the next session's
                // voice-drift threshold + branch-reflection floor adapt
                // to the kid's recent performance.
                if let service = reactionService {
                    let outcome = computeOutcomeSnapshot()
                    service.recordTreeOutcome(
                        reflectionRatio: outcome.reflectionRatio,
                        averageVoiceMatch: outcome.averageVoiceMatch
                    )
                }
                // Juice layer — the achievement haptic (if any) fires
                // separately from `evaluateAchievements()` below. The
                // publish-tier haptic lands first so the kid feels the
                // ship beat before the badge stack.
                DialogueSensoryService.shared.treePublished()
                // Scaffolding tier — a publish counts as a success when
                // the kid reflected on at least one branch point;
                // counts as a failure otherwise. ForgeKit's
                // `ScaffoldingEngine` auto-fades hints after 3 successes
                // + restores after 2 failures. Advisory for Phase 1 —
                // future Patter surfaces consume `currentTier` to
                // decide hint wording.
                if machine.reflectedBranchPointIDs.isEmpty {
                    DialogueScaffoldingService.shared.recordPublishedWithoutReflection()
                } else {
                    DialogueScaffoldingService.shared.recordPublishedWithReflection()
                }
                // Mastery moment — first time the tree's average
                // voice-match crosses 0.85, fire a `.epic` cinematic.
                // Subsequent crossings render normal acknowledgement
                // (publish celebration tier in RootView).
                let outcome = computeOutcomeSnapshot()
                _ = MasteryMomentService.shared.recordPublishedTree(
                    averageVoiceMatch: outcome.averageVoiceMatch
                )
            }
            evaluateAchievements()
        }
        .onChange(of: machine.confirmedSubtextLineIDs) { _, _ in
            evaluateAchievements()
        }
        .onChange(of: machine.reflectedBranchPointIDs) { _, _ in
            evaluateAchievements()
        }
        .sheet(item: branchSheetBinding) { branchID in
            BranchMeaningfulnessCheckView(
                machine: $machine,
                mentor: mentor,
                branchPointID: branchID.id,
                onClose: { activeBranchPointID = nil }
            )
            .presentationDetents([.medium, .large])
        }
        .overlay(alignment: .top) {
            if let badge = achievementService.pendingNewBadges.first {
                ForgeAchievementPopup(badge: badge) {
                    achievementService.consumeBadge(id: badge.id)
                }
                .padding(.top, 24)
            }
        }
        .overlay(alignment: .bottom) {
            if let tip = rareVoiceCraftTip {
                MentorBubbleView(message: tip)
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                    .onTapGesture { rareVoiceCraftTip = nil }
                    .accessibilityHint("Tap to dismiss this voice-craft tip.")
                    .transition(reduceMotion ? .identity : .opacity)
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            if let advisory = traumaAxisAdvisory {
                TenderThemeBannerView(
                    advisory: advisory,
                    onOpenResources: { showCrisisResourcesFromAdvisory = true },
                    onDismiss: { traumaAxisAdvisory = nil }
                )
                .padding(.horizontal)
                .padding(.top, 6)
                .transition(reduceMotion ? .identity : .opacity)
            }
        }
        .sheet(isPresented: $showCrisisResourcesFromAdvisory) {
            NavigationStack { CrisisResourcesView() }
        }
    }

    /// Inspect the tree's newest spoken lines for crisis cues / tender
    /// themes. Surfaces the soft banner via `@State traumaAxisAdvisory`
    /// when a cue lands. Per-session de-dup is the caller's responsibility
    /// (the gate sets `traumaAdvisorySurfacedThisSession = true` on emit).
    /// Pure value-type call; never blocks publication.
    private func updateTraumaAxisAdvisory() {
        for node in machine.tree.nodes.reversed() {
            if let advisory = traumaAdvisor.inspect(
                line: node.surfaceText,
                mood: machine.tree.mood
            ) {
                traumaAxisAdvisory = advisory
                traumaAdvisorySurfacedThisSession = true
                return
            }
        }
    }

    /// Snapshot of the just-published tree's pedagogical telemetry,
    /// fed into `DDAEngine.record(outcome:)`.
    private func computeOutcomeSnapshot() -> DDAEngine.RecentOutcome {
        let report = scorer.score(
            tree: machine.tree,
            reflectedBranchPointIDs: machine.reflectedBranchPointIDs
        )
        let reflectionRatio: Double
        if report.branchPointCount > 0 {
            reflectionRatio = Double(report.reflectedBranchPointCount) / Double(report.branchPointCount)
        } else {
            // No branch points at all: treat as midpoint so DDA doesn't
            // ramp up or down from a trivial tree.
            reflectionRatio = 0.5
        }
        // WritingEvaluator.VoiceSummary collapses the per-character
        // reports into one canonical tree-wide score the DDA engine can
        // consume directly. `treeAverage == nil` means no speaking
        // lines yet — fall back to midpoint so DDA doesn't ramp.
        let voiceSummary = voiceAnalyzer.summary(for: machine.tree)
        let averageVoiceMatch = voiceSummary.treeAverage ?? 0.5
        return DDAEngine.RecentOutcome(
            reflectionRatio: reflectionRatio,
            averageVoiceMatch: averageVoiceMatch
        )
    }

    /// Snapshot WriteTab state into an `AchievementService.Criteria` and
    /// fire `evaluate(criteria:)`. Triggered after every interesting
    /// state transition. The service handles dedupe + persistence — this
    /// is a cheap O(N-defs) check per call so safe to invoke on every
    /// `onChange`.
    private func evaluateAchievements() {
        let report = tagBalancer.report(for: machine.tree)
        // Phase 3 — has-action-beat signals subtext-via-pause + pacing
        // craft. Counts any `.action(...)` tag on a published-eligible tree.
        let hasActionBeat = machine.tree.nodes.contains { node in
            if case .action = node.tag { return true }
            return false
        }
        let criteria = AchievementService.Criteria(
            publishedTreeCount: publishedTreeCount,
            confirmedSubtextLineCount: machine.confirmedSubtextLineIDs.count,
            reflectedBranchPointCount: machine.reflectedBranchPointIDs.count,
            dominantTagAbsent: report.dominant == nil,
            totalNodes: machine.tree.nodes.count,
            characterCount: machine.tree.characters.count,
            readAloudCount: readAloudCount,
            audioExportCount: audioExportCount,
            hasActionBeat: hasActionBeat
        )
        _ = achievementService.evaluate(criteria: criteria)
    }

    /// Toggle read-aloud playback for the current tree. Bumps the Phase 3
    /// counter on first start so the `first_read_aloud` badge fires after
    /// the listen, and re-evaluates achievements so any compound Phase 3
    /// badges (`tree_read_three_voices` / `voice_distinguishable_aloud`)
    /// can land on the same tap.
    private func playReadAloud() {
        switch readAloudService.phase {
        case .idle, .completed:
            readAloudService.play(tree: machine.tree)
            readAloudCount += 1
            evaluateAchievements()
        case .playing:
            readAloudService.stop()
        }
    }

    @ViewBuilder
    private var content: some View {
        switch machine.stage {
        case .authoringCharacters:
            CharacterAuthoringView(machine: $machine)
        case .editingTree, .reviewing, .published:
            editingSurface
        }
    }

    private var editingSurface: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                DialogueTreeBuilderView(machine: $machine) { branchPointID in
                    activeBranchPointID = branchPointID
                }
                .frame(minHeight: 360)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                SubtextPanelView(machine: $machine, mentor: mentor)

                TagBalanceDashboardView(report: tagBalancer.report(for: machine.tree))

                NodeInspectorView(machine: $machine)
                    .frame(minHeight: 280)
                    .padding()
                    .background(panelBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                if let voicing = castVoicing.lastVoicing {
                    CastVoicingChip(voicing: voicing)
                        .transition(
                            reduceMotion
                            ? .opacity
                            : .opacity.combined(with: .scale(scale: 0.95, anchor: .leading))
                        )
                }

                publishStripe
            }
            .padding()
            .animation(reduceMotion ? nil : .snappy(duration: 0.2), value: castVoicing.lastVoicing?.id)
        }
        .background(DialoguePalette.cream.opacity(0.6))
    }

    /// Reduce-Transparency-aware background — per `.claude/rules/liquid-glass.md`
    /// glass + thin-material surfaces must collapse to a solid palette tint
    /// when `accessibilityReduceTransparency` is on, so the background isn't
    /// fully translucent (and so a low-vision reader keeps the surface
    /// boundary visible).
    @ViewBuilder
    private var panelBackground: some View {
        if reduceTransparency {
            DialoguePalette.cream
        } else {
            Color.clear.background(.thinMaterial)
        }
    }

    private var publishStripe: some View {
        let report = scorer.score(
            tree: machine.tree,
            reflectedBranchPointIDs: machine.reflectedBranchPointIDs
        )
        return HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Branches reflected upon")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                Text("\(report.reflectedBranchPointCount) of \(report.branchPointCount)")
                    .font(.callout.monospacedDigit())
                    .foregroundStyle(DialoguePalette.inkBlue)
                if machine.sessionTier != .experienced {
                    Text("\(machine.tree.nodes.count) of \(machine.maxNodes) lines (Session ladder)")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            Button {
                if machine.canPublish {
                    machine.markPublished()
                }
            } label: {
                Label(
                    machine.stage == .published ? "Published" : "Publish",
                    systemImage: machine.stage == .published ? "checkmark.seal.fill" : "paperplane.fill"
                )
            }
            .buttonStyle(.borderedProminent)
            .tint(DialoguePalette.rust)
            .disabled(!machine.canPublish || machine.stage == .published)
            .accessibilityHint(
                machine.canPublish
                ? Text("Mark the dialogue tree as ready for the anthology.")
                : Text("You need at least \(DialogueTree.NodeCountConstraint.phase1Min) lines to publish.")
            )
        }
        .padding()
        .background(panelBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private var navigationTitle: String {
        switch machine.stage {
        case .authoringCharacters: return "Cast the scene"
        case .editingTree: return machine.tree.title
        case .reviewing: return "Review"
        case .published: return "Published"
        }
    }

    /// Identifiable wrapper so we can drive `.sheet(item:)` off an
    /// optional UUID. SwiftUI requires Identifiable, not raw UUID.
    private struct PendingBranchSheet: Identifiable, Hashable {
        let id: UUID
    }

    private var branchSheetBinding: Binding<PendingBranchSheet?> {
        Binding(
            get: { activeBranchPointID.map(PendingBranchSheet.init) },
            set: { activeBranchPointID = $0?.id }
        )
    }

    /// Bucket a raw node count into a categorical label for analytics.
    /// Categorical buckets keep the analytics surface PII-free + future-
    /// proof against a kid's per-tree variance.
    static func nodeCountBucket(_ count: Int) -> String {
        switch count {
        case ..<3:    return "tiny"      // < 3
        case 3...5:   return "starter"   // 3-5
        case 6...10:  return "growing"   // 6-10
        case 11...15: return "tall"      // 11-15
        default:      return "epic"      // 16+
        }
    }
}

#Preview {
    WriteTabView()
}
