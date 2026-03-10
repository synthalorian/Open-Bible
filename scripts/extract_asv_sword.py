#!/usr/bin/env python3
"""
Extract complete ASV from Sword module and convert to JSON.
"""

import sys
sys.path.insert(0, '/tmp/sword')

from pysword.modules import SwordModules
import json
import os

# Book names in Sword format
BOOKS = [
    ('Genesis', 50), ('Exodus', 40), ('Leviticus', 27), ('Numbers', 36), ('Deuteronomy', 34),
    ('Joshua', 24), ('Judges', 21), ('Ruth', 4), ('I Samuel', 31), ('II Samuel', 24),
    ('I Kings', 22), ('II Kings', 25), ('I Chronicles', 29), ('II Chronicles', 36), ('Ezra', 10),
    ('Nehemiah', 13), ('Esther', 10), ('Job', 42), ('Psalms', 150), ('Proverbs', 31),
    ('Ecclesiastes', 12), ('Song of Solomon', 8), ('Isaiah', 66), ('Jeremiah', 52),
    ('Lamentations', 5), ('Ezekiel', 48), ('Daniel', 12), ('Hosea', 14), ('Joel', 3),
    ('Amos', 9), ('Obadiah', 1), ('Jonah', 4), ('Micah', 7), ('Nahum', 3), ('Habakkuk', 3),
    ('Zephaniah', 3), ('Haggai', 2), ('Zechariah', 14), ('Malachi', 4), ('Matthew', 28),
    ('Mark', 16), ('Luke', 24), ('John', 21), ('Acts', 28), ('Romans', 16),
    ('I Corinthians', 16), ('II Corinthians', 13), ('Galatians', 6), ('Ephesians', 6),
    ('Philippians', 4), ('Colossians', 4), ('I Thessalonians', 5), ('II Thessalonians', 3),
    ('I Timothy', 6), ('II Timothy', 4), ('Titus', 3), ('Philemon', 1), ('Hebrews', 13),
    ('James', 5), ('I Peter', 5), ('II Peter', 3), ('I John', 5), ('II John', 1),
    ('III John', 1), ('Jude', 1), ('Revelation of John', 22),
]

# Map display names
DISPLAY_NAMES = {
    'I Samuel': '1 Samuel',
    'II Samuel': '2 Samuel',
    'I Kings': '1 Kings',
    'II Kings': '2 Kings',
    'I Chronicles': '1 Chronicles',
    'II Chronicles': '2 Chronicles',
    'I Corinthians': '1 Corinthians',
    'II Corinthians': '2 Corinthians',
    'I Thessalonians': '1 Thessalonians',
    'II Thessalonians': '2 Thessalonians',
    'I Timothy': '1 Timothy',
    'II Timothy': '2 Timothy',
    'I Peter': '1 Peter',
    'II Peter': '2 Peter',
    'I John': '1 John',
    'II John': '2 John',
    'III John': '3 John',
    'Revelation of John': 'Revelation',
}

def main():
    print("Extracting ASV from Sword module...", flush=True)
    
    library = SwordModules('/tmp/sword')
    library.parse_modules()
    bible = library.get_bible_from_module('ASV')
    
    asv_data = {
        "id": "asv",
        "name": "American Standard Version",
        "abbreviation": "ASV",
        "language": "English",
        "books": []
    }
    
    output_file = "/home/synth/projects/open-bible/assets/bible_data/asv_complete.json"
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    total_books = len(BOOKS)
    for i, (book_name, num_chapters) in enumerate(BOOKS, 1):
        display_name = DISPLAY_NAMES.get(book_name, book_name)
        print(f"[{i}/{total_books}] {display_name}...", flush=True, end=" ")
        
        book_id = display_name.lower().replace(' ', '')
        book_data = {
            "id": book_id,
            "name": display_name,
            "chapters": []
        }
        
        for ch in range(1, num_chapters + 1):
            try:
                verses = list(bible.get_iter(books=[book_name], chapters=[ch]))
                if verses:
                    chapter_data = {
                        "chapter": ch,
                        "verses": [{"verse": vnum + 1, "text": vtext.strip()} 
                                   for vnum, vtext in enumerate(verses) if vtext.strip()]
                    }
                    book_data["chapters"].append(chapter_data)
            except Exception as e:
                pass
        
        asv_data["books"].append(book_data)
        
        # Save after each book
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(asv_data, f, indent=1, ensure_ascii=False)
        
        verse_count = sum(len(c["verses"]) for c in book_data["chapters"])
        print(f"{len(book_data['chapters'])} ch, {verse_count} v", flush=True)
    
    # Final stats
    total_chapters = sum(len(b["chapters"]) for b in asv_data["books"])
    total_verses = sum(sum(len(c["verses"]) for c in b["chapters"]) for b in asv_data["books"])
    size_mb = os.path.getsize(output_file) / (1024 * 1024)
    
    print(f"\n✓ Complete! {len(asv_data['books'])} books, {total_chapters} chapters, {total_verses:,} verses")
    print(f"✓ File size: {size_mb:.2f} MB")

if __name__ == "__main__":
    main()
