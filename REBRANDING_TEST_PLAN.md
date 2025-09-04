# Flow Ai Rebranding - Comprehensive Test Plan

## Overview
This test plan ensures all rebranding changes from ZyraFlow to Flow Ai are working correctly across all platforms and environments.

## 🧪 Test Categories

### 1. Configuration & Build Tests
### 2. Firebase Integration Tests
### 3. Platform-Specific Tests
### 4. UI/UX Branding Tests
### 5. Domain & Deployment Tests
### 6. Performance & Functionality Tests

---

## 🔧 1. Configuration & Build Tests

### 1.1 Flutter Build Tests
```bash
# Test all platform builds
flutter clean
flutter pub get

# Test iOS build
flutter build ios --debug
flutter build ios --release

# Test Android build
flutter build apk --debug
flutter build apk --release
flutter build appbundle --release

# Test macOS build
flutter build macos --debug
flutter build macos --release

# Test Web build
flutter build web --debug
flutter build web --release
```

**Validation Checklist:**
- [ ] All builds complete without errors
- [ ] No references to old "ZyraFlow" branding in build output
- [ ] Correct bundle identifiers in build artifacts
- [ ] Proper app names in built applications

### 1.2 Bundle Identifier Validation

#### iOS Bundle ID Test
```bash
# Check iOS build for correct bundle ID
unzip -l build/ios/Release-iphoneos/Runner.app/Info.plist
plutil -p build/ios/Release-iphoneos/Runner.app/Info.plist | grep -i bundle
```
**Expected:** `com.flowai.health`

#### Android Package Name Test
```bash
# Check Android APK for correct package name
aapt dump badging build/app/outputs/flutter-apk/app-release.apk | grep package
```
**Expected:** `package: name='com.flowai.health'`

#### macOS Bundle ID Test
```bash
# Check macOS bundle ID
defaults read build/macos/Build/Products/Release/Flow\ AI.app/Contents/Info CFBundleIdentifier
```
**Expected:** `com.flowai.app`

### 1.3 Configuration Files Test

#### Firebase Configuration
```bash
# Validate Firebase configuration files
cat .firebaserc | grep -i project
cat firebase.json | grep -i project
cat android/app/google-services.json | grep -i project
cat ios/Runner/GoogleService-Info.plist | grep -i project
cat macos/Runner/GoogleService-Info.plist | grep -i project
```

**Expected Values:**
- Project ID: `flowai-production`
- Storage bucket: `flowai-production.firebasestorage.app`
- Database URL: `https://flowai-production-default-rtdb.firebaseio.com`

---

## 🔥 2. Firebase Integration Tests

### 2.1 Firebase Connection Test
Create test script `test_firebase_connection.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> testFirebaseConnection() async {
  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    print('✅ Firebase initialized successfully');
    
    // Test Firestore connection
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('test').doc('connection').set({
      'timestamp': DateTime.now(),
      'test': 'Flow Ai connection test'
    });
    print('✅ Firestore connection successful');
    
    // Test Authentication
    final auth = FirebaseAuth.instance;
    print('✅ Firebase Auth initialized: ${auth.app.name}');
    
    // Verify project details
    print('📊 Firebase Project: ${Firebase.app().options.projectId}');
    print('📊 Storage Bucket: ${Firebase.app().options.storageBucket}');
    
  } catch (e) {
    print('❌ Firebase connection failed: $e');
  }
}
```

**Validation:**
- [ ] Firebase initializes without errors
- [ ] Correct project ID displayed
- [ ] Firestore read/write operations work
- [ ] Authentication service accessible

### 2.2 Firebase Hosting Test
```bash
# Deploy to Firebase Hosting
firebase deploy --only hosting

# Test deployed application
curl -I https://flowai-production.web.app
curl -I https://flowai.app  # If custom domain configured
```

**Validation:**
- [ ] Deployment successful
- [ ] App accessible at flowai-production.web.app
- [ ] Custom domain working (if configured)
- [ ] SSL certificate valid

