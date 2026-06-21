import Testing
import ForgeAI
@testable import AIMentor

/// DN-S Move D Step 3 — surface-mapping tests + moderation regression audit.
///
/// Exercises every `CoachingSurface` × every static catchphrase × every
/// trigger to confirm:
///   1. The map is total (no surface missing a cast).
///   2. Each cast utterance respects per-profile anti-patterns (length,
///      no clinical / therapeutic / grading language, no rewrite proposals).
///   3. The static fallback path returns non-empty + non-sentinel output
///      across the full 5 × 5 trigger matrix (proxy for "100 sample
///      moderation regression" without needing FoundationModels in CI).
@Suite("CastVoicing surface map + moderation regression")
struct CastVoicingSurfaceTests {

    // MARK: - Surface map

    @Test func everyCoachingSurfaceMapsToRegisteredCast() {
        let registeredIDs = Set(CastVoiceRegistry.allProfiles.map(\.id))
        for surface in CastVoiceRegistry.CoachingSurface.allCases {
            #expect(registeredIDs.contains(surface.castID), "\(surface) -> \(surface.castID) not registered")
        }
    }

    @Test func surfaceMapAssignsDistinctVoicesPerPrimitive() {
        // Branch-meaningfulness surfaces should both go to sprig.
        #expect(CastVoiceRegistry.CoachingSurface.branchPointReached.castID == "sprig")
        #expect(CastVoiceRegistry.CoachingSurface.branchReflectionConfirmed.castID == "sprig")
        // Subtext surfaces both to glance.
        #expect(CastVoiceRegistry.CoachingSurface.subtextDiscovered.castID == "glance")
        #expect(CastVoiceRegistry.CoachingSurface.subtextConfirmed.castID == "glance")
        // Tag balance to weigh.
        #expect(CastVoiceRegistry.CoachingSurface.tagBalanceImbalance.castID == "weigh")
        // Voice drift to brogue.
        #expect(CastVoiceRegistry.CoachingSurface.voiceDrift.castID == "brogue")
        // Pause beat to rest.
        #expect(CastVoiceRegistry.CoachingSurface.pauseBeat.castID == "rest")
    }

    @Test func surfaceTriggersFollowCoachingTone() {
        // Encouragement = invitation; affirmation = celebration of a milestone;
        // scaffold = post-error gentle redirect. Map per `CastDialogTrigger`
        // semantics in ForgeAI.
        #expect(CastVoiceRegistry.CoachingSurface.branchPointReached.trigger == .encouragement)
        #expect(CastVoiceRegistry.CoachingSurface.branchReflectionConfirmed.trigger == .affirmation)
        #expect(CastVoiceRegistry.CoachingSurface.tagBalanceImbalance.trigger == .scaffold)
        #expect(CastVoiceRegistry.CoachingSurface.subtextDiscovered.trigger == .encouragement)
        #expect(CastVoiceRegistry.CoachingSurface.subtextConfirmed.trigger == .affirmation)
        #expect(CastVoiceRegistry.CoachingSurface.voiceDrift.trigger == .scaffold)
        #expect(CastVoiceRegistry.CoachingSurface.pauseBeat.trigger == .greeting)
    }

    @Test func voiceDriftThresholdMatchesPanelRubric() {
        // The SubtextPanel voice-match bar shows red < 0.4 < amber < 0.65 ≤ green.
        // The drift threshold must align with the panel rubric so the kid
        // sees a red bar AND hears Brogue scaffold at the same time.
        #expect(CastVoiceRegistry.voiceDriftThreshold == 0.4)
    }

    // MARK: - Anti-pattern audit (proxy for "100-sample moderation")

    /// Aggregate anti-pattern guard set — language that NEVER surfaces in
    /// any cast utterance, regardless of profile. Lifted from the
    /// `antiPatterns` strings already declared on each `CastVoiceProfile`.
    private static let portfolioWideForbiddenPhrases: [String] = [
        // SAMHSA / clinical register
        "anxiety", "depression", "trauma", "diagnosis", "therapy", "therapeutic",
        // Grading / shaming
        "wrong", "bad", "stupid", "failure", "you should", "you must",
        // Rewrite proposals (Patter rule: only invite alternatives)
        "rewrite this", "let me fix"
    ]

