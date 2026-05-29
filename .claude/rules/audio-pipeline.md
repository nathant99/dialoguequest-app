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

**Future**: `ForgeServerAudio` module candidate. Containing `wrapPCMInWAV` + `Accept-Encoding: identity` request-builder helpers so portfolio servers using audio APIs share the implementation. Trigger: 2nd portfolio server adopts audio API (CQ is sole user today).

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

## Cross-references

- `labsmith/.claude/rules/debug-logging.md` § Real-world cascade lessons — body-sniff sizing + auth-consistency + "don't declare fixed early" rules
- `labsmith/Docs/RESEARCH_TTS_AUDIO_PIPELINE_CASCADE_2026-05-29.md` — full 8-lesson cascade table + per-layer diagnosis methodology
- `curiosityquest-app/Server/CuriosityQuestServer/Sources/Services/GeminiService.swift` (PRs #137 + #138) — gzip-disable + PCM→WAV reference impl
- `curiosityquest-app/Packages/Libraries/Sources/Services/TTSService.swift` (PRs #131 / #134 / #136) — iOS-side body-sniff + timeout diagnostics
- `.claude/rules/forgekit.md` § Server `/version` endpoint — companion observability rule
<!-- END LABSMITH-SYNCED CONTENT -->
