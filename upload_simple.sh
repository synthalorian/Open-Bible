#!/bin/bash
# Simple APK uploader with multiple services
set -e

APK_DIR="/home/synth/projects/open-bible/build/app/outputs/flutter-apk"

# Upload single APK trying multiple services
upload_apk() {
  local apk_path="$1"
  local filename=$(basename "$apk_path")
  
  echo "Uploading $filename..."
  
  # Try transfer.sh
  local url=$(curl -s --upload-file "$apk_path" "https://transfer.sh" 2>/dev/null)
  if [[ -n "$url" ]]; then
    echo "✅ transfer.sh: $url"
    return 0
  fi
  
  # Try 0x0.st
  url=$(curl -s -F "file=@$apk_path" "https://0x0.st" 2>/dev/null)
  if [[ -n "$url" ]]; then
    echo "✅ 0x0.st: $url"
    return 0
  fi
  
  # Try gofile.io
  local json=$(curl -s -F "file=@$apk_path" "https://store1.gofile.io/upload" 2>/dev/null)
  if [[ -n "$json" ]]; then
    echo "✅ gofile.io response: $json"
    return 0
  fi
  
  echo "❌ All services failed"
  return 1
}

# Upload all APKs
for apk in app-arm64-v8a-release.apk app-armeabi-v7a-release.apk app-x86_64-release.apk; do
  if [[ -f "$APK_DIR/$apk" ]]; then
    upload_apk "$APK_DIR/$apk"
    echo "---"
  fi
done