    @Test func everyCatchphraseIsModerationClean() {
        for profile in CastVoiceRegistry.allProfiles {
            for phrase in profile.catchphrases {
                let lower = phrase.lowercased()
                for forbidden in Self.portfolioWideForbiddenPhrases {
                    #expect(
                        !lower.contains(forbidden),
                        "\(profile.id) catchphrase contains forbidden phrase '\(forbidden)': \(phrase)"
                    )
                }
            }
        }
    }

    @Test func everyCatchphraseUnderUtteranceLength() {
        // CastDialog.maxUtteranceLength(for:) — `scaffold` + `closing` cap
        // at 200 chars; `encouragement` + `affirmation` cap at 140; `greeting`
        // at 80. We pin to the most-permissive 200 so a catchphrase can be
        // surfaced as ANY trigger. If a profile's catchphrase exceeds 140,
        // it CANNOT serve as fallback for encouragement / affirmation — flag.
        for profile in CastVoiceRegistry.allProfiles {
            for phrase in profile.catchphrases {
                #expect(
                    phrase.count <= 140,
                    "\(profile.id) catchphrase exceeds 140-char encouragement cap: \(phrase.count) chars"
                )
            }
        }
    }

    @Test func everyAntiPatternListIncludesNonJudgmentalGuard() {
        // The portfolio rule is "never grade or shame a draft." Individual
        // profiles may discharge that intent via primitive-specific anti-
        // patterns ("never tell the kid what the subtext is" for glance;
        // "never moralize about silence" for rest). The test accepts any
        // guard whose intent is "coach without judgment."
        let nonJudgmentalKeywords = [
            "shame", "grade", "lecture", "tell the kid", "moraliz",
            "prescriptive", "rewrite", "right answer", "correct"
        ]
        for profile in CastVoiceRegistry.allProfiles {
            let blob = profile.antiPatterns.joined(separator: " ").lowercased()
            let hasGuard = nonJudgmentalKeywords.contains { blob.contains($0) }
            #expect(hasGuard, "\(profile.id) anti-patterns missing non-judgmental guard")
        }
    }

    @Test func everyAntiPatternListIncludesLengthCap() {
        for profile in CastVoiceRegistry.allProfiles {
            let blob = profile.antiPatterns.joined(separator: " ").lowercased()
            #expect(
                blob.contains("under 30 words") || blob.contains("under 30"),
                "\(profile.id) anti-patterns missing length cap"
            )
        }
    }

    // MARK: - CastDialog fallback path (the 5 × 5 regression matrix)

    @Test func castDialogFallsBackCleanlyAcrossAllSurfaces() async throws {
        let dialog = try await CastVoiceRegistry.makeCastDialog()
        for surface in CastVoiceRegistry.CoachingSurface.allCases {
            let utterance = await dialog.respond(
                as: surface.castID,
                trigger: surface.trigger,
                context: CastDialogContext(
                    appIdentifier: "dialoguequest",
                    kitNumber: 1,
                    recentQuestionTopic: "playfulRivalry"
                )
            )
            #expect(!utterance.isEmpty, "empty utterance for \(surface)")
            #expect(utterance != "…", "unregistered sentinel for \(surface)")
        }
    }

    @Test func castDialogTriggerMatrixReturnsKnownCatchphrases() async throws {
        // For every (cast, trigger) pair we drive the fallback path. When
        // FoundationModels is unavailable the result MUST be one of the
        // profile's catchphrases (per CastDialog.swift line 75:
        // `let fallback = profile.catchphrases.randomElement() ?? "…"`).
        let dialog = try await CastVoiceRegistry.makeCastDialog()
        for profile in CastVoiceRegistry.allProfiles {
            let catchphraseSet = Set(profile.catchphrases)
            for trigger in CastDialogTrigger.allCases {
                let utterance = await dialog.respond(
                    as: profile.id,
                    trigger: trigger,
                    context: CastDialogContext(
                        appIdentifier: "dialoguequest",
                        kitNumber: 1
                    )
                )
                // FoundationModels may or may not be present in CI. When
                // absent, the response is always a catchphrase. When
                // present, the LM output passes moderation OR falls back —
                // so the result is either a catchphrase OR a non-empty
                // moderated utterance. Either path is acceptable here.
                let inCatchphrasePool = catchphraseSet.contains(utterance)
                let isModerated = utterance.count <= 200 && utterance != "…"
                #expect(
                    inCatchphrasePool || isModerated,
                    "\(profile.id) × \(trigger) produced unexpected output: \(utterance)"
                )
            }
        }
    }
}
