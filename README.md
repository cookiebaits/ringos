# Da Rings - Enhanced Android Application (RingOS)

This repository contains the modified, hardened, and optimized version of the "Da Rings" Android application (com.moyoung.ring), now rebranded as **RingOS**. The app is designed for smart rings, providing comprehensive health tracking and device management.

## 🌟 RingOS Features
- **All-in-One APK**: Converted from the original XAPK (split APKs) into a single, universal `RingOS.apk` for easier installation.
- **Health Tracking**: Monitoring for heart rate, blood oxygen, HRV, stress, and sleep patterns.
- **Workout Modes**: Support for various workouts with GPS tracking.
- **Modern UI**: Clean and intuitive interface for data visualization.

## 🛡️ Security & Efficiency
- **Security Hardening**: ADB backups and cleartext traffic are disabled (`android:allowBackup="false"`, `android:usesCleartextTraffic="false"`).
- **Reduced Bloat**: Removed unnecessary components like `ProfileInstallReceiver` to improve performance and reduce background overhead.
- **Target SDK 35**: Fully compatible with Android 15, including mandatory foreground service types and PendingIntent mutability.
- **Robust Connection Checks**: Enhanced `FindRingViewModel` to prevent commands from being sent when the ring is disconnected.

## 🛠️ Automated Repackaging
Repackaging is now fully automated via the `repackage.sh` script. This script handles decoding, merging split resources, applying security patches, removing bloat, and signing the final APK.

### Prerequisites
Ensure you have the following tools installed:
- `apktool` (v2.7.0+)
- `zipalign`
- `apksigner`
- `aapt` / `aapt2`
- `python3`
- `java` (for keytool and running apktool)

### Steps to Build RingOS.apk
1. **Prepare Source Files**: Ensure the original base and config APKs are in the root directory.
2. **Run the Script**:
   ```bash
   bash repackage.sh
   ```
3. **Output**: The final, signed, and aligned APK will be generated as `RingOS.apk` in the root directory.

*Note: The script generates a temporary test keystore if one is not present. For production releases, replace the signing logic with your own release key.*

## 🌐 Network & Ports
- **Outbound**: Port 443 (HTTPS) for cloud sync.
- **Local**: Bluetooth Low Energy (BLE) for device communication.
- **Inbound**: No inbound ports are opened.

## 🚀 Deployment
RingOS is optimized for deployment on Android devices (SDK 21 to 35). For associated backend services, use **Dokploy** behind a **Cloudflare proxy**.
