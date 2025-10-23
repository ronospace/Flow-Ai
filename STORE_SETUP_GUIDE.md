# Flow Ai - Store Setup Guide

## Step 1: TestFlight/Play Store Testing Setup

### Prerequisites Checklist

Before building for stores, verify:

- [ ] Apple Developer Account ($99/year) - [developer.apple.com](https://developer.apple.com)
- [ ] Google Play Developer Account ($25 one-time) - [play.google.com/console](https://play.google.com/console)
- [ ] Xcode installed (for iOS builds)
- [ ] Android Studio SDK installed
- [ ] Valid code signing certificates

---

## Part A: iOS TestFlight Setup

### 1. Prepare iOS Build

#### Update Version Info
```bash
# Check current version
grep version pubspec.yaml

# Update if needed (format: version: 1.0.0+1)
# version: major.minor.patch+buildNumber
```

#### Build iOS Release
```bash
# Clean previous builds
flutter clean
flutter pub get

# Build iOS release (requires macOS)
flutter build ios --release

# Or build IPA directly for App Store
flutter build ipa --release
```

**Build Location**: `build/ios/ipa/flow_ai.ipa`

### 2. Configure App Store Connect

#### Create App Record
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Click **Apps** → **+** → **New App**
3. Fill in:
   - **Platform**: iOS
   - **Name**: Flow Ai
   - **Primary Language**: English (US)
   - **Bundle ID**: Select your registered bundle ID
   - **SKU**: flowai_ios_001
   - **User Access**: Full Access

#### Set Up TestFlight
1. Click on your app → **TestFlight** tab
2. **Internal Testing**:
   - Create group: "Flow Ai Team"
   - Add internal testers (up to 100)
   - No review required
3. **External Testing** (optional for now):
   - Create group: "Beta Testers"
   - Requires App Review (1-2 days)

### 3. Upload Build to TestFlight

#### Option A: Using Xcode (Recommended)
```bash
# Open in Xcode
open ios/Runner.xcworkspace

# Then in Xcode:
# 1. Product → Archive
# 2. Window → Organizer
# 3. Select archive → Distribute App
# 4. App Store Connect → Upload
# 5. Follow prompts
```

#### Option B: Using Transporter App
1. Download [Transporter](https://apps.apple.com/app/transporter/id1450874784)
2. Drag `flow_ai.ipa` into Transporter
3. Click **Deliver**
4. Wait for processing (10-30 minutes)

### 4. Enable TestFlight Testing
1. Go to App Store Connect → TestFlight
2. Click on the build (once processing completes)
3. **Test Information**:
   - What to Test: "Initial beta build - testing core features"
   - Beta App Description: "AI-powered period and cycle tracking"
4. Add testers to Internal Testing group
5. Click **Start Testing**

Testers will receive email invite with TestFlight link.

---

## Part B: Google Play Console Setup

### 1. Prepare Android Build

#### Update Version Info
Already set in `pubspec.yaml` (shared with iOS)

#### Build Android Release

```bash
# Clean previous builds
flutter clean
flutter pub get

# Build Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# Or build APK for direct distribution
flutter build apk --release
```

**Build Locations**:
- App Bundle: `build/app/outputs/bundle/release/app-release.aab`
- APK: `build/app/outputs/flutter-apk/app-release.apk`

### 2. Sign Android Release

#### Check if Signing is Configured

Look for `android/key.properties`:
```properties
storePassword=<your-keystore-password>
keyPassword=<your-key-password>
keyAlias=upload
storeFile=<path-to-keystore.jks>
```

#### If Not Configured, Create Keystore:

```bash
# Generate release keystore
keytool -genkey -v -keystore ~/flow-ai-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload

# Follow prompts to set passwords
```

#### Create key.properties:
```bash
# Create file
cat > android/key.properties << EOF
storePassword=YOUR_STORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=upload
storeFile=/Users/$USER/flow-ai-release.jks
EOF
```

#### Update android/app/build.gradle:
Verify these lines exist:
```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

### 3. Create App in Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Click **Create app**
3. Fill in:
   - **App name**: Flow Ai
   - **Default language**: English (United States)
   - **App or game**: App
   - **Free or paid**: Free
4. Complete declarations:
   - Privacy Policy: (URL required - create one)
   - App access: All functionality available without restrictions
   - Ads: No (unless using ads)
   - Content rating: Fill questionnaire
   - Target audience: 13+ (or appropriate age)
   - Data safety: Complete data collection form

### 4. Upload to Internal Testing

1. **Create Internal Testing Release**:
   - Go to **Testing** → **Internal testing**
   - Click **Create new release**
   - Upload `app-release.aab`
   - Release name: `1.0.0 (1)` - Beta
   - Release notes:
     ```
     Initial beta release
     - Core cycle tracking
     - AI predictions
     - Health insights
     - Premium features
     ```

2. **Add Testers**:
   - Create email list (up to 100 internal testers)
   - Share testing link with team

3. **Review & Roll Out**:
   - Click **Review release**
   - Click **Start rollout to Internal testing**

### 5. Get Testing Link

After rollout:
1. Go to **Internal testing** → **Testers** tab
2. Copy **Copy link** under "How testers join your test"
3. Share with testers

Testers:
1. Click link on Android device
2. Accept invitation
3. Download app from Play Store

---

## Part C: Pre-Submission Checklist

### iOS App Store Connect

- [ ] App icon set (1024x1024px)
- [ ] Screenshots ready (all required sizes)
- [ ] App description written
- [ ] Keywords selected
- [ ] Support URL set
- [ ] Marketing URL (optional)
- [ ] Privacy policy URL
- [ ] App category selected
- [ ] Content rating completed
- [ ] Pricing and availability set
- [ ] Build uploaded and processed

### Google Play Console

- [ ] App icon set (512x512px)
- [ ] Feature graphic (1024x500px)
- [ ] Screenshots ready (phone + tablet)
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] Privacy policy URL
- [ ] App category selected
- [ ] Content rating completed
- [ ] Pricing and distribution set
- [ ] Release uploaded

---

## Troubleshooting

### iOS Build Issues

**"Signing requires a development team"**
```bash
# Open Xcode
open ios/Runner.xcworkspace

# In Xcode:
# 1. Select Runner in project navigator
# 2. Select "Signing & Capabilities"
# 3. Select your team
# 4. Check "Automatically manage signing"
```

**"Build failed - provisioning profile"**
- Log in to developer.apple.com
- Go to Certificates, Identifiers & Profiles
- Create new provisioning profile for App Store distribution

**"Archive not showing in Organizer"**
- Product → Clean Build Folder
- Ensure scheme is set to "Release"
- Archive again

### Android Build Issues

**"Signing key not found"**
- Verify `key.properties` exists
- Check keystore file path is correct
- Ensure passwords match

**"Gradle build failed"**
```bash
# Try cleaning gradle cache
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build appbundle --release
```

**"AAPT error"**
- Check `android/app/src/main/AndroidManifest.xml`
- Ensure all required permissions are declared
- Verify app icon exists in all density folders

---

## Next Steps After TestFlight/Internal Testing

1. **Gather Feedback** (1-2 days minimum)
   - Test all core features
   - Verify crashes are minimal
   - Collect tester feedback

2. **Fix Critical Issues** (if any)
   - Update version number
   - Build new release
   - Upload updated build

3. **Prepare for Production** (see PREMIUM_DEPLOYMENT_GUIDE.md)
   - Configure subscription products
   - Set up receipt validation
   - Complete store listings

4. **Submit for Review**
   - iOS: App Store review (1-3 days)
   - Android: Play Store review (1-7 days)

---

## Quick Commands Reference

```bash
# iOS Release Build
flutter clean && flutter pub get
flutter build ipa --release

# Android Release Build
flutter clean && flutter pub get
flutter build appbundle --release

# Check build versions
grep version pubspec.yaml

# View generated files
ls build/ios/ipa/
ls build/app/outputs/bundle/release/

# Sign APK manually (if needed)
jarsigner -verbose -sigalg SHA256withRSA -digestalg SHA-256 \
  -keystore ~/flow-ai-release.jks \
  app-release-unsigned.apk upload
```

---

## Support Resources

### iOS
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [TestFlight Guide](https://developer.apple.com/testflight/)
- [iOS Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/ios)

### Android
- [Play Console Help](https://support.google.com/googleplay/android-developer/)
- [Internal Testing Guide](https://support.google.com/googleplay/android-developer/answer/9845334)
- [Material Design Guidelines](https://material.io/design)

---

**Status**: Ready for testing setup ✅  
**Next**: Configure subscription products after successful test builds
