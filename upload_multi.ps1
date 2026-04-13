# Multi-service APK uploader (Windows PowerShell)
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ApkDir = Join-Path $ScriptDir 'build\app\outputs\flutter-apk'
$Apks = @('app-arm64-v8a-release.apk', 'app-armeabi-v7a-release.apk', 'app-x86_64-release.apk')

$Services = @(
    'https://transfer.sh'
    'https://0x0.st'
    'https://store1.gofile.io/upload'
)

function Upload-Apk([string]$ApkPath) {
    $filename = Split-Path $ApkPath -Leaf
    $filesize = '{0:N2} MB' -f ((Get-Item $ApkPath).Length / 1MB)

    Write-Host "========================================"
    Write-Host "Uploading: $filename ($filesize)"
    Write-Host "========================================"

    foreach ($service in $Services) {
        Write-Host "Trying $service..."
        try {
            $response = switch ($service) {
                'https://transfer.sh'              { curl.exe -s --upload-file "$ApkPath" "$service" 2>$null }
                'https://0x0.st'                   { curl.exe -s -F "file=@$ApkPath" "$service" 2>$null }
                'https://store1.gofile.io/upload'   { curl.exe -s -F "file=@$ApkPath" "$service" 2>$null }
            }
            if ($response) {
                Write-Host "SUCCESS with $service!" -ForegroundColor Green
                Write-Host "Download URL: $response"
                return
            }
        } catch {}
        Write-Host "Failed with $service" -ForegroundColor Red
    }

    Write-Host "All services failed for $filename" -ForegroundColor Red
}

Write-Host "Starting APK upload process...`n"

foreach ($apk in $Apks) {
    $path = Join-Path $ApkDir $apk
    if (Test-Path $path) {
        Upload-Apk $path
    } else {
        Write-Host "NOT FOUND: $path" -ForegroundColor Yellow
    }
}

Write-Host "`nUpload process complete!"
