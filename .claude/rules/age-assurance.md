# Age Assurance & COPPA (2026 Updates)

## Declared Age Range API (iOS 26.2+)

Returns age categories via Family Sharing: Under 13 (child), 13-15 (teen), 16-17 (older teen), Over 18 (adult). Actual birthdate never shared.

**CRITICAL**: Receiving "under 13" creates **COPPA actual knowledge** — all consent flows and record-keeping requirements immediately apply. Do not integrate this API without full COPPA compliance in place.

## 2026 FTC COPPA Rule Amendments

Compliance deadline: **April 22, 2026**. First update since 2013.

| Requirement | Detail |
|---|---|
| Opt-in consent for targeted ads | Separate verifiable parental consent required for ad data sharing |
| Data retention limits | Must define specific purpose and timeframe for any personal info |
| Written security program | Mandatory documented children's data security program |
| Safe Harbor transparency | COPPA Safe Harbor programs must publicly disclose membership lists |

### Portfolio Status

- **Already compliant**: No PII collection, no third-party analytics, no advertising
- **Data retention**: SwiftData student progress is local-only, no cloud sync of child data
- **Push notifications**: FTC explicitly preserved educational push notifications

## PermissionKit (Significant Change API)

When apps make significant changes, `PermissionKit` requires parental consent for children/teens. Apps must prevent access to new features until parent approves.

## Age Rating Updates

- New ratings: 13+, 16+, 18+ (joining 4+ and 9+)
- All apps must have updated age rating questionnaires
- AI content frequency affects age rating — disclose FoundationModels usage

## State Laws

| Date | Jurisdiction | Requirement |
|---|---|---|
| May 6, 2026 | Utah | Full compliance required |
| Jul 1, 2026 | Louisiana | Age category sharing |

Monitor state-level requirements — they may exceed federal COPPA minimums.
<!-- END LABSMITH-SYNCED CONTENT -->
