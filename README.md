# RingOS hardening bundle

Drop the contents of this folder next to the original APKs:

```
your-workdir/
├── com.moyoung.ring.apk
├── config.arm64_v8a.apk
├── config.en.apk
├── config.xhdpi.apk
├── decoded_base/            # (optional) your existing smali edits
├── patches/                 # from this bundle
│   └── res/xml/
│       ├── network_security_config.xml
│       ├── backup_rules.xml
│       └── data_extraction_rules.xml
└── repackage.sh             # from this bundle (replaces the old one)
```

## Prereqs (one-time)

macOS:
```bash
brew install apktool
brew install --cask android-platform-tools           # zipalign, apksigner via build-tools
# Or get build-tools through Android Studio; ensure zipalign + apksigner on PATH.
```

Linux:
```bash
sudo apt install apktool default-jdk
# zipalign + apksigner come from Android SDK build-tools (any 34+ version).
```

## Build

```bash
chmod +x repackage.sh
./repackage.sh
```

Output: `RingOS.apk` — install via `adb install -r RingOS.apk` or sideload.

## Keystore

First run generates `release.keystore`. **Back it up.** Without that exact
keystore you cannot push updates over the installed app — users would have to
uninstall (losing data) to install a re-signed version.

## What changed vs the original script

- Network: pinned to system CAs only via `network_security_config.xml` — user-installed root certs can no longer MITM.
- Backup: explicit empty `backup_rules.xml` + `data_extraction_rules.xml`; nothing leaks via auto-backup or device transfer.
- Manifest: `debuggable=false` explicit, MTE pointer-tagging re-enabled, native libs no longer extracted to writable storage.
- `ScreenReceiver` no longer exported — other apps can't spoof screen events into it.
- Signing: v1+v2+v3 enabled, 4096-bit RSA, PKCS12 keystore (modern format).
- Zipalign uses `-p` for page alignment (required for `extractNativeLibs=false`).

## Optional further hardening

Open `repackage.sh`, find the `DROP = [...]` block, and uncomment any
permission you don't need. Each line lists the feature it breaks.
