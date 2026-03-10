#!/usr/bin/env bash
set -euo pipefail

# Generate Android signing keystore for Open Bible app (no hardcoded secrets)

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
KEYSTORE_DIR="$ROOT_DIR/android/app"
KEYSTORE_FILE="$KEYSTORE_DIR/openbible-key.jks"
KEY_PROPERTIES="$ROOT_DIR/android/key.properties"

echo "Generating Android signing keystore for Open Bible..."
echo "======================================================"

read -r -p "Key alias [openbible]: " KEY_ALIAS
KEY_ALIAS="${KEY_ALIAS:-openbible}"

read -r -s -p "Store password: " STORE_PASSWORD
echo
read -r -s -p "Key password (leave blank to reuse store password): " KEY_PASSWORD
echo
KEY_PASSWORD="${KEY_PASSWORD:-$STORE_PASSWORD}"

read -r -p "Distinguished Name [CN=synth, O=Open Bible, C=US]: " DNAME
DNAME="${DNAME:-CN=synth, O=Open Bible, C=US}"

mkdir -p "$KEYSTORE_DIR"

keytool -genkey -v \
  -keystore "$KEYSTORE_FILE" \
  -alias "$KEY_ALIAS" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass "$STORE_PASSWORD" \
  -keypass "$KEY_PASSWORD" \
  -dname "$DNAME"

cat > "$KEY_PROPERTIES" << EOF
storePassword=$STORE_PASSWORD
keyPassword=$KEY_PASSWORD
keyAlias=$KEY_ALIAS
storeFile=app/openbible-key.jks
EOF

chmod 600 "$KEY_PROPERTIES"

echo
echo "✓ Keystore generated: $KEYSTORE_FILE"
echo "✓ key.properties created: $KEY_PROPERTIES"
echo "⚠ Keep both files private. key.properties is gitignored."