---

## 📱 3. Platform-Specific Tests

### 3.1 iOS Tests

#### Icon Tests
```bash
# Test iOS icon generation
./generate_ios_icons.sh

# Verify icons in Xcode
open ios/Runner.xcworkspace
```

**Manual Tests:**
- [ ] App displays with correct Flow Ai icon in iOS Simulator
- [ ] Icon appears correctly in different sizes (Settings, Spotlight, Home screen)
- [ ] Icon works on both light and dark backgrounds
- [ ] App name displays as "Flow Ai" in iOS

#### Info.plist Validation
```bash
# Check iOS Info.plist for correct branding
cat ios/Runner/Info.plist | grep -A1 "CFBundleDisplayName"
cat ios/Runner/Info.plist | grep -A1 "CFBundleName"
```

**Expected:**
- Display Name: "Flow Ai"
- Bundle Name: "Flow AI"

### 3.2 Android Tests

#### Icon Tests
```bash
# Test Android icon generation
./generate_android_icons.sh

# Check generated icons
ls -la android/app/src/main/res/mipmap-*/
```

**Manual Tests:**
- [ ] App displays with correct Flow Ai icon in Android Emulator
- [ ] Icon appears correctly across different DPI densities
- [ ] App name displays as "Flow Ai" in Android launcher
- [ ] Deep links work with flowai.app domain

#### Manifest Validation
```bash
# Check Android manifest for correct branding
cat android/app/src/main/AndroidManifest.xml | grep -i "android:label"
cat android/app/src/main/AndroidManifest.xml | grep -i "flowai"
```

### 3.3 macOS Tests

#### Icon Tests
```bash
# Test macOS icon generation and build
./generate_macos_icons.sh
flutter build macos --release

# Check app in Finder
open build/macos/Build/Products/Release/
```

**Manual Tests:**
- [ ] App displays with correct Flow Ai icon in Finder
- [ ] Icon appears correctly in Dock
- [ ] App name displays as "Flow AI" in macOS
- [ ] Menu bar shows correct app name

### 3.4 Web Tests

#### Web Manifest Test
```bash
# Check web manifest
cat web/manifest.json
```

**Browser Tests:**
- [ ] Favicon displays correctly in browser tab
- [ ] PWA install prompt shows "Flow Ai"
- [ ] Web app icon correct when installed
- [ ] Meta tags show correct branding

---

## 🎨 4. UI/UX Branding Tests

### 4.1 Visual Branding Test
Run the app and manually verify:

- [ ] App name displays as "Flow Ai" in title bars
- [ ] Loading screens show Flow Ai branding
- [ ] About page shows correct app name
- [ ] Settings page displays correct app information
- [ ] Authentication screens show Flow Ai branding
- [ ] Error messages refer to Flow Ai (not ZyraFlow)

### 4.2 Text Content Audit
```bash
# Search for any remaining ZyraFlow references
grep -r "ZyraFlow" lib/ --include="*.dart"
grep -r "zyraflow" lib/ --include="*.dart"
grep -r "ZyraFlow" assets/ --include="*.json"
```

**Expected:** No results found

### 4.3 Strings and Localization Test
- [ ] All user-visible strings use "Flow Ai"
- [ ] Localization files updated correctly
- [ ] No hardcoded "ZyraFlow" references in UI

---

## 🌐 5. Domain & Deployment Tests

### 5.1 Domain Configuration Test
```bash
# Test domain resolution
dig flowai.app
nslookup flowai.app

# Test SSL certificate
openssl s_client -connect flowai.app:443 -servername flowai.app
```

### 5.2 Deep Links Test

#### iOS Deep Links
```bash
# Test iOS deep links
xcrun simctl openurl booted "https://flowai.app/test"
```

#### Android Deep Links
```bash
# Test Android deep links
adb shell am start -W -a android.intent.action.VIEW -d "https://flowai.app/test" com.flowai.health
```

