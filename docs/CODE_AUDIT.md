# Open Bible App — Deep Code Audit

**Date:** 2026-03-12
**Scope:** All Dart code in `lib/` (~27,298 lines across 85 files), build config, Android manifest, scripts
**Method:** Manual review + 7 parallel specialized audit agents (core services, presentation layer, silent failures, dead code, security, storage, providers)

---

## Executive Summary

A Flutter Bible study app with Riverpod state management, featuring 20+ feature modules. The app has **significant architectural debt** that threatens data integrity and user experience:

- **116 silent error-swallowing catch blocks** across 31 files
- **41 hardcoded `'kjv'` references** ignoring the user's selected translation
- **Three conflicting storage systems** (two SharedPreferences silos + file-based)
- **Triple model duplication** (BibleBook defined 3 times with incompatible schemas)
- **Font theme entirely non-functional** (references fonts that don't exist in the app)
- **6 unused dependencies** bloating the binary
- **1 smoke test** as the entire test suite
- **No crash/error reporting** in production builds

The app works for basic KJV reading but has data-loss risks, broken features, and significant maintainability issues.

---

## Findings by Severity

### CRITICAL (Data loss, crashes, completely broken features)

---

#### C1. Font Theme References Non-Existent Fonts

**File:** `lib/core/themes/app_theme.dart:167-238`

**Code:**

The `_buildTextTheme()` method defines all text styles for the app. Every style references a font not bundled in the app:

```dart
static TextTheme _buildTextTheme(Color primary, Color secondary) {
  return TextTheme(
    bodyLarge: TextStyle(
      fontFamily: 'Merriweather',   // line 171 — NOT BUNDLED
      fontSize: 18, height: 1.8, color: primary,
    ),
    bodyMedium: TextStyle(
      fontFamily: 'Merriweather',   // line 177 — NOT BUNDLED
      fontSize: 16, height: 1.7, color: primary,
    ),
    bodySmall: TextStyle(
      fontFamily: 'Merriweather',   // line 183 — NOT BUNDLED
      fontSize: 14, height: 1.6, color: secondary,
    ),
    headlineLarge: TextStyle(
      fontFamily: 'Lato',           // line 190 — NOT BUNDLED
      fontSize: 28, fontWeight: FontWeight.bold, color: primary,
    ),
    // ... 5 more headline/title/label styles all using 'Lato' (lines 196-237)
  );
}
```

**Root Cause:**

The theme was written for fonts `Merriweather` (serif) and `Lato` (sans-serif), but `pubspec.yaml:126-161` bundles completely different fonts:

| Bundled Font | Type | Status in Theme |
|---|---|---|
| CrimsonText | serif | Never referenced |
| Lora | serif | Never referenced |
| NotoSerif | serif | Never referenced |
| SourceSerif4 | serif | Never referenced |
| Roboto | sans-serif | Never referenced |

Flutter silently falls back to the platform default font when a named font isn't found. There is no warning at build time or runtime.

**Related/Affected Code:**

All four theme instances call `_buildTextTheme()`:
- `lightTheme` (line 60)
- `darkTheme` (line 108)
- `sepiaTheme` (line 146)
- `amoledTheme` (line 146)

Every widget in the app that uses `Theme.of(context).textTheme.bodyLarge` etc. renders in the system default font instead of the intended serif/sans-serif pairing. The app is shipping font assets (~200KB+) that are never displayed.

**Suggested Fix:**

Replace the two references throughout `_buildTextTheme()`:
- `'Merriweather'` → `'CrimsonText'` or `'Lora'` (body/verse text — serif for readability)
- `'Lato'` → `'Roboto'` (UI headlines/titles/labels — sans-serif)

These are already bundled and paid for in APK size.

---

#### C2. Three Conflicting Storage Systems

**Files:** `lib/core/services/storage_service.dart`, `lib/core/services/verse_storage_service.dart`, `lib/core/services/continue_reading_service.dart`

**Code & Root Cause:**

Three independent persistence systems exist, each with their own initialization and data format:

| System | Technology | Backing Store | Used For |
|---|---|---|---|
| `StorageService` | SharedPreferences singleton | `shared_prefs/*.xml` (Android) | Bookmarks, highlights, notes, settings, prayers, streaks, plans |
| `VerseStorageService` | File-based JSON + Completer lock | `verse_storage_backup_v5.json` | Bookmarks, highlights, notes, settings, history **(AUTHORITATIVE)** |
| `ContinueReadingService` | Separate SharedPreferences | `continue_reading_position` key | Last reading position (book, chapter, verse, scroll offset) |

The providers in `app_providers.dart` read from `VerseStorageService` at init:

```dart
class BookmarksNotifier extends StateNotifier<List<String>> {
  Future<void> init() async {
    await VerseStorageService.initialize();                    // line 27
    state = VerseStorageService.getBookmarks().map((b) => b.id).toList();
  }
```

But `StorageService` also has full bookmark CRUD methods (`addBookmark`, `removeBookmark`, `getAllBookmarks` — lines 324-365) that store data in a completely separate location.

**How Data Diverges — Bookmarks Example:**

`bookmarks_page.dart` merges from **three** separate sources (lines 46-73):

```dart
final bookmarks = VerseStorageService.getBookmarks();        // Source 1: file-backed
final providerBookmarks = ref.read(bookmarksProvider);       // Source 2: in-memory Riverpod
final prefs = await SharedPreferences.getInstance();
legacyBookmarks = prefs.getStringList('bookmarks') ?? [];    // Source 3: SharedPreferences list

// Merge: iterate legacy + provider bookmarks, create synthetic SavedVerse
// objects from bare ID strings for any not found in VerseStorageService
final mergedBookmarks = <SavedVerse>[...bookmarks];
for (final id in [...legacyBookmarks, ...providerBookmarks]) {
  final exists = mergedBookmarks.any((b) => b.id == id);
  if (!exists) {
    mergedBookmarks.add(_savedVerseFromLegacyId(id));        // line 73: reconstructed
  }
}
```

This merge creates synthetic `SavedVerse` objects with missing metadata (no `bookName`, no `text`, no `savedAt`) from bare ID strings — producing broken bookmark entries in the UI.

**Related/Affected Code:**

- `ContinueReadingService` (lines 19-29) creates its own `SharedPreferences.getInstance()` call, separate from `StorageService`'s instance — on some platforms these may be different instances
- `ContinueReadingService.savePosition()` writes 7 separate SharedPreferences keys non-atomically (lines 39-45) — process kill mid-write corrupts position data
- `StorageService` has 25 methods that silently no-op when `_prefs == null` (see C6)

**Suggested Fix:**

1. Make `VerseStorageService` the single source of truth for all persistent data
2. Delete `StorageService` entirely — migrate any prayer/streak/plan data it holds into `VerseStorageService`
3. Fold `ContinueReadingService` position data into `VerseStorageService` as a single JSON key (not 7 separate SharedPreferences keys)
4. Remove the triple-source merge in `bookmarks_page.dart` — read only from `VerseStorageService`

---

#### C3. App Initialization Swallows Fatal Errors

**File:** `lib/main.dart:29-49`

**Code:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([...]);

  try {
    await FootnoteService().initialize();       // line 39
    await VerseStorageService.initialize();      // line 40
  } catch (e) {
    debugPrint('Service Init Error: $e');        // line 42 — SWALLOWED
  }

  runApp(const ProviderScope(child: OpenBibleApp()));
}
```

**Root Cause:**

Both critical services share a single try-catch. If `FootnoteService().initialize()` throws on line 39, `VerseStorageService.initialize()` on line 40 never runs. The error is logged with `debugPrint()` which is **invisible in release builds**, and the app proceeds normally.

**Downstream Impact When VerseStorageService Fails:**

`VerseStorageService.initialize()` sets `_initialized = true` even on failure (line 174/281). Downstream code checks `_initialized` but never checks `_lastError`:

```dart
// verse_storage_service.dart line 409
static bool get isInitialized => _initialized;  // Always true after init attempt
```

When storage fails:
- `VerseStorageService.getBookmarks()` returns empty list
- `VerseStorageService.addBookmark()` writes to in-memory state only, `_saveToBackupFile()` fails silently
- User bookmarks, highlights, and notes for an entire session, believing data is saved
- On next launch, all data is gone — `_backupFile` was never set, so there's nothing to load

No provider code checks initialization health:
```dart
// app_providers.dart lines 176-193
Future<void> _load() async {
  try {
    await VerseStorageService.initialize();      // Assumes success
    final s = VerseStorageService.getSettings(); // Gets empty map on failure
    // ... uses settings regardless
    _isLoaded = true;
  } catch (_) { _isLoaded = true; }             // Swallows AGAIN
}
```

**Suggested Fix:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([...]);

  // Initialize independently so one failure doesn't block the other
  try { await FootnoteService().initialize(); }
  catch (e) { debugPrint('FootnoteService init failed: $e'); }

  try { await VerseStorageService.initialize(); }
  catch (e) {
    // Storage failure is CRITICAL — surface to user
    debugPrint('CRITICAL: VerseStorageService init failed: $e');
    // Consider showing an error dialog or banner on first frame
  }

  runApp(const ProviderScope(child: OpenBibleApp()));
}
```

