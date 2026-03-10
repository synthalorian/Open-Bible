#!/usr/bin/env python3
"""
Fetch essential KJV Bible books for offline use.
Prioritizes: Gospels, Psalms, Genesis, Proverbs, Romans
"""

import json
import urllib.request
import ssl
import time
import os

ssl._create_default_https_context = ssl._create_unverified_context

ESSENTIAL_BOOKS = [
    ("Genesis", 50, "GEN"),
    ("Psalms", 150, "PSA"),
    ("Proverbs", 31, "PRO"),
    ("Matthew", 28, "MAT"),
    ("Mark", 16, "MRK"),
    ("Luke", 24, "LUK"),
    ("John", 21, "JHN"),
    ("Acts", 28, "ACT"),
    ("Romans", 16, "ROM"),
    ("1 Corinthians", 16, "1CO"),
    ("Revelation", 22, "REV"),
]

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
        return None

def main():
    bible = {
        "id": "kjv",
        "name": "King James Version",
        "abbreviation": "KJV",
        "language": "English",
        "books": []
    }
    
    print("Fetching Essential KJV Books...")
    print("=" * 60)
    
    for book_name, num_chapters, book_id in ESSENTIAL_BOOKS:
        print(f"\n{book_name} ({num_chapters} chapters)")
        
        book_data = {
            "id": book_id,
            "name": book_name,
            "chapters": []
        }
        
        for ch_num in range(1, num_chapters + 1):
            print(f"  Ch {ch_num}...", end=" ", flush=True)
            
            data = fetch_chapter(book_name, ch_num)
            
            if data and 'verses' in data:
                verses = [{"verse": v['verse'], "text": v['text'].strip()} 
                         for v in data['verses']]
                
                book_data["chapters"].append({
                    "chapter": ch_num,
                    "verses": verses
                })
                print(f"✓ ({len(verses)} verses)")
            else:
                print("✗")
            
            time.sleep(0.15)
        
        bible["books"].append(book_data)
    
    # Save
    output = "/home/synth/projects/open-bible/assets/bible_data/kjv_essential.json"
    os.makedirs(os.path.dirname(output), exist_ok=True)
    
    with open(output, 'w', encoding='utf-8') as f:
        json.dump(bible, f, indent=1, ensure_ascii=False)
    
    # Stats
    total_chapters = sum(len(b["chapters"]) for b in bible["books"])
    total_verses = sum(sum(len(c["verses"]) for c in b["chapters"]) for b in bible["books"])
    size_mb = os.path.getsize(output) / (1024 * 1024)
    
    print("\n" + "=" * 60)
    print("ESSENTIAL BIBLE DOWNLOADED!")
    print(f"Books: {len(bible['books'])}")
    print(f"Chapters: {total_chapters}")
    print(f"Verses: {total_verses:,}")
    print(f"File size: {size_mb:.2f} MB")

if __name__ == "__main__":
    main()
