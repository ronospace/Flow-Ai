# App Store Submission Checklist
**Date**: December 2025  
**Version**: 2.1.5 (Build 16)  
**App**: Flow Ai

---

## ✅ Pre-Submission Verification

### 1. Compliance Requirements

#### Guideline 2.5.1 - HealthKit Transparency ✅
- [x] HealthKit disclosure banner implemented (`HealthKitDisclosureBannerPermanent`)
- [x] HealthKit disclosure visible on Health screen
- [x] HealthKit disclosure visible on Biometric Dashboard
- [x] HealthKit disclosure accessible in Settings
- [x] HealthKit permission dialog includes disclosure
- [x] HealthKit usage descriptions in Info.plist:
  - `NSHealthShareUsageDescription`: ✅ Present
  - `NSHealthUpdateUsageDescription`: ✅ Present
- [x] HealthKit entitlements configured in `Runner.entitlements`

#### Guideline 1.4.1 - Medical Citations ✅
- [x] Medical Citations Section implemented in Settings
- [x] Medical disclaimer banner on all medical screens
- [x] Medical citations footer on relevant screens
- [x] Citations visible in AI chat responses
- [x] Citations database populated with medical sources
- [x] Easy access to citations from Settings menu

### 2. Privacy Descriptions (Info.plist)

All required privacy usage descriptions are present and accurate:

- [x] **NSFaceIDUsageDescription**: Face ID authentication for health data
- [x] **NSLocalNetworkUsageDescription**: Local network sync
- [x] **NSCameraUsageDescription**: Camera for health documents/QR codes
- [x] **NSPhotoLibraryUsageDescription**: Photo library for health documentation
- [x] **NSCalendarsUsageDescription**: Calendar integration for reminders
- [x] **NSHealthShareUsageDescription**: Read health data for predictions
- [x] **NSHealthUpdateUsageDescription**: Write health data
- [x] **NSContactsUsageDescription**: Share reports with providers
- [x] **NSLocationWhenInUseUsageDescription**: Location for insights
- [x] **NSLocationAlwaysAndWhenInUseUsageDescription**: Location services

### 3. App Configuration

- [x] **Bundle ID**: `com.flowai.health`
- [x] **Display Name**: Flow Ai
- [x] **Version**: 2.1.5
- [x] **Build Number**: 16
- [x] **Minimum iOS**: 16.0 (Info.plist) / 15.0 (Xcode project)
- [x] **App Category**: Medical (`public.app-category.medical`)
- [x] **Development Team**: 9FY62NTL53
- [x] **Bitcode**: Disabled
- [x] **App Transport Security**: Enabled (no arbitrary loads)

### 4. Capabilities & Entitlements

- [x] **HealthKit**: Enabled in entitlements
- [x] **Sign in with Apple**: Enabled
- [x] **Push Notifications**: Configured (Firebase)
- [x] **Background Modes**: Configured if needed

### 5. Build Verification

- [x] Code compiles without errors
- [x] Static analysis passes (warnings only, no errors)
- [x] App runs on simulator (iPhone 16 Pro)
- [x] All features functional
- [x] HealthKit disclosures visible
- [x] Medical citations accessible

---

## 📋 App Store Connect Preparation

### Metadata Required

#### App Information
- [x] App Name: Flow Ai
- [x] Subtitle: AI-Powered Menstrual Health
- [x] Primary Language: English
- [ ] Privacy Policy URL: https://ubiquitous-dieffenbachia-b852fc.netlify.app/
- [ ] Support URL: (to be configured)
- [ ] Marketing URL: (optional)

#### Description
```
Flow Ai is an advanced AI-powered menstrual health platform designed to help you understand and track your cycle with precision. Using cutting-edge machine learning, Flow Ai provides personalized cycle predictions, intelligent health insights, and comprehensive analytics.

Key Features:
• AI-Powered Cycle Predictions
• Comprehensive Health Analytics
• Partner Sharing & Care Actions
• Medical-Grade Privacy & Security
• Evidence-Based Health Insights
```

#### Keywords
period tracker, menstrual cycle, women health, AI health, cycle prediction, fertility tracking, PCOS, hormone tracking, period calendar, ovulation tracker

#### Screenshots Required
- iPhone 6.7" (iPhone 16 Pro Max):
  1. Home Dashboard
  2. Calendar View
  3. AI Predictions
  4. Health Analytics
  5. Settings & Privacy

#### App Review Information
- [ ] Demo Account Credentials (if required)
- [ ] Notes for Reviewer:
  - HealthKit integration is optional and clearly disclosed
  - Medical information includes citations accessible in Settings
  - All privacy permissions are clearly explained

---

## 🚀 Build & Submission Steps

### Step 1: Clean Build
```bash
flutter clean
flutter pub get
cd ios && pod install && cd ..
```

### Step 2: Verify Configuration
- [ ] Check version number in `pubspec.yaml`
- [ ] Verify bundle identifier
- [ ] Confirm signing certificate is valid
- [ ] Verify all privacy descriptions

### Step 3: Build Release IPA
```bash
flutter build ipa \
    --release \
    --export-options-plist=ios/ExportOptionsAppStore.plist \
    --build-number=16 \
    --build-name=2.1.5
```

**OR** use the build script:
```bash
./build_appstore.sh
```

### Step 4: Archive in Xcode (Recommended)
1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device" as target
3. Product > Archive
4. Wait for archive to complete
5. Click "Distribute App"
6. Select "App Store Connect"
7. Follow the distribution wizard

### Step 5: Submit for Review
1. Go to App Store Connect
2. Select your app
3. Create new version (2.1.5)
4. Upload build from Xcode Organizer
5. Complete all metadata
6. Add screenshots
7. Answer review questions
8. Submit for review

---

## ⚠️ Critical Items to Verify Before Submission

### Compliance
- [ ] HealthKit disclosure banners visible and non-dismissible
- [ ] Medical citations section accessible from Settings
- [ ] All medical screens show disclaimer banners
- [ ] Privacy policy URL is accessible and accurate

### Functionality
- [ ] App launches without crashes
- [ ] All core features work
- [ ] HealthKit integration works (if enabled)
- [ ] Medical citations load correctly
- [ ] AI chat responses include citations

### Testing
- [ ] Tested on iOS 16.0+
- [ ] Tested on iPhone 16 Pro simulator
- [ ] Tested on physical device (recommended)
- [ ] Verified all permissions request correctly
- [ ] Verified HealthKit disclosure flow

---

## 📝 Post-Submission

### What to Monitor
- App Review status in App Store Connect
- Any reviewer questions or requests
- Rejection reasons (if any)

### Common Rejection Reasons (Already Addressed)
1. ✅ **Guideline 2.5.1**: HealthKit disclosure - FIXED
2. ✅ **Guideline 1.4.1**: Medical citations - FIXED
3. ⚠️ **Guideline 4.0**: Design issues - Review UI/UX
4. ⚠️ **Guideline 5.1.1**: Privacy policy - Verify URL works

---

## 🔗 Important Files

- Build Script: `build_appstore.sh`
- Export Options: `ios/ExportOptionsAppStore.plist`
- Entitlements: `ios/Runner/Runner.entitlements`
- Info.plist: `ios/Runner/Info.plist`
- HealthKit Disclosure: `lib/features/health/widgets/healthkit_disclosure_banner_permanent.dart`
- Medical Citations: `lib/features/settings/widgets/medical_citations_section.dart`
- Medical Disclaimer: `lib/core/widgets/medical_disclaimer_banner.dart`

---

**Last Updated**: December 2025  
**Status**: ✅ Ready for Submission
