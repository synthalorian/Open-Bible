#!/usr/bin/env python3
import os
import sys

from pathlib import Path
_REPO_ROOT = Path(__file__).resolve().parent
apk_dir = str(_REPO_ROOT / "build" / "app" / "outputs" / "flutter-apk")

# List APK files
apks = []
for f in os.listdir(apk_dir):
    if f.endswith('.apk'):
        apks.append(f)
        
print(f"Found {len(apks)} APK files")
for apk in apks:
    print(f"  {apk}")
