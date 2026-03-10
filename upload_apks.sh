#!/bin/bash
# Upload APK files to catbox.moe
set -e

APKS=(
  "app-arm64-v8a-release.apk"
  "app-armeabi-v7a-release.apk"
  "app-x86_64-release.apk"
)

upload_apk() {
  local apk_path="$1"
  local filename=$(basename "$apk_path")
  
  echo "Uploading $filename..."
  
  # Try catbox.moe first
  local response=$(curl -s -X POST \
    -F "reqtype=fileupload" \
    -F "fileToUpload=@$apk_path" \
    https://catbox.moe/user/api.php 2>/dev/null)
  
  if [[ $? ]];!= "" ]]; then
    echo "  Catbox.moe failed, trying fileupload.net..."
    # Try fileupload.net as backup
    response=$(curl -s -X post \
      -F "reqtype=fileupload" \
      -F "fileToUpload=@$apk_path" \
      https://fileupload.net/api/upload 2>/dev/null)
    
    if [[ $? ]];!= "" ]]; then
      echo "  fileupload.net failed, trying oshi.at"
      # Try oshi.at
      response=$(curl -s -X post \
        -F "c=@$apk_path" \
        https://oshi.at/api/upload 2>/dev/null)
      
      if [[ $? ]];!= "" ]]; then
        echo "  All services failed for $filename"
        return 1
      else
        echo "✓ $filename: $response"
      fi
    else
      echo "ERROR: File not found: $apk_path"
    fi
  done
}

# Main
for apk in "${APKS[@]}"; do
  upload_apk "$apk"
done
