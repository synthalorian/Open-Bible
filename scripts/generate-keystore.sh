#!/bin/bash
# Generate Android signing keystore for Open Bible app.
# Passwords come from the environment or an interactive prompt.
# They are written to android/key.properties, which is gitignored.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
KEYSTORE_DIR="$PROJECT_DIR/android/app"
KEYSTORE_FILE="$KEYSTORE_DIR/openbible-key.jks"
KEY_PROPERTIES="$PROJECT_DIR/android/key.properties"

prompt_secret() {
  local env_name="$1"
  local prompt="$2"
  local value="${!env_name-}"
  if [[ -z "$value" ]]; then
    if [[ ! -t 0 ]]; then
      echo "Set $env_name or run this script in a terminal to be prompted." >&2
      exit 1
    fi
    read -r -s -p "$prompt" value
    echo >&2
  fi
  if [[ -z "$value" || "$value" == *$'\n'* ]]; then
    echo "A single-line password is required ($env_name)." >&2
    exit 1
  fi
  printf '%s' "$value"
}

echo "Generating Android signing keystore for Open Bible..."
echo "======================================================"

mkdir -p "$KEYSTORE_DIR"

STORE_PASS="$(prompt_secret OPENBIBLE_STORE_PASSWORD "Store password: ")"
KEY_PASS="$(prompt_secret OPENBIBLE_KEY_PASSWORD "Key password: ")"

keytool -genkey -v \
    -keystore "$KEYSTORE_FILE" \
    -alias openbible \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$STORE_PASS" \
    -keypass "$KEY_PASS" \
    -dname "CN=synth, O=Open Bible, C=US"

umask 077
{
  printf 'storePassword=%s\n' "$STORE_PASS"
  printf 'keyPassword=%s\n' "$KEY_PASS"
  printf 'keyAlias=%s\n' 'openbible'
  printf 'storeFile=%s\n' 'app/openbible-key.jks'
} > "$KEY_PROPERTIES"

unset STORE_PASS KEY_PASS

echo ""
echo "Keystore generated successfully."
echo "  Location: $KEYSTORE_FILE"
echo "key.properties created (gitignored)."
echo "  Location: $KEY_PROPERTIES"
echo "======================================================"
echo "Keep the keystore and key.properties private."
echo "Key alias: openbible"
echo "======================================================"
