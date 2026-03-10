#!/usr/bin/env python3
"""
Fetch complete KJV Bible from API.Bible using verified API key.
"""

import json
import urllib.request
import urllib.error
import time
import os
import ssl

ssl._create_default_https_context = ssl._create_unverified_context

API_KEY = "6f2JvHkjAMKbbvEhW28uE"
BASE_URL = "https://api.scripture.api.bible/v1"
KJV_BIBLE_ID = "de4e12af7f28f599-02"

def api_request(endpoint):
    """Make API request."""
    url = f"{BASE_URL}{endpoint}"
    req = urllib.request.Request(
        url,
        headers={
            "api-key": API_KEY,
            "Accept": "application/json"
        }
    )
    
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            data = json.loads(response.read().decode('utf-8'))
            return data.get("data", [])
    except Exception as e:
        print(f"  Error: {e}")
        return None

def get_books():
    return api_request(f"/bibles/{KJV_BIBLE_ID}/books")

def get_chapters(book_id):
    return api_request(f"/bibles/{KJV_BIBLE_ID}/books/{book_id}/chapters")

def get_chapter_content(chapter_id):
    result = api_request(f"/bibles/{KJV_BIBLE_ID}/chapters/{chapter_id}?content-type=text")
    return result

def parse_verses(content):
    """Parse verses from chapter content."""
    verses = []
    if not content:
        return verses
    
    import re
    # Look for [number] verse text pattern
    matches = re.findall(r'\[(\d+)\]\s*([^\[]+)', content)
    
    for num, text in matches:
        text = text.strip()
        if text:
            verses.append({"verse": int(num), "text": text})
    
    return verses

def fetch_bible():
    bible = {
        "id": "kjv",
        "name": "King James Version",
        "abbreviation": "KJV",
        "language": "English",
        "books": []
    }
    
    print("Fetching KJV Bible from API.Bible...")
    print("=" * 60)
    
    books = get_books()
    if not books:
        print("Failed to fetch books!")
        return None
    
    print(f"Found {len(books)} books\n")
    
    for i, book in enumerate(books, 1):
        book_id = book.get("id")
        book_name = book.get("name")
        
        print(f"[{i:2d}/{len(books)}] {book_name}", end=" ", flush=True)
        
        book_data = {
            "id": book_id,
            "name": book_name,
            "chapters": []
        }
        
        chapters = get_chapters(book_id)
        verse_count = 0
        
        for chapter in chapters:
            chapter_id = chapter.get("id")
            ch_num = chapter_id.split(".")[-1] if "." in chapter_id else "0"
            
            try:
                ch_num = int(ch_num)
            except:
                continue
            
            if ch_num == 0:  # Skip intros
                continue
            
            content_data = get_chapter_content(chapter_id)
            
            if content_data:
                content = content_data.get("content", "")
                verses = parse_verses(content)
                
                if verses:
                    book_data["chapters"].append({
                        "chapter": ch_num,
                        "verses": verses
                    })
                    verse_count += len(verses)
            
            time.sleep(0.1)  # Rate limiting
        
        print(f"- {len(book_data['chapters'])} chapters, {verse_count} verses")
        bible["books"].append(book_data)
    
    return bible

def main():
    bible = fetch_bible()
    
    if not bible:
        print("Failed to fetch Bible!")
        return
    
    # Save
    output = "/home/synth/projects/open-bible/assets/bible_data/kjv_complete.json"
    os.makedirs(os.path.dirname(output), exist_ok=True)
    
    with open(output, 'w', encoding='utf-8') as f:
        json.dump(bible, f, indent=1, ensure_ascii=False)
    
    # Stats
    total_books = len(bible["books"])
    total_chapters = sum(len(b["chapters"]) for b in bible["books"])
    total_verses = sum(
        sum(len(c["verses"]) for c in b["chapters"])
        for b in bible["books"]
    )
    
    size_mb = os.path.getsize(output) / (1024 * 1024)
    
    print("\n" + "=" * 60)
    print("COMPLETE KJV BIBLE DOWNLOADED!")
    print(f"Books: {total_books}")
    print(f"Chapters: {total_chapters}")
    print(f"Verses: {total_verses:,}")
    print(f"File size: {size_mb:.2f} MB")
    print(f"Saved: {output}")

if __name__ == "__main__":
    main()
