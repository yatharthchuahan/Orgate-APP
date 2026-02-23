# Setup Image Picker for Profile Picture Upload

## 📦 Add Dependencies

Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  image_picker: ^1.0.7
```

## 🔧 Install Packages

Run this command in your terminal:

```bash
flutter pub get
```

## ⚙️ Platform Configuration

### Android (android/app/src/main/AndroidManifest.xml)

Add these permissions inside the `<manifest>` tag:

```xml
<!-- Required for camera -->
<uses-feature android:name="android.hardware.camera" android:required="false" />
<uses-permission android:name="android.permission.CAMERA" />

<!-- Required for gallery -->
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" 
                 android:maxSdkVersion="32" />
```

### iOS (ios/Runner/Info.plist)

Add these keys inside the `<dict>` tag:

```xml
<!-- Camera Permission -->
<key>NSCameraUsageDescription</key>
<string>We need access to your camera to take profile pictures.</string>

<!-- Gallery Permission -->
<key>NSPhotoLibraryUsageDescription</key>
<string>We need access to your photo library to select profile pictures.</string>
```

## ✅ That's It!

After completing the above steps:
1. Run `flutter pub get`
2. Restart your app
3. The profile picture upload feature will work!

---

## 🎯 Feature Overview

When users click "Upload Profile Picture":
1. **Dialog Opens** - Choose Camera or Gallery
2. **Camera** - Opens camera to take a new photo
3. **Gallery** - Opens gallery to select existing photo
4. **Automatic Conversion** - Image is converted to base64
5. **Upload** - Base64 image is sent to API
6. **Success Message** - Shows upload confirmation
7. **Auto Refresh** - Profile screen refreshes to show new picture

---

## 📝 API Endpoint

The upload uses:
- **URL**: `https://demoapi.wavelift.in/api/ProfilePicture/Upload`
- **Method**: POST
- **Body**: `{ "base64Image": "<base64_string>" }`
- **Headers**: Includes authentication token

---

## 🎨 Features

✅ Camera and Gallery options  
✅ Image optimization (max 1024x1024, 85% quality)  
✅ Automatic base64 conversion  
✅ File size display  
✅ Loading indicator  
✅ Success/Error messages  
✅ Auto-refresh after upload  
✅ 401 error handling (auto-logout)  

---

## 🐛 Troubleshooting

**Permission Denied on Android:**
- Check if camera/storage permissions are in AndroidManifest.xml
- For Android 13+, request runtime permissions

**Camera/Gallery not opening:**
- Restart the app after adding dependencies
- Check platform-specific configuration

**Upload failed:**
- Check internet connection
- Verify API endpoint is correct
- Check if authentication token is valid