Also: `VerseStorageService` should NOT set `_initialized = true` on failure. Add an `_initError` field that downstream code can check.

---

#### C4. VerseStorageService Write Lock Race Condition

**File:** `lib/core/services/verse_storage_service.dart:110-123`

**Code:**

```dart
static Completer<void>? _writeLock;

static Future<void> _acquireWriteLock() async {
  while (_writeLock != null) {
    await _writeLock!.future;              // line 114
  }
  _writeLock = Completer<void>();          // line 116 — RACE WINDOW
}

static void _releaseWriteLock() {
  final lock = _writeLock;
  _writeLock = null;
  lock?.complete();
}
```

**Root Cause:**

The check-then-act sequence on lines 113-116 is **not atomic**. Dart is single-threaded but async/await yields at `await` points. If two coroutines call `_acquireWriteLock()` in the same microtask batch:

```
T0: Coroutine A checks _writeLock != null → false (null), skips while loop
T1: Coroutine B checks _writeLock != null → false (still null), skips while loop
T2: Coroutine A assigns _writeLock = Completer X
T3: Coroutine B assigns _writeLock = Completer Y (overwrites X)
T4: Both believe they hold the lock — concurrent writes proceed
```

**All 11 Callers of `_saveToBackupFile()`:**

Every mutating operation calls through to `_saveToBackupFile()`: `saveSettings` (253), `saveHistory` (262), `addBookmark` (269), `removeBookmark` (275), `addHighlight` (292), `setHighlight` (304), `removeHighlight` (310), `saveNote` (330), `removeNote` (336), `clearAll` (356), `forceSave` (361).

**Real-World Scenario:**

```dart
// User rapidly bookmarks two verses (or bookmarks while auto-saving history)
Future.wait([
  VerseStorageService.addBookmark(verse1),
  VerseStorageService.addHighlight(verse2),
]);
// Both acquire lock simultaneously → both encode partial state →
// both write to .tmp file → one overwrites the other → data lost
```

**Same Pattern in ReadingHistoryService:**

`reading_history_service.dart:45-58` has an identical `_acquireWriteLock()` with the same race. Additionally, `ReadingHistoryService.addEntry()` has a TOCTOU (time-of-check-time-of-use) race: it reads history (line 79), modifies the local copy (lines 82-94), then writes back (line 96) — a concurrent caller's changes are overwritten.

**Suggested Fix:**

Replace the manual Completer pattern with a proper async mutex. No external package needed:

```dart
static Future<void>? _pendingWrite;

static Future<void> _serializedWrite(Future<void> Function() work) async {
  while (_pendingWrite != null) {
    await _pendingWrite;
  }
  final completer = Completer<void>();
  _pendingWrite = completer.future;
  try {
    await work();
  } finally {
    _pendingWrite = null;
    completer.complete();
  }
}
```

Or use `package:synchronized` from pub.dev which provides a battle-tested `Lock()`.

---

#### C5. dotenv Never Loaded

**File:** `lib/core/services/bible_api_service.dart:4,15`

**Code:**

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';         // line 4

// In constructor:
'api-key': apiKey ?? dotenv.env['BIBLE_API_KEY'] ?? '',      // line 15
```

**Root Cause:**

`flutter_dotenv` requires an explicit `await dotenv.load()` call before `dotenv.env` can be accessed. This call exists nowhere in the codebase. Search results:
- `dotenv.load()` — 0 matches across all files
- `DotEnv` — 0 matches
- `.env` file — exists as `.env.example` only, no actual `.env` file
- `pubspec.yaml` assets (lines 115-124) — no `.env` listed

Without `dotenv.load()`, `dotenv.env['BIBLE_API_KEY']` returns `null`, the `??` chain falls through to `''`, and every API request includes an empty `api-key` header → silent 401 responses.

**Related Code:**

`app_constants.dart:14-16` has a separate mechanism:
```dart
// Import dotenv in the file that uses this
static const String bibleApiKey = String.fromEnvironment('BIBLE_API_KEY');
```
This uses compile-time `--dart-define`, not runtime dotenv — a completely different approach that also won't work without build flags.

**Suggested Fix:**

The app is fully offline (Bible data is bundled JSON assets). The API service is dead code. Remove `flutter_dotenv` from `pubspec.yaml` and delete the import in `bible_api_service.dart`. If runtime API access is ever needed, use `--dart-define=BIBLE_API_KEY=xxx` at build time with `String.fromEnvironment()`.

---

#### C6. StorageService "Memory Fallback" is a Lie

**File:** `lib/core/services/storage_service.dart:264, 298-669`

**Code:**

The field is declared but never used:

```dart
// line 264
final Map<String, Map<String, dynamic>> _memoryStorage = {};   // NEVER READ OR WRITTEN
```

When `SharedPreferences.getInstance()` fails, init logs "using memory fallback" but sets `_prefs = null`. Every subsequent method checks `_prefs` and silently no-ops:

```dart
// Example: setSetting (lines 296-306)
Future<void> setSetting<T>(String key, T value) async {
  if (!_initialized) await init();
  if (_prefs == null) return;           // ← SILENT DISCARD — no fallback used
  try {
    final jsonStr = json.encode({'value': value});
    await _prefs!.setString('settings_$key', jsonStr);
  } catch (e) {
    debugPrint('StorageService: setSetting error: $e');
  }
}
```

**All 25 Guard Clauses:**

Every CRUD method has the same `if (_prefs == null) return [empty];` pattern:

| Method | Line | Returns on null |
|---|---|---|
| `setSetting` | 298 | `void` (data discarded) |
| `getSetting` | 310 | `defaultValue` |
| `addBookmark` | 326 | `void` (bookmark lost) |
| `removeBookmark` | 338 | `void` (no-op) |
| `getAllBookmarks` | 349 | `[]` (empty list) |
| `isBookmarked` | 369 | `false` |
| `addHighlight` | 391 | `void` (highlight lost) |
| `removeHighlight` | 403 | `void` (no-op) |
| `getHighlight` | 414 | `null` |
| `getAllHighlights` | 427 | `[]` |
| `saveNote` | 449 | `void` (note lost) |
| `deleteNote` | 461 | `void` (no-op) |
| `getNote` | 472 | `null` |
| `getAllNotes` | 485 | `[]` |
| `saveReadingPlan` | 511 | `void` (progress lost) |
| `getReadingPlanProgress` | 524 | `null` |
| `getAllReadingPlanProgress` | 538 | `[]` |
| `savePrayerEntry` | 560 | `void` (prayer lost) |
| `deletePrayerEntry` | 572 | `void` (no-op) |
| `getAllPrayerEntries` | 583 | `[]` |
| `updateStreak` | 605 | `void` (streak lost) |
| `getStreak` | 616 | `null` |
| `cacheData` | 631 | `void` (cache lost) |
| `getCachedData` | 648 | `null` |
| `clearCache` | 669 | `void` (no-op) |

**Suggested Fix:**

Since `VerseStorageService` is the authoritative storage (see C2), delete `StorageService` entirely. If a SharedPreferences-based service is still needed for lightweight data (streaks, plans), either implement the memory fallback properly or throw on init failure so the app can surface the error.

---

#### C7. GenealogyPage Class Name Collision

**Files:** `lib/features/genealogy/presentation/pages/genealogy_page.dart:5`, `enhanced_genealogy_page.dart:5`

**Code:**

Both files define `class GenealogyPage extends StatefulWidget` at line 5. They also each define `class _GenealogyPageState extends State<GenealogyPage>`.

**Root Cause:**

`genealogy_page.dart` is **dead code**. Only `enhanced_genealogy_page.dart` is imported:
- `main.dart:21` — `import 'features/genealogy/presentation/pages/enhanced_genealogy_page.dart';`
- `main.dart:568` — `MaterialPageRoute(builder: (_) => const GenealogyPage())`

The old `genealogy_page.dart` also defines its own local `GenealogyPerson` model (lines 247-289) with different fields than `genealogy_service.dart`'s `GenealogyPerson` — another model collision waiting to happen.

**Suggested Fix:**

Delete `genealogy_page.dart` entirely. It's dead code with a colliding class name. If both need to coexist temporarily, rename the old one to `LegacyGenealogyPage`.

---

#### C8. Atomic File Save Has Data-Loss Window

**File:** `lib/core/services/verse_storage_service.dart:210-245`

**Code:**

```dart
static Future<void> _saveToBackupFile() async {
  await _acquireWriteLock();
  try {
    final f = _backupFile;
    if (f == null) return;
    final map = { /* bookmarks, highlights, notes, settings, history */ };
    final jsonString = json.encode(map);
    final tmpFile = File('${f.path}.tmp');
    await tmpFile.writeAsString(jsonString, flush: true);     // line 226

    if (await tmpFile.exists() && (await tmpFile.length()) > 0) {
      if (await f.exists()) await f.delete();                 // line 229 — DELETES ORIGINAL
      try {
        await tmpFile.rename(f.path);                         // line 231 — RENAME
      } on FileSystemException {
        await f.writeAsString(jsonString, flush: true);       // line 233 — FALLBACK
        try { await tmpFile.delete(); } catch (_) {}
      }
    }
  } catch (e) {
    _lastError = "SaveFile: $e";
  } finally {
    _releaseWriteLock();
  }
}
```

**Root Cause:**

The dangerous sequence at lines 229-231:

```
Step 1: await f.delete()         → Original file GONE
  ← CRITICAL WINDOW: no authoritative file exists on disk →
