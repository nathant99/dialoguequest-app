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

## Labsmith-side pre-gen pipeline (R411 #889; DN-S Phase 2 audio drama)

For **pre-generated audio bundled into apps as static CAF files** (NOT runtime TTS streaming — that's the path above), labsmith owns the gen pipeline end-to-end per `.claude/rules/portfolio.md` § Asset generation ownership.

Canonical script: `scripts/gen_dn_s_audio_drama.py`. Pattern lifted from CQ's `GeminiService.swift` TTS path:

### Authoritative TTS model + auth

- **Model**: `gemini-2.5-flash-preview-tts` via Gemini API (`generativelanguage.googleapis.com`) — same model CQ uses in production
- **Auth**: `GEMINI_API_KEY` env var, or `~/.config/labsmith/gemini_api_key` (chmod 600) — same key surface as `scripts/gen_app_illustrations.py`
- **SDK**: `google-genai` Python (`pip3 install google-genai`); `genai.Client(api_key=...).models.generate_content(model=..., config=GenerateContentConfig(response_modalities=["AUDIO"]))`
- **Pro tier** (`gemini-2.5-pro-preview-tts`) reserved for hero-character voicing where Flash quality is insufficient

### Per-character voice — prompt-driven, NOT cloning

Gemini 2.5 TTS does not clone custom voices (that's Studio-tier Cloud TTS, enterprise). Instead, per-character voice register from `<app>-app/Docs/dn-s/chapters/<char>.md` § Voice register becomes the TTS prompt prefix:

```
Read the following AS <character>. Voice style: <directive from script>. Pace: slightly slower than normal adult speech; clear and deliberate. Tone: age-9-14 readable; warm but not saccharine; trust the reader's intelligence. Voice register guidance: <voiceRegister text from chapter, ≤300 chars>. Text: <line>
```

Apps NEVER author this prompt — labsmith does at gen time. The per-character voiceRegister card is the single source of truth.

### Output format chain (updated 2026-06-02 per ADR-022 Q2)

1. Gemini 2.5 TTS returns `audio/L16;codec=pcm;rate=24000` (raw signed-16-bit PCM mono @ 24kHz)
2. Labsmith concatenates per-line PCM bytes + tracks per-line byte offsets for WebVTT timing
3. Wrap concatenated PCM in 44-byte RIFF/WAVE header → WAV (port of CQ's `wrapPCMInWAV` in Python at `scripts/gen_dn_s_audio_drama.py:wrap_pcm_in_wav`)
4. **Triple-emit from the single WAV**:
   - **`.caf`** (app-bundled; iOS-native): `afconvert -f caff -d aac -b 64000 -c 1 in.wav out.caf`
   - **`.m4a`** (web-distributed; universal browser support): `afconvert -f m4af -d aac -b 64000 -c 1 in.wav out.m4a`
   - **`.vtt`** (WebVTT chapter+transcript): per-line PCM offset → timestamp; `<v Character>line text` voice tag for WCAG accessibility + per-speaker player styling
5. Ship all three (`.caf` + `.m4a` + `.vtt`) + `catalog.json` to `<app>-app/Resources/AudioDramas/<app>/` via cross-repo PR
6. App-side `ForgeAudio.AudioDramaPlayer` (ForgeKit 0.99.11+) consumes the bundled `.caf` via `Bundle.module`; spark-anvil-site `<AudioDramaPlayer />` component consumes `.m4a` + `.vtt` via static `public/audio/<app>/` serving

**Catalog metadata** (post-ADR-022): `catalog.json` per-drama entries now carry `bundlePath` (CAF), `webM4APath`, `webVTTPath`, and `chapters[]` (array of `{index, startMs, endMs, character}` per line) so consumers can build chapter-marker navigation in either client.

**Legacy CAF backfill** (for the 124 dramas shipped before ADR-022): the gen script only emits the new sibling files going forward. For existing CAFs, backfill via `afconvert -f m4af -d aac -b 64000 -c 1 existing.caf out.m4a` + write a placeholder VTT (or re-run the full gen script for line-accurate VTT timings).

### Cost discipline (R410 #888)

- Gemini 2.5 Flash TTS: ~$0.00-0.20 per drama (within free monthly tier for pilot)
- Gemini 2.5 Pro TTS: ~$2 per drama (reserve for hero characters)
- ElevenLabs A/B comparison (Phase 2A only): ~$30-100 per drama
- Per `.claude/rules/portfolio.md` table, all pre-1.0 audio gen lives within the ~$5K Phase 2 envelope; Gemini's cost-efficiency leaves headroom for Phase 2B etymology triad + ensemble dramas + retry takes

### Script-format convention

Audio drama scripts live at `labsmith/Resources/AudioDramaScripts/<app>/<drama-title>.script.md` with YAML front-matter (`drama-title:` + `app:` + `source-chapter:` + `duration-target-seconds:`) followed by `[CHARACTER, voice-directive]: dialogue` markers. The format is consumed by `gen_dn_s_audio_drama.py` automatically.

### Pre-gen vs runtime — orthogonal axes

If an app needs RUNTIME TTS (kid types a word → server proxies → returns audio mid-session), that's the path documented above in § Server: wrap raw PCM in WAV. NOT this pre-gen path. They share the same Gemini model + same WAV-wrap mechanic, but run at different times by different actors (runtime: app server; pre-gen: labsmith curation).

## Cross-references

- `labsmith/.claude/rules/debug-logging.md` § Real-world cascade lessons — body-sniff sizing + auth-consistency + "don't declare fixed early" rules
- `labsmith/.claude/rules/portfolio.md` § Asset generation ownership + handoff requirement — Phase 2 audio drama listed in canonical asset class table
- `labsmith/Docs/RESEARCH_TTS_AUDIO_PIPELINE_CASCADE_2026-05-29.md` — full 8-lesson cascade table + per-layer diagnosis methodology
- `labsmith/Docs/PLAN_DN_S_PHASE_2_AUDIO_DRAMA.md` — parent plan (Option E of DN-S Integration per ADR-019)
- `labsmith/scripts/gen_dn_s_audio_drama.py` — canonical labsmith-side pre-gen script (R411 #889)
- `curiosityquest-app/Server/CuriosityQuestServer/Sources/Services/GeminiService.swift` (PRs #137 + #138) — gzip-disable + PCM→WAV reference impl (server runtime path)
- `curiosityquest-app/Packages/Libraries/Sources/Services/TTSService.swift` (PRs #131 / #134 / #136) — iOS-side body-sniff + timeout diagnostics
- `forgekit/Sources/Client/ForgeAudio/AudioDramaPlayer.swift` (0.99.11) — app-side bundle player
- `.claude/rules/forgekit.md` § Server `/version` endpoint — companion observability rule
<!-- END LABSMITH-SYNCED CONTENT -->
