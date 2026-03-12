#!/bin/bash
# Generate Android signing keystore for Open Bible app

KEYSTORE_DIR="<repo>/android/app"
KEYSTORE_FILE="$KEYSTORE_DIR/openbible-key.jks"
KEY_PROPERTIES="<repo>/android/key.properties"

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
    -storepass ***REMOVED*** \
    -keypass ***REMOVED*** \
    -dname "CN=synth, O=Open Bible, C=US"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Keystore generated successfully!"
    echo "  Location: $KEYSTORE_FILE"
    echo ""
    
    # Create key.properties file
    cat > "$KEY_PROPERTIES" << EOF
storePassword=***REMOVED***
keyPassword=***REMOVED***
keyAlias=openbible
storeFile=app/openbible-key.jks
EOF
    
    echo "✓ key.properties created"
    echo "  Location: $KEY_PROPERTIES"
    echo ""
    echo "======================================================"
    echo "IMPORTANT: Keep these credentials secure!"
    echo "Store Password: ***REMOVED***"
    echo "Key Password: ***REMOVED***"
    echo "Key Alias: openbible"
    echo "======================================================"
else
    echo "✗ Failed to generate keystore"
    exit 1
fi
