# **JuiceNet-Voltie Android**
## **The VoltiE UUID Snatcher for Android**

![Static Badge](https://img.shields.io/badge/Author-Jgooch-1F4D37)  
![Static Badge](https://img.shields.io/badge/Distribution-npm-orange)  
![Target](https://img.shields.io/badge/Target-Android-3DDC84)  

---

### **Overview**
VoltiE UUID Snatcher is an Android application designed to:
- Scan for Wi-Fi Access Points (APs) with names containing **"Juice"**.
- Allow users to select and connect to the desired AP.
- Fetch a UUID by accessing `http://10.10.10.1/command/get+system.uuid`.
- Email the UUID to `support@voltiegroup.com`.
- Persist previously processed APs to avoid redundant connections.

---

### **Features**
- **Wi-Fi Scanning**: Lists all APs with names containing "Juice."
- **AP Selection**: Users can pick specific APs to connect to.
- **UUID Fetching**: Fetches the UUID from the AP’s HTTP interface.
- **Email Integration**: Automatically sends the UUID to a support email.
- **Persistence**: Skips APs previously processed by saving them locally.

---

### **Technical Details**

| Feature                    | Details                                          |
|----------------------------|-------------------------------------------------|
| **Platform**               | Android                                         |
| **Frameworks**             | `Android Jetpack`, `ConnectivityManager`, `WorkManager` |
| **Persistence**            | `SharedPreferences`                             |
| **Network API**            | `OkHttp`, `Retrofit`                            |
| **Languages**              | Kotlin                                          |
| **Email**                  | Sent via `Intent.ACTION_SENDTO`                 |

---

### **How It Works**

1. **Wi-Fi Scanning**: 
   - The app scans for APs containing "Juice" in their SSID using the `WifiManager`.
   - Skips networks previously processed.

2. **User Interaction**:
   - Displays a list of matching networks.
   - Allows the user to select an AP to connect to.

3. **Connection & UUID Fetch**:
   - The app connects to the selected AP using `WifiNetworkSuggestion` or `WifiManager`.
   - Fetches the UUID from the AP’s endpoint `http://10.10.10.1/command/get+system.uuid` using `OkHttp`.

4. **Email Automation**:
   - Emails the UUID to `support@voltiegroup.com` via an email intent.

5. **Persistence**:
   - The app saves previously processed APs in `SharedPreferences` to avoid reprocessing.

---

### **Installation**

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/VoltiE-UUID-Snatcher-Android.git
   ```

2. Open the project in Android Studio:
   ```bash
   cd VoltiE-UUID-Snatcher-Android
   ./gradlew build
   ```

3. Configure your keystore and AndroidManifest.xml with proper permissions.

4. Build and run the app on a physical Android device.

---

### **Usage**

1. Launch the app on your Android device.
2. Grant location and Wi-Fi permissions when prompted.
3. Select a Wi-Fi network starting with "Juice" from the list.
4. The app will:
   - Connect to the selected AP.
   - Fetch the UUID.
   - Send an email to `support@voltiegroup.com` with the UUID.
5. Previously processed APs will not appear again.

---

### **Required Permissions**
Add the following permissions to your `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
<uses-permission android:name="android.permission.INTERNET" />
```

---


