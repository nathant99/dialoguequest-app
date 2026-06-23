import SwiftUI
import SharedUI

/// Thin per-cast chip rendered alongside Patter's main bubble when the
/// `CastVoicingService` produces a voicing. Patter stays the protagonist
/// (Pattern B); this chip lets the cast member's voice register surface
/// as supplementary coaching without claiming the protagonist slot.
///
/// Liquid Glass per `.claude/rules/liquid-glass.md` § B (interactive
/// controls). Read-only here — no `.interactive()` — so it stays a
/// passive surface; tinted with the cast's signature accent.
struct CastVoicingChip: View {
    let voicing: CastVoicingService.Voicing

    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            castAvatar
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(voicing.displayName) hears…")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(castAccent)
                Text(voicing.utterance)
                    .font(.callout)
                    .foregroundStyle(DialoguePalette.inkBlue)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(chipBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(voicing.displayName) coaching")
        .accessibilityValue(voicing.utterance)
        .accessibilityIdentifier("cast.voicing.chip.\(voicing.castID)")
    }

    @ViewBuilder
    private var chipBackground: some View {
        if reduceTransparency {
            castAccent.opacity(0.10)
        } else {
            castAccent.opacity(0.06)
        }
    }

    /// Cast avatar — portrait when shipped (LESSONS layer), letter chip
    /// fallback otherwise (WORLD / META archetypes don't ship per-app
    /// portraits per Pattern B + `Docs/HANDOFF_FROM_HUB_CAST_PORTRAITS.md`).
    @ViewBuilder
    private var castAvatar: some View {
        if CastPortraitImage.url(forSlug: voicing.castID) != nil {
            CastPortraitImage.image(forSlug: voicing.castID)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 36, height: 36)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .strokeBorder(castAccent.opacity(0.35), lineWidth: 1.5)
                )
        } else {
            ZStack {
                Circle()
                    .fill(castAccent.opacity(0.18))
                    .frame(width: 36, height: 36)
                Text(voicing.displayName.prefix(1))
                    .font(.callout.weight(.semibold))
                    .foregroundStyle(castAccent)
            }
        }
    }

    /// Each profile gets a stable accent tint so the kid can pattern-match
    /// "this kind of bubble = this kind of coaching." Tints are derived
    /// from `DialoguePalette`; same hex space as Patter's primary rust.
    private var castAccent: Color {
        switch voicing.castID {
        case "brogue": return DialoguePalette.inkBlue
        case "glance": return DialoguePalette.rust
        case "rest":   return DialoguePalette.warmGold
        case "sprig":  return Color(red: 75.0 / 255.0, green: 130.0 / 255.0, blue: 95.0 / 255.0)
        case "weigh":  return Color(red: 120.0 / 255.0, green: 90.0 / 255.0, blue: 160.0 / 255.0)
        default:       return DialoguePalette.rust
        }
    }
}
