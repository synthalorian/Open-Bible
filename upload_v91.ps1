# APK Upload Script - tries multiple services (Windows PowerShell)
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ApkDir = Join-Path $ScriptDir 'build\app\outputs\flutter-apk'
$Apk = 'app-arm64-v8a-release.apk'
$ApkPath = Join-Path $ApkDir $Apk

Write-Host "Uploading $Apk..."

$services = @(
    @{ Name = 'transfer.sh';  Cmd = { curl.exe -s --upload-file "$ApkPath" "https://transfer.sh/$Apk" 2>$null } }
    @{ Name = '0x0.st';       Cmd = { curl.exe -s -F "file=@$ApkPath" "https://0x0.st" 2>$null } }
    @{ Name = 'file.io';      Cmd = { curl.exe -s -F "file=@$ApkPath" "https://file.io" 2>$null } }
    @{ Name = 'oshi.at';      Cmd = { curl.exe -s -F "c=@$ApkPath" "https://oshi.at/api/upload" 2>$null } }
)

foreach ($svc in $services) {
    Write-Host "Trying $($svc.Name)..."
    $resp = & $svc.Cmd
    if ($resp) {
        Write-Host "$($svc.Name): $resp" -ForegroundColor Green
        exit 0
    }
}

Write-Host "All services failed" -ForegroundColor Red
exit 1
