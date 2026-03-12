# Open Bible — Full Code Audit

**Date:** 2026-03-12
**Scope:** All Dart source files (83), Python scripts (13), shell scripts (7), Android build configs, manifests, and project configuration.

---

## Table of Contents

1. [Critical Issues](#1-critical-issues)
2. [High Severity Issues](#2-high-severity-issues)
3. [Important Issues](#3-important-issues)
4. [Architecture Debt](#4-architecture-debt)
5. [Performance Issues](#5-performance-issues)
6. [Dependency Issues](#6-dependency-issues)
7. [Testing](#7-testing)
8. [Remediation Priority](#8-remediation-priority)

---

## 1. Critical Issues

### 1.1 Hardcoded API Keys in Version-Controlled Scripts

**Files:**
- `scripts/fetch_asv.py:15`
- `scripts/fetch_web.py:14`
- `scripts/fetch_kjv_rest.py:15`
- `scripts/fetch_kjv.py:16`
- `scripts/fetch_complete_kjv.py:15`

Two live API.Bible keys are hardcoded in committed Python scripts:

```python
API_KEY = "vJSmrm7p-nnHwXE71LTgk"  # fetch_asv, fetch_web, fetch_kjv_rest
API_KEY = "6f2JvHkjAMKbbvEhW28uE"  # fetch_kjv, fetch_complete_kjv
```

These are free-tier keys for `rest.api.bible` / `api.scripture.api.bible`, used at build time to download Bible text into static JSON assets. The app does not call the API at runtime. The blast radius is limited to rate-limit exhaustion, but the keys should still be rotated and removed from source.

**Remediation:** Revoke both keys at https://scripture.api.bible/. Replace with `os.environ.get('BIBLE_API_KEY')` in all scripts. Add a pre-commit hook (e.g., `gitleaks` or `git-secrets`) to prevent future credential commits.

---

### 1.2 `.env` File Bundled as a Flutter Asset

**File:** `pubspec.yaml:122`

```yaml
assets:
  - .env
```

The `.env` file (which contains `BIBLE_API_KEY`) is declared as a Flutter asset. This means it is packaged directly into the APK/IPA and is trivially extractable by anyone who downloads the app (`apktool d app.apk` or simply `unzip`). The `.gitignore` exclusion is meaningless if the file ships in the binary.

**Remediation:** Remove `- .env` from the assets list. For runtime API keys, use `--dart-define=BIBLE_API_KEY=xxx` at build time and access via `String.fromEnvironment()`. For truly secret keys, proxy through a backend server.

---

### 1.3 SSL Certificate Verification Disabled Globally

**Files:** All 7 `scripts/fetch_*.py` files

```python
ssl._create_default_https_context = ssl._create_unverified_context
```

This disables TLS certificate verification for the entire Python process, making every HTTPS request vulnerable to man-in-the-middle attacks. Combined with the hardcoded API keys sent in request headers, an attacker on the same network could intercept both the credentials and the response data.

**Remediation:** Remove all `ssl._create_default_https_context` lines. The default SSL context verifies certificates correctly. If a specific cert issue was encountered, fix the root cause (update CA bundle via `pip install certifi`).

---

### 1.4 Hardcoded Keystore Password

**File:** `scripts/generate-keystore.sh:16-22, 32-37`

The script hardcodes the keystore store password and key password as `openbible123` and writes them into `key.properties`:

```bash
-storepass openbible123 \
-keypass openbible123 \
```

If the `.jks` keystore file is obtained alongside this script (both are in the same repo), an attacker can sign malicious APKs as the official app.

**Remediation:** Remove hardcoded passwords. Let `keytool` prompt interactively (omit `-storepass`), or accept passwords via environment variable. Use a strong, randomly generated password stored only in a secrets manager.

---

### 1.5 API Key Logged in Production via LogInterceptor

**File:** `lib/core/services/bible_api_service.dart:20-24`

```dart
_dio.interceptors.add(LogInterceptor(
  requestBody: true,
  responseBody: true,
  error: true,
));
```

Dio's `LogInterceptor` logs all request headers (including the `api-key` header) via `print()`, which is not stripped in Flutter release builds. On Android, this output is readable via `adb logcat`.

**Remediation:** Remove the `LogInterceptor` from the production path, or guard with `kDebugMode` and set `requestHeader: false`:

```dart
if (kDebugMode) {
  _dio.interceptors.add(LogInterceptor(
    requestHeader: false,
    requestBody: true,
    responseBody: true,
  ));
}
```

---

### 1.6 Debug Panel Exposed in Production

**File:** `lib/main.dart:823-829`

The "Storage Debug" page is in the production "More" menu with no debug-mode guard:

```dart
ListTile(
  leading: const Icon(Icons.bug_report),
  title: const Text('Storage Debug'),
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const DebugStoragePage()),
  ),
),
```

The `DebugStoragePage` (`lib/debug_storage_page.dart`) exposes:
- Full raw JSON of all stored user data (bookmarks, notes, highlights, prayer journal entries)
- Storage file paths on the device
- A "Wipe All Saved Data" button
- Internal diagnostic details

**Remediation:** Wrap with `if (kDebugMode)` from `package:flutter/foundation.dart`, or remove entirely before production release.

---

### 1.7 String Interpolation Bug — All Verse IDs Are Malformed

**File:** `lib/features/bible/presentation/pages/chapter_reader_page.dart`

Three locations use `$widget.bookId` instead of `${widget.bookId}`:

- **Line 108:** `verseId: '${_currentBibleId}:$widget.bookId:$chapter:${v['verse']}'`
- **Line 882:** `id: '$widget.bookId-$_currentChapter-${DateTime.now().millisecondsSinceEpoch}'`
- **Line 1098:** `final verseId = '${CurrentBible.id}:$widget.bookId:$_currentChapter:$verseNum'`

In Dart, `$widget.bookId` interpolates `widget.toString()` followed by the literal string `.bookId`. This produces verse IDs like `"kjv:Instance of 'ChapterReaderPage'.bookId:3:5"` instead of `"kjv:genesis:3:5"`. Every bookmark, highlight, and note is stored with a malformed key and will never match on subsequent lookup.

**Remediation:** Change all three to `${widget.bookId}`.

---

### 1.8 GoRouter Is Dead Code — `context.push()` Crashes at Runtime

**Files:**
- `lib/main.dart:83` — uses `MaterialApp(home: const MainNavigationPage())`
- `lib/core/app_router.dart:80-285` — full GoRouter config, never wired
- `lib/features/bible/presentation/pages/chapter_reader_page.dart:681, 695` — calls `context.push()`

`main.dart` uses `MaterialApp(home:)`, not `MaterialApp.router(routerConfig: appRouter)`. The entire GoRouter definition in `app_router.dart` is unreachable dead code. However, `chapter_reader_page.dart` calls `context.push('/more/commentary')` (line 681) and `context.push('/more/maps')` (line 695), which will crash at runtime with "No GoRouter found in context."

**Remediation:** Choose one navigation system. Either:
- Wire GoRouter: replace `MaterialApp(home:)` with `MaterialApp.router(routerConfig: appRouter)` and delete `MainNavigationPage`, or
- Delete `app_router.dart` and replace the two `context.push()` calls with `Navigator.push()`

---

### 1.9 Download Manager Is a Stub — Fakes Successful Downloads

**File:** `lib/core/services/bible_download_manager.dart:266-310`

The download loop calls `await Future.delayed()` 11 times to simulate progress, then sets `_downloadedVersions[versionId] = true` without writing any file to disk. `isVersionAvailable()` returns `true` for "downloaded" versions, but `DirectBibleLoader._loadBible()` attempts `rootBundle.loadString('assets/bible_data/${fileName}')` — non-bundled translations have no corresponding asset, so the load throws and returns `null`.

The user sees a spinner, gets a success confirmation, but then the Bible content is empty. The `bible_downloads.json` state file persists the `true` flag across restarts, so the user is never shown a download prompt again.

**Remediation:** Either implement actual download logic that writes Bible JSON to the app's documents directory and loads from there, or remove the download feature entirely and only offer bundled translations.

---

### 1.10 Dual TTS Engine Instances — Audio State Permanently Inconsistent

**Files:**
- `lib/core/services/bible_audio_service.dart` — `BibleAudioService` singleton with its own `FlutterTts`
- `lib/core/providers/audio_bible_provider.dart` — `AudioBibleNotifier` with a separate `FlutterTts`

Two independent TTS systems exist:
- `ChapterReaderPage` uses `BibleAudioService.instance` directly (lines 956, 971, 973)
- `AudioBibleWidget` and `CompactAudioButton` use `audioBibleProvider` (wraps `AudioBibleNotifier`)

Both call `_tts.speak()` on different engine instances. Neither is aware of the other's state. Additionally, `AudioBibleNotifier` has no `dispose()` override — the `FlutterTts` instance is held for the entire app lifetime with no cleanup.

**Remediation:** Eliminate one system. `BibleAudioService` is the one wired to the chapter reader — either delete `AudioBibleNotifier` or refactor it to delegate to `BibleAudioService`. Add a `dispose()` override to call `_tts.stop()`.

---

### 1.11 Triple-Redundant Bookmark Storage

**File:** `lib/main.dart:407-434`

A single bookmark action writes to three separate storage systems:

```dart
await VerseStorageService.addBookmark(verse);            // file-backed JSON
ref.read(bookmarksProvider.notifier).addBookmark(chapterRef); // in-memory Riverpod
final prefs = await SharedPreferences.getInstance();      // SharedPreferences
```

These three stores diverge immediately. The `BookmarksPage` reads from `VerseStorageService`, the provider's in-memory list may differ, and `SharedPreferences` has its own copy.

Additionally, two separate `bookmarksProvider` definitions exist:
- `lib/core/bookmarks_provider.dart:4` — uses `SharedPreferences`
- `lib/core/providers/app_providers.dart:22` — uses `VerseStorageService`

Depending on import order, consumers get different state.

**Remediation:** Delete `lib/core/bookmarks_provider.dart`. Remove all `SharedPreferences` bookmark writes. Ensure `BookmarksNotifier.addBookmark()` delegates to `VerseStorageService`.

---

### 1.12 Concurrent Write Race in Persistence Layer

**File:** `lib/core/services/verse_storage_service.dart:194-220`

All mutating operations (`addBookmark`, `removeBookmark`, `addHighlight`, `saveNote`, `saveHistory`, etc.) each independently call `_saveToBackupFile()` with no synchronization. If two operations are awaited concurrently, both create and write `${f.path}.tmp`, then both attempt `f.delete()` followed by `tmpFile.rename(f.path)`. One rename wins; the other's `f.delete()` deletes the winner's file, leaving storage empty. If the app is killed at that instant, all data is lost.

**Remediation:** Serialize writes with a mutex:

```dart
import 'package:synchronized/synchronized.dart';
final _writeLock = Lock();

static Future<void> _saveToBackupFile() async {
  await _writeLock.synchronized(() async { /* ... */ });
}
```

---

### 1.13 `File.rename()` Fails Cross-Device on Android

**File:** `lib/core/services/verse_storage_service.dart:208-218`

`_saveToBackupFile()` writes to a `.tmp` file and calls `tmpFile.rename(f.path)`. On Android, `getApplicationSupportDirectory()` and `getApplicationDocumentsDirectory()` can resolve to paths on different mount points. `File.rename()` across mount points throws `FileSystemException: Cross-device link`. The catch block only updates `_lastError` — no fallback write occurs. Silent data loss.

**Remediation:** After a rename exception, fall back to a direct write:

```dart
try {
  await tmpFile.rename(f.path);
} on FileSystemException {
  await f.writeAsString(jsonString, flush: true);
  await tmpFile.delete();
}
```

---

### 1.14 Full Bible JSON Re-parsed on Every Search and Chapter Load

**Files:**
- `lib/features/search/data/search_provider.dart:155-188` — `rootBundle.loadString` + `jsonDecode` on every search
- `lib/features/bible/data/repositories/bible_repository.dart:44-75` — same on every `getChapter()` call
- `lib/main.dart:540-543` — legacy SearchPage re-decodes KJV on every search

Each Bible JSON file is 5-15 MB. Decoding on every operation causes 300-800ms UI freezes on mid-range devices. `DirectBibleLoader` has a cache, but these code paths bypass it entirely.

**Remediation:** Route all Bible data access through `DirectBibleLoader` which already caches decoded JSON, or add static caches to `BibleRepository` and `BibleSearchNotifier`.

---

### 1.15 `CurrentBible` Global Mutable Singleton — Race Conditions

**File:** `lib/core/services/current_bible.dart`

`CurrentBible` is a plain static class with mutable state, written from at least four separate call sites and read in `ChapterReaderPage._loadChapterContent`, `_buildChapterContent`, `_playAudio`, and `_bookmarkCurrentVerse`. If a user taps a search result (which calls `CurrentBible.set`) while `ChapterReaderPage` is mid-load using a previous value, the chapter content and bookmarks will be attributed to the wrong translation.

**Remediation:** Eliminate `CurrentBible`. Use `ref.watch(selectedTranslationProvider)` consistently everywhere.

---

## 2. High Severity Issues

### 2.1 Location Permissions Requested but Never Used

**File:** `android/app/src/main/AndroidManifest.xml:3-5`

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

The maps feature (`BiblicalMapsPage`) uses OpenStreetMap tiles with hardcoded coordinates centered on Jerusalem. No code requests the user's device location. Over-permissioning violates least privilege and will trigger Play Store review questions.

**Remediation:** Remove both location permissions unless a "show my location" feature is planned. If so, request only at runtime when invoked.

---

### 2.2 Privacy Policy Inaccurate — No Analytics, No Opt-Out, No Contact

**File:** `lib/features/settings/presentation/pages/privacy_policy_page.dart:46-97`

The privacy policy claims:
- "Usage Data: Anonymous app usage statistics" — no analytics SDK exists in the codebase
- "Analytics: Anonymous usage statistics (optional)" — no opt-out toggle exists in settings
- "Developer: synth (synthalorian)" — no email address or contact URL provided

This creates GDPR and CCPA exposure.

**Remediation:** Either remove references to analytics (since none exists) or implement the described opt-out. Add a real contact email.

---

### 2.3 APK Distribution via Anonymous/Defunct File Hosts

**Files:** `upload_v91.py`, `upload_v91.sh`, `upload_multi.sh`, `upload_simple.sh`

Upload scripts distribute signed APKs to anonymous file hosting services: transfer.sh, 0x0.st, file.io, oshi.at, and anonfiles.com. `anonfiles.com` shut down in 2023 and the domain redirects to unrelated content. These services provide no integrity verification, no expiry control, and no access revocation.

**Remediation:** Distribute via Google Play Store, GitHub Releases with SHA-256 checksums, or F-Droid. Remove anonfiles.com references.

---

### 2.4 Audio Play State Polled, Not Observed — Stale UI

**File:** `lib/features/bible/presentation/pages/chapter_reader_page.dart:163-167`

`_isPlayingAudio` is a manual boolean updated via a one-shot `Future.delayed(1 second)` in `initState` and when the user taps play/stop. `BibleAudioService` has completion and error handlers that set `_isPlaying = false`, but `ChapterReaderPage` never observes these. If TTS finishes naturally, the UI shows a stale "playing" icon indefinitely.

**Remediation:** `BibleAudioService` should expose a `ValueNotifier<bool>` or `Stream<bool>` for `isPlaying`. `ChapterReaderPage` should subscribe in `initState` and cancel in `dispose`.

---

### 2.5 `build()` Method Mutates State — Potential Infinite Rebuild Loop

**File:** `lib/features/bible/presentation/pages/chapter_reader_page.dart:395-402`

```dart
if (_currentBibleId != currentBibleId) {
  _currentBibleId = currentBibleId;   // mutates field in build()
  _chapterCache.clear();              // mutates state in build()
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _loadChapterContent(_currentChapter);  // calls setState
  });
}
```

Mutating state inside `build()` is a contract violation. `_loadChapterContent` calls `setState()`, triggering another `build()`, which may re-evaluate the condition and re-schedule. This also races with the `didChangeDependencies` override at lines 367-384 which performs the same check.

**Remediation:** Remove the in-`build()` detection block. The `didChangeDependencies` override already handles this correctly.

---

### 2.6 `FlutterTts` Never Disposed — Memory Leak

**File:** `lib/core/providers/audio_bible_provider.dart`

`AudioBibleNotifier` creates a `FlutterTts` instance in its field initializer with no `dispose()` override. The TTS engine is held for the entire app lifetime.

**Remediation:** Override `dispose()`:

```dart
@override
void dispose() {
  _flutterTts.stop();
  super.dispose();
}
```

---

### 2.7 Search Debounce Timer Not Cancelled on Dispose

**File:** `lib/features/search/data/search_provider.dart:115`

`Timer? _debounceTimer` is cancelled in `updateQuery` but there is no `dispose()` override. If the provider is disposed while a timer is pending, it fires and calls `search()` on a disposed notifier, causing a crash.

**Remediation:** Override `dispose()`:

```dart
@override
void dispose() {
  _debounceTimer?.cancel();
  super.dispose();
}
```

---

### 2.8 All Scripts Hardcoded to `/home/synth/...`

**Files:** Nearly every script in `scripts/` and all `upload_*.sh` files.

Examples:
- `scripts/generate-keystore.sh:4-6`
- `scripts/fetch_asv.py:18`: `OUTPUT_FILE = "/home/synth/projects/open-bible/assets/bible_data/asv_complete.json"`
- `upload_multi.sh:5`: `APK_DIR="/home/synth/projects/open-bible/build/..."`

None of these scripts will work on any other machine.

**Remediation:** Replace hardcoded paths with relative paths using `$(dirname "$0")` in shell or `pathlib.Path(__file__).parent` in Python.

---

### 2.9 Machine-Specific Java Path in gradle.properties

**File:** `android/gradle.properties:2`

```
org.gradle.java.home=/home/synth/.local/share/mise/installs/java/17.0.2
```

Gradle will fail on any other machine. This file is committed to git.

**Remediation:** Remove this line. Gradle uses `JAVA_HOME` or auto-detects. Document required Java version in README instead.

---

### 2.10 Release Build Has No Code Shrinking or Obfuscation

**File:** `android/app/build.gradle:67-71`

```groovy
release {
    signingConfig = signingConfigs.release
    minifyEnabled false
    shrinkResources false
}
```

The release APK includes all class names, method names, and resources in unobfuscated form. Larger APK size and easier reverse engineering.

**Remediation:** Enable `minifyEnabled true` and `shrinkResources true`. Add ProGuard/R8 rules for libraries that require them.

---

## 3. Important Issues

### 3.1 `themeProvider` Written But Never Read — Dead Code

**Files:**
- `lib/core/providers/theme_provider.dart` — stores `isDark` in SharedPreferences
- `lib/features/settings/presentation/pages/settings_page.dart:268` — writes to `themeProvider`
- `lib/main.dart:64-81` — reads theme exclusively from `settingsProvider.readingMode`

`themeProvider` is an orphan. `settings_page.dart` writes to both providers, but only `settingsProvider` is consumed.

**Remediation:** Delete `themeProvider` entirely. Remove the call at `settings_page.dart:268`.

---

### 3.2 "Clear Cache" Dialog Is a No-Op

**File:** `lib/features/settings/presentation/pages/settings_page.dart:368-391`

The "Clear Cache" confirm button only pops the dialog and shows a SnackBar saying "Cache cleared!" — no actual cache-clearing method is called.

**Remediation:** Implement actual cache clearing or remove the UI option.

---

### 3.3 Historical Context Always Shows Genesis Content

**File:** `lib/features/bible/presentation/pages/chapter_reader_page.dart:843-855`

The "Historical Context" bottom sheet always displays:
- "Traditionally attributed to Moses, written around 1440-1400 BC."
- "Creation, Covenant, Faith, Redemption"

This is Genesis-only content shown for all 66 books.

**Remediation:** Make content dynamic based on `_bookName`, or show "Content coming soon" for books without data.

---

### 3.4 Hardcoded Colors Break Dark/AMOLED Mode

**File:** `lib/features/bible/presentation/widgets/verse_widget.dart:183-203, 525-549`

```dart
color: Colors.grey[100],
border: Border.all(color: Colors.grey[300]!),
color: Colors.black87,
```

These hardcoded colors in note display and verse preview are invisible or low-contrast in dark mode.

**Remediation:** Use `Theme.of(context).colorScheme.surfaceContainerHighest` and `Theme.of(context).colorScheme.onSurface`.

---

### 3.5 `didChangeDependencies` Triggers File I/O on Every Inherited Widget Change

**File:** `lib/features/bible/presentation/pages/bible_home_page.dart:186-189`

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  _loadContinueReading();
}
```

`didChangeDependencies` fires on every theme, locale, or MediaQuery change. `ContinueReadingService.getLastPosition()` does synchronous I/O on each call.

**Remediation:** Cache the result and only reload on actual navigation events.

---

### 3.6 Full History Deserialized on Every Chapter Swipe

**File:** `lib/core/services/reading_history_service.dart:58-82`

`addEntry()` deserializes the entire history list, scans for duplicates, inserts, re-serializes, and writes back to disk on every chapter swipe. With 100+ history items, this is a full JSON round-trip per swipe.

**Remediation:** Keep history in memory and batch-write on a timer or app lifecycle event.

---

### 3.7 Read-Modify-Write Race in Reading History

**File:** `lib/core/services/reading_history_service.dart:58-82`

Two concurrent `addEntry()` calls both read the same list snapshot, each produce a list with only one new entry, and the second `saveHistory()` overwrites the first. The entry written first is lost.

**Remediation:** Serialize access with a lock, same as the `VerseStorageService` fix (issue 1.12).

---

### 3.8 `ContinueReadingService` Writes 7 SharedPreferences Keys Non-Atomically

**File:** `lib/core/services/continue_reading_service.dart:39-45`

Seven sequential `await _prefs!.setString/setInt()` calls. If the process is killed mid-write, `getLastPosition()` sees partial state (e.g., `bookId` but null `chapter`), which the null check on line 74 rejects — the user loses their "continue reading" position.

**Remediation:** Serialize the position as a single JSON string under one key.

---

### 3.9 Settings Save Silently Swallows All Errors

**File:** `lib/core/providers/app_providers.dart:209`

```dart
} catch (_) {}
```

User settings (font size, reading mode, notifications) failing to persist is invisible. Settings revert on restart with no indication.

The same pattern appears in:
- `reading_history_service.dart:52`
- `search_provider.dart` (RecentSearchesNotifier): lines 43, 55, 64, 71
- `reading_plan_provider.dart`: 6 occurrences
- `verse_widget.dart:71`

**Remediation:** At minimum `debugPrint` the error. For critical paths, surface to the user or retry.

---

### 3.10 34x Bare `print()` Calls in Release Code

**Files:** 11 files, notably `lib/core/services/direct_bible_loader.dart` (14 calls in hot paths).

`print()` is not stripped from Flutter release builds. It causes performance degradation on Android (Logcat buffering) and leaks internal operation details.

The project already depends on the `logger` package (`pubspec.yaml:71`) but never uses it.

**Remediation:** Replace all `print()` with `debugPrint()` (stripped in release) or use the already-imported `logger` package.

---

### 3.11 `_normalizeBookId` Heuristic Duplicated and Fragile

**Files:**
- `lib/main.dart:740-744`
- `lib/features/search/presentation/pages/search_page.dart:336-342`

The logic `if (id.contains(' ') || id.length > 4) return id` will incorrectly pass through short IDs like "JHN" or "1SA" unchanged. Error handling in the caller swallows failures silently.

**Remediation:** Create a single `BookIdNormalizer` utility using `BibleStructure.allBooks` as the canonical reference.

---

### 3.12 `OfflineBibleService` Null-Unsafe Verse Formatting

**File:** `lib/core/services/offline_bible_service.dart:79`

```dart
verse['text']  // no null check
```

`DirectBibleLoader` uses `verse['text']?.toString() ?? ''`. `OfflineBibleService` does not — any Bible JSON file that omits the `text` field will render the literal string `"null"` in the UI.

Note: `OfflineBibleService` appears to be dead code (never called by the active code path), but the inconsistency is a maintenance hazard.

**Remediation:** Either delete `OfflineBibleService` (if dead code) or add null-safe access matching `DirectBibleLoader`.

---

### 3.13 Duplicate `BibleBook` Class with Divergent Testament Parsing

**Files:**
- `lib/features/bible/data/repositories/bible_repository.dart:4-22`
- `lib/features/bible/data/models/bible_book.dart`

Both define a `BibleBook` class with a `_parseTestament()` helper. The repository version checks `'new_testament'` but not `'old'`; the models version checks both. Code importing from one gets silently different parsing behavior.

**Remediation:** Delete the duplicate in `bible_repository.dart`. Import from `bible_book.dart`.

---

### 3.14 `StorageService.init()` Has a TOCTOU Race

**File:** `lib/core/services/storage_service.dart:268-278`

The guard `if (_initialized) return;` is checked before the async `await SharedPreferences.getInstance()`. Two concurrent callers can both pass the guard before either completes. Currently harmless because `SharedPreferences.getInstance()` is idempotent, but fragile if non-idempotent work is ever added.

**Remediation:** Use a `Completer` to join concurrent init calls:

```dart
static Completer<void>? _initCompleter;

static Future<void> initialize({bool force = false}) async {
  if (_initialized && !force) return;
  if (_initCompleter != null) return _initCompleter!.future;
  _initCompleter = Completer();
  try {
    /* init logic */
    _initCompleter!.complete();
  } catch (e) {
    _initCompleter!.completeError(e);
  } finally {
    _initCompleter = null;
  }
}
```

---

### 3.15 Book-Matching Algorithm Can Produce False Positives

**File:** `lib/core/services/direct_bible_loader.dart:66-73`

The matching logic includes:

```dart
normalizedBookId.startsWith(bookNameInJson) || bookNameInJson.startsWith(normalizedBookId)
```

And: `bookIdInJson == normalizedBookId.substring(0, 3)` — any 3-character book ID matches any request whose normalized form starts with the same 3 characters. Low-severity given the closed set of Bible books, but fragile and untested.

---

### 3.16 104x Deprecated `Color.withOpacity()` Calls

**Files:** 30 files across the codebase.

`Color.withOpacity()` was deprecated in Flutter 3.27 in favor of `Color.withValues(alpha: ...)`. Will emit warnings now and break in a future release.

**Remediation:** Replace all instances with `Color.withValues(alpha: x)`.

---

### 3.17 Upload Shell Scripts Have Broken Bash Syntax

**Files:**
- `upload_apks.sh:23, 31, 38`
- `upload_multi.sh:45`

```bash
if [[ $? ]];!= "" ]];
```

This is invalid Bash. Both scripts have `set -e` at the top, so they will exit on the first error.

**Remediation:** Rewrite conditionals as `if [[ -n "$response" ]]; then`. Audit the overall control flow of `upload_apks.sh` (loop/function structure is also malformed).

---

### 3.18 `lib/screens/**` Excluded from Dart Analyzer

**File:** `analysis_options.yaml:14-16`

```yaml
analyzer:
  exclude:
    - lib/screens/**
```

If `lib/screens/` contains active production code, all analysis errors are silently ignored.

**Remediation:** Remove the exclusion unless the directory contains only archived code.

---

### 3.19 Defunct Upload Target

**Files:** `upload_multi.sh:14`, `upload_v91.sh:44`, `upload_v91.py:43`

`anonfiles.com` shut down in 2023. Uploading to it will either fail or send APKs to an unknown third party.

**Remediation:** Remove all `anonfiles.com` references.

---

### 3.20 Unguarded `print()` Leaks User Activity in Release Builds

**File:** `lib/core/services/reading_history_service.dart:80` and others

`print()` calls in production code output to `stdout`, readable via `adb logcat`. Messages include internal paths, operation details, and which translation the user switched to.

**Remediation:** Replace with `debugPrint()` or gate behind `kDebugMode`.

---

### 3.21 Prayer Journal and Notes Stored Unencrypted

**File:** `lib/core/services/verse_storage_service.dart:134`

User notes and prayer journal entries are stored in plaintext JSON in the app's documents directory. On a compromised device or via ADB backup, this data is readable. The privacy policy claims "industry-standard security practices."

**Remediation:** For sensitive categories, use `flutter_secure_storage` with AES-256 encryption. At minimum, update the privacy policy to accurately describe the storage model.

---

### 3.22 Google Maps API Key Placeholder Pattern

**File:** `android/app/src/main/AndroidManifest.xml:13-16`

```xml
<meta-data
    android:name="com.google.android.geo.API_KEY"
    android:value="YOUR_GOOGLE_MAPS_API_KEY_HERE"/>
```

Currently a placeholder, but the pattern means a real key will be committed when substituted.

**Remediation:** Use `manifestPlaceholders` in `build.gradle` to inject the key from a `local.properties` file or environment variable.

---

### 3.23 `_BiblePageState.build` Triggers Async Load

**File:** `lib/main.dart:187-191`

```dart
if (_currentTranslation != selectedTranslationId) {
  Future.microtask(() => _loadBibleDataFor(selectedTranslationId));
}
```

Scheduling async work via `Future.microtask` from within `build` is an anti-pattern that can cause infinite rebuild loops.

**Remediation:** Use `ref.listen` outside of `build` (in `initState` or `ref.listenManual`).

---

### 3.24 GoRouter `debugLogDiagnostics` Left On

**File:** `lib/core/app_router.dart:82`

```dart
debugLogDiagnostics: true
```

Routing events are printed to the console in release builds.

**Remediation:** Set `debugLogDiagnostics: kDebugMode`.

---

### 3.25 `_BookAbbr` Map Duplicated Three Times

The 66-entry book name to abbreviation map is copy-pasted in:
- `chapter_reader_page.dart:53-70`
- `bible_search_service.dart:31-53`
- `bible_repository.dart` (implicit via `bookIdInJson.startsWith` matching)

**Remediation:** Extract to a single constant in `app_constants.dart`.

---

## 4. Architecture Debt

### 4.1 Two Parallel Navigation Systems

GoRouter (`app_router.dart`) defines a complete routing table with `StatefulShellRoute`, deep-link paths, and an `AppShell`. `main.dart` uses `Navigator.push` for all navigation and defines its own `MainNavigationPage` with a bottom nav bar. The GoRouter `AppShell` is a completely separate entry point. GoRouter deep links do not work. Back button behavior is unpredictable.

### 4.2 Three Incompatible `BibleBook` Models

- `main.dart:845-863` — has `id`, `name`, `List<BibleChapter>` (full verse data)
- `features/bible/data/repositories/bible_repository.dart:4` — has `id`, `name`, `abbreviation`, `chapters` (int), `testament`
- `features/bible/domain/bible_models.dart:74` — has `id`, `name`, `nameLong`, `abbreviation`, `testament` (int), `position`, `chapterCount`

These cannot be substituted for one another.

### 4.3 Three Redundant Bible Loading Services

- `DirectBibleLoader` — has cache, used by `ChapterReaderPage`
- `OfflineBibleService` — no cache, null-unsafe, apparently dead code
- `BibleRepository` — no cache, re-parses on every call

### 4.4 Two `SearchPage` Classes

- `main.dart:519-648` — uses raw `rootBundle.loadString` on KJV only, no provider, no debounce (dead code)
- `features/search/presentation/pages/search_page.dart` — full feature with providers, debounce, filters

### 4.5 `DatabaseService` Is Dead Code

`lib/core/services/database_service.dart` — a complete SQLite layer imported nowhere. The `sqflite` dependency adds binary size for zero functionality.

### 4.6 Duplicate `SearchResult` Classes

`main.dart:651` and `search_provider.dart:87` define `SearchResult` with incompatible shapes.

---

## 5. Performance Issues

### 5.1 `_buildBooksListFor` Does O(n*m) String Matching Per Build

**File:** `lib/main.dart:261-265`

```dart
final filteredBooks = _books.where((book) {
  final normalized = book.name.toLowerCase().trim();
  return testamentBooks.any((b) => b.toLowerCase().trim() == normalized);
}).toList();
```

For each of 66 books, iterates 39 or 27 testament items. Re-lowercases constant strings every call. Runs on every `build()`.

**Remediation:** Pre-compute filtered sets as `Set<String>` during `initState`.

### 5.2 `KJV JSON Re-decoded Per Search (Legacy SearchPage)`

**File:** `lib/main.dart:540-543`

The legacy `SearchPage` calls `rootBundle.loadString('assets/bible_data/kjv_bible.json')` and `json.decode()` on every search submission with no caching. 4-8 MB decoded on the main isolate per search.

### 5.3 Missing `const` Constructors

Various widget instantiations throughout the codebase miss the `const` keyword on constructors that support it (e.g., `audio_bible_widget.dart:55`). Causes unnecessary rebuilds.

---

## 6. Dependency Issues

### 6.1 Both `flutter_map` and `google_maps_flutter` Declared

**File:** `pubspec.yaml:82-84`

Both mapping libraries are declared. Three separate map page files exist. Including `google_maps_flutter` without a working API key causes runtime crashes. If only OSM is used, the Google Maps dependency adds ~2MB to APK size for no benefit.

### 6.2 `hive` / `hive_flutter` Declared But Unused

**File:** `pubspec.yaml:29-30`

No `HiveObject` subclasses, `Hive.openBox` calls, or `@HiveType` annotations found anywhere. All persistence uses file-backed JSON and SharedPreferences.

### 6.3 `dio` / `retrofit` Declared But Unused

**File:** `pubspec.yaml:25-26`

`BibleApiService` exists but is not wired into any provider or page. The app is fully offline. These packages (plus build-time `retrofit_generator`) add unnecessary build complexity and APK weight.

---

## 7. Testing

### 7.1 Effectively Zero Test Coverage

**File:** `test/widget_test.dart`

The single test only verifies the navigation bar label `'Bible'` appears. No unit tests exist for:

- `VerseStorageService` (migration logic, concurrent write safety)
- `BibleSearchService` or `BibleSearchNotifier`
- `ReadingHistoryService.addEntry` (deduplication, size limiting)
- `SettingsNotifier` (persistence round-trip)
- `ChapterReaderPage` (translation switching, page navigation)
- Any widget tests for `VerseWidget`, bookmark/highlight state
- String interpolation correctness in verse IDs

Given the number of subtle state management bugs found, automated tests would have caught most of them.

---

## 8. Remediation Priority

### Immediate (Before Any Distribution)

1. Rotate the two API.Bible keys
2. Remove `.env` from `pubspec.yaml` assets
3. Fix `${widget.bookId}` string interpolation (3 locations)
4. Gate debug page behind `kDebugMode`
5. Remove hardcoded keystore password from script

### Short-Term (Before Production Release)

6. Pick one navigation system and delete the other
7. Add write serialization to `VerseStorageService`
8. Consolidate to one TTS instance and one bookmark store
9. Cache decoded Bible JSON (stop re-parsing 5MB per operation)
10. Implement actual download logic or remove the feature
11. Remove SSL verification disabling from scripts
12. Fix `File.rename()` cross-device fallback
13. Remove unused dependencies (`hive`, `dio`, `retrofit`, `google_maps_flutter`, `sqflite`)
14. Enable `minifyEnabled` and `shrinkResources` for release builds
15. Replace all `print()` with `debugPrint()`
16. Remove location permissions

### Medium-Term (Code Quality)

17. Delete dead code (`app_router.dart`, `DatabaseService`, `OfflineBibleService`, legacy `SearchPage`)
18. Unify `BibleBook` model to single definition
19. Extract book abbreviation map to single constant
20. Fix privacy policy accuracy
21. Replace hardcoded colors with theme-aware values
22. Replace deprecated `withOpacity` calls (104 instances)
23. Fix all shell script syntax errors
24. Replace hardcoded `/home/synth/` paths with relative paths

### Long-Term (Reliability)

25. Add unit tests for storage, search, history services
26. Add widget tests for core reading experience
27. Encrypt sensitive local storage (prayer journal, notes)
28. Set up pre-commit secret scanning
29. Implement proper CI/CD pipeline with APK signing via secrets manager
