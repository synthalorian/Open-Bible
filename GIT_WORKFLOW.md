# Open Bible - Git Workflow

## Current Version: v1.0.0 ✅
**Tag:** `v1.0.0`
**Status:** Working
**Features:**
- Bible reader (books → chapters → verses)
- Bottom navigation
- Search with highlighted results
- Genealogy (More → Genealogy)

## Commit Protocol
Before adding new features:
1. Test current build works
2. `git add .`
3. `git commit -m "vX.Y.Z - Feature description"`
4. `git tag vX.Y.Z`
5. Then add new feature

## Version History

### v1.0.0 (Current)
- Navigation working
- Search working  
- Genealogy working
- No persistence (bookmarks/notes/streaks)

### Planned Versions
- v1.1.0 - Bookmarks & Highlights
- v1.2.0 - Notes
- v1.3.0 - Reading Plans
- v1.4.0 - Streaks
- v1.5.0 - Prayer Journal
- v1.6.0 - Footnotes
- v1.7.0 - Compare Translations
- v2.0.0 - Audio / Polish

## Recovery
If build breaks:
```bash
git reset --hard v1.0.0  # Go back to last working version
```