Step 2: await tmpFile.rename()   → Temp file becomes new original
```

If the app is killed, device loses power, or the process is force-stopped between steps 1 and 2, **both files are gone**: the original was deleted and the temp was never renamed. On next launch, `_loadFromBackupFile()` checks `if (!await f.exists()) return;` (line 180) — returns empty. All user data (bookmarks, highlights, notes, settings, history) is permanently lost.

**Why This Is Wrong:**

The correct atomic write pattern is **rename-over** — `File.rename()` on the same filesystem atomically replaces the destination. The delete on line 229 is unnecessary and creates the data-loss window. The code should be:

```dart
// CORRECT: rename atomically replaces destination
await tmpFile.rename(f.path);   // Old file replaced in one inode operation
```

The cross-device fallback (lines 232-235) also has issues: if the original was already deleted and the fallback `writeAsString` is interrupted, the file is partially written (corrupted JSON).

**Suggested Fix:**

Remove line 229 (`await f.delete()`) entirely. Let `rename()` handle replacement atomically. For the cross-device fallback, write to a second temp file and then copy:

```dart
if (await tmpFile.exists() && (await tmpFile.length()) > 0) {
  try {
    await tmpFile.rename(f.path);   // Atomic on same filesystem
  } on FileSystemException {
    // Cross-device: copy content, then clean up
    await f.writeAsString(jsonString, flush: true);
    try { await tmpFile.delete(); } catch (_) {}
  }
}
```

---

#### C9. Provider Mutations Never Persist to Storage

**File:** `lib/core/providers/app_providers.dart:20-40, 230-258`

**Code:**

```dart
// BookmarksNotifier (lines 31-33)
Future<void> addBookmark(String verseId) async {
  if (!state.contains(verseId)) state = [...state, verseId];
  // ← NO call to VerseStorageService.addBookmark()
}

// HighlightsNotifier (line 241)
Future<void> addHighlight(String id, String color) async {
  state = {...state, id: color};
  // ← NO call to VerseStorageService.setHighlight()
}

// NotesNotifier (line 256)
Future<void> addNote(String id, String note) async {
  state = {...state, id: note};
  // ← NO call to VerseStorageService.saveNote()
}
```

**Root Cause:**

The notifiers update only their Riverpod in-memory state. Actual file persistence happens in **widget code** that calls `VerseStorageService` directly, bypassing the providers entirely:

```dart
// verse_widget.dart line 618 — widget calls storage directly
await VerseStorageService.addBookmark(savedVerse);

// verse_widget.dart line 729 — same for highlights
await VerseStorageService.removeHighlight(verseId);

// verse_widget.dart line 652 — same for notes
await VerseStorageService.saveNote(savedVerse, result);
```

This creates two independent state channels:
1. **Provider state** (RAM) — updated by notifier methods, lost on restart
2. **File state** (disk) — updated by widget code calling `VerseStorageService`

If any code path calls the notifier without also calling `VerseStorageService`, that data exists only in RAM and vanishes on app restart.

**Suggested Fix:**

Each notifier mutation must delegate to `VerseStorageService`:

```dart
Future<void> addBookmark(String verseId) async {
  final savedVerse = SavedVerse(id: verseId, /* ... */);
  await VerseStorageService.addBookmark(savedVerse);   // Persist first
  state = [...state, verseId];                          // Then update RAM
}
```

Or better: make the notifiers the **only** interface for mutations, and remove direct `VerseStorageService` calls from widgets. One path for writes, one source of truth.

---

#### C10. Two Conflicting FlutterTts Engines

**Files:** `lib/core/providers/audio_bible_provider.dart:48`, `lib/core/services/bible_audio_service.dart:13`

**Code:**

**Engine 1 — `AudioBibleNotifier` (provider-based):**
```dart
// audio_bible_provider.dart line 48
final FlutterTts _flutterTts = FlutterTts();
// Truncation limit: 3500 chars (line 98)
// Used by: AudioBibleWidget, CompactAudioButton, FloatingAudioControls
```

**Engine 2 — `BibleAudioService` (singleton service):**
```dart
// bible_audio_service.dart line 13
final FlutterTts _tts = FlutterTts();
// Truncation limit: 1200 chars (line 102)
// Used by: ChapterReaderPage (imported line 7)
```

**Root Cause:**

Two completely independent TTS systems were implemented at different times. They have different:

| Aspect | AudioBibleNotifier | BibleAudioService |
|---|---|---|
| **Instance** | Riverpod StateNotifier | Singleton static |
| **Char limit** | 3500 | 1200 |
| **Handler style** | Direct callbacks | Promise `.then()/.catchError()` |
| **Dispose** | No `dispose()` override (leak) | No cleanup method |

On Android, two active `FlutterTts` instances conflict — one can stop the other's playback mid-sentence. Both are wired into the chapter reader view: `main.dart` renders `CompactAudioButton` (line 401, uses `AudioBibleNotifier`) and `AudioBibleWidget` (line 471, also uses `AudioBibleNotifier`), while `chapter_reader_page.dart` imports `BibleAudioService` (line 7).

**Suggested Fix:**

Delete `AudioBibleNotifier` and `audio_bible_provider.dart`. Wrap `BibleAudioService` in a single Riverpod provider. All audio UI components should use this one provider. Add a `dispose()` method that calls `_tts.stop()`.

---

#### C11. Translation Selection Not Persisted

**Files:** `lib/core/providers/app_providers.dart:43,81,140-143`, `lib/core/services/current_bible.dart:6,22`

**Code:**

```dart
// app_providers.dart line 43
final selectedTranslationProvider = StateProvider<String>((ref) => 'kjv');  // Default, no persistence

