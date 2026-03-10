# Holy Bible App 📖

[![Flutter](https://img.shields.io/badge/Flutter-3.22+-02569B?logo=flutter)](https://flutter.dev)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-4CAF50)](#)

An extensive Bible study app for Android and iOS, built with Flutter.

## Features

### Core Features
- 📚 **Multiple Translations** - KJV, ESV, NIV, NASB, and more via api.bible
- 🔍 **Powerful Search** - Find verses, phrases, and topics instantly
- 📖 **Offline Support** - Download translations for offline reading

### Study Tools
- 🔖 **Bookmarks** - Save your favorite verses
- 🎨 **Highlights** - 8 beautiful highlight colors
- 📝 **Notes** - Add personal notes to any verse
- 📅 **Reading Plans** - 365-day, 90-day, and thematic plans
- 📊 **Reading Streaks** - Track your daily reading progress

### Advanced Features
- 🌍 **Strong's Concordance** - Greek & Hebrew word lookup
- 📜 **Commentary** - Matthew Henry, JFB, Barnes' Notes
- 🗺️ **Biblical Maps** - Interactive maps of Bible lands
- ⏳ **Timeline** - Biblical history timeline
- 🎤 **Audio Bible** - Listen to scripture (TTS)
- 🙏 **Prayer Journal** - Record and track prayers

### Daily Features
- ☀️ **Daily Verse** - New verse each day with reflection
- 🔔 **Notifications** - Customizable verse reminders
- 📱 **Home Screen Widget** - Daily verse on your home screen

### Sharing
- 🖼️ **Verse Images** - Create beautiful shareable graphics
- 📋 **Copy & Share** - Easy sharing to social media

## Tech Stack

- **Framework:** Flutter 3.22+
- **State Management:** Riverpod
- **Local Storage:** Hive + SQLite
- **Networking:** Dio + Retrofit
- **Navigation:** GoRouter
- **Charts:** FL Chart
- **Maps:** Flutter Map

## Project Structure

```
lib/
├── core/
│   ├── constants/       # App constants, Bible structure
│   ├── themes/          # Light/dark themes, reading modes
│   ├── services/        # API, storage, notifications
│   ├── providers/       # Riverpod providers
│   └── widgets/         # Shared widgets
├── features/
│   ├── bible/           # Bible reading, chapters, verses
│   ├── search/          # Search functionality
│   ├── bookmarks/       # Bookmarks management
│   ├── highlights/      # Highlight management
│   ├── notes/           # Notes management
│   ├── reading_plans/   # Reading plans
│   ├── daily_verse/     # Daily verse feature
│   ├── concordance/     # Strong's concordance
│   ├── commentary/      # Bible commentary
│   ├── maps/            # Biblical maps
│   ├── timeline/        # Biblical timeline
│   ├── prayer_journal/  # Prayer tracking
│   ├── streaks/         # Reading streaks
│   ├── sharing/         # Verse sharing
│   ├── audio/           # Audio playback
│   └── settings/        # App settings
└── main.dart
```

## Getting Started

### Prerequisites
- Flutter SDK 3.22+
- Dart 3.4+
- Android Studio / Xcode

### Installation

1. Clone the repository:
```bash
cd ~/projects
git clone <repo-url> holy_bible_app
cd holy_bible_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Set up API key:
```bash
cp .env.example .env
# Edit .env and add your api.bible key
```

4. Run the app:
```bash
flutter run
```

### API Key

Get a free API key from [api.bible](https://scripture.api.bible/):

1. Sign up at api.bible
2. Create a new application
3. Copy your API key
4. Add it to `.env` or `lib/core/constants/app_constants.dart`

## Building for Release

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing

This is a personal project, but suggestions and improvements are welcome!

## License

MIT License - feel free to use this for your own projects.

---

Made with ❤️ for the glory of God.
