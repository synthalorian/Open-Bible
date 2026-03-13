# Open Bible 📖

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-4CAF50)](#)

A comprehensive, performance-optimized, and high-precision Bible study application for Android and iOS. Built with a focus on stability, offline accessibility, and a seamless reading experience.

**This is the wave.** 🌊

## 🚀 Key Features

### 📖 The Word, Offline
- **20+ Bundled Translations**: Immediate access to KJV, Geneva (1599), Wycliffe (1382), Tyndale (1526), ASV, YLT, and many more without needing a data connection.
- **Deep Stabilization**: High-reliability persistence engine ensuring your reading mode, translation choice, and progress survive force-closes and system reboots.
- **High-Precision Search**: Instant full-text search across all bundled translations with support for biblical references.

### 🛠️ Professional Study Tools
- **Translation Comparison**: Long-press any verse to instantly compare it across all 20+ available versions.
- **Strong's Concordance**: Deep Greek & Hebrew word lookups integrated directly into the reading flow.
- **Precision Highlighting**: 8 theme-aware highlight colors with support for specific word-range selection.
- **Integrated Notes & Bookmarks**: Add personal reflections to any verse or bookmark whole chapters for quick access.

### 🎧 Audio & Daily Engagement
- **Smart Audio Bible**: Integrated Text-to-Speech (TTS) with **Real-Time Slider Sync**. Adjust speed, pitch, and volume mid-verse with immediate feedback.
- **Structured Reading Plans**: Complete the Bible in a Year (365 days), New Testament in 90 days, or focused Gospel journeys.
- **Daily Verse & Streaks**: Stay consistent with customizable daily reminders and progress tracking.

### 🎨 Visuals & UI
- **Four Reading Modes**: Optimized Day, Night, Sepia, and AMOLED modes for any lighting condition.
- **Typographic Precision**: Featuring **CrimsonText** for a classic scriptural feel and **Roboto** for a clean UI.
- **Zero-Flicker Startup**: Gated initialization ensures your theme is applied before the first frame, eliminating startup "white flashes."

---

## 🛠️ Tech Stack

- **Framework:** Flutter 3.22+
- **State Management:** Riverpod (Reactive state architecture)
- **Local Storage:** Unified `VerseStorageService` with `SharedPreferences` mirroring for critical reliability.
- **Audio:** `flutter_tts` with custom debounced re-sync logic.
- **Build System:** Automated Gradle environment locking for consistent release artifacts.

---

## 📂 Project Architecture

The codebase follows a modular feature-based architecture for maximum maintainability:

```
lib/
├── core/                # App-wide services, themes, and unified persistence
├── features/
│   ├── bible/           # Multi-engine reader & book navigation
│   ├── search/          # Optimized full-text search
│   ├── comparison/      # Side-by-side translation analysis
│   ├── audio/           # Real-time reactive TTS engine
│   ├── concordance/     # Lexicon & word studies
│   ├── reading_plans/   # Linear traversal scheduling
│   └── ...              # Streaks, Prayer Journal, Maps, etc.
└── main.dart            # Gated initialization & root navigation
```

---

## ⚙️ Getting Started

### Prerequisites
- Flutter SDK 3.22+
- Dart 3.4+
- Android Studio (OpenJDK 17 recommended) / Xcode

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/synthalorian/open-bible.git
   cd open-bible
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Build the app:**
   ```bash
   flutter run
   ```

---

## 📦 Building for Release

The build environment is locked to OpenJDK 17 for stability.

### Android
```bash
# Generate a new signing key locally if needed
./scripts/generate-keystore.sh
# Build release APK
flutter build apk --release
```

---

## 🙏 Credits & Dedication

Every line of code in this project carries the DNA of those who came before. Developed by **synth** with assistance from **synthclaw**.

**Write the future in the present while preserving the past.**

---

Made with ❤️ for the glory of God. ✝️
