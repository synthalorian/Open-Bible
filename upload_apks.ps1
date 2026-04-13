# Upload APK files to catbox.moe (Windows PowerShell)
$ErrorActionPreference = 'Stop'

$Apks = @(
    'app-arm64-v8a-release.apk'
    'app-armeabi-v7a-release.apk'
    'app-x86_64-release.apk'
)

function Upload-Apk([string]$ApkPath) {
    $filename = Split-Path $ApkPath -Leaf
    Write-Host "Uploading $filename..."

    # Try catbox.moe
    try {
        $response = curl.exe -s -X POST -F "reqtype=fileupload" -F "fileToUpload=@$ApkPath" "https://catbox.moe/user/api.php" 2>$null
        if ($response) {
            Write-Host "  catbox.moe: $response" -ForegroundColor Green
            return
        }
    } catch {}

    # Try 0x0.st
    try {
        $response = curl.exe -s -F "file=@$ApkPath" "https://0x0.st" 2>$null
        if ($response) {
            Write-Host "  0x0.st: $response" -ForegroundColor Green
            return
        }
    } catch {}

    # Try oshi.at
    try {
        $response = curl.exe -s -F "c=@$ApkPath" "https://oshi.at/api/upload" 2>$null
        if ($response) {
            Write-Host "  oshi.at: $response" -ForegroundColor Green
            return
        }
    } catch {}

    Write-Host "  All services failed for $filename" -ForegroundColor Red
}

foreach ($apk in $Apks) {
    if (Test-Path $apk) {
        Upload-Apk $apk
    } else {
        Write-Host "NOT FOUND: $apk" -ForegroundColor Yellow
    }
}
