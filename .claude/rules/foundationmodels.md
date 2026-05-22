# FoundationModels Patterns

## Availability

- **Always check first**: `SystemLanguageModel.default.availability == .available` — gate all AI features
- **Store model reference**: `let model = SystemLanguageModel.default` as a stored property — it's `Observable`, derive availability via computed property. Never re-create per call
- **Handle all states**: `.available`, `.unavailable(.deviceNotEligible)`, `.unavailable(.appleIntelligenceNotEnabled)`, `.unavailable(.modelNotReady)` (downloading)

## Session Management

- **Lazy session**: Create `LanguageModelSession` on first use, reuse across requests — never create per-call
- **Always provide fallbacks**: `try?` around LLM calls, fall back to static content dictionaries
- FoundationModels is paused/unloaded in background and Game Mode — never rely on it for time-critical logic

## Structured Output

- Use `@Generable` structs with `@Guide` properties for typed responses
- Unwrap `.content` from the response
- **Property order matters**: LLM generates properties sequentially in declaration order. Put dependencies first (e.g., question prompt before answer)
- Tailor `@Generable` models to include only needed fields — smaller schemas = faster generation

## Content Safety

- All AI-generated content is draft until verified — never ship unreviewed AI output
- Known risk areas: spelling/grammar rules, science facts with specific numbers, math examples, historical dates
- Use hedging language when uncertain: "usually", "often", "in most cases"
