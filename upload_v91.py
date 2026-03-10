#!/usr/bin/env python3
import requests
import os

apk_path = "/home/synth/projects/open-bible/build/app/outputs/flutter-apk/app-arm64-v8a-release.apk"
filename = os.path.basename(apk_path)

print(f"Uploading {filename}...")
print(f"File size: {os.path.getsize(apk_path) / (1024*1024):.1f} MB")

# Try 1: transfer.sh
print("\n1. Trying transfer.sh...")
try:
    with open(apk_path, 'rb') as f:
        response = requests.put(
            f'https://transfer.sh/{filename}',
            data=f,
            timeout=60
        )
        if response.status_code == 200:
            url = response.text.strip()
            print(f"✅ SUCCESS: {url}")
            with open('/tmp/apk_url.txt', 'w') as out:
                out.write(url)
            exit(0)
        else:
            print(f"❌ Failed: {response.status_code}")
except Exception as e:
    print(f"❌ Error: {e}")

# Try 2: 0x0.st
print("\n2. Trying 0x0.st...")
try:
    with open(apk_path, 'rb') as f:
        response = requests.post(
            'https://0x0.st',
            files={'file': (filename, f)},
            timeout=60
        )
        if response.status_code == 200:
            url = response.text.strip()
            print(f"✅ SUCCESS: {url}")
            with open('/tmp/apk_url.txt', 'w') as out:
                out.write(url)
            exit(0)
        else:
            print(f"❌ Failed: {response.status_code}")
except Exception as e:
    print(f"❌ Error: {e}")

# Try 3: file.io
print("\n3. Trying file.io...")
try:
    with open(apk_path, 'rb') as f:
        response = requests.post(
            'https://file.io',
            files={'file': (filename, f)},
            timeout=60
        )
        if response.status_code == 200:
            data = response.json()
            if 'link' in data:
                url = data['link']
                print(f"✅ SUCCESS: {url}")
                with open('/tmp/apk_url.txt', 'w') as out:
                    out.write(url)
                exit(0)
            else:
                print(f"❌ Response: {data}")
        else:
            print(f"❌ Failed: {response.status_code}")
except Exception as e:
    print(f"❌ Error: {e}")

# Try 4: oshi.at
print("\n4. Trying oshi.at...")
try:
    with open(apk_path, 'rb') as f:
        response = requests.post(
            'https://oshi.at/api/upload',
            files={'c': (filename, f)},
            timeout=60
        )
        if response.status_code == 200:
            data = response.json()
            if 'url' in data:
                url = data['url']
                print(f"✅ SUCCESS: {url}")
                with open('/tmp/apk_url.txt', 'w') as out:
                    out.write(url)
                exit(0)
            else:
                print(f"❌ Response: {data}")
        else:
            print(f"❌ Failed: {response.status_code}")
except Exception as e:
    print(f"❌ Error: {e}")

print("\n❌ All services failed")
exit(1)
