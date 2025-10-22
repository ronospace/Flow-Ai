# Flow Ai Publishing Guide v2.1.1+8

## ✅ Build Status

### iOS Release Build
- **Status**: ✅ Successfully Built
- **Location**: `build/ios/iphoneos/Runner.app`
- **Size**: 40.0MB
- **Version**: 2.1.1 (Build 8)
- **Bundle ID**: com.flowai.health

### Android Release Builds
- **APK Status**: ✅ Successfully Built
  - **Location**: `build/app/outputs/flutter-apk/app-release.apk`
  - **Size**: 95.3MB
  
- **App Bundle Status**: ✅ Successfully Built  
  - **Location**: `build/app/outputs/bundle/release/app-release.aab`
  - **Size**: 65.5MB
  - **Package**: com.flowai.health

---

## 🎯 AdMob Configuration

### Current Status
✅ **App IDs are configured** in manifest files:
- Android: `ca-app-pub-8707491489514576~5064348089`
- iOS: `ca-app-pub-8707491489514576~3053779336`

⚠️ **Ad Unit IDs need updating** in code (currently using test IDs)

### Required: Update Ad Unit IDs

#### Step 1: Get Your Real Ad Unit IDs from AdMob
1. Go to https://apps.admob.google.com
2. Navigate to Apps → Flow Ai → Ad units
3. Copy your actual ad unit IDs for:
   - Banner ads
   - Interstitial ads (optional)
   - Rewarded ads (optional)

#### Step 2: Update Ad Unit IDs in Code

Edit `lib/core/services/admob_service.dart`:

**Current (Test IDs):**
```dart
// Lines 16-18
static const String _prodBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
static const String _prodInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
static const String _prodRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
```

**Replace with YOUR actual AdMob Ad Unit IDs:**
```dart
// ANDROID Ad Units
static const String _androidBannerAdUnitId = 'ca-app-pub-XXXXXXX/XXXXXXXX';
static const String _androidInterstitialAdUnitId = 'ca-app-pub-XXXXXXX/XXXXXXXX';
static const String _androidRewardedAdUnitId = 'ca-app-pub-XXXXXXX/XXXXXXXX';

// iOS Ad Units
static const String _iosBannerAdUnitId = 'ca-app-pub-XXXXXXX/XXXXXXXX';
static const String _iosInterstitialAdUnitId = 'ca-app-pub-XXXXXXX/XXXXXXXX';
static const String _iosRewardedAdUnitId = 'ca-app-pub-XXXXXXX/XXXXXXXX';

// Ad unit getters
static String get bannerAdUnitId {
  if (kDebugMode) {
    return _testBannerAdUnitId;
  } else {
    return Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId;
  }
}
```

#### Step 3: Rebuild After Updating
```bash
flutter clean
flutter pub get
flutter build apk --release
flutter build appbundle --release
flutter build ios --release --no-codesign
```

### AdMob Testing Checklist
- [ ] Get real ad unit IDs from AdMob console
- [ ] Update `lib/core/services/admob_service.dart` with real IDs
- [ ] Test ads in debug mode (uses test ads automatically)
- [ ] Rebuild apps with updated ad units
- [ ] Verify ads load in production build

---

## 📱 iOS App Store Submission

### Prerequisites
- [x] Apple Developer Account ($99/year)
- [x] App built successfully
- [x] Demo account credentials ready
- [x] Screenshots prepared
- [ ] App signed with distribution certificate

### Steps

#### 1. Open Project in Xcode
```bash
open ios/Runner.xcworkspace
```

#### 2. Configure Signing
- Select Runner target
- Go to Signing & Capabilities
- Select your Team
- Ensure "Automatically manage signing" is checked

#### 3. Archive the App
- Product → Archive
- Wait for archive to complete
- Window → Organizer will open automatically

#### 4. Upload to App Store Connect
- Click "Distribute App"
- Select "App Store Connect"
- Click "Upload"
- Wait for processing (10-30 minutes)

#### 5. Complete App Store Connect Listing
- Go to https://appstoreconnect.apple.com
- Fill in app information
- Upload screenshots
- Set pricing (Free)
- **Update demo account**:
  - Email: `demo@flowai.app`
  - Password: `FlowAiDemo2024!`

#### 6. Submit for Review
- Click "Submit for Review"
- Answer questions about encryption (No)
- Submit

---

## 🤖 Google Play Store Submission

### Prerequisites
- [x] Google Play Developer Account ($25 one-time)
- [x] App Bundle built successfully
- [x] Screenshots prepared
- [ ] App signed (automatic with `--release` flag)

### Steps

