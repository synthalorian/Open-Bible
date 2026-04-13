# Generate Android signing keystore for Open Bible app (Windows PowerShell)
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir
$KeystoreDir = Join-Path $ProjectDir 'android\app'
$KeystoreFile = Join-Path $KeystoreDir 'openbible-key.jks'
$KeyProperties = Join-Path $ProjectDir 'android\key.properties'

Write-Host "Generating Android signing keystore for Open Bible..."
Write-Host "======================================================"

New-Item -ItemType Directory -Path $KeystoreDir -Force | Out-Null

keytool -genkey -v `
    -keystore $KeystoreFile `
    -alias openbible `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -storepass openbible123 `
    -keypass openbible123 `
    -dname "CN=synth, O=Open Bible, C=US"

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nKeystore generated successfully!" -ForegroundColor Green
    Write-Host "  Location: $KeystoreFile"

    @"
storePassword=openbible123
keyPassword=openbible123
keyAlias=openbible
storeFile=app/openbible-key.jks
"@ | Set-Content $KeyProperties -Encoding UTF8

    Write-Host "key.properties created" -ForegroundColor Green
    Write-Host "  Location: $KeyProperties"
    Write-Host "======================================================"
    Write-Host "IMPORTANT: Keep these credentials secure!"
    Write-Host "Store Password: openbible123"
    Write-Host "Key Password: openbible123"
    Write-Host "Key Alias: openbible"
    Write-Host "======================================================"
} else {
    Write-Host "Failed to generate keystore" -ForegroundColor Red
    exit 1
}