// current_bible.dart line 6
static String _id = 'kjv';   // Static field, RAM only

// current_bible.dart line 22
static void set(String newId) {
  _id = newId.toLowerCase();  // Updates RAM, no persistence
}
```

**Root Cause:**

When the user selects a translation via `TranslationSelectorWidget` (line 102-112), two things happen:
1. `ref.read(selectedTranslationProvider.notifier).state = value;` — updates Riverpod state (RAM)
2. `ref.read(bibleDataProvider.notifier).selectTranslation(value);` → calls `CurrentBible.set(id)` — updates static field (RAM)

Neither writes to disk. `AppSettings` has a `selectedBibleId` field (line 91) but it's never included in `SettingsNotifier._save()` (lines 195-211) — the save method serializes font size, reading mode, notifications, but **not** `selectedBibleId`.

On app restart, `selectedTranslationProvider` reinitializes to `'kjv'` (the default), and `CurrentBible._id` resets to `'kjv'`.

**Suggested Fix:**

1. Include `selectedBibleId` in the settings map saved by `SettingsNotifier._save()`
2. Load it in `SettingsNotifier._load()` and update both `selectedTranslationProvider` and `CurrentBible`
3. Better yet: eliminate `CurrentBible` static class entirely and use `selectedTranslationProvider` everywhere

---

### HIGH (Functional bugs, significant UX issues)

---

#### H1. Hardcoded `'kjv'` Everywhere (41 occurrences)

**Files:** 17 files across the codebase

**Code & Categorization:**

**Default fallbacks (28 instances)** — `'kjv'` used as fallback when variable is null/empty:
- `chapter_reader_page.dart:131,141,142,191,233,961` — 6 instances including `_currentBibleId = 'kjv'` initialization and KJV fallback loading
- `verse_display_widget.dart:398,549,646` — `bibleId: bibleId ?? 'kjv'` in bookmark/highlight/note creation
- `bible_home_page.dart:157,168` — `_selectedTranslationId = 'kjv'` initialization
- `continue_reading_service.dart:86,107` — deserialization fallback
- `reading_history_service.dart:36,138` — deserialization fallback
- `verse_storage_service.dart:72` — deserialization fallback
- `bookmarks_page.dart:310,322` — legacy bookmark conversion
- `daily_verse_page.dart:272` — bookmark creation
- `app_providers.dart:43,91,139` — provider defaults
- `search_provider.dart:170` — search fallback
- `bible_repository.dart:24` — method parameter default
- `comparison_provider.dart:85,122` — comparison defaults

**Primary bibleId (7 instances)** — `'kjv'` hardcoded as the primary/only value:
- `main.dart:387,418,495` — history/bookmark/verse display always tagged KJV
- `daily_verse_page.dart:272` — daily verse bookmarks always KJV
- `chapter_reader_page.dart:768` — hardcoded comparison list starts with `'kjv'`

**Root Cause:**

`selectedTranslationProvider` exists but isn't threaded through the widget/service call chain. Code was written assuming KJV-only, and `'kjv'` was used as a quick constant instead of reading from the provider.

**Impact:**

Every bookmark, highlight, note, and history entry is tagged `bibleId: 'kjv'` regardless of what translation the user selected. When a user switches to ASV, their bookmarks still store `'kjv'`. Cross-translation features (comparison, search across translations) always default to KJV.

**Suggested Fix:**

Thread `bibleId` as an explicit required parameter from the provider through all widget constructors and service calls. Replace all `'kjv'` with `ref.read(selectedTranslationProvider)` in provider-accessible code, or `CurrentBible.id` in service code. Keep `'kjv'` only as the default initialization value of `selectedTranslationProvider`.

---

#### H2. TTS Silently Truncates at 1200 Characters

**File:** `lib/core/services/bible_audio_service.dart:90-104`

**Code:**

```dart
final buffer = StringBuffer();
buffer.write('$bookName chapter $chapter. ');

for (final v in verses) {
  if (_stopRequested) return false;
  final n = v['verse']?.toString() ?? '';
  final raw = (v['text'] ?? '').toString().trim();
  final t = _normalizeForTts(raw);
  if (t.isEmpty) continue;

  final addition = '$n. $t ';
  if (buffer.length + addition.length > 1200) break;   // line 102 — HARD STOP
  buffer.write(addition);
}
```

**Root Cause:**

A hard-coded 1200 character limit exists to prevent TTS engine buffer overflows. When the buffer would exceed 1200 chars, the loop `break`s silently. Most Bible chapters are 2000-10000+ characters. For example, Psalm 119 (176 verses) would be truncated after roughly 5-8 verses.

There is **no chunking, no continuation, no notification** to the user. The `speakChapter()` method returns `true` (success) at line 121 regardless of how many verses were truncated.

**Related:** The competing `AudioBibleNotifier` has a different limit of 3500 chars (line 98 in `audio_bible_provider.dart`) — yet another inconsistency between the two TTS engines (see C10).

**Suggested Fix:**

Implement chunking: split chapter text into 1200-char segments at sentence boundaries, queue them sequentially using `_tts.setCompletionHandler()` to chain playback, and expose a progress indicator showing `"Playing verse X of Y"`.

---

#### H3. `_highlightText()` is a No-Op

**File:** `lib/core/services/bible_search_service.dart:233-241`

**Code:**

```dart
static String _highlightText(String text, List<String> terms) {
  String result = text;
  for (final term in terms) {
    if (term.isEmpty) continue;
    // We'll return the text as-is; highlighting will be done in the UI
  }
  return result;   // ← Returns original text unchanged
}
```

**Root Cause:**

The method body was gutted and replaced with a comment saying "highlighting will be done in the UI" — but the UI doesn't do highlighting either. The method is called on line 141 when building `SearchResult` objects:

```dart
highlightedText: _highlightText(text, searchTerms),
```

The `highlightedText` field in `SearchResult` is populated with the verbatim original text. The search results UI renders this field without any term highlighting.

**Suggested Fix:**

Either implement highlighting here (wrap matched terms in `**bold**` markers that the UI interprets) or implement it in the UI widget using `TextSpan` with styled spans for matched terms. The method signature and call site are already correct — only the implementation body is missing.

---

#### H4. Settings Race Condition on Startup

**File:** `lib/core/providers/app_providers.dart:172-193`

**Code:**

```dart
class SettingsNotifier extends StateNotifier<AppSettings> {
  bool _isLoaded = false;
  SettingsNotifier() : super(const AppSettings()) { _load(); }   // line 174

  Future<void> _load() async {
    try {
      await VerseStorageService.initialize();
      final s = VerseStorageService.getSettings();
      if (s.isEmpty) { _isLoaded = true; return; }
      state = state.copyWith(
        fontSize: s['fontSize'] as int? ?? state.fontSize,
        readingMode: ReadingMode.values[modeIndex.clamp(...)],
        // ... more fields
      );
      _isLoaded = true;
    } catch (_) { _isLoaded = true; }
  }
```

**Root Cause:**

The constructor fires `_load()` as a **fire-and-forget** async call. It is not awaited. The constructor returns immediately with `super(const AppSettings())` — hardcoded defaults: `readingMode: ReadingMode.day`, `fontSize: 18`, `isDarkMode: false`.

**Timeline:**

```
T0:     Constructor completes → state = AppSettings() [all defaults]
T1-50ms: Widget tree builds → reads defaults → applies light theme
T51-100ms: _load() completes → state updated to user's saved dark theme
T101ms: Widget rebuilds → FLASH from light to dark theme
```

**Visible Symptoms:**
- Flash of wrong theme on every cold start (light → dark)
- Font size jump (18 → user's saved size)
- Notification toggles briefly show wrong state
- Audio controls flash enabled→disabled or vice versa

The `_isLoaded` flag (line 195: `if (!_isLoaded) return;`) prevents writes during loading, but doesn't help readers — UI reads are unrestricted during the race window.

**Suggested Fix:**

Use an `AsyncNotifier` pattern or expose a loading state:

```dart
class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  SettingsNotifier() : super(const AsyncValue.loading()) { _load(); }
  // UI shows loading indicator until settings are ready
}
```

Or simpler: load settings synchronously in `main()` before `runApp()` and pass the loaded values to the SettingsNotifier constructor.

---

#### H5. Bible Data Cached Forever in Memory

**Files:** `lib/core/services/bible_search_service.dart:31`, `lib/core/services/direct_bible_loader.dart:8`

**Code:**

Two independent static caches, both unbounded:

```dart
// bible_search_service.dart line 31
static final Map<String, Map<String, dynamic>> _bibleCache = {};

