# Simple APK uploader with multiple services (Windows PowerShell)
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ApkDir = Join-Path $ScriptDir 'build\app\outputs\flutter-apk'

function Upload-Apk([string]$ApkPath) {
    $filename = Split-Path $ApkPath -Leaf
    Write-Host "Uploading $filename..."

    # Try transfer.sh
    $url = curl.exe -s --upload-file "$ApkPath" "https://transfer.sh" 2>$null
    if ($url) { Write-Host "transfer.sh: $url" -ForegroundColor Green; return }

    # Try 0x0.st
    $url = curl.exe -s -F "file=@$ApkPath" "https://0x0.st" 2>$null
    if ($url) { Write-Host "0x0.st: $url" -ForegroundColor Green; return }

    # Try gofile.io
    $json = curl.exe -s -F "file=@$ApkPath" "https://store1.gofile.io/upload" 2>$null
    if ($json) { Write-Host "gofile.io: $json" -ForegroundColor Green; return }

    Write-Host "All services failed" -ForegroundColor Red
}

foreach ($apk in @('app-arm64-v8a-release.apk', 'app-armeabi-v7a-release.apk', 'app-x86_64-release.apk')) {
    $path = Join-Path $ApkDir $apk
    if (Test-Path $path) {
        Upload-Apk $path
        Write-Host "---"
    }
}
