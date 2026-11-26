#!/bin/bash
# Upload APK files to catbox.moe
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APK_DIR="$SCRIPT_DIR/build/app/outputs/flutter-apk"
APKS=(
  "app-arm64-v8a-release.apk"
  "app-armeabi-v7a-release.apk"
  "app-x86_64-release.apk"
)

upload_apk() {
  local apk_path="$1"
  local filename
  filename="$(basename "$apk_path")"

  if [[ ! -f "$apk_path" ]]; then
    echo "ERROR: File not found: $apk_path" >&2
    return 1
  fi

  echo "Uploading $filename..."

  local response
  response="$(curl -s -X POST \
    -F "reqtype=fileupload" \
    -F "fileToUpload=@$apk_path" \
    https://catbox.moe/user/api.php 2>/dev/null || true)"
  if [[ -n "$response" ]]; then
    echo "$filename: $response"
    return 0
  fi

  echo "  Catbox.moe failed, trying fileupload.net..."
  response="$(curl -s -X POST \
    -F "reqtype=fileupload" \
    -F "fileToUpload=@$apk_path" \
    https://fileupload.net/api/upload 2>/dev/null || true)"
  if [[ -n "$response" ]]; then
    echo "$filename: $response"
    return 0
  fi

  echo "  fileupload.net failed, trying oshi.at"
  response="$(curl -s -X POST \
    -F "c=@$apk_path" \
    https://oshi.at/api/upload 2>/dev/null || true)"
  if [[ -n "$response" ]]; then
    echo "$filename: $response"
    return 0
  fi

  echo "  All services failed for $filename" >&2
  return 1
}

for apk in "${APKS[@]}"; do
  upload_apk "$APK_DIR/$apk"
done
