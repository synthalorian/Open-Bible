# Open Bible - Feature Implementation Plan

## Current State
✅ Minimal Bible reader works (loads from assets, displays books/chapters/verses)

## Phase 1: Core Architecture (Next)
1. Add Riverpod providers (safely initialized)
2. Add SharedPreferences storage (with fallback)
3. Add bottom navigation (Bible, Search, Saved, Plans, More)

## Phase 2: Features (In Order)
1. **Genealogy** (More → Genealogy) - Visual family tree
2. **Search** - Search verses across Bible
3. **Bookmarks & Highlights** - Save verses with colors
4. **Notes** - Add notes to verses
5. **Reading Plans** - Structured reading schedules
6. **Streaks** - Track daily reading
7. **Prayer Journal** - Personal prayer notes
8. **Footnotes** - Cross-references and study notes
9. **Compare Translations** - Side-by-side versions
10. **Audio** - Text-to-speech

## Phase 3: Polish
- Settings page
- Dark mode
- Font size controls
- Notifications

## Implementation Rules
- Test each feature before adding the next
- Never use `late final` without null safety
- Always provide fallback for storage failures
- Keep UI responsive during async operations
