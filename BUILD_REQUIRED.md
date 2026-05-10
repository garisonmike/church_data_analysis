# ⚠️ Code Generation Required

After extracting this archive, run the following command **before building or testing** the app:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This regenerates `lib/database/app_database.g.dart` to reflect the three new
database columns added in this batch:

| Column | Table | Schema version |
|--------|-------|---------------|
| `baptisms` | `WeeklyRecords` | v3 |
| `holy_communion` | `WeeklyRecords` | v4 |
| `pin_hash` | `AdminUsers` | v5 |

After regeneration, confirm the file contains all three column names, then run:

```bash
flutter test
flutter analyze
```

All tests should pass. Zero analyzer errors expected in the changed files.
