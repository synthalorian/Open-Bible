#!/bin/bash
# APK Upload Script - tries multiple services
set -e

APK_DIR="/home/synth/projects/open-bible/build/app/outputs/flutter-apk"
APK="app-arm64-v8a-release.apk"

echo "Uploading $APK..."

# Try transfer.sh first
echo "Trying transfer.sh..."
URL=$(curl -s --upload-file "$APK_DIR/$APK" "https://transfer.sh/$APK" 2>/dev/null || true)
if [[ -n "$URL" ]]; then
  echo "✅ transfer.sh: $URL"
  exit 0
fi

# Try 0x0.st
echo "Trying 0x0.st..."
URL=$(curl -s -F "file=@$APK_DIR/$APK" "https://0x0.st" 2>/dev/null || true)
if [[ -n "$URL" ]]; then
  echo "✅ 0x0.st: $URL"
  exit 0
fi

# Try file.io
echo "Trying file.io..."
RESP=$(curl -s -F "file=@$APK_DIR/$APK" "https://file.io" 2>/dev/null || true)
if [[ -n "$RESP" ]]; then
  echo "✅ file.io response: $RESP"
  exit 0
fi

# Try oshi.at
echo "Trying oshi.at..."
URL=$(curl -s -F "c=@$APK_DIR/$APK" "https://oshi.at/api/upload" 2>/dev/null || true)
if [[ -n "$URL" ]]; then
  echo "✅ oshi.at: $URL"
  exit 0
fi

# Try anonfiles
echo "Trying anonfiles.com..."
RESP=$(curl -s -F "file=@$APK_DIR/$APK" "https://api.anonfiles.com/upload" 2>/dev/null || true)
if [[ -n "$RESP" ]]; then
  echo "✅ anonfiles response: $RESP"
  exit 0
fi

echo "❌ All services failed"
exit 1
