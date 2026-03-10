#!/usr/bin/env python3
import requests
import os

apk_path = "/home/synth/projects/open-bible/build/app/outputs/flutter-apk/app-release.apk"
filename = "open-bible-v81-production.apk"

print(f"Uploading {filename} to catbox.moe...")
print(f"File size: {os.path.getsize(apk_path) / (1024*1024):.1f} MB")

try:
    with open(apk_path, 'rb') as f:
        files = {'fileToUpload': (filename, f, 'application/vnd.android.package-archive')}
        data = {'reqtype': 'fileupload'}
        
        response = requests.post(
            'https://catbox.moe/user/api.php',
            files=files,
            data=data,
            timeout=120
        )
        
        if response.status_code == 200:
            url = response.text.strip()
            if url.startswith('http'):
                print(f"✅ SUCCESS: {url}")
                with open('/tmp/apk_url.txt', 'w') as out:
                    out.write(url)
                exit(0)
            else:
                print(f"❌ Unexpected response: {url}")
        else:
            print(f"❌ Failed: HTTP {response.status_code}")
            print(f"Response: {response.text}")
except Exception as e:
    print(f"❌ Error: {e}")
    import traceback
    traceback.print_exc()

exit(1)