// direct_bible_loader.dart line 8
static final Map<String, Map<String, dynamic>> _cache = {};
```

Data enters on first access and is never evicted:

```dart
// direct_bible_loader.dart lines 34
_cache[normalizedId] = data;   // Cached forever

// bible_search_service.dart line 69
_bibleCache[normalizedId] = data;  // Cached forever (separate cache!)
```

Both classes have `clearCache()` methods but they are never called by normal app flow. There is no LRU eviction, no TTL, no size limit.

**Memory Impact:**

Each Bible JSON file is 3-6 MB on disk, expanding to 4-8 MB decoded in memory. With the two caches being independent, a single translation can be cached **twice** (once in each service). Loading 3-4 translations = 24-64 MB of retained memory with no release.

**Suggested Fix:**

1. Unify to a single cache (in `DirectBibleLoader`, which all code should route through)
2. Add LRU eviction with a max of 2-3 entries
3. Clear cache on memory pressure using `WidgetsBindingObserver.didHaveMemoryPressure()`

---

#### H6. `bookId` Generation is Fragile

**File:** `lib/main.dart:482`

**Code:**

```dart
final bookId = widget.book.name.replaceAll(' ', '').toUpperCase().substring(0, 3);
```

**Root Cause:**

The transformation takes the first 3 characters after removing spaces and uppercasing. This produces correct IDs for most single-word books but fails for multi-word books:

| Book Name | After transform | Expected ID | Match? |
|---|---|---|---|
| Genesis | GEN | GEN | ✓ |
| 1 Samuel | 1SA | 1SA | ✓ |
| Song of Solomon | SON | SOS | ✗ |
| Ecclesiastes | ECC | ECC | ✓ |

The `SOS` ID is used by `FootnoteService` and `DirectBibleLoader` — but `main.dart` generates `SON`. Result: footnotes never load for Song of Solomon.

Meanwhile, `DirectBibleLoader` reads the `id` field directly from JSON (line 66: `book['id'].toString()`) which is the correct, canonical ID. The `BibleBook` model in `main.dart` has an `id` field (line 617: `id: json['id'] ?? ''`) that's populated from JSON but then **ignored** — the code regenerates the ID on-the-fly using substring.

**Suggested Fix:**

Use `widget.book.id` (already populated from JSON) instead of regenerating from the name. If `id` is empty/unreliable, use the canonical `AppConstants.bookAbbreviations` map for lookup by name.

---

#### H7. `ref.listen` Inside `build()` — Rebuild Loop Risk

**File:** `lib/features/bookmarks/presentation/pages/bookmarks_page.dart:114-116`

**Code:**

```dart
@override
Widget build(BuildContext context) {
  ref.listen<List<String>>(bookmarksProvider, (_, __) => _loadData());
  ref.listen<Map<String, String>>(highlightsProvider, (_, __) => _loadData());
  ref.listen<Map<String, String>>(notesProvider, (_, __) => _loadData());

  return Scaffold( /* ... */ );
}
```

**Root Cause:**

`ref.listen()` inside `build()` registers a callback that fires when a provider changes. The callback `_loadData()` calls `setState()` (lines 47, 98-103), which triggers another `build()`, which re-registers the listeners. If the async work in `_loadData()` causes any provider to change (e.g., by calling a notifier method), the loop becomes:

```
ref.listen fires → _loadData() → setState() → build() → ref.listen registers →
provider changes during async gap → callback fires → _loadData() → setState() → ...
```

Additionally, three listeners all calling `_loadData()` means a single external change can trigger 3 simultaneous `_loadData()` calls racing against each other. If the widget is disposed during the async gap in `_loadData()`, the `setState()` on line 98 crashes with "setState called after dispose."

**Suggested Fix:**

In Riverpod's `ConsumerStatefulWidget`, `ref.listen` should be called in `build()` (it's lifecycle-aware there). But the callback should NOT call `setState()`. Instead, use `ref.watch()` for reactive rebuilds:

```dart
@override
Widget build(BuildContext context) {
  // Reactive: rebuilds automatically when providers change
  final bookmarks = ref.watch(bookmarksProvider);
  final highlights = ref.watch(highlightsProvider);
  final notes = ref.watch(notesProvider);

  // Build UI from provider data directly — no setState needed
  return Scaffold( /* use bookmarks, highlights, notes */ );
}
```

If async loading from `VerseStorageService` is needed, do it in `initState()` and store results in provider state, not local widget state.

---

#### H8. `setState` After Async Without `mounted` Check

**File:** `lib/features/daily_verse/presentation/pages/daily_verse_page.dart:252-282`

**Code:**

```dart
Future<void> _bookmarkVerse() async {
  if (_isBookmarked) {
    await VerseStorageService.removeBookmark(verseId);      // ASYNC GAP
    setState(() => _isBookmarked = false);                  // line 257 — NO MOUNTED CHECK
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(...);      // This HAS mounted check
    }
  } else {
    await VerseStorageService.addBookmark(savedVerse);      // ASYNC GAP
    setState(() => _isBookmarked = true);                   // line 275 — NO MOUNTED CHECK
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  }
}
```

**Root Cause:**

The `mounted` check is applied to `ScaffoldMessenger` (correctly) but **not** to `setState()` (incorrectly). If the user navigates away during the `await VerseStorageService` call, the widget is disposed and `setState()` throws: `"setState() called after dispose()"`.

The same file inconsistently handles this — `_checkBookmarkStatus()` (line 30) correctly wraps `setState` in `if (mounted)`, but `_bookmarkVerse()` and `_addNote()` (line 326) do not.

**Other Instances Across Codebase:**

This pattern likely exists wherever `setState()` follows an `await` without a `mounted` guard. The daily verse page is the confirmed instance, but similar patterns should be audited in `chapter_reader_page.dart`, `prayer_journal_widget.dart`, and any other stateful widgets with async operations.

**Suggested Fix:**

Add `if (!mounted) return;` before every `setState()` that follows an `await`:

```dart
await VerseStorageService.removeBookmark(verseId);
if (!mounted) return;
setState(() => _isBookmarked = false);
```

---

#### H9. Continue Reading "Dismiss" Button Doesn't Work

**File:** `lib/features/bible/presentation/widgets/continue_reading_card.dart:94-106`

**Code:**

```dart
TextButton(
  onPressed: () async {
    await ContinueReadingService.clear();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reading history cleared')),
      );
      Navigator.of(context).maybePop();      // line 103 — DOES NOTHING
    }
  },
  child: const Text('Dismiss'),
),
```

**Root Cause:**

`ContinueReadingCard` is rendered inside `BiblePage`, which is a **tab** in `MainNavigationPage` — not a pushed route. The navigation stack is:

```
Navigator Stack:
┌─ MainNavigationPage (root — only route) ─┐
│   └─ _pages[0] = BiblePage              │
│       └─ ContinueReadingCard             │
└──────────────────────────────────────────┘
```

`Navigator.maybePop()` attempts to pop the current route. Since `MainNavigationPage` is the only route in the stack (root), `maybePop()` silently returns `false` and does nothing. The card stays on screen. The SnackBar shows "Reading history cleared" but the card doesn't disappear.

The developer was aware of this — the comment on lines 98-99 says `// Notify parent to refresh` and `// Use a callback to parent or setState equivalent` — but used `Navigator` instead.

