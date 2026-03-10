# Launch Phase 6 (QA Matrix + Go/No-Go)

## Automated checks run
- `flutter test` ❌ FAILED
  - Failure: pending timer after widget tree disposed in `test/widget_test.dart` (App smoke test).
  - Likely cause: timer started in `main.dart` (`_BiblePageState.initState`) not cleaned/flushed in test harness.
- `flutter analyze --no-fatal-infos --no-fatal-warnings` ⚠️
  - 807 non-fatal issues (mostly style/lint + unused imports + debug prints).
  - No blocker compile errors observed.
- APK artifacts present ✅
  - Debug: `build/app/outputs/flutter-apk/app-debug.apk` (~271 MB)
  - Release: `build/app/outputs/flutter-apk/app-release.apk` (~126 MB)

## Go/No-Go Gate
- **Release buildability:** GO ✅
- **Automated test quality gate:** NO-GO ❌ (until timer-related test failure is fixed or test expectation adjusted)
- **Overall recommendation:** CONDITIONAL GO
  - Ship internally / beta testing: **GO**
  - Public production release with CI gate on tests: **NO-GO** until failing widget test is addressed

## High-priority next fixes
1. Fix test timer leak in `test/widget_test.dart` / app init timer lifecycle.
2. Remove obvious noisy unused imports in app entry and feature pages.
3. Decide lint threshold (treat infos as warnings only in CI for now).

## Manual smoke matrix (run on device)
- Reader: open chapter, swipe next/prev, translation switch, back/forward nav.
- Verse actions: highlight (full + precision), note add/edit/delete, bookmark toggle, copy.
- Saved tab: verify bookmarks/highlights/notes appear and dismiss-delete works.
- Settings: font size, reading mode (incl. AMOLED), notification toggle/time.
- Daily verse: bookmark, note, copy, share and permission prompts.
- Audio: play/stop chapter readout and state restore.
