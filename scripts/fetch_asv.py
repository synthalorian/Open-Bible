#!/usr/bin/env python3
"""
Fetch complete ASV (American Standard Version) from rest.api.bible.
Public domain translation from 1901.
"""

import json
import urllib.request
import ssl
import time
import os

ssl._create_default_https_context = ssl._create_unverified_context

API_KEY = "vJSmrm7p-nnHwXE71LTgk"
BASE_URL = "https://rest.api.bible/v1"
ASV_BIBLE_ID = "06125adad2d5898a-01"  # ASV from API list
OUTPUT_FILE = "/home/synth/projects/open-bible/assets/bible_data/asv_complete.json"

def api_request(endpoint):
    url = f"{BASE_URL}{endpoint}"
    req = urllib.request.Request(url, headers={"api-key": API_KEY, "Accept": "application/json"})
    try:
        with urllib.request.urlopen(req, timeout=30) as response:
            data = json.loads(response.read().decode('utf-8'))
            return data.get("data", [])
    except Exception as e:
        return None

def get_books():
    return api_request(f"/bibles/{ASV_BIBLE_ID}/books")

def get_chapters(book_id):
    return api_request(f"/bibles/{ASV_BIBLE_ID}/books/{book_id}/chapters")

def get_chapter_content(chapter_id):
    return api_request(f"/bibles/{ASV_BIBLE_ID}/chapters/{chapter_id}?content-type=text")

def parse_verses(content):
    verses = []
    if not content:
        return verses
    import re
    matches = re.findall(r'\[(\d+)\]\s*([^\[]+)', content)
    for num, text in matches:
        text = text.strip()
        if text:
            verses.append({"verse": int(num), "text": text})
    return verses

def save_bible(bible):
    os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        json.dump(bible, f, indent=1, ensure_ascii=False)

def main():
    print("Fetching Complete ASV Bible...", flush=True)
    
    bible = {
        "id": "asv",
        "name": "American Standard Version",
        "abbreviation": "ASV",
        "language": "English",
        "books": []
    }
    
    save_bible(bible)
    
    books = get_books()
    if not books:
        print("Failed to fetch books!")
        return
    
    print(f"Found {len(books)} books", flush=True)
    
    for i, book in enumerate(books, 1):
        book_id = book.get("id")
        book_name = book.get("name")
        
        print(f"[{i}/{len(books)}] {book_name}...", flush=True, end=" ")
        
        book_data = {"id": book_id, "name": book_name, "chapters": []}
        chapters = get_chapters(book_id)
        
        for chapter in chapters:
            chapter_id = chapter.get("id")
            ch_num = chapter_id.split(".")[-1] if "." in chapter_id else "0"
            
            try:
                ch_num = int(ch_num)
            except:
                continue
            if ch_num == 0:
                continue
            
            content_data = get_chapter_content(chapter_id)
            if content_data:
                content = content_data.get("content", "")
                verses = parse_verses(content)
                if verses:
                    book_data["chapters"].append({"chapter": ch_num, "verses": verses})
            
            time.sleep(0.05)
        
        bible["books"].append(book_data)
        save_bible(bible)
        
        verse_count = sum(len(c["verses"]) for c in book_data["chapters"])
        print(f"{len(book_data['chapters'])} chapters, {verse_count} verses", flush=True)
    
    total_chapters = sum(len(b["chapters"]) for b in bible["books"])
    total_verses = sum(sum(len(c["verses"]) for c in b["chapters"]) for b in bible["books"])
    size_mb = os.path.getsize(OUTPUT_FILE) / (1024 * 1024)
    
    print(f"\n✓ Complete! {len(bible['books'])} books, {total_chapters} chapters, {total_verses:,} verses")
    print(f"✓ File size: {size_mb:.2f} MB")

if __name__ == "__main__":
    main()
