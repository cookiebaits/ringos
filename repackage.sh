#!/bin/bash
# RingOS hardened repackage script
# Requires: apktool, zipalign, apksigner, keytool, python3
#
# Drop this file alongside the original APKs (com.moyoung.ring.apk + config splits)
# and the `patches/` directory from this bundle. Then run: ./repackage.sh
set -euo pipefail

echo "--- RingOS Hardened Repackage ---"

BASE_APK="com.moyoung.ring.apk"
CONFIG_APKS=("config.arm64_v8a.apk" "config.en.apk" "config.xhdpi.apk")
BASE_DIR="full_decoded_base"
MOD_DIR="decoded_base"          # your existing smali mods (optional)
PATCH_DIR="patches"             # hardening assets shipped with this script

# ---------- 1. Decode ----------
if [ ! -d "$BASE_DIR" ]; then
    echo "Decoding base APK..."
    apktool d "$BASE_APK" -o "$BASE_DIR" -f
fi
for apk in "${CONFIG_APKS[@]}"; do
    dir="decoded_${apk%.apk}"
    [ -d "$dir" ] || { echo "Decoding $apk..."; apktool d "$apk" -o "$dir" -f; }
done

# ---------- 2. Merge smali mods (if present) ----------
if [ -d "$MOD_DIR" ]; then
    for smali_dir in "$MOD_DIR"/smali*; do
        [ -d "$smali_dir" ] && { echo "  Merging $(basename "$smali_dir")..."; cp -r "$smali_dir" "$BASE_DIR/"; }
    done
fi

# ---------- 3. Merge config APK resources ----------
CONFIG_ARM64_DIR="decoded_config_arm64_v8a"
if [ -d "$CONFIG_ARM64_DIR/lib" ]; then
    mkdir -p "$BASE_DIR/lib"
    cp -r "$CONFIG_ARM64_DIR/lib/"* "$BASE_DIR/lib/"
fi
for apk in "${CONFIG_APKS[@]}"; do
    dir="decoded_${apk%.apk}"
    [ -d "$dir/res" ] && cp -r "$dir/res/"* "$BASE_DIR/res/" 2>/dev/null || true
done

# ---------- 4. AAPT2 filename sanitization ----------
find "$BASE_DIR/res" -name "\$*" -print0 | while IFS= read -r -d '' f; do
    mv "$f" "$(dirname "$f")/$(basename "$f" | tr '$' '_')"
done
find "$BASE_DIR/res" -type f -name "*.xml" -print0 \
    | xargs -0 sed -i 's/@[^/]*\/\$/@drawable\/_/g' 2>/dev/null || true

# ---------- 5. Drop hardening XMLs ----------
mkdir -p "$BASE_DIR/res/xml"
cp "$PATCH_DIR/res/xml/network_security_config.xml" "$BASE_DIR/res/xml/"
cp "$PATCH_DIR/res/xml/backup_rules.xml"            "$BASE_DIR/res/xml/"
cp "$PATCH_DIR/res/xml/data_extraction_rules.xml"   "$BASE_DIR/res/xml/"

# ---------- 6. Manifest hardening ----------
echo "Hardening AndroidManifest.xml..."
python3 - "$BASE_DIR" <<'PY'
import os, re, sys
manifest = os.path.join(sys.argv[1], "AndroidManifest.xml")
with open(manifest) as f: x = f.read()

# --- application tag attributes ---
x = x.replace('android:allowBackup="true"',           'android:allowBackup="false"')
x = x.replace('android:usesCleartextTraffic="true"',  'android:usesCleartextTraffic="false"')
x = x.replace('android:extractNativeLibs="true"',     'android:extractNativeLibs="false"')

# Remove pointer-tagging opt-out (default true = MTE-friendly)
x = re.sub(r'\s*android:allowNativeHeapPointerTagging="false"', '', x)

# Force-add networkSecurityConfig + explicit debuggable=false on <application>
def patch_app(m):
    tag = m.group(0)
    if 'android:networkSecurityConfig=' not in tag:
        tag = tag.replace('<application ', '<application android:networkSecurityConfig="@xml/network_security_config" ', 1)
    if 'android:debuggable=' not in tag:
        tag = tag.replace('<application ', '<application android:debuggable="false" ', 1)
    return tag
x = re.sub(r'<application [^>]*>', patch_app, x, count=1)

# --- ScreenReceiver: stop exporting it (no permission was guarding it) ---
x = re.sub(
    r'(<receiver [^>]*android:name="com\.moyoung\.ring\.common\.ble\.broadcast\.ScreenReceiver"[^>]*)android:exported="true"',
    r'\1android:exported="false"', x)

# --- Standalone APK fixes (split metadata) ---
x = re.sub(r'\s*android:requiredSplitTypes="[^"]*"', '', x)
x = re.sub(r'\s*android:splitTypes="[^"]*"', '', x)
x = re.sub(r'<meta-data android:name="com\.android\.vending\.splits\.required"[^/]*/>', '', x)
x = re.sub(r'<meta-data android:name="com\.android\.vending\.splits"[^/]*/>', '', x)

# --- Bloat removal ---
x = re.sub(r'<receiver [^>]*androidx\.profileinstaller\.ProfileInstallReceiver[^>]*>.*?</receiver>',
           '', x, flags=re.DOTALL)

# --- OPTIONAL permission stripping ----------------------------------------
# Uncomment the lines below to drop dangerous perms you don't need. Each one
# disables a real feature — read the comment before uncommenting.
DROP = [
    # "android.permission.SEND_SMS",         # breaks: replying to SMS from ring
    # "android.permission.READ_SMS",         # breaks: mirroring SMS to ring
    # "android.permission.READ_CALL_LOG",    # breaks: showing recent calls on ring
    # "android.permission.CALL_PHONE",       # breaks: initiating calls from ring
    # "android.permission.ANSWER_PHONE_CALLS",
    # "android.permission.CAMERA",           # breaks: QR pairing
    # "android.permission.FLASHLIGHT",
    # "android.permission.READ_CALENDAR", "android.permission.WRITE_CALENDAR",
    # "com.coloros.permission.READ_COLOROS_CALENDAR",
    # "com.coloros.permission.WRITE_COLOROS_CALENDAR",
]
for p in DROP:
    x = re.sub(r'\s*<uses-permission[^/]*android:name="' + re.escape(p) + r'"[^/]*/>', '', x)

with open(manifest, 'w') as f: f.write(x)
print("  manifest patched.")
PY

# ---------- 7. Build / align / sign ----------
echo "Building unsigned APK..."
apktool b "$BASE_DIR" --use-aapt2 -o RingOS.unsigned.apk

echo "Aligning..."
zipalign -f -p -v 4 RingOS.unsigned.apk RingOS.aligned.apk

if [ ! -f "release.keystore" ]; then
    echo ""
    echo ">>> No release.keystore found. Generating one (interactive)."
    echo ">>> KEEP THIS FILE SAFE — you need the SAME keystore to ship updates."
    keytool -genkeypair -v \
        -keystore release.keystore -alias ringos \
        -keyalg RSA -keysize 4096 -validity 10000 \
        -storetype PKCS12
fi

echo "Signing with v1+v2+v3 schemes..."
apksigner sign \
    --ks release.keystore --ks-key-alias ringos \
    --v1-signing-enabled true \
    --v2-signing-enabled true \
    --v3-signing-enabled true \
    --out RingOS.apk RingOS.aligned.apk

apksigner verify --verbose RingOS.apk
echo ""
echo "Done -> RingOS.apk"
