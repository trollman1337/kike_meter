#!/bin/bash

# Variables
NETWORK_SECURITY_CONFIG_DIR="android/app/src/main/res/xml"
PROGUARD_RULES_FILE="android/app/proguard-rules.pro"
ANDROID_MANIFEST_FILE="android/app/src/main/AndroidManifest.xml"
NETWORK_SECURITY_FILE="$NETWORK_SECURITY_CONFIG_DIR/network_security_config.xml"

# Create network security configuration directory if it doesn't exist
if [ ! -d "$NETWORK_SECURITY_CONFIG_DIR" ]; then
    mkdir -p "$NETWORK_SECURITY_CONFIG_DIR"
    echo "Created network security config directory."
fi

# Create network security configuration file
cat <<EOL > "$NETWORK_SECURITY_FILE"
<?xml version="1.0" encoding="utf-8"?>
<network-security-config>
    <domain-config cleartextTrafficPermitted="true">
        <domain includeSubdomains="true">yourdomain.com</domain>
    </domain-config>
</network-security-config>
EOL

echo "Created network security config file."

# Update AndroidManifest.xml to use the network security config
if ! grep -q 'android:networkSecurityConfig="@xml/network_security_config"' "$ANDROID_MANIFEST_FILE"; then
    sed -i '/<\/application>/i \    android:networkSecurityConfig="@xml/network_security_config"' "$ANDROID_MANIFEST_FILE"
    echo "Updated AndroidManifest.xml with network security config."
fi

# Add ProGuard rules
cat <<EOL >> "$PROGUARD_RULES_FILE"
# Preserve necessary classes and methods for network requests
-keep class com.yourpackage.** { *; }
-keep class okhttp3.** { *; }
-keep class retrofit2.** { *; }
EOL

echo "Added ProGuard rules."

# Ensure internet permissions are in AndroidManifest.xml
if ! grep -q 'android.permission.INTERNET' "$ANDROID_MANIFEST_FILE"; then
    sed -i '/<\/manifest>/i \    <uses-permission android:name="android.permission.INTERNET"/>' "$ANDROID_MANIFEST_FILE"
    sed -i '/<\/manifest>/i \    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>' "$ANDROID_MANIFEST_FILE"
    echo "Added internet permissions to AndroidManifest.xml."
fi

echo "Setup completed. Please check the AndroidManifest.xml, network security config, and ProGuard rules."
