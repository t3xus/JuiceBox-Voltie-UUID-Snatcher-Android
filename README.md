
![Static Badge](https://img.shields.io/badge/Author-Jgooch-1F4D37)
![Static Badge](https://img.shields.io/badge/Distribution-npm-orange)
![Target](https://img.shields.io/badge/Target-Android%20OS-357EC7)
# Voltie UUID Snatcher Android Application

>>> Art=text2art("art") # Return ASCII text (default font) and default chr_ignore=True 
>>> print(Art)
>>> 
## Overview

The **Voltie UUID Snatcher** is an Android application that scans for Wi-Fi Access Points (APs) containing "Juice" in their SSID, fetches a unique UUID from the AP, and emails it to the designated support address. It includes features like detailed AP information, QR code generation, background scanning, and enhanced error handling.

Additionally, a companion **Build Android APK Script** automates the process of building, signing, and aligning the APK for deployment.

---

## Application Features

### Wi-Fi Scanning
- Lists all Wi-Fi APs containing "Juice" in their SSID.
- Filters APs based on signal strength.

### Detailed AP Information
- Displays signal strength (RSSI), encryption type (WEP, WPA, WPA2), and frequency band (2.4 GHz or 5 GHz).

### Retry Logic
- Automatically retries fetching UUIDs if the first attempt fails.

### QR Code Generation
- Generates QR codes for fetched UUIDs for easy sharing.

### Background Scanning
- Scans for matching APs in the background and notifies users when a new AP is detected.

### Customizable Settings
- Adjust scanning intervals and enable/disable features such as QR code generation or notifications.

### Localization
- Multi-language support for global usability.

---

## Technical Features

| Feature              | Description                                       |
|----------------------|---------------------------------------------------|
| **Frameworks**       | Android Jetpack, `ConnectivityManager`, `OkHttp` |
| **Persistence**      | SQLite and SharedPreferences                      |
| **Languages**        | Kotlin                                           |
| **Network API**      | `OkHttp`, `Retrofit`                              |
| **QR Code**          | ZXing library for QR code generation             |

---

## Build Android APK Script Features

- **Operating System Detection**:
  Automatically detects the operating system (macOS, Ubuntu, Debian, or Red Hat) and adjusts commands for the environment.

- **Dependency Management**:
  Installs required tools such as `keytool`, `jarsigner`, `zipalign`, and `curl` if they are not already installed.

- **Gradle Wrapper Support**:
  Downloads the Gradle wrapper if it is missing from the project.

- **Interactive Build Type Selection**:
  Prompts users to select the build type (`release` or `debug`).

- **Keystore Management**:
  Automatically generates a keystore if one is not available.

- **APK Signing and Alignment**:
  Ensures the APK is signed and aligned for sideloading onto Android devices.

- **Logging**:
  Logs all build steps and errors to a timestamped log file for troubleshooting.

- **Email Notifications**:
  Sends an optional email notification with build results and logs attached.

---

## Files Overview

### Application Files

#### `activity_main.xml`
Defines the layout for the main activity, including:
- A list of available APs.
- A button for QR code generation.

#### `styles.xml`
Defines the app's visual theme, including primary and secondary colors.

#### `strings.xml`
Contains all string resources for the app, including localizable text.

#### `AndroidManifest.xml`
Specifies app permissions and declares the main activity.

#### `MainActivity.kt`
The core logic for:
- Wi-Fi scanning.
- UUID fetching.
- QR code generation.
- Background scanning and notifications.

### Build Script

#### `build_android_apk.sh`
A script to automate building, signing, and aligning the Android APK. It ensures all dependencies are available, builds the project, signs the APK, aligns it, and generates a sideloadable APK file for manual installation on Android devices.

---

## Installation and Setup

### Prerequisites
- Android Studio installed on your computer.
- A physical Android device or emulator for testing.

### Steps

#### Application Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/Voltie-UUID-Snatcher.git
   cd Voltie-UUID-Snatcher
   ```

2. Open the project in Android Studio.

3. Build the project:
   ```bash
   ./gradlew build
   ```

4. Run the application on a connected Android device.

#### Script Usage

1. Ensure the script is executable:
   ```bash
   chmod +x build_android_apk.sh
   ```

2. Run the script:
   ```bash
   ./build_android_apk.sh
   ```

3. Follow prompts to select the build type (`release` or `debug`).

4. Locate the final APK in the `output_apks` directory.

---

## Required Permissions

Add the following permissions in `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```

---

## Usage

1. Launch the app.
2. Grant location and Wi-Fi permissions.
3. Select an AP with "Juice" in the SSID.
4. Fetch the UUID and email it to `support@voltiegroup.com`.
5. Optionally, generate and share a QR code for the UUID.

---

## Logs

Logs for the build process are saved in the `build_logs` directory with a timestamp for easy reference.

---

## Troubleshooting

### Application Issues

1. **Missing Dependencies**:
   Ensure all required libraries and tools are installed.

2. **Permission Issues**:
   Check that the necessary permissions are granted.

3. **Logs**:
   Use the `Logcat` tool in Android Studio to debug runtime errors.

### Build Script Issues

1. **Missing Dependencies**:
   Ensure the required tools are installed using the commands provided in the script.

2. **Permission Issues**:
   Run the script with elevated privileges if required:
   ```bash
   sudo ./build_android_apk.sh
   ```

3. **Logs**:
   Check the logs in the `build_logs` directory for error details.

---