**Validation:**
- [ ] Deep links open the correct app
- [ ] URLs with flowai.app domain work correctly
- [ ] Universal links configured properly

### 5.3 CI/CD Pipeline Test
```bash
# Test GitHub Actions workflow
git add .
git commit -m "Test Flow Ai rebranding"
git push origin main
```

**Validation:**
- [ ] GitHub Actions workflows run successfully
- [ ] Deployment to flowai-production project works
- [ ] No build errors related to rebranding

---

## ⚡ 6. Performance & Functionality Tests

### 6.1 App Functionality Test
Manual testing of core features:

- [ ] User registration/login works
- [ ] Data sync to Firebase successful
- [ ] Push notifications work correctly
- [ ] Biometric authentication functions
- [ ] Data export/import features work
- [ ] All main app features functional

### 6.2 Performance Baseline Test
```bash
# Run performance tests
flutter test test/performance/
flutter drive --target=test_driver/app.dart
```

### 6.3 Analytics Test
- [ ] Firebase Analytics tracking correctly
- [ ] Custom events fire properly
- [ ] Crash reporting works
- [ ] Performance monitoring active

---

## 🧪 7. Automated Test Execution

### 7.1 Unit Tests
```bash
# Run all unit tests
flutter test

# Run with coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 7.2 Integration Tests
```bash
# Run integration tests
flutter drive --target=test_driver/app.dart
```

### 7.3 Widget Tests
```bash
# Run specific widget tests for branding
flutter test test/widgets/branding_test.dart
```

---

## 📊 8. Test Results Documentation

### Test Execution Log
Create a test execution log documenting:

```markdown
# Flow Ai Rebranding Test Execution Log

## Test Environment
- Flutter Version: [VERSION]
- Test Date: [DATE]
- Tester: [NAME]

## Test Results Summary
- Total Tests: [COUNT]
- Passed: [COUNT]
- Failed: [COUNT]
- Skipped: [COUNT]

## Failed Tests
[List any failed tests with details]

## Notes
[Any additional notes or observations]
```

### Performance Baseline
Document performance metrics:
- App launch time
- Firebase connection time
- Build times
- Bundle sizes

---

## 🚨 9. Rollback Plan

If critical issues are found:

### Immediate Rollback Steps
```bash
# 1. Revert configuration files
git checkout HEAD~1 .firebaserc
git checkout HEAD~1 firebase.json
git checkout HEAD~1 android/app/google-services.json
git checkout HEAD~1 ios/Runner/GoogleService-Info.plist
git checkout HEAD~1 macos/Runner/GoogleService-Info.plist

# 2. Redeploy with old configuration
firebase use zyraflow-production
firebase deploy

# 3. Notify team of rollback
echo "Rollback completed. Investigating issues."
```

### Rollback Validation
- [ ] Old Firebase project working
- [ ] Apps connecting to correct backend
- [ ] No user data loss
- [ ] All services operational

---

## ✅ 10. Final Approval Checklist

Before considering rebranding complete:

### Technical Approval
- [ ] All automated tests passing
- [ ] All manual tests completed successfully
- [ ] Performance within acceptable ranges
- [ ] No critical bugs identified

### Business Approval
- [ ] Visual branding approved by stakeholders
- [ ] Legal approval for domain/trademark usage
- [ ] Marketing materials updated
- [ ] Support documentation updated

### Production Readiness
- [ ] Monitoring and alerts configured
- [ ] Support team trained on new branding
- [ ] Rollback procedures documented and tested
- [ ] Communication plan for users ready

---

**🎯 Success Criteria:**
The rebranding is considered successful when:
1. All tests pass without critical issues
2. Apps display consistent Flow Ai branding
3. All Firebase services connect to flowai-production
4. Domain flowai.app is fully functional
5. No degradation in app performance or functionality
6. User experience remains smooth and consistent

**📞 Support Contacts:**
- Technical Issues: [CONTACT]
- Firebase Support: [CONTACT]
- Domain Issues: [CONTACT]
- Emergency Rollback: [CONTACT]
