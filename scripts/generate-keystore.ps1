# Generate Android signing keystore for Open Bible app (Windows PowerShell).
# Passwords come from the environment or an interactive prompt.
# They are written to android/key.properties, which is gitignored.
$ErrorActionPreference = 'Stop'

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir
$KeystoreDir = Join-Path $ProjectDir 'android\app'
$KeystoreFile = Join-Path $KeystoreDir 'openbible-key.jks'
$KeyProperties = Join-Path $ProjectDir 'android\key.properties'

function Get-PlainPassword([string]$EnvName, [string]$Prompt) {
    $value = [Environment]::GetEnvironmentVariable($EnvName)
    if ([string]::IsNullOrEmpty($value)) {
        $secure = Read-Host $Prompt -AsSecureString
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
        try {
            $value = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        } finally {
            [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        }
    }
    if ([string]::IsNullOrEmpty($value) -or $value.Contains("`n") -or $value.Contains("`r")) {
        Write-Error "A single-line password is required ($EnvName)."
        exit 1
    }
    return $value
}

Write-Host "Generating Android signing keystore for Open Bible..."
Write-Host "======================================================"

New-Item -ItemType Directory -Path $KeystoreDir -Force | Out-Null

$StorePass = Get-PlainPassword 'OPENBIBLE_STORE_PASSWORD' 'Store password'
$KeyPass = Get-PlainPassword 'OPENBIBLE_KEY_PASSWORD' 'Key password'

keytool -genkey -v `
    -keystore $KeystoreFile `
    -alias openbible `
    -keyalg RSA `
    -keysize 2048 `
    -validity 10000 `
    -storepass $StorePass `
    -keypass $KeyPass `
    -dname "CN=synth, O=Open Bible, C=US"

if ($LASTEXITCODE -ne 0) {
    Write-Host "Failed to generate keystore" -ForegroundColor Red
    exit 1
}

$props = @(
    "storePassword=$StorePass"
    "keyPassword=$KeyPass"
    'keyAlias=openbible'
    'storeFile=app/openbible-key.jks'
) -join "`n"
Set-Content -Path $KeyProperties -Value $props -Encoding UTF8
Remove-Variable StorePass, KeyPass

Write-Host "Keystore generated successfully." -ForegroundColor Green
Write-Host "  Location: $KeystoreFile"
Write-Host "key.properties created (gitignored)." -ForegroundColor Green
Write-Host "  Location: $KeyProperties"
Write-Host "======================================================"
Write-Host "Keep the keystore and key.properties private."
Write-Host "Key alias: openbible"
Write-Host "======================================================"
