import Testing
import ForgeAI
@testable import AIMentor

/// DN-D layered-cast tests — verify the WORLD + META expansion stays
/// faithful to `Docs/HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md` and the
/// portfolio DN-D rules (`.claude/rules/distributed-narrative.md`).
///
/// What this suite covers:
/// 1. Layer-aware registry lookup (5 / 4 / 1 across lessons / world / meta).
/// 2. Coaching surfaces route to the correct DN layer.
/// 3. Kit-number gating per layer (LESSONS kit 1+, WORLD kit 5+, META kit 11+).
/// 4. **Aria-is-data rule**: Audience Aria's catchphrases + anti-patterns
///    never grade, fix, or correct a kid's draft (load-bearing DN-D rule).
@Suite("CastVoiceLayer + WORLD/META expansion")
struct CastVoiceLayerTests {

    // MARK: - Layer-aware registry

    @Test func layerLookupReturnsCorrectLayerForEverySlug() {
        let lessonsIDs = ["brogue", "glance", "rest", "sprig", "weigh"]
        let worldIDs = ["heralda", "murmur", "quip", "vesperline"]
        let metaIDs = ["aria"]

        for id in lessonsIDs {
            #expect(CastVoiceRegistry.layer(forID: id) == .lessons, "\(id) should be .lessons")
        }
        for id in worldIDs {
            #expect(CastVoiceRegistry.layer(forID: id) == .world, "\(id) should be .world")
        }
        for id in metaIDs {
            #expect(CastVoiceRegistry.layer(forID: id) == .meta, "\(id) should be .meta")
        }
    }

    @Test func layerLookupReturnsNilForUnknownSlug() {
        #expect(CastVoiceRegistry.layer(forID: "patter") == nil)
        #expect(CastVoiceRegistry.layer(forID: "") == nil)
    }

    @Test func layerCollectionsArePartitionedNoOverlap() {
        let lessonsSet = Set(CastVoiceRegistry.lessonsLayerProfiles.map(\.id))
        let worldSet = Set(CastVoiceRegistry.worldLayerProfiles.map(\.id))
        let metaSet = Set(CastVoiceRegistry.metaLayerProfiles.map(\.id))

        #expect(lessonsSet.intersection(worldSet).isEmpty)
        #expect(lessonsSet.intersection(metaSet).isEmpty)
        #expect(worldSet.intersection(metaSet).isEmpty)

        let union = lessonsSet.union(worldSet).union(metaSet)
        #expect(union.count == 10)
    }

    // MARK: - Coaching surface → layer routing

    @Test func everyCoachingSurfaceReportsItsLayer() {
        for surface in CastVoiceRegistry.CoachingSurface.allCases {
            // Sanity: surface.layer is non-nil (compile-time enforced; runtime
            // check confirms the switch is total).
            let layer = surface.layer
            #expect(CastVoiceLayer.allCases.contains(layer))
        }
    }

    @Test func worldLayerSurfacesRouteToFourRegisterCharacters() {
        let worldSurfaces: [CastVoiceRegistry.CoachingSurface] = [
            .voiceRegisterEpic,
            .voiceRegisterLyric,
            .voiceRegisterComic,
            .voiceRegisterTragic,
        ]
        let expectedSlugs = ["heralda", "murmur", "quip", "vesperline"]
        for (surface, expected) in zip(worldSurfaces, expectedSlugs) {
            #expect(surface.castID == expected, "\(surface) should route to \(expected)")
            #expect(surface.layer == .world)
        }
    }

    @Test func metaLayerSurfaceRoutesToAria() {
        let surface = CastVoiceRegistry.CoachingSurface.audiencePerception
        #expect(surface.castID == "aria")
        #expect(surface.layer == .meta)
        // DN-D Aria-is-data rule: surface uses `.closing` so the LM
        // produces a reflective observation, never a corrective scaffold.
        #expect(surface.trigger == .closing)
    }