**Suggested Fix:**

Add an `onDismiss` callback parameter to `ContinueReadingCard`:

```dart
class ContinueReadingCard extends StatelessWidget {
  final VoidCallback? onDismiss;
  // ...
  onPressed: () async {
    await ContinueReadingService.clear();
    onDismiss?.call();   // Let parent hide the card via setState
  },
}

// In BiblePage:
if (_showContinueReading)
  ContinueReadingCard(
    onDismiss: () => setState(() => _showContinueReading = false),
  ),
```

---

#### H10. `_loadingChapters` Mutated Without `setState`

**File:** `lib/features/bible/presentation/pages/chapter_reader_page.dart:208-258`

**Code:**

```dart
if (_chapterCache.containsKey(cacheKey) || _loadingChapters.contains(cacheKey)) {
  return;                                          // line 208: early return
}
_loadingChapters.add(cacheKey);                    // line 213: OUTSIDE setState()

try {
  var content = await DirectBibleLoader.getChapter(bibleId, bookId, chapter);
  if (content != null && content.isNotEmpty) {
    if (mounted) {
      setState(() {
        _chapterCache[cacheKey] = content!;
        _loadingChapters.remove(cacheKey);         // line 225: INSIDE setState()
      });
    }
    return;
  }
  // ... fallback paths also remove inside setState()
}
```

**Root Cause:**

`_loadingChapters.add(cacheKey)` on line 213 mutates state **outside** `setState()`. Flutter doesn't know the set changed, so a loading indicator that checks `_loadingChapters.contains(cacheKey)` may not render.

Worse: if `mounted` becomes `false` during the async gap, the `remove(cacheKey)` inside `setState()` is never reached. The entry stays in `_loadingChapters` permanently, and the guard on line 208 returns early on all future attempts to load that chapter — the chapter content never displays for that session.

**Suggested Fix:**

Wrap the `add` in `setState()` as well, and add a `finally` block to guarantee cleanup:

```dart
setState(() => _loadingChapters.add(cacheKey));
try {
  // ... load content ...
} finally {
  if (mounted) {
    setState(() => _loadingChapters.remove(cacheKey));
  } else {
    _loadingChapters.remove(cacheKey);  // Clean up even if unmounted
  }
}
```

---

#### H11. Chapter Reader Silently Falls Back to KJV

**File:** `lib/features/bible/presentation/pages/chapter_reader_page.dart:231-243`

**Code:**

```dart
debugPrint('Direct loader failed for $bibleId, trying KJV fallback...');
content = await DirectBibleLoader.getChapter('kjv', bookId, chapter);
if (content != null && content.isNotEmpty) {
  if (mounted) {
    setState(() {
      _chapterCache[cacheKey] = '[KJV]\n\n$content';      // line 238: prefixed
      _loadingChapters.remove(cacheKey);
    });
  }
  return;
}
```

**Root Cause:**

When a non-KJV translation fails to load, the code silently loads KJV instead and prefixes the cached content with `'[KJV]\n\n'`. The only user-visible indication is the literal text `[KJV]` appearing at the top of the chapter — no Toast, Dialog, SnackBar, or banner explains what happened or why.

In release builds, the `debugPrint` on line 231 is invisible. The user selected ASV, sees KJV text, and may not notice the small `[KJV]` prefix.

**Suggested Fix:**

Show an explicit notification: `ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$bibleId unavailable — showing KJV')))`. Also consider a persistent banner at the top of the chapter view when displaying fallback content.

---

#### H12. Reading Plan Persistence Has 7 Empty Catch Blocks

**File:** `lib/features/reading_plans/data/reading_plan_provider.dart`

**Code (all 7 blocks follow this pattern):**

```dart
// Example: completeDay (line 413)
try {
  await _savePlans(updatedPlans);
} catch (_) {
  // Storage may be unavailable on some builds; keep in-memory update.
}
```

**All 7 Locations:**

| Line | Method | Data Lost on Failure |
|---|---|---|
| 297 | `_loadPlans` (map) | Entire plan entry discarded from list |
| 337 | `_loadPlans` (fallback save) | Recovery plan only exists in RAM |
| 371 | `setActivePlan` | Active plan selection reverts on restart |
| 413 | `completeDay` | Day completion progress lost on restart |
| 464 | `createPlan` | New plan vanishes on restart |
| 499 | `deletePlan` | Deleted plan reappears on restart |
| 523 | `resetPlan` | Reset not persisted, progress reappears |

**Impact:** A user can complete 30 days of a reading plan, restart the app, and find it reset to day 1. All 7 operations update in-memory state successfully but silently discard persistence failures. The comment "keep in-memory update" acknowledges the problem but treats it as acceptable.

**Suggested Fix:**

At minimum, log the error with `debugPrint`. For critical operations like `completeDay`, surface a user-visible error: `"Failed to save progress — changes may be lost on restart"`. Consider a retry mechanism for transient failures.

---

#### H13. BibleAudioService Sets `_initialized = true` on Failure

**File:** `lib/core/services/bible_audio_service.dart:49-64`

**Code:**

```dart
try {
  try { await _tts.setLanguage('en-US'); } catch (_) {}     // line 54
  try { await _tts.setSpeechRate(_rate); } catch (_) {}     // line 55
  try { await _tts.setPitch(_pitch); } catch (_) {}         // line 56
  try { await _tts.setVolume(1.0); } catch (_) {}           // line 57

  _initialized = true;                                      // line 59 — SUCCESS
} catch (e) {
  debugPrint('AUDIO_SERVICE: Init failed: $e');
  _initialized = true;                                      // line 63 — ALSO ON FAILURE!
}
```

**Root Cause:**

Line 63 sets `_initialized = true` in the catch block. This means:
1. Init fails for any reason (TTS engine not available, platform error)
2. `_initialized` is set to `true` anyway
3. Future calls to `initialize()` hit the guard `if (_initialized) return;` (line 29) and skip
4. `_tts.speak()` calls fail silently because the engine was never properly configured
5. No retry is possible — the service believes it's initialized

The 4 inner empty catch blocks (lines 54-57) additionally mask individual TTS configuration failures — language, rate, pitch, or volume settings silently fail with no logging.

**Suggested Fix:**

Only set `_initialized = true` on success. On failure, leave it `false` so retry is possible:

```dart
try {
  await _tts.setLanguage('en-US');
  await _tts.setSpeechRate(_rate);
  await _tts.setPitch(_pitch);
  await _tts.setVolume(1.0);
  _initialized = true;
} catch (e) {
  debugPrint('AUDIO_SERVICE: Init failed: $e');
  _initialized = false;   // Allow retry
}
```

---

#### H14. Unencrypted Sensitive Data in SharedPreferences

**File:** `lib/core/services/storage_service.dart`

**Sensitive Data Stored as Plaintext JSON:**

| Data | Key Pattern | Sensitivity |
|---|---|---|
| Prayer journal entries | `prayer_<id>` | **High** — personal beliefs, struggles |
| Prayer content | `.content` field | **High** — private prayers |
| Personal notes on verses | `note_<id>` | **Medium** — theological commentary |
| Bookmarks | `bookmark_<id>` | **Medium** — reveals interests |
| Highlights | `highlight_<verseId>` | **Medium** — study patterns |
| Reading plan progress | `reading_plan_<id>` | **Low** — reading habits |
| Streak data | `streak_reading` | **Low** — usage statistics |

All stored via `json.encode()` as plain strings in SharedPreferences, which on Android are XML files in `/data/data/<package>/shared_prefs/` — accessible via ADB backup, device compromise, or rooting. The privacy policy (in `privacy_policy_page.dart`) claims "industry-standard security practices."

**Suggested Fix:**

Use `flutter_secure_storage` for prayer entries and notes (high-sensitivity data). At minimum, update the privacy policy to accurately describe the plaintext storage model.

---

### MEDIUM (Code quality, maintainability, partial functionality)

---

#### M1. Triple BibleBook Model Duplication

**Code — Three Incompatible Definitions:**