#### 1. Create App in Play Console
- Go to https://play.google.com/console
- Click "Create app"
- Fill in app details:
  - Name: Flow Ai
  - Default language: English (US)
  - App or game: App
  - Free or paid: Free

#### 2. Upload App Bundle
- Go to Production → Create new release
- Upload: `build/app/outputs/bundle/release/app-release.aab`
- Set release name: `2.1.1 (8)`
- Add release notes

#### 3. Complete Store Listing
- **App name**: Flow Ai
- **Short description**: AI-Powered Menstrual Health Tracking
- **Full description**: (See APP_STORE_DESCRIPTION.md)
- **Category**: Health & Fitness
- **Content rating**: Everyone
- **Privacy policy**: Required (URL needed)

#### 4. Upload Assets
- **Icon**: 512x512px (already generated)
- **Feature graphic**: 1024x500px
- **Screenshots**: At least 2 for phone, 1 for tablet

#### 5. Set Up Pricing & Distribution
- Free
- Available countries: All countries
- Target audience: 13+

#### 6. Submit for Review
- Review all sections have green checkmarks
- Click "Submit for review"

---

## 🔐 Demo Account Information

### For App Store & Play Store Reviewers

**Credentials:**
- Email: `demo@flowai.app`
- Password: `FlowAiDemo2024!`

**Features to Review:**
- Sign in with demo account (auto-created on first launch)
- View cycle tracking dashboard
- Log symptoms and mood
- View AI-powered insights
- Track daily feelings
- Set notifications

**Alternative:**
- Tap "Sign Up" to create a test account
- Use any email address (no verification required for demo)
- Password must be at least 8 characters

---

## 📊 Build Artifacts Location

```
Flow-Ai/
├── build/
│   ├── ios/
│   │   └── iphoneos/
│   │       └── Runner.app          # iOS Release Build (40.0MB)
│   └── app/
│       └── outputs/
│           ├── flutter-apk/
│           │   └── app-release.apk # Android APK (95.3MB)
│           └── bundle/
│               └── release/
│                   └── app-release.aab # Android App Bundle (65.5MB)
```

---

## ✅ Pre-Submission Checklist

### Both Platforms
- [x] App builds successfully
- [x] Version incremented to 2.1.1+8
- [x] Demo account working
- [x] App icons generated
- [ ] AdMob ad units updated with real IDs
- [ ] Privacy policy URL ready
- [ ] Screenshots prepared (5-8 per platform)
- [ ] App descriptions written

### iOS Specific
- [ ] Apple Developer account active
- [ ] Distribution certificate configured
- [ ] App signed and archived
- [ ] TestFlight testing completed (optional)

### Android Specific
- [ ] Google Play Developer account active
- [ ] App bundle uploaded
- [ ] Content rating completed
- [ ] Target API level 34 (Android 14) met

---

## 🚀 Quick Commands Reference

### Rebuild Everything
```bash
flutter clean
flutter pub get
flutter build ios --release --no-codesign
flutter build apk --release
flutter build appbundle --release
```

### Test on Devices
```bash
# iOS Simulator
flutter run -d [ios-simulator-id]

# Android Emulator  
flutter run -d [android-emulator-id]

# Chrome (Web)
flutter run -d chrome
```

### Version Bump
Edit `pubspec.yaml`:
```yaml
version: 2.1.2+9  # Increment for next update
```

---

## 📝 Important Notes

### AdMob Requirements
- **Test ads during development** - App automatically uses test IDs in debug mode
- **Real ads in production** - Must update ad unit IDs before publishing
- **AdMob policies** - Review https://support.google.com/admob/answer/6128543

### App Store Review Times
- iOS: 24-48 hours typically
- Android: Few hours to 7 days

### Post-Publishing
1. Monitor crash reports
2. Respond to user reviews
3. Plan updates based on feedback
4. Enable Firebase after approval for production analytics

---

## 🆘 Troubleshooting

### iOS Build Fails
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios --release --no-codesign
```

### Android Build Fails
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter build appbundle --release
```

### AdMob Not Showing Ads
- Check ad unit IDs are correct
- Verify AdMob app IDs in manifest files
- Test with debug mode first (uses test ads)
- Real ads may take hours to appear after first install

---

## 📞 Support Resources

- **Flutter Docs**: https://docs.flutter.dev
- **App Store Connect**: https://appstoreconnect.apple.com
- **Google Play Console**: https://play.google.com/console
- **AdMob Help**: https://support.google.com/admob
- **Firebase Console**: https://console.firebase.google.com/project/flow-ai-656b3

---

**Build Date**: October 22, 2025  
**Version**: 2.1.1+8  
**Status**: Ready for App Store & Play Store Submission
