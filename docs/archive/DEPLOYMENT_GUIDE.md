# FlowSense Deployment Guide 🚀

## Quick Deployment Options

### 1. 📱 iOS App Store Deployment

#### Prerequisites
- Apple Developer Account ($99/year)
- Xcode with valid certificates
- App Store Connect setup

#### Build for iOS
```bash
# Build iOS release
flutter build ios --release

# Or build archive for App Store
flutter build ipa
```

#### Deploy Steps
1. Open `ios/Runner.xcworkspace` in Xcode
2. Set up signing certificates
3. Archive and upload to App Store Connect
4. Submit for review

---

### 2. 🤖 Google Play Store Deployment

#### Prerequisites
- Google Play Console account ($25 one-time)
- Android signing key

#### Build for Android
```bash
# Build Android APK
flutter build apk --release

# Or build App Bundle (recommended)
flutter build appbundle --release
```

#### Deploy Steps
1. Upload to Google Play Console
2. Set up store listing
3. Submit for review

---

### 3. 🌐 Web Deployment

#### Build for Web
```bash
# Build web app
flutter build web --release
```

#### Deploy Options
- **Firebase Hosting** (Recommended)
- **Netlify**
- **Vercel**
- **GitHub Pages**

---

### 4. 🖥️ Desktop Deployment

#### macOS
```bash
flutter build macos --release
```

#### Windows
```bash
flutter build windows --release
```

#### Linux
```bash
flutter build linux --release
```

---

## Detailed Deployment Instructions

### iOS App Store Deployment

#### Step 1: Configure iOS Project
1. **Bundle Identifier**: Set unique bundle ID in `ios/Runner/Info.plist`
2. **App Name**: Configure display name
3. **Icons**: Add app icons to `ios/Runner/Assets.xcassets`
4. **Signing**: Set up development team and certificates

#### Step 2: Build and Archive
```bash
# Clean previous builds
flutter clean
flutter pub get

# Generate localization files
flutter gen-l10n

# Build for iOS
flutter build ios --release --no-codesign

# Open in Xcode for signing and archiving
open ios/Runner.xcworkspace
```

#### Step 3: App Store Connect
1. Create new app in App Store Connect
2. Fill out app information
3. Add screenshots and descriptions
4. Set pricing and availability
5. Submit for review

---

### Google Play Store Deployment

#### Step 1: Generate Signing Key
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

#### Step 2: Configure Android Signing
Create `android/key.properties`:
```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path-to-upload-keystore.jks>
```

Update `android/app/build.gradle`:
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

#### Step 3: Build and Deploy
```bash
# Build App Bundle (recommended)
flutter build appbundle --release

# Build APK (alternative)
flutter build apk --release --split-per-abi
```

---

### Web Deployment with Firebase

#### Step 1: Setup Firebase
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase in project
firebase init hosting
```

#### Step 2: Configure Firebase
Update `firebase.json`:
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ]
  }
}
```

#### Step 3: Build and Deploy
```bash
# Build for web
flutter build web --release

# Deploy to Firebase
firebase deploy
```

---

## Environment-Specific Builds

### Development Build
```bash
# Debug build with hot reload
flutter run --debug
```

### Staging Build
```bash
# Build with staging configuration
flutter build apk --release --flavor staging
flutter build ios --release --flavor staging
```

### Production Build
```bash
# Production release builds
flutter build apk --release --flavor production
flutter build ios --release --flavor production
flutter build web --release --dart-define=ENVIRONMENT=production
```

---

## Build Optimization

### Performance Optimization
```bash
# Build with tree shaking and minification
flutter build apk --release --obfuscate --split-debug-info=build/debug-info

# Web optimization
flutter build web --release --web-renderer canvaskit
```

### Size Optimization
```bash
# Split APKs by ABI
flutter build apk --release --split-per-abi

# Generate App Bundle (smaller size)
flutter build appbundle --release
```

---

## Pre-Deployment Checklist

### ✅ Code Quality
- [ ] Run `flutter analyze` (no errors)
- [ ] Run `flutter test` (all tests pass)
- [ ] Code review completed
- [ ] Performance testing done

### ✅ App Configuration
- [ ] App name and description set
- [ ] App icons added for all platforms
- [ ] Splash screens configured
- [ ] Deep linking configured
- [ ] Push notifications set up (if needed)

### ✅ Store Preparation
- [ ] App store descriptions written
- [ ] Screenshots taken for all devices
- [ ] Privacy policy created
- [ ] Terms of service written
- [ ] App categories selected

### ✅ Legal & Compliance
- [ ] Privacy policy compliant with GDPR/CCPA
- [ ] Health data handling complies with regulations
- [ ] Age rating appropriate
- [ ] Accessibility features implemented

### ✅ Internationalization
- [ ] All 36 languages configured
- [ ] Key languages fully translated
- [ ] Right-to-left layout tested (Arabic, Hebrew)
- [ ] Date/time formats localized

---

## Automated Deployment (CI/CD)

### GitHub Actions Example
Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy FlowSense

on:
  push:
    branches: [ main ]
    tags: [ 'v*' ]

jobs:
  deploy-web:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.32.8'
    
    - run: flutter pub get
    - run: flutter gen-l10n
    - run: flutter build web --release
    
    - name: Deploy to Firebase
      uses: FirebaseExtended/action-hosting-deploy@v0
      with:
        repoToken: '${{ secrets.GITHUB_TOKEN }}'
        firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
        projectId: flowsense-app

  deploy-android:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '11'
    
    - uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.32.8'
    
    - run: flutter pub get
    - run: flutter gen-l10n
    - run: flutter build appbundle --release
    
    - name: Upload to Play Store
      uses: r0adkll/upload-google-play@v1
      with:
        serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
        packageName: com.flowsense.app
        releaseFiles: build/app/outputs/bundle/release/app-release.aab
        track: internal
```

---

## Monitoring & Analytics

### Firebase Analytics Setup
```bash
# Add Firebase to project
firebase init analytics
```

### Crashlytics Setup
```bash
# Add crash reporting
firebase init crashlytics
```

### Performance Monitoring
```bash
# Add performance monitoring
firebase init performance
```

---

## Rollback Strategy

### Version Management
```bash
# Tag releases
git tag v1.0.0
git push origin v1.0.0

# Rollback if needed
git checkout v1.0.0
flutter build appbundle --release
```

### Store Rollback
- **Google Play**: Use staged rollout, can halt at any percentage
- **App Store**: Can remove app from sale or release previous version

---

## Post-Deployment

### Monitor Key Metrics
- App downloads and installs
- Crash reports and stability
- User reviews and ratings
- Performance metrics
- Internationalization coverage

### Update Strategy
- Regular security updates
- Feature releases based on user feedback
- Internationalization improvements
- Performance optimizations

---

## Quick Deploy Commands

Choose your target platform:

```bash
# iOS App Store
./scripts/deploy-ios.sh

# Google Play Store  
./scripts/deploy-android.sh

# Web (Firebase)
./scripts/deploy-web.sh

# All platforms
./scripts/deploy-all.sh
```

---

**🚀 FlowSense is ready for global deployment across all platforms with comprehensive internationalization support!**
