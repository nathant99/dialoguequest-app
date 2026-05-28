# Localization Patterns

Learned from CubeSensei. Apply when adding `.xcstrings` string catalogs.

## Brand Names

- **`Text(verbatim: "AppName")`** — Prevents accidental translation of the app name
- Mark brand names `shouldTranslate: false` in the `.xcstrings` catalog
- Algorithm notation, mathematical symbols, and technical notation also use `Text(verbatim:)`

## Non-SwiftUI Strings

- SwiftUI `Text("key")` auto-looks up localized strings — but this ONLY works in SwiftUI `Text`
- **`String(localized: "key")`** required for `AccessibilityNotification.Announcement`, share text, notification content, and any other non-`Text` usage

## String Catalog Gotchas

- **Symbol collision**: Two keys differing only in capitalization generate the same symbol — use identical casing or remove one (also in `warnings.md`)
<!-- END LABSMITH-SYNCED CONTENT -->
