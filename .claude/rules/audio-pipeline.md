---
paths:
  - "**/*audio*.swift"
  - "**/*tts*.swift"
  - "**/*Audio*.swift"
  - "**/*TTS*.swift"
  - "**/Server/**/*.swift"
  - "scripts/*audio*.py"
  - "scripts/*tts*.py"
  - "scripts/gen_dn_s_audio_drama.py"
  - "scripts/gen_app_background_music.py"
  - "**/AudioDramas/**"
---

# Audio Pipeline (TTS proxying + iOS playback)

Portfolio-wide rules for servers proxying audio APIs (Google Cloud TTS / Gemini 2.5 TTS / ElevenLabs / OpenAI TTS / music-gen APIs) to iOS clients. Codified after a 7-root-cause cascade in CuriosityQuest TTS (PRs #130 → #138, 2026-05-29) where each layer's fix revealed the next layer's bug.

## Server: disable gzip on binary-payload responses

For TTS / image / video / large-base64 outbound calls via async-http-client:

```swift
var request = try makeRequest(url: url, ...)
request.headers.replaceOrAdd(name: "Accept-Encoding", value: "identity")
```

**Why**: swift-nio-extras' gzip decompressor can throw `NIOHTTPDecompression.ExtraDecompressionError.truncatedData` when the compressed stream doesn't complete cleanly. Proxy + streaming + edge cases interact. Binary payloads (audio, images, base64-encoded blobs) don't compress meaningfully anyway, so disabling sidesteps the bug at zero cost.

**Scope**: per-request, NOT globally. Text JSON responses DO benefit from gzip and should keep the default behavior. Apply only on the request builder for the outbound binary call.

## Server: wrap raw PCM in WAV before forwarding to iOS clients

Gemini 2.5 TTS (and several other audio APIs) returns `audio/L16;codec=pcm;rate=24000` — raw signed-16-bit PCM with no container. `AVAudioPlayer(data:)` on iOS can't auto-detect raw PCM and throws `kAudioFileUnsupportedFileTypeError` (OSStatus 1954115647 = `'typ?'`).

**Fix**: wrap in a 44-byte RIFF/WAVE header server-side before forwarding to iOS; change response mime type to `audio/wav`.

**Detection rule**: mime types starting with `audio/L16` / `audio/pcm` / `audio/L24` route through the wrapper. Non-PCM (MP3, OGG, AAC) passes through unchanged.

**Reference impl**: `curiosityquest-app/Server/CuriosityQuestServer/Sources/Services/GeminiService.swift` (PR #138, 2026-05-29) — see `wrapPCMInWAV(pcmData:sampleRate:channels:bitsPerSample:)` and `extractSampleRate(fromMimeType:default:)`.

**Future** (R168 #602 update; CQ App-side handoff `HANDOFF_FROM_APP_LIFT_FORGESERVERAUDIO_MODULE.md`): `ForgeServerAudio` module candidate, **proposed by CQ 2026-05-29**. Containing `wrapPCMInWAV` + `extractSampleRate` + optional `transcodeIfPCM` helpers + `Accept-Encoding: identity` request-builder helpers, so portfolio servers using audio APIs share the implementation. Pure value-type API; no Hummingbird / async-http-client dependency. CQ's reference impl in `Server/CuriosityQuestServer/Sources/Services/GeminiService.swift:808-857` is ready for verbatim extraction.

**Status**: DEFERRED to dedicated ForgeKit-release round (likely R170+). Module work + tests + version bump + downstream CQ migration is too much scope for a typical lift round. Trigger to expedite: 2nd portfolio server adopts a raw-PCM TTS API (CQ is sole user today).

## iOS: OSStatus → ASCII FourCC for AVFoundation errors

Multi-digit `Code=` values from `NSOSStatusErrorDomain` or `kAudioToolboxErrorDomain` are FourCC values cast to Int. Convert to hex, read as ASCII.

| Code | Hex | FourCC | Meaning |
|---|---|---|---|
| 1954115647 | 0x7479703F | `'typ?'` | `kAudioFileUnsupportedFileTypeError` |
| 1718449215 | 0x666D743F | `'fmt?'` | `kAudioFileUnsupportedDataFormatError` |
| 1685283391 | 0x6474613F | `'dta?'` | `kAudioFileInvalidFileError` |
| 1718449215 | 0x666D743F | `'fmt?'` | `kAudio_UnimplementedError` (overlap) |
| 1953063283 | 0x74717273 | `'tqrs'` | `kAudio_TooManyFilesOpenError` |

**Quick conversion**: `python -c "import struct; print(struct.pack('>I', N))"` — replace `N` with the OSStatus value to get the ASCII bytes.

**Why**: AVFoundation errors look like noise until you decode them. The error code IS the diagnostic — `'typ?'` means "I can't recognize this file's format" which immediately narrows to "the data isn't in a container the player recognizes" (often raw PCM without WAV wrapper).

## Diagnosis-flow rule (cascade lesson)

When an audio-pipeline issue surfaces, walk this order:

1. **iOS-side `AVAudioPlayer(data:)` error code** — convert OSStatus to FourCC; the FourCC names the layer (file-type / data-format / file-invalid)
2. **If `'typ?'`**: payload likely raw PCM without container. Check upstream server: is it forwarding `audio/L16` or `audio/pcm` mime type? Add WAV wrapper.
3. **If `'fmt?'`**: payload has a container but contains a codec AVFoundation doesn't support directly. Check what the upstream API actually returns (MP3? OGG?).
4. **If `truncatedData` server-side**: gzip decompression race. Disable gzip on the request.
5. **If endpoint silently 200s with empty body**: check auth-header consistency (the body might have errored upstream + been swallowed). See § "Auth header consistency check" in `debug-logging.md`.

## Hub-side pre-gen pipeline (R411 #889; DN-S Phase 2 audio drama)

For **pre-generated audio bundled into apps as static CAF files** (NOT runtime TTS streaming — that's the path above), hub owns the gen pipeline end-to-end per `.claude/rules/portfolio.md` § Asset generation ownership.

Canonical script: `scripts/gen_dn_s_audio_drama.py`. Pattern lifted from CQ's `GeminiService.swift` TTS path:

### Authoritative TTS model + auth

- **Model**: `gemini-2.5-flash-preview-tts` via Gemini API (`generativelanguage.googleapis.com`) — same model CQ uses in production
- **Auth**: `GEMINI_API_KEY` env var, or `~/.config/labsmith/gemini_api_key` (chmod 600) — same key surface as `scripts/gen_app_illustrations.py`
- **SDK**: `google-genai` Python (`pip3 install google-genai`); `genai.Client(api_key=...).models.generate_content(model=..., config=GenerateContentConfig(response_modalities=["AUDIO"]))`
- **Pro tier** (`gemini-2.5-pro-preview-tts`) reserved for hero-character voicing where Flash quality is insufficient

#### Verify the key BEFORE any paid batch (R-GEMINI-KEY-VERIFY-BEFORE-BATCH; 2026-07-02)

**Before running any paid Gemini wave (TTS, illustrations, cast portraits, book covers), sanity-check the key shape AND run a cheap auth probe — never assume the key is live.** Codified after the 2026-06-30 FractionForge session opened with `~/.config/labsmith/gemini_api_key` holding the 14-char literal placeholder `gemini api key`, which silently blocked all paid gen (the failure looked like a gen bug, not a config gap). Memory `project-gemini-key-placeholder.md` records the placeholder history.

Two-step check:

```bash
# 1. Shape check — a real key is ~39 chars, starts with "AIza", has no spaces
KEY=$(cat ~/.config/labsmith/gemini_api_key)
[ "${#KEY}" -ge 39 ] && [[ "$KEY" == AIza* ]] && [[ "$KEY" != *" "* ]] \
    && echo "shape OK (${#KEY} chars)" || echo "SUSPECT KEY — do NOT run a paid batch"

# 2. Cheap auth probe — one free list call; if it errors, the key is invalid/unauthorized
python3 -c "from google import genai; import os; \
c=genai.Client(api_key=open(os.path.expanduser('~/.config/labsmith/gemini_api_key')).read().strip()); \
print('auth OK:', next(iter(c.models.list())).name)"
```

Only run the wave once BOTH pass. This is cheaper than a half-completed batch that fails partway (Gemini partial-batch failures leave the pipeline in a mixed state; per R-GEMINI-KEY-SERIAL waves are single-flight, so a mid-batch auth failure wastes the whole serial run). When the probe passes but throughput crawls, suspect throttle (R-GEMINI-KEY-SERIAL), not the key.

### Per-character voice — prompt-driven, NOT cloning

Gemini 2.5 TTS does not clone custom voices (that's Studio-tier Cloud TTS, enterprise). Instead, per-character voice register from `<app>-app/Docs/dn-s/chapters/<char>.md` § Voice register becomes the TTS prompt prefix:

```
Read the following AS <character>. Voice style: <directive from script>. Pace: slightly slower than normal adult speech; clear and deliberate. Tone: age-9-14 readable; warm but not saccharine; trust the reader's intelligence. Voice register guidance: <voiceRegister text from chapter, ≤300 chars>. Text: <line>
```

Apps NEVER author this prompt — hub does at gen time. The per-character voiceRegister card is the single source of truth.

### Output format chain (updated 2026-06-17 Option PC; was 2026-06-02 ADR-022 Q2)

1. Gemini 2.5 TTS returns `audio/L16;codec=pcm;rate=24000` (raw signed-16-bit PCM mono @ 24kHz)
2. Hub concatenates per-line PCM bytes + tracks per-line byte offsets for WebVTT timing
3. Wrap concatenated PCM in 44-byte RIFF/WAVE header → WAV (port of CQ's `wrapPCMInWAV` in Python at `scripts/gen_dn_s_audio_drama.py:wrap_pcm_in_wav`)
4. **Triple-emit from the single WAV**:
   - **`.caf`** (app-bundled; iOS-native): `afconvert -f caff -d aac -b 64000 -c 1 in.wav out.caf` — **64 kbps**
   - **`.m4a`** (web-distributed; universal browser support): `afconvert -f m4af -d aac -b 48000 -c 1 in.wav out.m4a` — **48 kbps** per § Web M4A bitrate below
   - **`.vtt`** (WebVTT chapter+transcript): per-line PCM offset → timestamp; `<v Character>line text` voice tag for WCAG accessibility + per-speaker player styling
5. Ship all three (`.caf` + `.m4a` + `.vtt`) + `catalog.json` to `<app>-app/Resources/AudioDramas/<app>/` via cross-repo PR
6. App-side `ForgeAudio.AudioDramaPlayer` (ForgeKit 0.99.11+) consumes the bundled `.caf` via `Bundle.module`; spark-anvil-site `<AudioDramaPlayer />` component consumes `.m4a` + `.vtt` via static `public/audio/<app>/` serving

**Catalog metadata** (post-ADR-022): `catalog.json` per-drama entries now carry `bundlePath` (CAF), `webM4APath`, `webVTTPath`, and `chapters[]` (array of `{index, startMs, endMs, character}` per line) so consumers can build chapter-marker navigation in either client.

**Legacy CAF backfill** (for the 124 dramas shipped before ADR-022): the gen script only emits the new sibling files going forward. For existing CAFs, backfill via `afconvert -f m4af -d aac -b 48000 -c 1 existing.caf out.m4a` (48 kbps per § Web M4A bitrate below) + write a placeholder VTT (or re-run the full gen script for line-accurate VTT timings).

### Web M4A bitrate — 48 kbps (R-WEB-M4A-BITRATE; 2026-06-17)

**The web-distributed `.m4a` leg uses 48 kbps mono AAC-LC at 24 kHz.** The app-bundled `.caf` leg stays at 64 kbps.

Codified after `Docs/AUDIT_AUDIO_BITRATE_DEDUP_2026-06-17.md` (Option OD) surfaced that the prior portfolio-wide 64 kbps default contributed materially to Cloudflare Pages `public/` footprint at portfolio scale (3.36 GB across 1513 audio files). 48 kbps mono AAC-LC at 24 kHz on spoken-word lives well within the AAC-LC transparent band per ISO/IEC 14496-3 + AAC-LC perceptual-quality literature; the bitrate drop reduces site `public/audio/` + `public/chapters/` audio footprint by ~25% (~0.92 GB) at zero perceptible quality cost for portfolio TTS register.

**Why the asymmetry**:

| Leg | Bitrate | Where it ships | Sizing constraint |
|---|---|---|---|
| `.caf` | **64 kbps** | App bundle (`<app>-app/Resources/AudioDramas/<app>/*.caf` → bundled into IPA via `Bundle.module`) | App Store / TestFlight ceiling; CAF size is part of overall bundle size where IPA cap is at 4 GB+; current portfolio audio per app is <100 MB so 64 kbps headroom is fine |
| `.m4a` | **48 kbps** | Cloudflare Pages (`spark-anvil-site/public/{audio,chapters}/<app>/*.m4a`) | Cloudflare Pages `public/` deploy-size ceiling; saw ENOSPC at ~4.2 GB; 48 kbps mono drops audio footprint enough to push the ENOSPC ceiling out 24+ months |

**Forward gen**:
- `scripts/pilot_interleaved_ensemble_chapter.py::wav_to_m4a` — emits at 48 kbps (ffmpeg `-b:a 48k` / afconvert `-b 48000`)
- `scripts/gen_dn_s_audio_drama.py::encode_wav_to_m4a` — emits at 48 kbps (default arg); CAF leg unchanged at 64 kbps
- `scripts/backfill_audio_m4a_vtt.sh` — emits at 48 kbps when backfilling from CAF
- All other scripts emitting M4A for web distribution MUST follow

**Bulk re-encode**: `scripts/reencode_audio_to_48kbps.py` re-encodes the 1500+ historical M4A files already shipped to spark-anvil-site at 60-69 kbps. Operates on `public/{audio,chapters}/*/*.m4a`; skips versioned archives (defense in depth over PR #929 sync filter); idempotent (skip-if-already-at-target with 5 kbps margin); dry-run by default. Source-of-truth `.m4a` siblings in app-repo `Resources/AudioDramas/<app>/` are NOT touched by the bulk re-encode — those align to the source on next gen-run.

**Transcode-at-sync seam (R-TRANSCODE-AT-SYNC; 2026-06-17, Option RD)**: `sync_content_to_site.sh` now transcodes source `.m4a` files above target on-the-fly during sync. The seam closes the re-bloat regression class — without it, future syncs from un-updated 64 kbps sources would re-emit at the source rate on top of the already-transcoded 48 kbps site files.

| Source .m4a state | Sync behavior |
|---|---|
| At-target (≤ 53 kbps; 48 + 5 kbps margin) | Plain `cp -p` source to dst (preserves quality; no upscale) |
| Above-target (> 53 kbps) | `ffmpeg -c:a aac -b:a 48k -ac 1 -movflags +faststart -f mp4` source → dst |
| ffmpeg / ffprobe missing OR `--no-transcode` | Plain `cp -p` + warning emission |
| Transcode failure (corrupt source) | Cleanup tmp + fall back to plain `cp -p` (FAILED_TRANSCODE_FALLBACK_COPY counter) |

`sync_content_to_site.sh --no-transcode` reverts to pre-seam plain `cp` behavior for emergency-rollback / debugging. The seam is per-file independent; if one source m4a corrupts, the others still sync.

**Opportunistic per-app re-encode (companion of the seam)**: when an app session re-runs `gen_dn_s_audio_drama.py` (or any audio gen), the regenerated `.m4a` in `<app>-app/Resources/AudioDramas/<app>/` lands at 48 kbps by default. The next `sync_content_to_site.sh` run becomes a no-op for that app. Over time, the portfolio's source-of-truth `.m4a` files trend toward 48 kbps without a coordinated retroactive wave — closes Option A of the QC plan (`Docs/PLAN_APP_REPO_SOURCE_M4A_REENCODE_2026-06-17.md`) opportunistically.

**Reversibility**: a future rule supersession can restore 64 kbps. Re-encoding 48 → 64 is a non-recoverable lossy step (information lost in the 64 → 48 pass); if quality issues surface in the field, re-gen from source via `gen_dn_s_audio_drama.py --regen-all`. Source TTS PCM bytes are not retained, but Gemini API determinism for the same prompt is high enough that re-gen approximates the original within imperceptible margin.

**Bitrate selection** (why 48 not 32 or 56):

- 32 kbps mono AAC-LC: borderline for kid dialog clarity — perceptual audits flag artifact at high-energy plosives + sibilance
- 48 kbps mono AAC-LC: well within transparent band for 24 kHz spoken-word; chosen default
- 56 kbps mono AAC-LC: imperceptibly different from 48 kbps for spoken-word; not worth the 8 kbps headroom delta
- 64 kbps mono AAC-LC: prior portfolio default; transparent but over-spec for kid TTS narration register

**Empirical validation**: ffmpeg AAC-LC encoder hits actual ~50 kbps on portfolio TTS source when targeting 48k (VBR closes within tolerance); ~23% file-size reduction vs prior 64 kbps default observed in single-file smoke test (PR #932 verification).

### Cost discipline (R410 #888)

- Gemini 2.5 Flash TTS: ~$0.00-0.20 per drama (within free monthly tier for pilot)
- Gemini 2.5 Pro TTS: ~$2 per drama (reserve for hero characters)
- ElevenLabs A/B comparison (Phase 2A only): ~$30-100 per drama
- Per `.claude/rules/portfolio.md` table, all pre-1.0 audio gen lives within the ~$5K Phase 2 envelope; Gemini's cost-efficiency leaves headroom for Phase 2B etymology triad + ensemble dramas + retry takes

### Script-format convention

Audio drama scripts live at `spark-anvil-hub/Resources/AudioDramaScripts/<app>/<drama-title>.script.md` with YAML front-matter (`drama-title:` + `app:` + `source-chapter:` + `duration-target-seconds:`) followed by `[CHARACTER, voice-directive]: dialogue` markers. The format is consumed by `gen_dn_s_audio_drama.py` automatically.

### Register sourcing — UPPER tier (FK 7-8), NOT lower tier

Per `Docs/RESEARCH_AUDIO_DRAMA_TIER_2026-06-04.md` (14-source research), audio drama scripts source at the **upper-MG register (FK 7-8 / Wonder-Hatchet-Holes band)** even though chapter print editions ship in two tiers. The 2-year listening gap (Audio Publishers Association canonical; Berl 2010 brain imaging; Logan 2019 vocabulary measurement) means listening comprehension exceeds independent-reading comprehension by ≥2 grade levels through middle school.

A single drama at FK 7-8 serves the entire 9-14 audience because:
- A 9-year-old reading at lower-tier FK 4-6 can absorb FK 7-8 audio comfortably (+2 grade level cushion)
- A 13-year-old reading at upper-tier FK 7-8 gets the matching register
- One drama production cost serves both audiences — no need for two audio tiers

**Sourcing rule**:
- Drama scripts (`.script.md`) are hand-crafted/AI-authored INDEPENDENTLY from chapter MDs. They target the upper-MG register naturally because scene-driven dialogue + per-character voice directives match the upper-MG audio sweet spot. The dual-tier chapter rewrite work does NOT propagate to script files; they're stable.
- When a new drama is authored for a character whose Tier-2 chapter exists, the chapter's voice register card is the source of truth for the voice-directive prefix in the script. The Tier-1 chapter is NOT used.
- If a script needs revision (e.g., voice-register drift), edit `<drama-title>.script.md` directly + re-run `gen_dn_s_audio_drama.py`.
- Existing dramas generated from pre-rewrite chapters (FK 10.5) do NOT need re-generation — the gen pipeline reads the script file, not the chapter MD.

### TTS vendor choice — Gemini 2.5 canonical (post-V15 codification 2026-06-24)

Per `RESEARCH_TTS_QUALITY_GOOGLE_CLOUD_VS_ELEVENLABS_VS_GEMINI_2026-06-04` + V15 production verification: **Gemini 2.5 TTS won the A/B pilot.** As of V15 (2026-06-24) all 963 audio drama M4A files in production are Gemini-generated; 0 ElevenLabs variants reached production. The vendor decision is codified — new dramas ship Gemini Flash by default with NO A/B parallel.

- **Gemini 2.5 Flash TTS — CANONICAL for all portfolio dramas.** Native multi-speaker single-call is unique in the 2026 vendor landscape. Cost ~$0.20/drama; ~$25-75 portfolio-wide. This is the default; no per-drama vendor flag needed.
- **Gemini 2.5 Pro TTS — hero-character override only** (~$2 per drama vs Flash ~$0.20). Use when register fidelity matters more than cost. ~5 hero characters portfolio-wide.
- **ElevenLabs v3 — RETIRED from production rotation.** 3 Phase 2A pilot dramas (Sir Pinwell + Direct-Proof Dora + Lexa) preserved in `<app>-app/Resources/AudioDramas/<app>/<drama>-elevenlabs.caf` as A/B artifacts; not used for forward gen. ElevenLabs may return if a future audio-tag-driven hero drama justifies the ~$30-100 spend, but that requires per-drama founder approval.
- **Google Cloud TTS classic/WaveNet/Neural2/Studio — do NOT use.** No native multi-speaker; same cost as Gemini Pro without the multi-speaker advantage.

### Version preservation discipline (keep-all-versions policy)

Per WORK_QUEUE 2026-06-04 § Audio drama version preservation + ADR-025:

- `gen_dn_s_audio_drama.py` **refuses to overwrite** an existing `<drama>.caf` unless `--overwrite-canonical` (or `--regen-all`) is passed
- When `--overwrite-canonical` is in effect AND a prior canonical exists, the prior `<drama>.{caf,m4a,vtt}` is archived as `<drama>-v1-<YYYY-MM-DD>.{caf,m4a,vtt}` (date = prior file's mtime) BEFORE regen writes the new canonical
- `catalog.json versions[]` is appended with the archived version record + the new canonical entry; `canonicalVersionIndex` points to the new entry
- Site distribution (`scripts/sync_content_to_site.sh`) syncs ONLY the canonical version; sibling versions stay in the app repo as hub-side curation artifacts (not bundled to apps' production builds)
- Vendor variants (`<drama>-elevenlabs.caf`, future `<drama>-cloud-tts-neural2.caf` etc.) follow the same versions[] tracking; pre-existing convention preserved

### Default attribution metadata (when script.md front-matter is sparse)

`scripts/gen_dn_s_audio_drama.py` applies portfolio-canonical defaults so the 167 existing scripts (which predate the v2 front-matter convention) regenerate with attribution v2 without per-script edits:

| Field | Default source |
|---|---|
| `attribution-version` | defaults to `v2` (post-ADR-025) when unspecified |
| `trauma-gating` | derived from app slug membership in `DEFAULT_TRAUMA_GATED_APPS` (ADR-016/020/021 cluster) |
| `trauma-topic` | derived from `DEFAULT_TRAUMA_TOPICS[app_slug]` (parent-readable plain-language phrase) |
| `cultural-advisor` | derived from `DEFAULT_CULTURAL_TEK_APPS` set (Indigenous-knowledge-anchored cluster) |
| `curriculum-alignment` | derived from `DEFAULT_CURRICULUM_ALIGNMENT[app_slug]` (per-app primary standard) |
| `sensitivity-reviewer`, `funder` | explicit front-matter only (no defaults — these arrive per-grant / per-review) |

When a script wants to override the default (e.g., a new app slug not yet in the dictionary, or a per-drama trauma-topic variant), specify the field explicitly in the script.md front-matter and it wins.

### Re-gen orchestration

```bash
# Single drama (preview without API calls):
python3 scripts/gen_dn_s_audio_drama.py --app <slug> --drama <title-slug> --dry-run

# Single drama (real gen; archives prior canonical):
python3 scripts/gen_dn_s_audio_drama.py --app <slug> --drama <title-slug> --apply --overwrite-canonical

# Full portfolio regen (archives every prior canonical):
python3 scripts/gen_dn_s_audio_drama.py --regen-all --apply

# Batched run (smoke-test first N or resume from a known point):
python3 scripts/gen_dn_s_audio_drama.py --regen-all --apply --stop-after 5
python3 scripts/gen_dn_s_audio_drama.py --regen-all --apply --start-at activeforge/cheer-learnable-sportsmanship
```

`--regen-all` implies `--overwrite-canonical`. Without `--overwrite-canonical`, single-drama runs skip if the canonical CAF already exists. Scripts whose target `<app>-app` repo doesn't exist on disk are silently skipped (no place to ship).

### Pre-gen vs runtime — orthogonal axes

If an app needs RUNTIME TTS (kid types a word → server proxies → returns audio mid-session), that's the path documented above in § Server: wrap raw PCM in WAV. NOT this pre-gen path. They share the same Gemini model + same WAV-wrap mechanic, but run at different times by different actors (runtime: app server; pre-gen: hub curation).

## Cross-references

- `spark-anvil-hub/.claude/rules/debug-logging.md` § Real-world cascade lessons — body-sniff sizing + auth-consistency + "don't declare fixed early" rules
- `spark-anvil-hub/.claude/rules/portfolio.md` § Asset generation ownership + handoff requirement — Phase 2 audio drama listed in canonical asset class table
- `spark-anvil-hub/Docs/RESEARCH_TTS_AUDIO_PIPELINE_CASCADE_2026-05-29.md` — full 8-lesson cascade table + per-layer diagnosis methodology
- `spark-anvil-hub/Docs/PLAN_DN_S_PHASE_2_AUDIO_DRAMA.md` — parent plan (Option E of DN-S Integration per ADR-019)
- `spark-anvil-hub/scripts/gen_dn_s_audio_drama.py` — canonical hub-side pre-gen script (R411 #889)
- `curiosityquest-app/Server/CuriosityQuestServer/Sources/Services/GeminiService.swift` (PRs #137 + #138) — gzip-disable + PCM→WAV reference impl (server runtime path)
- `curiosityquest-app/Packages/Libraries/Sources/Services/TTSService.swift` (PRs #131 / #134 / #136) — iOS-side body-sniff + timeout diagnostics
- `forgekit/Sources/Client/ForgeAudio/AudioDramaPlayer.swift` (0.99.11) — app-side bundle player
- `.claude/rules/forgekit.md` § Server `/version` endpoint — companion observability rule
<!-- END LABSMITH-SYNCED CONTENT -->
