---
paths:
  - "**/alcumusforge*/**"
  - "**/AlcumusForge/**"
  - "**/competition_problem*.py"
  - "**/Resources/Curriculum/alcumusforge/**"
---

# Competition Problem Ingestion (R-COMPETITION-PROBLEMS; 2026-06-07)

Portfolio-wide rule for ingesting **public competition-math archives** (AMC 8 / MATHCOUNTS / Math Kangaroo / public IMO shortlist / public AIME public-domain problems) into per-app question kits.

Codified per `Docs/RESEARCH_AOPS_INSPIRED_PORTFOLIO_INNOVATION_2026-06-07.md` + `Docs/ADR-026_AOPS_PORTFOLIO_INNOVATION_PHASE_1.md` as a Phase-1 prerequisite. The research finding: AoPS treats competition problems as the PRIMARY curriculum (not enrichment); we can ship a 17% problem-density increase per app at near-zero authoring cost by importing public archives.

## The principle

Public competition archives contain ~50 years of pedagogically-vetted, non-routine, depth-over-coverage problems. They are the empirical existence-proof that the AoPS approach works at scale. Spark & Anvil portfolio apps gain immediate problem density + AoPS-pattern fidelity by ingesting them — **subject to the constraints below**.

## What counts as "public"

The following archives are public-domain or explicitly licensed for educational re-use:

| Archive | License / status | Source |
|---|---|---|
| **AMC 8** (American Mathematics Contest 8) | MAA publishes archive; non-commercial educational re-use permitted with attribution | maa.org/AMC8 |
| **AMC 10 / 12** | Same as AMC 8 | maa.org |
| **AIME** (American Invitational Mathematics Examination) | Same as AMC | maa.org |
| **MATHCOUNTS** Chapter / State / National competitions | Public via mathcounts.org; non-commercial educational re-use permitted | mathcounts.org |
| **Math Kangaroo** (Kangourou Sans Frontières) | Public via mathkangaroo.org; non-commercial educational re-use permitted with attribution | mathkangaroo.org |
| **IMO public shortlist** | IMO publishes selected problems openly; re-use permitted with citation | imo-official.org |
| **AHSME** historical (pre-AMC) | Public historical archive | maa.org |
| **State Math Olympiad public archives** (USAMO, USAJMO public problems) | Public via MAA | maa.org |
| **MATHCOUNTS Trainer / OK Mathematical League / NCAML public sets** | Per-archive — check before ingesting | varies |

The following are **NOT** public-domain and must NOT be ingested:

- ❌ Singapore Math Olympiad commercial problem sets
- ❌ AoPS Alcumus problem bank (proprietary)
- ❌ Brilliant.org problem bank (proprietary)
- ❌ Art of Problem Solving textbook problems (copyrighted by AoPS)
- ❌ MOEMS / Math Olympiad for Elementary and Middle Schools (commercial)
- ❌ Mu Alpha Theta national competition problems (mixed copyright)

When unsure: don't ingest. Author original problems through the existing question-kit pipeline.

## Per-problem ingestion shape

Every imported problem MUST carry attribution metadata for the audit trail + display-time citation:

```json
{
  "id": "amc8-2019-q14",
  "source": "AMC 8 2019",
  "sourceURL": "https://artofproblemsolving.com/wiki/index.php/2019_AMC_8_Problems/Problem_14",
  "sourceLicense": "MAA public-domain educational re-use",
  "sourceYear": 2019,
  "sourceProblemNumber": 14,
  "topic": "<app-specific topic key>",
  "bloomLevel": "apply",
  "gradeLevel": "6-8",
  "originalPrompt": "<verbatim original problem text>",
  "rephrasedPrompt": "<kid-paced 9-14-register rephrasing>",
  "rephrasingMethod": "gemini-2.5-pro / hand-edit",
  "originalAnswer": "<verbatim original answer>",
  "answer": "<answer key in app's format>",
  "explanation": "<solution walk-through; cite original solution>",
  "originalSolutionURL": "<canonical solution URL if public>"
}
```

### The `rephrasedPrompt` field — load-bearing for kid-paced register

Competition problems are written at high-school / AMC register. The 9-14 portfolio audience needs **kid-paced rephrasing**:

- Replace olympiad jargon with plain-language equivalents
- Break long sentences into shorter ones
- Add 1-2 sentences of grounding context for unfamiliar concepts
- Preserve the mathematical structure verbatim
- Preserve the answer

**Rephrasing method**: `gemini-2.5-pro` with the Polya 4-step rephrasing prompt + human review per problem (per `.claude/rules/ai-content.md` — all AI-generated content is draft until verified). Per-problem hand-review takes ~30 seconds; the bulk of work is in batched rephrasing + spot-check.

