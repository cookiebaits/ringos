#!/bin/bash
set -e

echo "--- RingOS Auto-Repackage Script ---"

# 1. Setup paths
BASE_APK="com.moyoung.ring.apk"
CONFIG_APKS=("config.arm64_v8a.apk" "config.en.apk" "config.xhdpi.apk")
BASE_DIR="full_decoded_base"
MOD_DIR="decoded_base"

# 2. Decode APKs if directories don't exist
if [ ! -d "$BASE_DIR" ]; then
    echo "Decoding base APK..."
    apktool d "$BASE_APK" -o "$BASE_DIR" -f
fi

for apk in "${CONFIG_APKS[@]}"; do
    dir="decoded_${apk%.apk}"
    if [ ! -d "$dir" ]; then
        echo "Decoding $apk..."
        apktool d "$apk" -o "$dir" -f
    fi
done

echo "Merging modifications from $MOD_DIR..."
# Merge all smali directories
for smali_dir in "$MOD_DIR"/smali*; do
    if [ -d "$smali_dir" ]; then
        echo "  Merging $(basename "$smali_dir")..."
        cp -r "$smali_dir" "$BASE_DIR/"
    fi
done

echo "Merging config APK resources..."
# Merge native libs from arm64 config
CONFIG_ARM64_DIR="decoded_config_arm64_v8a"
if [ -d "$CONFIG_ARM64_DIR/lib" ]; then
    mkdir -p "$BASE_DIR/lib"
    cp -r "$CONFIG_ARM64_DIR/lib/"* "$BASE_DIR/lib/"
fi

# Merge resources from all configs
for apk in "${CONFIG_APKS[@]}"; do
    dir="decoded_${apk%.apk}"
    if [ -d "$dir/res" ]; then
        echo "  Merging resources from $dir..."
        cp -r "$dir/res/"* "$BASE_DIR/res/" 2>/dev/null || true
    fi
done

echo "Fixing resource names for AAPT2 compatibility..."
# AAPT2 doesn't like '$' in filenames.
find "$BASE_DIR/res" -name "\$*" -print0 | while IFS= read -r -d '' f; do
    dir=$(dirname "$f")
    base=$(basename "$f")
    newbase=$(echo "$base" | tr '$' '_')
    mv "$f" "$dir/$newbase"
done

# Update references in XML files.
echo "Updating XML references..."
find "$BASE_DIR/res" -type f -name "*.xml" -print0 | xargs -0 sed -i 's/@[^/]*\/\$/@drawable\/_/g' 2>/dev/null || true
# Note: The above sed is a bit broad but targets the most common issue.
# AAPT2 error specifically mentioned drawable.

echo "Hardening and Bloat Removal (AndroidManifest.xml)..."
python3 - <<EOF
import os
import re

manifest_path = os.path.join("$BASE_DIR", "AndroidManifest.xml")
with open(manifest_path, 'r') as f:
    content = f.read()

# Security Hardening
content = content.replace('android:allowBackup="true"', 'android:allowBackup="false"')
content = content.replace('android:usesCleartextTraffic="true"', 'android:usesCleartextTraffic="false"')

# Standalone APK fixes (removing split info)
content = re.sub(r'android:requiredSplitTypes="[^"]*"', '', content)
content = re.sub(r'android:splitTypes="[^"]*"', '', content)
content = re.sub(r'<meta-data android:name="com.android.vending.splits.required" android:value="true"/>', '', content)
content = re.sub(r'<meta-data android:name="com.android.vending.splits" android:resource="@xml/splits0"/>', '', content)

# Bloat Removal: ProfileInstallReceiver
profile_receiver_pattern = r'<receiver [^>]*android:name="androidx.profileinstaller.ProfileInstallReceiver"[^>]*>.*?</receiver>'
content = re.sub(profile_receiver_pattern, '', content, flags=re.DOTALL)

with open(manifest_path, 'w') as f:
    f.write(content)
EOF

echo "Building unsigned APK with AAPT2..."
apktool b "$BASE_DIR" --use-aapt2 -o RingOS.unsigned.apk

echo "Aligning APK..."
zipalign -f -v 4 RingOS.unsigned.apk RingOS.aligned.apk

echo "Signing APK..."
if [ ! -f "test.keystore" ]; then
    echo "Generating temporary test keystore..."
    keytool -genkey -v -keystore test.keystore -alias ringos -keyalg RSA -keysize 2048 -validity 10000 -storepass password -keypass password -dname "CN=RingOS, O=Moyoung, C=US"
fi

apksigner sign --ks test.keystore --ks-pass pass:password --out RingOS.apk RingOS.aligned.apk

echo "Done! Final APK: RingOS.apk"