**Version 1** (`lib/main.dart:605-623`):
```dart
class BibleBook {
  final String id;
  final String name;
  final List<BibleChapter> chapters;   // Full nested verse data
}
```

**Version 2** (`lib/features/bible/data/models/bible_book.dart:5-39`):
```dart
class BibleBook {
  final String id;
  final String name;
  final String abbreviation;
  final int chapters;                  // Just a count
  final Testament testament;           // Enum type
}
```

**Version 3** (`lib/features/bible/domain/bible_models.dart:74-117`):
```dart
class BibleBook {
  final String id;
  final String name;
  final String nameLong;
  final String abbreviation;
  final int testament;                 // Integer (1=OT, 2=NT)
  final int position;
  final int chapterCount;
}
```

`testament` is an `enum` in Version 2 but an `int` in Version 3. `chapters` is a `List<BibleChapter>` in Version 1 but an `int` count in Versions 2/3. These types cannot be substituted for each other. `BibleTranslation` is also defined in both `app_providers.dart` and `bible_models.dart` with different field sets.

**Suggested Fix:** Create a single canonical `BibleBook` in `lib/core/models/bible_book.dart` with a superset of fields. Delete the other two definitions and update all imports.

---

#### M2. Six Unused Dependencies

| Dependency | pubspec line | Evidence | APK Impact |
|---|---|---|---|
| `go_router: ^13.1.0` | 55 | 0 imports anywhere | ~100KB |
| `retrofit: ^4.1.0` | 25 | 0 `@RestApi` annotations | ~50KB |
| `json_annotation: ^4.8.1` | 26 | 0 `@JsonSerializable` uses | ~30KB |
| `in_app_purchase: ^3.1.13` | 85 | 0 imports | ~200KB |
| `workmanager: ^0.7.0` | 41 | 0 imports | ~50KB |
| `flutter_dotenv: ^5.1.0` | 58 | Imported once, `load()` never called | ~10KB |

Dev deps `retrofit_generator`, `json_serializable`, `riverpod_generator` also unused — add build time overhead for no benefit.

**Suggested Fix:** Remove all 6 from `dependencies` and 3 from `dev_dependencies` in `pubspec.yaml`.

---

#### M3. Book Name Data Duplicated 4 Times

Four separate copies of the 66-book name/abbreviation mapping:

