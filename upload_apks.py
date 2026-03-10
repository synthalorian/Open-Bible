#!/usr/bin/env python3
import os
import sys

apk_dir = "/home/synth/projects/open-bible/build/app/outputs/flutter-apk"

# List APK files
apks = []
for f in os.listdir(apk_dir):
    if f.endswith('.apk'):
        apks.append(f)
        
print(f"Found {len(apks)} APK files")
for apk in apks:
    print(f"  {apk}")
