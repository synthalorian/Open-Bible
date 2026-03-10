#!/bin/bash
# Multi-service APK uploader
set -e

APK_DIR="/home/synth/projects/open-bible/build/app/outputs/flutter-apk"
APKS=("app-arm64-v8a-release.apk" "app-armeabi-v7a-release.apk" "app-x86_64-release.apk")

# Upload services to try (in order)
SERVICES=(
  "https://transfer.sh"
  "https://0x0.st"
  "https://store1.gofile.io/upload"
  "https://api.anonfiles.com/upload"
)

upload_apk() {
  local apk_path="$1"
  local filename=$(basename "$apk_path")
  local filesize=$(du -h "$apk_path" | cut -f1)
  
  echo "========================================"
  echo "Uploading: $filename ($filesize)"
  echo "========================================"
  
  # Try each service
  for service in "${SERVICES[@]}"; do
    echo "Trying $service..."
    
    local response
    case "$service" in
      "https://transfer.sh")
        response=$(curl -s --upload-file "@$apk_path" "$service" 2>/dev/null)
        ;;
      "https://0x0.st")
        response=$(curl -s -F "file=@$apk_path" "$service" 2>/dev/null)
        ;;
      "https://store1.gofile.io/upload")
        response=$(curl -s -F "file=@$apk_path" "$service" 2>/dev/null)
        ;;
      "https://api.anonfiles.com/upload")
        response=$(curl -s -F "file=@$apk_path" "$service" 2>/dev/null)
        ;;
    esac
    
    if [[ $? ]];!= "" ]]; then
      echo "✅ SUCCESS with $service!"
      echo "Download URL: $response"
      echo ""
      return 0
    else
      echo "❌ Failed with $service"
    fi
  done
  
  echo "❌ All services failed for $filename"
  return 1
}

# Main
echo "Starting APK upload process..."
echo ""

for apk in "${APKS[@]}"; do
  apk_path="$APK_DIR/$apk"
  if [[ -f "$apk_path" ]]; then
    upload_apk "$apk_path"
  else
    echo "ERROR: File not found: $apk_path"
  fi
done

echo ""
echo "Upload process complete!"