    @Test func lessonsLayerSurfacesAllUseLessonsLayer() {
        let lessonsSurfaces: [CastVoiceRegistry.CoachingSurface] = [
            .branchPointReached,
            .branchReflectionConfirmed,
            .tagBalanceImbalance,
            .subtextDiscovered,
            .subtextConfirmed,
            .voiceDrift,
            .pauseBeat,
        ]
        for surface in lessonsSurfaces {
            #expect(surface.layer == .lessons)
        }
    }

    // MARK: - Kit gating per layer

    @Test func layerMinimumKitNumbersMatchHandoffPacing() {
        // Per Docs/HANDOFF_FROM_LABSMITH_DN_ENHANCEMENT.md § 4 pacing — Patter
        // is solo for early kits; WORLD-layer guests enter mid-arc; Audience
        // Aria enters late when listener-perspective content surfaces.
        #expect(CastVoiceLayer.lessons.minimumKitNumber == 1)
        #expect(CastVoiceLayer.world.minimumKitNumber == 5)
        #expect(CastVoiceLayer.meta.minimumKitNumber == 11)
    }

    // MARK: - Aria-is-data rule (load-bearing DN-D constraint)

    @Test func ariaCatchphrasesNeverGradeOrCorrect() {
        let correctiveLexicon = [
            "correct", "wrong", "right answer", "fix this", "you should",
            "you must", "better to", "improve", "shame",
        ]
        let aria = CastVoiceRegistry.aria
        for phrase in aria.catchphrases {
            let lower = phrase.lowercased()
            for word in correctiveLexicon {
                #expect(
                    !lower.contains(word),
                    "Aria's catchphrase contains corrective term '\(word)': \(phrase)"
                )
            }
        }
    }

    @Test func ariaAntiPatternsAreLoadBearingAboutNotCorrecting() {
        // The DN-D rule "Aria's reactions are data, not corrective" must
        // surface in the antiPatterns string so the system prompt
        // enforces it at generation time.
        let blob = CastVoiceRegistry.aria.antiPatterns.joined(separator: " ").lowercased()
        // Must explicitly forbid grading, scoring, fixing, or rewriting.
        let mandatory: [String] = ["grade", "rewrite", "data"]
        for token in mandatory {
            #expect(
                blob.contains(token),
                "Aria's antiPatterns missing load-bearing token '\(token)'"
            )
        }
    }

    @Test func ariaReportsListenerExperienceRatherThanJudgment() {
        // Soft test of register: at least one catchphrase frames the
        // utterance as an observation ("I noticed" / "from back here" /
        // "listeners" / "I felt the room" — listener-stance vocabulary).
        let listenerStanceTokens = ["i noticed", "from back here", "listeners", "i felt", "i hear"]
        let pool = CastVoiceRegistry.aria.catchphrases.map { $0.lowercased() }
        let hasListenerStance = pool.contains { phrase in
            listenerStanceTokens.contains { phrase.contains($0) }
        }
        #expect(hasListenerStance, "Aria's catchphrases should foreground listener stance")
    }

    // MARK: - WORLD-layer register identification

    @Test func worldLayerEmbodimentsNameTheRegisterTheyTeach() {
        // Each WORLD-layer character must call out the register they're
        // demonstrating so the kid can pattern-match the cast member to
        // the voice-register quadrant.
        #expect(CastVoiceRegistry.heralda.embodiment.lowercased().contains("third-person"))
        #expect(CastVoiceRegistry.murmur.embodiment.lowercased().contains("first-person"))
        #expect(CastVoiceRegistry.quip.embodiment.lowercased().contains("comic"))
        #expect(CastVoiceRegistry.vesperline.embodiment.lowercased().contains("tragic"))
    }

    @Test func worldLayerCharactersNeverClaimSuperiorRegister() {
        // Cluster-shared WORLD voice-register archetypes EACH demonstrate
        // a register without claiming superiority — anti-pattern must
        // forbid "register is the right one" type claims so the kid
        // doesn't read one register as canonical.
        let worldProfiles = CastVoiceRegistry.worldLayerProfiles
        for profile in worldProfiles {
            let blob = profile.antiPatterns.joined(separator: " ").lowercased()
            #expect(
                blob.contains("right one") || blob.contains("right register"),
                "\(profile.id) missing 'register is one of four' guard"
            )
        }
    }
}
