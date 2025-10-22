# Firebase Setup for Flow Ai

## Current Configuration
- **Firebase Project**: flowai-demo-project
- **iOS Bundle ID**: com.flowai.health
- **Android Package**: com.flowai.health
- **App Name**: Flow Ai

## Steps to Complete Firebase Configuration

### 1. Download Configuration Files from Firebase Console

Visit: https://console.firebase.google.com/project/flowai-demo-project/settings/general

#### For Android:
1. Go to Project Settings → Your apps → Android app
2. Download `google-services.json`
3. Replace file at: `android/app/google-services.json`

#### For iOS:
1. Go to Project Settings → Your apps → iOS app  
2. Download `GoogleService-Info.plist`
3. Replace files at:
   - `ios/Runner/GoogleService-Info.plist`
   - `macos/Runner/GoogleService-Info.plist`

### 2. Verify Firebase Services Enabled

Make sure these services are enabled in Firebase Console:

✅ **Authentication**
- Email/Password
- Google Sign-In
- Apple Sign-In

✅ **Firestore Database**
- Create database in production mode
- Set up security rules

✅ **Analytics**
- Enabled by default

✅ **Crashlytics**
- Enable crash reporting

✅ **Cloud Messaging**
- For push notifications

### 3. Update Security Rules

#### Firestore Rules:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /cycles/{cycleId} {
      allow read, write: if request.auth != null && request.auth.uid == resource.data.userId;
    }
  }
}
```

### 4. Test Firebase Authentication

Run the app and test:
```bash
flutter run -d chrome --release
```

Or on iOS/Android:
```bash
flutter run -d [device-id]
```

### 5. App Store Connect & Play Console Setup

#### iOS App Store
- Bundle ID: `com.flowai.health`
- App Name: `Flow Ai`
- Category: Health & Fitness
- Age Rating: 12+ (health/medical information)

#### Android Play Store
- Package: `com.flowai.health`
- App Name: `Flow Ai`
- Category: Health & Fitness
- Content Rating: Teen (health information)

## Publishing Checklist

### iOS (App Store)
- [ ] Download GoogleService-Info.plist from Firebase
- [ ] Update iOS signing certificates in Xcode
- [ ] Create App Store Connect record
- [ ] Upload screenshots and metadata
- [ ] Submit for review

### Android (Play Store)
- [ ] Download google-services.json from Firebase
- [ ] Generate signed APK/App Bundle
- [ ] Create Play Console listing
- [ ] Upload screenshots and metadata
- [ ] Submit for review

## Current Status

✅ App rebranded to Flow Ai
✅ Firebase dependencies enabled (v2.1.0+7)
✅ Bundle IDs configured
✅ App icons generated
✅ Release build tested

🔲 Firebase configuration files need updating
🔲 Test authentication flow
🔲 Submit to App Store
🔲 Submit to Play Store

## Commands for Publishing

### Build Release APK (Android)
```bash
flutter build apk --release
```

### Build App Bundle (Google Play)
```bash
flutter build appbundle --release
```

### Build iOS Release
```bash
flutter build ios --release
```

### Build for Web
```bash
flutter build web --release
```

## Firebase Console Links

- **Main Console**: https://console.firebase.google.com/project/flowai-demo-project
- **Authentication**: https://console.firebase.google.com/project/flowai-demo-project/authentication
- **Firestore**: https://console.firebase.google.com/project/flowai-demo-project/firestore
- **Analytics**: https://console.firebase.google.com/project/flowai-demo-project/analytics
- **Settings**: https://console.firebase.google.com/project/flowai-demo-project/settings/general
