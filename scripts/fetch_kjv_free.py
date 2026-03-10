#!/usr/bin/env python3
"""
Fetch KJV Bible from bible-api.com (free public API)
"""

import json
import urllib.request
import ssl
import time
import os

ssl._create_default_https_context = ssl._create_unverified_context

# Bible books with chapter counts
BOOKS = [
    ("Genesis", 50), ("Exodus", 40), ("Leviticus", 27), ("Numbers", 36), ("Deuteronomy", 34),
    ("Joshua", 24), ("Judges", 21), ("Ruth", 4), ("1 Samuel", 31), ("2 Samuel", 24),
    ("1 Kings", 22), ("2 Kings", 25), ("1 Chronicles", 29), ("2 Chronicles", 36), ("Ezra", 10),
    ("Nehemiah", 13), ("Esther", 10), ("Job", 42), ("Psalms", 150), ("Proverbs", 31),
    ("Ecclesiastes", 12), ("Song of Solomon", 8), ("Isaiah", 66), ("Jeremiah", 52),
    ("Lamentations", 5), ("Ezekiel", 48), ("Daniel", 12), ("Hosea", 14), ("Joel", 3),
    ("Amos", 9), ("Obadiah", 1), ("Jonah", 4), ("Micah", 7), ("Nahum", 3),
    ("Habakkuk", 3), ("Zephaniah", 3), ("Haggai", 2), ("Zechariah", 14), ("Malachi", 4),
    ("Matthew", 28), ("Mark", 16), ("Luke", 24), ("John", 21), ("Acts", 28),
    ("Romans", 16), ("1 Corinthians", 16), ("2 Corinthians", 13), ("Galatians", 6),
    ("Ephesians", 6), ("Philippians", 4), ("Colossians", 4), ("1 Thessalonians", 5),
    ("2 Thessalonians", 3), ("1 Timothy", 6), ("2 Timothy", 4), ("Titus", 3),
    ("Philemon", 1), ("Hebrews", 13), ("James", 5), ("1 Peter", 5), ("2 Peter", 3),
    ("1 John", 5), ("2 John", 1), ("3 John", 1), ("Jude", 1), ("Revelation", 22)
]

# Book ID mapping
BOOK_IDS = {
    "Genesis": "GEN", "Exodus": "EXO", "Leviticus": "LEV", "Numbers": "NUM", "Deuteronomy": "DEU",
    "Joshua": "JOS", "Judges": "JDG", "Ruth": "RUT", "1 Samuel": "1SA", "2 Samuel": "2SA",
    "1 Kings": "1KI", "2 Kings": "2KI", "1 Chronicles": "1CH", "2 Chronicles": "2CH", "Ezra": "EZR",
    "Nehemiah": "NEH", "Esther": "EST", "Job": "JOB", "Psalms": "PSA", "Proverbs": "PRO",
    "Ecclesiastes": "ECC", "Song of Solomon": "SNG", "Isaiah": "ISA", "Jeremiah": "JER",
    "Lamentations": "LAM", "Ezekiel": "EZK", "Daniel": "DAN", "Hosea": "HOS", "Joel": "JOL",
    "Amos": "AMO", "Obadiah": "OBA", "Jonah": "JON", "Micah": "MIC", "Nahum": "NAM",
    "Habakkuk": "HAB", "Zephaniah": "ZEP", "Haggai": "HAG", "Zechariah": "ZEC", "Malachi": "MAL",
    "Matthew": "MAT", "Mark": "MRK", "Luke": "LUK", "John": "JHN", "Acts": "ACT",
    "Romans": "ROM", "1 Corinthians": "1CO", "2 Corinthians": "2CO", "Galatians": "GAL",
    "Ephesians": "EPH", "Philippians": "PHP", "Colossians": "COL", "1 Thessalonians": "1TH",
    "2 Thessalonians": "2TH", "1 Timothy": "1TI", "2 Timothy": "2TI", "Titus": "TIT",
    "Philemon": "PHM", "Hebrews": "HEB", "James": "JAS", "1 Peter": "1PE", "2 Peter": "2PE",
    "1 John": "1JN", "2 John": "2JN", "3 John": "3JN", "Jude": "JUD", "Revelation": "REV"
}

def fetch_chapter(book, chapter):
    """Fetch a single chapter from bible-api.com"""
    book_encoded = book.replace(" ", "%20")
    url = f"https://bible-api.com/{book_encoded}%20{chapter}?translation=kjv"
    
    try:
        req = urllib.request.Request(url, headers={"Accept": "application/json"})
        with urllib.request.urlopen(req, timeout=30) as response:
            data = json.loads(response.read().decode('utf-8'))
            return data
    except Exception as e:
        print(f"      Error: {e}")
        return None

def main():
    bible = {
        "id": "kjv",
        "name": "King James Version",
        "abbreviation": "KJV",
        "language": "English",
        "books": []
    }
    
    print("Fetching KJV Bible from bible-api.com...")
    print("=" * 60)
    
    total_chapters = sum(chapters for _, chapters in BOOKS)
    current = 0
    
    for book_name, num_chapters in BOOKS:
        book_id = BOOK_IDS.get(book_name, book_name[:3].upper())
        
        print(f"\n[{list(BOOK_IDS.keys()).index(book_name)+1}/66] {book_name}")
        
        book_data = {
            "id": book_id,
            "name": book_name,
            "chapters": []
        }
        
        for ch_num in range(1, num_chapters + 1):
            current += 1
            print(f"  Ch {ch_num}/{num_chapters}...", end=" ", flush=True)
            
            data = fetch_chapter(book_name, ch_num)
            
            if data and 'verses' in data:
                verses = []
                for v in data['verses']:
                    verses.append({
                        "verse": v['verse'],
                        "text": v['text'].strip()
                    })
                
                book_data["chapters"].append({
                    "chapter": ch_num,
                    "verses": verses
                })
                print(f"✓ ({len(verses)} verses)")
            else:
                print("✗")
            
            time.sleep(0.2)  # Rate limiting
        
        bible["books"].append(book_data)
    
    # Save
    output = "/home/synth/projects/open-bible/assets/bible_data/kjv_complete.json"
    os.makedirs(os.path.dirname(output), exist_ok=True)
    
    with open(output, 'w', encoding='utf-8') as f:
        json.dump(bible, f, indent=1, ensure_ascii=False)
    
    # Stats
    total_books = len(bible["books"])
    total_chapters_saved = sum(len(b["chapters"]) for b in bible["books"])
    total_verses = sum(
        sum(len(c["verses"]) for c in b["chapters"])
        for b in bible["books"]
    )
    
    size_mb = os.path.getsize(output) / (1024 * 1024)
    
    print("\n" + "=" * 60)
    print("COMPLETE KJV BIBLE DOWNLOADED!")
    print(f"Books: {total_books}")
    print(f"Chapters: {total_chapters_saved}")
    print(f"Verses: {total_verses:,}")
    print(f"File size: {size_mb:.2f} MB")
    print(f"Saved: {output}")

if __name__ == "__main__":
    main()