1. `app_constants.dart:41-65` — `bookAbbreviations` Map (66 entries)
2. `app_constants.dart:72-90` — `BibleStructure.oldTestament/newTestament` lists
3. `bible_search_service.dart:32-54` — `_bookNames` static Map (66 entries, identical to #1)
4. `chapter_reader_page.dart:51-73` — `_bookAbbr` getter (66 entries, local to widget)

Any book name fix or addition requires updating 4 files. These can easily drift out of sync.

**Suggested Fix:** Keep `AppConstants.bookAbbreviations` as the single canonical source. Import and reference it everywhere.

---

#### M4. Google Maps API Key Placeholder

**File:** `android/app/src/main/AndroidManifest.xml:13`

```xml
<meta-data android:name="com.google.android.geo.API_KEY"
           android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

The `google_maps_flutter` dependency (pubspec.yaml line 79) is present, but the API key is a placeholder. Any code path reaching Google Maps will crash at runtime.

**Suggested Fix:** Use `manifestPlaceholders` in `build.gradle` to inject via `local.properties` or environment variable. Or remove `google_maps_flutter` entirely since the app uses `flutter_map` (OpenStreetMap) for its maps feature.

---

#### M5. Download Feature Always Fails

**File:** `lib/core/services/bible_download_manager.dart:269-281`

```dart
Future<bool> downloadVersion(String versionId) async {
  final version = _availableVersions[versionId];
  if (version == null || version.isBundled) return false;

  _downloadProgress[versionId] = DownloadProgress(
    versionId: versionId,
    status: DownloadStatus.error,              // IMMEDIATELY ERROR
    progress: 0.0,
    errorMessage: 'Bible download not yet implemented.',
  );
  notifyListeners();
  return false;
}
```

All 18 non-bundled translations (ASV, BBE, Geneva, YLT, Darby, etc.) immediately fail with "not yet implemented" but are still shown in the downloads UI. A dead `_apiBaseUrl` constant on line 8 (`'https://api.biblebrain.com/v1'`) hints at abandoned implementation.

**Suggested Fix:** Either implement actual downloads (write Bible JSON to app documents directory and load from there via `DirectBibleLoader`) or hide non-bundled translations from the UI entirely.

---

#### M6. `main.dart` Contains 650 Lines with 13 Classes

`main.dart` defines: `OpenBibleApp`, `MainNavigationPage`, `_MainNavigationPageState`, `BiblePage`, `_BiblePageState`, `ChapterListPage`, `ChapterReaderPage`, `_ChapterReaderPageState`, `SavedPage`, `MorePage`, `BibleBook`, `BibleChapter`, `BibleVerse`.

**Suggested Fix:** Extract model classes to `lib/core/models/`, page widgets to their respective feature directories. Keep only `main()`, `OpenBibleApp`, and `MainNavigationPage` in `main.dart`.

---

#### M7. `_parseReference` Regex Broken for Multi-Word Books

**File:** `lib/core/services/bible_search_service.dart:208-213`

```dart
final patterns = [
  RegExp(r'^(\d?\s*\w+)\s+(\d+):(\d+)$', caseSensitive: false),
  RegExp(r'^(\d?\s*\w+)\s+(\d+)$', caseSensitive: false),
];
```

The pattern `(\d?\s*\w+)` captures one optional digit, optional whitespace, then one contiguous word. Multi-word book names fail:

| Input | Captured Book | Result |
|---|---|---|
| `"John 3:16"` | `"John"` | ✓ Works |
| `"1 Corinthians 13:4"` | `"1 Corinthians"` | ✓ Works (digit+space+word) |
| `"Song of Solomon 3:5"` | `"Song"` | ✗ Fails — tries to parse `"of"` as chapter |
| `"2 Peter 1:5"` | `"2 Peter"` | ✓ Works |

Books without a leading digit AND with multiple words (only "Song of Solomon") fail. The catch block on line 219 silently discards the parse error.

**Suggested Fix:** Instead of regex, match against the known `_bookNames` map by iterating book names longest-first and checking if the query starts with one.

---

#### M8. TextEditingController Memory Leaks

6 instances of `TextEditingController` created inside dialog builders without disposal:

- `chapter_reader_page.dart:825` — `_addNote()` dialog: 1 controller
- `prayer_journal_widget.dart:242` — `_showAnswerDialog()`: 1 controller
- `prayer_journal_widget.dart:277` — `_showEditDialog()`: 2 controllers
- `prayer_journal_widget.dart:366` — `_showAddPrayerDialog()`: 2 controllers

When dialogs close, controllers are garbage-collected but their native resources (on Android: `InputConnection`) may leak.

**Suggested Fix:** Use `StatefulBuilder` inside the dialog with local disposal, or create controllers in the parent State class and dispose in `dispose()`.

---

#### M9. Brand Inconsistency

`share_verse_page.dart:273` says `'Holy Bible App'` while everywhere else uses `'Open Bible'` (`main.dart:83`, `pubspec.yaml:2`, `AndroidManifest.xml:6`, `build.gradle:59`).

**Suggested Fix:** Replace `'Holy Bible App'` with `'Open Bible'` or reference a constant from `AppConstants`.

---

#### M10. Commentary Chapter Dropdown Hardcoded to 150

**File:** `lib/features/commentary/presentation/pages/commentary_page.dart:97`

```dart
items: List.generate(150, (i) => i + 1)    // HARDCODED 150 for ALL books
```

Only Psalms has 150 chapters. Genesis has 50, Revelation has 22. Users can select "Genesis 100" which returns nothing.

**Suggested Fix:** Use `BibleStructure.getChapterCount(_selectedBook)` (already used correctly in `chapter_reader_page.dart:121`).

---

#### M11. Hardcoded Colors Break Dark Mode

`bible_illustrations_page.dart:756` and **40+ instances across 20+ files** use `Colors.white`, `Colors.black87`, `Colors.grey[100]` etc. instead of theme-aware values. Bottom sheets, cards, and text rendered with hardcoded light colors become invisible or low-contrast in dark/AMOLED mode.

**Suggested Fix:** Replace with `Theme.of(context).colorScheme.surface`, `.onSurface`, `.surfaceContainerHighest` etc.

---

#### M12. `ChapterContent.fromJson` Creates Empty Verses

**File:** `lib/core/services/bible_api_service.dart:215-230`

```dart
factory ChapterContent.fromJson(Map<String, dynamic> json) {
  final verses = <Verse>[];           // Always empty
  final content = json['content'] ?? '';
  return ChapterContent(
    // ...
    verses: verses,                   // Empty list returned
  );
}
```

Comment says "Parse content into verses" but no parsing code exists. Any code using `ChapterContent.verses` gets an empty list.

**Suggested Fix:** Either implement verse parsing from the `content` string, or remove the `verses` field and use `content` directly (which is what all consumers currently do).

---

#### M13. 116 Silent Catch Blocks (Systemic)

~90 blocks use only `debugPrint` (invisible in release), ~10 are completely empty `catch (_) {}`, and <5 do any actual error handling. Worst offenders by file:

| File | Silent Catches | Impact |
|---|---|---|
| `storage_service.dart` | 13+ | All storage operations fail silently |
| `verse_storage_service.dart` | 9 | Data persistence failures hidden |
| `reading_plan_provider.dart` | 7 | Plan progress lost silently |
| `bible_audio_service.dart` | 5 | Audio config failures hidden |
| `reading_history_service.dart` | 3+ | History entries lost |

The `logger` package is already in `pubspec.yaml:66` but never used anywhere.

**Suggested Fix:** Add a centralized error reporting service. Replace `catch (_) {}` with `catch (e) { ErrorReporter.log(e, stackTrace); }`. For critical operations (storage writes), surface errors to the user.

---

#### M14. `_ContextSection` Dead Code

`chapter_reader_page.dart:1141-1172` — A `StatelessWidget` that renders a titled content section. Never instantiated anywhere in the file. ~30 lines of abandoned UI.

**Suggested Fix:** Delete.

---

#### M15. `_buildTreeNode` Dead Code

`enhanced_genealogy_page.dart:201-308` — A recursive tree layout method with complex styling for patriarchs and tribes. Never called — the page uses `_buildLineageView()` and `_buildTribesView()` instead. ~108 lines of abandoned code.

**Suggested Fix:** Delete.

---

#### M16. Comparison Provider Silently Skips Failed Translations

**File:** `lib/features/comparison/data/comparison_provider.dart:114-128`

```dart
for (final translationId in state.selectedTranslations) {
  try {
    final text = await _loadVerseText(repository, translationId);
    if (text != null) {
      comparisons.add(TranslationComparison(/* ... */));
    }
  } catch (e) {
    continue;       // line 127: silent skip
  }
}
```

If a user selects 3 translations for comparison and one fails to load, they see only 2 results with no indication the third failed. `_loadVerseText()` also returns `null` silently on any internal failure (lines 150-168).

**Suggested Fix:** Collect failed translations and show a banner: `"Could not load ASV for comparison"`.

---

#### M17. Search Decodes Full Bible JSON on Main Thread

**File:** `lib/features/search/data/search_provider.dart:172-203`

```dart
final jsonString = await rootBundle.loadString(path);
final Map<String, dynamic> bibleJson = jsonDecode(jsonString);  // line 174: MAIN THREAD
```

Each Bible JSON file is 3-6 MB. `jsonDecode()` is CPU-intensive and blocks the main thread. Searching 3 translations = 9-18 MB decoded sequentially on the UI isolate, causing 1-5 second freezes.

**Suggested Fix:** Use `compute()` to offload JSON decode to a background isolate. Or route through `DirectBibleLoader` which already caches decoded data (avoiding redundant decoding).

---

### LOW (Minor issues, code hygiene)

- **L1.** `lib/screens/bible_page.dart` — Dead code stub (45 lines), never imported
- **L2.** `lib/debug_storage_page.dart` — Compiled into release APK but properly guarded by `kDebugMode` at runtime in `main.dart:581`
- **L3.** `android/app/build.gradle:69` — `minifyEnabled true` set but no custom ProGuard rules. Default R8 rules should suffice for Flutter but untested
- **L4.** `AndroidManifest.xml` — No `usesCleartextTraffic` attribute (defaults to `false` on API 28+ which is fine)
- **L5.** 7 upload/deployment scripts committed to repo root (`upload_apks.py/sh`, `upload_catbox.py`, `upload_multi.sh`, `upload_simple.sh`, `upload_v91.py/sh`) — should be in CI/CD, not source tree
- **L6.** `intl` and `flutter_localizations` declared in `pubspec.yaml` but no actual translations implemented — localization setup incomplete
- **L7.** Test suite is 1 file (`test/widget_test.dart`, 25 lines) — single smoke test verifying `'Bible'` label appears
- **L8.** `DailyVerseTime` model defined in `app_providers.dart` (presentation/provider layer) instead of domain/models
- **L9.** `_parseColor` defined twice within `verse_display_widget.dart` (lines 289-310 and 675-696) — identical 29-line functions
- **L10.** `trivia_page.dart:185` — `score / currentQuestions.length` has no division-by-zero guard; `currentQuestions` is checked elsewhere but not at the division point

---

## Recommended Fix Priority

### Phase 1: Critical Fixes (prevent data loss and crashes)
1. Fix font references in `app_theme.dart` — use CrimsonText/Lora/Roboto
2. Consolidate storage to `VerseStorageService` only; remove `StorageService`
3. Fix write lock race condition (use proper Mutex/async lock)
4. Remove delete-before-rename in `_saveToBackupFile()` (C8)
5. Make provider mutations persist to storage (C9)
6. Fix `mounted` checks in `daily_verse_page.dart` and other async setState sites
7. Rename/delete duplicate `GenealogyPage` class

### Phase 2: High-Impact Functional Fixes
8. Replace all 41 hardcoded `'kjv'` with selected translation
9. Persist translation selection in `SettingsNotifier._save()`
10. Fix `_highlightText()` no-op in search
11. Fix continue reading dismiss button (use callback)
12. Either call `dotenv.load()` or remove dotenv dependency
13. Consolidate to single TTS engine
14. Surface storage errors to users instead of silent swallowing

### Phase 3: Architecture Cleanup
15. Unify BibleBook/BibleTranslation model definitions
16. Remove 6 unused dependencies from pubspec.yaml
17. Extract classes from main.dart into separate files
18. Move search JSON decode to `compute()` isolate
19. Add Bible cache eviction (LRU with max 2-3 entries)
20. Deduplicate book name maps (use single canonical source)

### Phase 4: Quality & Testing
21. Add centralized error reporting service
22. Add unit tests for storage services (write lock, atomic save, persistence)
23. Add widget tests for critical flows (bookmark, highlight, translation switch)
24. Fix commentary chapter dropdown (use actual chapter count)
25. Fix `_parseReference` regex for multi-word books
26. Replace 40+ hardcoded colors with theme-aware values
27. Delete dead code (genealogy_page.dart, _ContextSection, _buildTreeNode, screens/bible_page.dart)

---

## Statistics

| Metric | Count |
|---|---|
| Total Dart files | 85 |
| Total lines of code | 27,298 |
| Critical issues | 11 |
| High issues | 14 |
| Medium issues | 17 |
| Low issues | 10 |
| Silent catch blocks | 116 |
| Hardcoded 'kjv' references | 41 |
| Unused dependencies | 6 (+ 3 dev deps) |
| Duplicate model definitions | 3 (BibleBook) + 2 (BibleTranslation) |
| Test files | 1 (smoke test only) |
| Dead code files | 2 |
| Dead code methods | 2 (~140 lines) |
| Storage systems | 3 (should be 1) |
| Hardcoded color instances | 40+ across 20+ files |
| TextEditingController leaks | 6 |
| Book name map copies | 4 |
