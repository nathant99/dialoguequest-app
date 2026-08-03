import Foundation
import SwiftUI
import ForgeAudio
import SharedUI

// MARK: - Catalog loading (hub-format → ForgeAudio types)
//
// The hub-generated `catalog.json` is NOT directly `Codable`-decodable into
// ForgeAudio's `AudioDramaCatalog`: its per-drama `chapters[]` are per-line TTS
// timing markers (`{index, startMs, endMs, character}`), whereas ForgeAudio's
// `AudioDramaChapter` is a kid-facing navigable chapter (`{title, startSeconds,
// skipSummary}`), and there is no `AudioDramaCatalog.load(from:)`. So we decode a
// lightweight shape of the fields we need and construct ForgeAudio values via
// their public init. A single opener chapter is synthesized (ForgeAudio requires
// `!chapters.isEmpty`); DialogueQuest is standard-register (writing craft, the
// Sprig/Glance/Weigh/Brogue/Rest cast set `reviewerGated: false`, not
// trauma-gated), so off-ramps are skip±seconds + stop — skip-to-chapter
// navigation isn't required. (The chapter-schema divergence is flagged to hub
// for a native catalog per Docs/HANDOFF_FROM_HUB_AUDIO_DRAMA_VERIFY_AND_WIRE.md.)

private struct RawDramaCatalog: Decodable {
    let dramas: [RawDrama]
}

private struct RawDrama: Decodable {
    let id: UUID
    let title: String
    let appSlug: String
    let sourceChapterSlugs: [String]
    let durationSeconds: Double
    let bundlePath: String
}

/// App-owned audio-drama service: decodes the bundled catalog once and owns the
/// `ForgeAudio.AudioDramaPlayer`. Held via `@State` so it's built once.
@MainActor
@Observable
public final class AudioDramaService {
    public let catalog: AudioDramaCatalog
    public let player: AudioDramaPlayer

    public init() {
        let loaded = Self.loadCatalog()
        self.catalog = loaded
        self.player = AudioDramaPlayer(bundle: .module, dramaCatalog: loaded)
    }

    /// Dramas whose source chapter matches a cast member's slug.
    public func dramas(forCharacter slug: String) -> [AudioDrama] {
        catalog.dramas.filter { $0.sourceChapterSlugs.contains(slug) }
    }

    /// Every `bundlePath` in the decoded catalog. Exposed for the bundling
    /// test (which asserts each one resolves in `Bundle.module`) so the test
    /// need not import ForgeAudio to reach into `AudioDrama`.
    package var bundlePaths: [String] {
        catalog.dramas.map(\.bundlePath)
    }

    /// Resolves a drama's `bundlePath` in the AppFeature bundle, mirroring
    /// ForgeAudio's subdirectory-aware lookup. Exposed for tests to assert the
    /// `.copy("AudioDramas")` bundling actually ships every referenced CAF —
    /// `Bundle.module` here is the AppFeature source bundle (this code compiles
    /// into AppFeature), so the test runs against the real shipped resources.
    package static func resolvedURL(forBundlePath path: String) -> URL? {
        let comps = path.split(separator: ".", omittingEmptySubsequences: false)
        guard comps.count >= 2 else { return nil }
        let ext = String(comps.last ?? "")
        let name = comps.dropLast().joined(separator: ".")
        if let url = Bundle.module.url(forResource: name, withExtension: ext) { return url }
        if let slash = name.lastIndex(of: "/") {
            let subdir = String(name[..<slash])
            let leaf = String(name[name.index(after: slash)...])
            if let url = Bundle.module.url(forResource: leaf, withExtension: ext, subdirectory: subdir) {
                return url
            }
        }
        return nil
    }

    /// Resolves + decodes `AudioDramas/dialoguequest/catalog.json` from the
    /// AppFeature bundle. `.copy` preserves the subdirectory, so try the
    /// subdirectory lookup then fall back to flat (defensive, per the
    /// `.process`-flatten gotcha class).
    static func loadCatalog() -> AudioDramaCatalog {
        let url = Bundle.module.url(
            forResource: "catalog", withExtension: "json",
            subdirectory: "AudioDramas/dialoguequest"
        ) ?? Bundle.module.url(forResource: "catalog", withExtension: "json")

        guard let url,
              let data = try? Data(contentsOf: url),
              let raw = try? JSONDecoder().decode(RawDramaCatalog.self, from: data)
        else {
            return AudioDramaCatalog(dramas: [])
        }

        let dramas = raw.dramas.map { r in
            AudioDrama(
                id: r.id,
                title: r.title,
                appSlug: r.appSlug,
                sourceChapterSlugs: r.sourceChapterSlugs,
                durationSeconds: r.durationSeconds,
                bundlePath: r.bundlePath,
                chapters: [
                    AudioDramaChapter(
                        title: r.title,
                        startSeconds: 0,
                        skipSummary: "Listen to the whole story."
                    )
                ],
                moderationSensitivity: .normal
            )
        }
        return AudioDramaCatalog(dramas: dramas)
    }
}

// MARK: - Player sheet

/// Minimal audio-drama player surface — play / pause / resume / stop / skip.
/// Drives the `ForgeAudio.AudioDramaPlayer` actor from the main actor via tasks.
struct AudioDramaPlayerSheet: View {
    let dramas: [AudioDrama]
    let player: AudioDramaPlayer
    @Environment(\.dismiss) private var dismiss

    @State private var activeDrama: AudioDrama?
    @State private var isPlaying = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(dramas) { drama in
                    Section {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(drama.title)
                                .font(.headline)
                                .foregroundStyle(DialoguePalette.inkBlue)
                            Text(durationLabel(drama.durationSeconds))
                                .font(.caption)
                                .foregroundStyle(.secondary)

                            controls(for: drama)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Audio Drama")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        Task { await player.stop(); dismiss() }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func controls(for drama: AudioDrama) -> some View {
        let isActive = activeDrama?.id == drama.id
        HStack(spacing: 20) {
            Button {
                Task { await player.skipBackward(seconds: 15) }
            } label: {
                Image(systemName: "gobackward.15")
            }
            .disabled(!isActive)
            .accessibilityLabel("Skip back 15 seconds")

            Button {
                if isActive, isPlaying {
                    Task { await player.pause(); isPlaying = false }
                } else if isActive {
                    Task { await player.resume(); isPlaying = true }
                } else {
                    Task {
                        try? await player.play(drama)
                        activeDrama = drama
                        isPlaying = true
                    }
                }
            } label: {
                Image(systemName: (isActive && isPlaying) ? "pause.circle.fill" : "play.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(DialoguePalette.rust)
            }
            .accessibilityLabel(isActive && isPlaying ? "Pause" : "Play")
            .accessibilityHint("Plays the audio drama \(drama.title).")

            Button {
                Task { await player.skipForward(seconds: 15) }
            } label: {
                Image(systemName: "goforward.15")
            }
            .disabled(!isActive)
            .accessibilityLabel("Skip forward 15 seconds")

            Spacer()

            Button {
                Task { await player.stop(); activeDrama = nil; isPlaying = false }
            } label: {
                Image(systemName: "stop.circle")
            }
            .disabled(!isActive)
            .accessibilityLabel("Stop")
        }
        .font(.title3)
        .buttonStyle(.plain)
    }

    private func durationLabel(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}