## Kit slot — `kit_17_competition.json`

Per-app question kits currently span `kit_01_*.json` through `kit_16_*.json`. The competition-archive kit lands as **kit slot 17**:

| Slot | Name pattern | Source |
|---|---|---|
| 01-08 | Hand-authored per-domain | Original |
| 09-12 | Redistribution of 01-08 | Hand-authored |
| 13-16 | Cross-topic / application / misconception / synthesis | Hand-authored |
| **17** | **Competition problems** | **Imported via this rule** |

Kit 17 ships per the same JSON schema as 01-16. The per-problem attribution metadata is additive in `meta` field.

## The import pipeline

Tool: `scripts/import_competition_problems.py`. Pipeline:

1. **Source selection**: pick an archive + year range
2. **Topic mapping**: human authors a YAML mapping per-app: `competition_topic_map.yaml` mapping AMC topic keys → app topic keys (e.g., "Number Theory" → `fractionforge.fractions.equivalence` for fraction-relevant problems)
3. **Filtering**: pipeline pulls problems matching the topic map + grade level + AMC difficulty appropriate for ages 9-14 (AMC 8 problems mostly; AMC 10 problems 1-15; not AIME / USAMO)
4. **Rephrasing**: Gemini 2.5 Pro batched pass per problem → `rephrasedPrompt`
5. **Human review**: per-problem spot-check (~30 sec each)
6. **Output**: writes `Resources/Questions/<app>/kit_17_competition.json` matching the existing kit schema + per-problem attribution metadata
7. **Distribution**: `scripts/copy_kits_to_repos.sh --app <slug>` ships to the app repo

## Per-app handoff

When kit 17 ships to an app's repo, the same wave files `Docs/HANDOFF_FROM_LABSMITH_COMPETITION_PROBLEMS_KIT_17.md` per `.claude/rules/portfolio.md` § Standing rule — every asset distribution wave files a per-app handoff.

Handoff content:
- What shipped (count of problems + source archives + year range)
- How to consume (same as other kits; routes through existing `IllustrationRegistry` / question-kit loader)
- Attribution requirement: app UI MUST surface source + license per problem
- Trauma-safety: AMC / MATHCOUNTS problems are content-safe (no trauma-axis surfaces); IMO public-shortlist problems sometimes reference contexts requiring review (war / contested borders / etc.) — flag and exclude in topic mapping

## Attribution display requirement

App UI MUST surface attribution at problem display time:

```swift
// Required UI element when displaying a kit_17 problem:
Text("Source: AMC 8 2019, Problem 14 · Used under MAA educational re-use")
    .font(.caption2)
    .foregroundStyle(.secondary)
```

The attribution caption is non-optional. Hiding source is a license violation for some archives.

## Trauma-axis filtering

Some competition problems contain contexts that don't fit the 9-14 trauma-informed register:

- Problems referencing war / weapons / military counting (filter out)
- Problems with named historical figures (filter; rephrase to anonymous "a mathematician")
- Problems with stereotyped gendered / racial / ethnic / national framings (filter; rephrase)
- Problems with body-mass / weight / BMI context (filter per body-image-risk-app rules)

The pipeline runs a pre-filter pass via Gemini + categorical match. Filter rules ship as `scripts/competition_problem_filter_rules.yaml`.

## What this rule does NOT cover

- **Original problem authoring** — kits 01-16 stay original; the existing per-domain authoring discipline doesn't change
- **Competition CONTEXT** — we ship competition PROBLEMS, not competition format (no timers, no rankings, no leaderboards per ADR-026's anti-recommendations)
- **Per-locale archives** — non-English-language competition archives (e.g., Russian Mathematical Olympiad, Iranian Math Olympiad) are public but require translation + cultural review; deferred to Phase 2
- **Solutions video / multimedia** — only the textual problem + textual solution import; video sources excluded

## Cross-references

- `Docs/RESEARCH_AOPS_INSPIRED_PORTFOLIO_INNOVATION_2026-06-07.md` § 3 (move #4: competition problems as curriculum)
- `Docs/ADR-026_AOPS_PORTFOLIO_INNOVATION_PHASE_1.md` — decision artifact
- `Docs/TEMPLATE_COMPETITION_PROBLEM_INTEGRATION.md` — per-app integration template
- `.claude/rules/trauma-informed-content.md` — trauma-axis filtering rules
- `.claude/rules/ai-content.md` — AI-content draft-until-verified rule (applies to Gemini rephrasing)
- `.claude/rules/portfolio.md` § Asset generation ownership — handoff requirement
- `scripts/import_competition_problems.py` — import pipeline (skeleton in this PR; full impl Phase 1)
<!-- END LABSMITH-SYNCED CONTENT -->
