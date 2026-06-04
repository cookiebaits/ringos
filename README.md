# Da Rings - Enhanced Android Application

This repository contains the modified and hardened version of the "Da Rings" Android application (com.moyoung.ring). The app is designed to work with smart rings, providing health tracking, workout monitoring, and device management features.

## 🌟 Key Features
- **Health Tracking**: Monitoring for heart rate, blood oxygen, HRV, stress, and sleep patterns.
- **Workout Modes**: Support for various popular workouts and GPS-based training.
- **Device Management**: Firmware updates, find ring feature, and indicator light control.
- **Modern UI**: Clean and intuitive interface for data visualization.

## 🛡️ Security Improvements
The following security hardening measures have been implemented:
- **Disabled ADB Backups**: Set `android:allowBackup="false"` in `AndroidManifest.xml` to prevent sensitive user data from being extracted via ADB.
- **Enforced HTTPS**: Set `android:usesCleartextTraffic="false"` to block unencrypted network communication.
- **Reduced Attack Surface**: Restricted `android:exported="false"` for 60+ internal activities that do not require external access, preventing malicious apps from directly launching internal screens.
- **Robust Find Ring Logic**: Added a connection check in `FindRingViewModel` to ensure commands are only sent when the device is verified as connected, preventing unnecessary resource usage and providing better user feedback.

## 📱 Android 15 Compatibility
- **Foreground Service Compliance**: Verified all foreground services (`BandConnectService`, `GPSTrainingService`) use the correct `connectedDevice` type and have the mandatory permissions.
- **PendingIntent Mutability**: Confirmed and verified that all `PendingIntent` instances use `FLAG_IMMUTABLE` (or `FLAG_MUTABLE` where specifically required) as mandated by Android 12+.

## 🛠️ Repackaging Instructions

To rebuild, sign, and align the application, follow these steps:

### 1. Build the APK
Use `apktool` to reassemble the decoded project:
```bash
apktool b decoded_base -o com.moyoung.ring.modified.apk
```

### 2. ZipAlign the APK
Ensure the APK is optimized for memory usage:
```bash
zipalign -v 4 com.moyoung.ring.modified.apk com.moyoung.ring.final.apk
```

### 3. Sign the APK
Sign the APK using `apksigner` (requires a valid keystore):
```bash
apksigner sign --ks my-release-key.jks --out com.moyoung.ring.signed.apk com.moyoung.ring.final.apk
```

### 4. Create an .XAPK (Optional)
To package as an `.xapk` (which includes split APKs for different architectures/configs):
1. Create a new directory.
2. Copy the modified base APK and the original config APKs (`config.arm64_v8a.apk`, `config.en.apk`, `config.xhdpi.apk`) into it.
3. Include the `manifest.json` and `icon.png` in the root.
4. Compress all files into a ZIP archive and rename it with the `.xapk` extension.

## 🌐 Network & Ports
- **Ports**: This application primarily uses standard outbound HTTPS (Port 443) for cloud synchronization and Bluetooth Low Energy (BLE) for device communication. No inbound ports are opened.

## 🚀 Deployment
This application is designed to be installed on Android devices (SDK 21 to 35). For backend services, deployment via **Dokploy** behind a **Cloudflare proxy** is recommended for optimal security and reliability.
