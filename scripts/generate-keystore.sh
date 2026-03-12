#!/bin/bash
# Generate Android signing keystore for Open Bible app

KEYSTORE_DIR="/home/synth/projects/open-bible/android/app"
KEYSTORE_FILE="$KEYSTORE_DIR/openbible-key.jks"
KEY_PROPERTIES="/home/synth/projects/open-bible/android/key.properties"

echo "Generating Android signing keystore for Open Bible..."
echo "======================================================"

# Create keystore directory if needed
mkdir -p "$KEYSTORE_DIR"

# Generate keystore
keytool -genkey -v \
    -keystore "$KEYSTORE_FILE" \
    -alias openbible \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass openbible123 \
    -keypass openbible123 \
    -dname "CN=synth, O=Open Bible, C=US"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Keystore generated successfully!"
    echo "  Location: $KEYSTORE_FILE"
    echo ""
    
    # Create key.properties file
    cat > "$KEY_PROPERTIES" << EOF
storePassword=openbible123
keyPassword=openbible123
keyAlias=openbible
storeFile=app/openbible-key.jks
EOF
    
    echo "✓ key.properties created"
    echo "  Location: $KEY_PROPERTIES"
    echo ""
    echo "======================================================"
    echo "IMPORTANT: Keep these credentials secure!"
    echo "Store Password: openbible123"
    echo "Key Password: openbible123"
    echo "Key Alias: openbible"
    echo "======================================================"
else
    echo "✗ Failed to generate keystore"
    exit 1
fi
