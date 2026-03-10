#!/usr/bin/env python3
"""
Fetch complete KJV Bible from API.Bible using urllib.
"""

import json
import urllib.request
import urllib.error
import time
import os
import ssl

# Disable SSL verification for simplicity
ssl._create_default_https_context = ssl._create_unverified_context

API_KEY = "6f2JvHkjAMKbbvEhW28uE"
BASE_URL = "https://api.scripture.api.bible/v1"

# Bible ID for KJV
KJV_BIBLE_ID = "de4e12af7f28f599-02"

def make_request(url):
    """Make API request."""
    req = urllib.request.Request(
        url,
        headers={
            "api-key": API_KEY,
            "Accept": "application/json"
        }
    )
    
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            return json.loads(response.read().decode('utf-8'))
    except Exception as e:
        print(f"Request error: {e}")
        return None

def get_books():
    """Get all books from KJV Bible."""
    url = f"{BASE_URL}/bibles/{KJV_BIBLE_ID}/books"
    data = make_request(url)
    return data.get("data", []) if data else []

def get_chapters(book_id):
    """Get all chapters for a book."""
    url = f"{BASE_URL}/bibles/{KJV_BIBLE_ID}/books/{book_id}/chapters"
    data = make_request(url)
    return data.get("data", []) if data else []

def get_chapter_content(chapter_id):
    """Get content for a specific chapter."""
    url = f"{BASE_URL}/bibles/{KJV_BIBLE_ID}/chapters/{chapter_id}?content-type=text"
    data = make_request(url)
    return data.get("data") if data else None

def parse_verses(content):
    """Parse verse content from text."""
    verses = []
    
    # Try to find verse markers like [1], [2], etc.
    import re
    
    # Pattern: [number] text
    matches = re.findall(r'\[(\d+)\]\s*([^\[]+)', content)
    
    if matches:
        for verse_num, verse_text in matches:
            text = verse_text.strip()
            if text:
                verses.append({
                    "verse": int(verse_num),
                    "text": text
                })
    
    return verses

def fetch_complete_bible():
    """Fetch complete KJV Bible."""
    bible_data = {
        "id": "kjv",
        "name": "King James Version",
        "abbreviation": "KJV",
        "language": "English",
        "books": []
    }
    
    print("Fetching books...")
    books = get_books()
    print(f"Found {len(books)} books")
    
    for i, book in enumerate(books):
        book_id = book.get("id")
        book_name = book.get("name")
        
        print(f"\n[{i+1}/{len(books)}] {book_name} ({book_id})")
        
        book_data = {
            "id": book_id,
            "name": book_name,
            "chapters": []
        }
        
        chapters = get_chapters(book_id)
        print(f"  Found {len(chapters)} chapters")
        
        for chapter in chapters:
            chapter_id = chapter.get("id")
            chapter_num_str = chapter_id.split(".")[-1] if "." in chapter_id else "0"
            
            try:
                chapter_num = int(chapter_num_str)
            except:
                continue
            
            # Skip intro chapters
            if chapter_num == 0:
                continue
            
            content_data = get_chapter_content(chapter_id)
            
            if content_data:
                content_text = content_data.get("content", "")
                verses = parse_verses(content_text)
                
                if verses:
                    book_data["chapters"].append({
                        "chapter": chapter_num,
                        "verses": verses
                    })
                    print(f"    Ch {chapter_num}: {len(verses)} verses")
                else:
                    # Store raw content if no verses parsed
                    book_data["chapters"].append({
                        "chapter": chapter_num,
                        "verses": [{"verse": 1, "text": content_text[:500]}]
                    })
                    print(f"    Ch {chapter_num}: raw content")
            
            time.sleep(0.3)  # Rate limiting
        
        bible_data["books"].append(book_data)
    
    return bible_data

def main():
    print("Fetching Complete KJV Bible from API.Bible")
    print("=" * 50)
    
    bible_data = fetch_complete_bible()
    
    # Save
    output_file = "/home/synth/projects/open-bible/assets/bible_data/kjv_complete.json"
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        json.dump(bible_data, f, indent=2, ensure_ascii=False)
    
    # Stats
    total_books = len(bible_data["books"])
    total_chapters = sum(len(b["chapters"]) for b in bible_data["books"])
    total_verses = sum(
        sum(len(c["verses"]) for c in b["chapters"])
        for b in bible_data["books"]
    )
    
    file_size = os.path.getsize(output_file) / (1024 * 1024)
    
    print("\n" + "=" * 50)
    print("Complete!")
    print(f"Books: {total_books}")
    print(f"Chapters: {total_chapters}")
    print(f"Verses: {total_verses}")
    print(f"File: {file_size:.2f} MB")

if __name__ == "__main__":
    main()
