# SwiftData Safety Patterns

## Data Access

1. **Zero `@Query` in Views** — Use `modelContext.fetch(FetchDescriptor)` in `onAppear` → `@State` value-type caches. `@Query` re-evaluates on every model change across the entire store, causing cascading re-renders
2. **Never store `@Model` in `@State`** — `@Model` conforms to `@Observable`, so any read in `body` creates observation; mutation + save → re-evaluation → infinite loop. Use `@Model` as LOCAL variables only
3. **Value-type cache structs** — Create lightweight `nonisolated struct` caches (e.g., `BadgeData`, `SolveRecordData`) with only display fields. Populate from `@Model` objects in `onAppear`, never in `body`. Never pass `@Model` objects to views
4. **Save after insert** — Always `try? modelContext.save()` immediately after `modelContext.insert()` before storing `persistentModelID`
5. **ModelContext injection** — Pass from view's `onAppear` to ViewModel, NOT in `init` — `@Environment(\.modelContext)` only works in views

## Relationships

6. **Never traverse `@Relationship` in `body`** — Cache relationship data in `onAppear`. Fetch via `FetchDescriptor` as local variables
7. **`@Relationship` arrays are unordered** — SwiftData randomly reorders relationship arrays on reload. Always sort explicitly or add `sortOrder: Int` attribute
8. **Many-to-many relationships are slow** — 30× slower than Core Data. Batch operations; use `relationshipKeyPathsForPrefetching` in `FetchDescriptor`

## Schema Versioning & Migration

9. **Start with `VersionedSchema` from day one** — Even before first App Store release. Retrofitting is painful; starting early is free
10. **`VersionedSchema.versionIdentifier`** — Must be `static let`, not `static var` — global mutable state is a concurrency error
11. **One `VersionedSchema` per app version** — All `@Model` types live in the same `VersionedSchema` enum. Don't split models across versions
12. **Treat schema versions as release artifacts** — Create a new version per App Store release that changes models, not per development iteration
13. **`typealias` for current models** — `typealias Exercise = SchemaV2.Exercise` so app code never references version-specific types directly
14. **Order matters in `SchemaMigrationPlan`** — `schemas` array must be chronological (oldest → newest). `stages` array must match. Misordering silently corrupts data

### Lightweight vs Custom Migration

15. **Lightweight (automatic)** — Adding optional properties, adding properties with default values, renaming with `@Attribute(originalName:)`
16. **Custom (`MigrationStage`)** — Removing properties, changing types, splitting/merging models, data transforms, populating new required fields from existing data
17. **`willMigrate` sees old models only** — Use for reading/transforming data from the old schema before it's gone
18. **`didMigrate` sees new models only** — Use for populating new fields, fixing up relationships, or setting defaults based on migrated data
19. **Never force unwrap in migration closures** — A crash in `willMigrate`/`didMigrate` leaves the store in an unrecoverable state

### Silent Corruption Risks

20. **Rename without `originalName`** — SwiftData sees it as "delete old + add new" — existing data is silently lost
21. **Autosave after corruption** — SwiftData autosaves on `willResignActive`. If corrupt state reaches memory, it's persisted permanently. Validate data integrity before allowing saves
22. **Optionality changes** — Changing `String` → `String?` or vice versa without a migration stage can crash or lose data
23. **Uniqueness constraint violations** — `@Attribute(.unique)` violations prevent the app from launching entirely. Test constraint additions with existing production-like data
24. **Array attribute storage (iOS 26.1 known issue)** — Array attributes changed from Binary Data to Transformable storage, triggering "missing mapping model" errors on upgrade. Test array-containing models across OS versions

### Fail-Safe Recovery Pattern

25. **Try-catch container initialization** — Wrap `ModelContainer` init in `do/catch`. On failure: backup, recreate fresh, regenerate initial data
26. **Back up all 3 files** — `.store`, `.store-wal`, `.store-shm` — missing the WAL file means losing uncommitted transactions
27. **Backup location** — Use `FileManager.default.urls(for: .applicationSupportDirectory)` with a `Backups/` subfolder and timestamp

### Migration Testing

28. **Test every version path** — Create `ModelContainer` with old schema at `URL.temporaryDirectory`, insert representative data, then open with new schema. Verify all fields survived
29. **Test with production-like data volumes** — Empty databases migrate fine; databases with 1000+ records and relationships may not
30. **iOS 26 class inheritance** — `@Model` subclasses require `@available(iOS 26, *)` checks and dedicated `VersionedSchema` + `MigrationStage` entries

## @Observable/@Model Ownership Patterns

- `@State` only for objects the view **creates** (e.g., `@State private var engine = GameEngine()`)
- `var`/`let` for objects **passed in** — SwiftUI tracks `@Observable` automatically
- `@Bindable` for two-way `$bindings` on passed-in `@Observable`/`@Model`
- No `State(initialValue:)` in `init` — captures only first value
- Computed properties in `@Observable` must derive from tracked stored properties only
<!-- END LABSMITH-SYNCED CONTENT -->
