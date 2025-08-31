# 🔄 REBRANDING GUIDE - ZyraFlow to New Name

## 📋 Overview
This document outlines all files and locations that need to be updated when changing the app name from "ZyraFlow" to a new name and updating logos/icons.

## ✅ BACKUP STATUS
- **✅ Committed to Git:** `26383a1` - WORKING VERSION
- **✅ Backup Branch:** `backup/zyraflow-working-v1.0`  
- **✅ Pushed to GitHub:** All changes backed up
- **✅ APK Status:** Working APKs built and tested

---

## 📱 CORE APP CONFIGURATION

### 1. App Identity Files
```
📄 pubspec.yaml (line 2)
   - name: zyraflow → NEW_NAME

📄 android/app/src/main/AndroidManifest.xml (line 9)
   - android:label="ZyraFlow" → android:label="NEW_NAME"

📄 ios/Runner/Info.plist (line 8)
   - <string>ZyraFlow</string> → <string>NEW_NAME</string>

📄 web/manifest.json (lines 2,3,8)
   - "name": "ZyraFlow"
   - "short_name": "ZyraFlow"
   - Multiple references to update
```

### 2. Main Application Files  
```
📄 lib/main.dart (lines 33,154,155,158,161,207)
   - App title references
   - Window title configurations
   - Multiple ZyraFlow references

📄 lib/core/widgets/zyraflow_logo.dart
   - ENTIRE FILE needs renaming and content update
   - Widget class names
   - Asset references

📄 web/index.html (lines 21,26,32)
   - Page title
   - Meta tags
   - Loading text
```

---

## 🎨 LOGOS & ICONS (Complete Replacement Needed)

### A. Vector Graphics (Source Files)
```
📁 assets/icons/
   ├── zyraflow_icon.svg ← REPLACE
   └── zyraflow_quantum_flow/quantum_flow_master.svg ← REPLACE

📁 assets/logos/
   ├── refined_flow_icon.svg ← REPLACE
   ├── zyraflow_lovely_icon.svg ← REPLACE
   └── primary/flowsense_icon_only.svg ← REPLACE

📁 assets/images/
   ├── cycleai_logo.svg ← REPLACE  
   └── cycleai_logo_1024.png ← REPLACE
```

### B. iOS App Icons (Generated from Master)
```
📁 ios/Runner/Assets.xcassets/AppIcon.appiconset/
   ├── Icon-App-1024x1024@1x.png ← REGENERATE
   ├── Icon-App-20x20@1x.png ← REGENERATE
   ├── Icon-App-20x20@2x.png ← REGENERATE
   ├── Icon-App-20x20@3x.png ← REGENERATE
   ├── Icon-App-29x29@1x.png ← REGENERATE
   ├── Icon-App-29x29@2x.png ← REGENERATE
   ├── Icon-App-29x29@3x.png ← REGENERATE
   ├── Icon-App-40x40@1x.png ← REGENERATE
   ├── Icon-App-40x40@2x.png ← REGENERATE
   ├── Icon-App-40x40@3x.png ← REGENERATE
   ├── Icon-App-60x60@2x.png ← REGENERATE
   ├── Icon-App-60x60@3x.png ← REGENERATE
   ├── Icon-App-76x76@1x.png ← REGENERATE
   ├── Icon-App-76x76@2x.png ← REGENERATE
   └── Icon-App-83.5x83.5@2x.png ← REGENERATE

📁 assets/icons/ios/ (Flutter assets)
   ├── icon_1024.png ← REPLACE
   ├── icon_120.png ← REPLACE
   ├── icon_180.png ← REPLACE
   ├── icon_20.png ← REPLACE
   ├── icon_29.png ← REPLACE
   ├── icon_40.png ← REPLACE
   ├── icon_58.png ← REPLACE
   ├── icon_60.png ← REPLACE
   ├── icon_80.png ← REPLACE
   └── icon_87.png ← REPLACE
```

### C. Android App Icons (Need Generation)
```
📁 android/app/src/main/res/
   ├── mipmap-hdpi/launcher_icon.png ← GENERATE
   ├── mipmap-mdpi/launcher_icon.png ← GENERATE
   ├── mipmap-xhdpi/launcher_icon.png ← GENERATE
   ├── mipmap-xxhdpi/launcher_icon.png ← GENERATE
   ├── mipmap-xxxhdpi/launcher_icon.png ← GENERATE
   └── (Various density folders)
```

### D. Root Level Icons (Archive)
```
Root Directory:
├── cycleai_logo_256_updated.png ← REPLACE/REMOVE
├── flowsense_current.png ← REPLACE/REMOVE
├── flowsense_icon_1024.png ← REPLACE/REMOVE
├── flowsense_icon_1024_updated.png ← REPLACE/REMOVE
├── flowsense_icon_128.png ← REPLACE/REMOVE
├── flowsense_icon_256.png ← REPLACE/REMOVE
├── flowsense_icon_32.png ← REPLACE/REMOVE
├── flowsense_icon_512.png ← REPLACE/REMOVE
├── flowsense_icon_64.png ← REPLACE/REMOVE
└── flowsense_icon_aura_1024.png ← REPLACE/REMOVE
```

---

## 🌍 LOCALIZATION FILES

### Localization Files (Key: "appName")
```
📄 lib/l10n/app_en.arb (lines 4,267)
📄 lib/l10n/app_ar.arb 
📄 lib/l10n/app_de.arb
📄 lib/l10n/app_es.arb
📄 lib/l10n/app_fr.arb
📄 lib/l10n/app_hi.arb
📄 lib/l10n/app_it.arb
📄 lib/l10n/app_ja.arb
📄 lib/l10n/app_ko.arb
📄 lib/l10n/app_nl.arb
📄 lib/l10n/app_pt.arb
📄 lib/l10n/app_ru.arb
📄 lib/l10n/app_tr.arb
📄 lib/l10n/app_zh.arb
```

### Generated Localization Files (Auto-regenerated)
```
📁 lib/generated/ 
   ├── app_localizations.dart ← AUTO-UPDATED
   ├── app_localizations_en.dart ← AUTO-UPDATED
   └── (All language variants) ← AUTO-UPDATED
```

---

## 📚 DOCUMENTATION & METADATA

### Documentation Files
```
📄 README.md ← UPDATE
📄 l10n.yaml (line 9)
📄 DEPLOYMENT_SUMMARY.md (lines 1,7,74,146,160,161)
📄 RELEASE_SUMMARY.md (lines 1,4,24,90)
📄 PRE_LAUNCH_CHECKLIST.md (lines 1,6,8,83)
📄 firebase_setup_guide.md (lines 1,12,13,14,101)
📄 ICON_UPDATE_SUMMARY.md (line 8)
📄 docs/ICON_DESIGN.md (lines 1,5,7,80,126)
📄 PRODUCTION_READINESS_REPORT.md (lines 1,239,249,252)
📄 RELEASE_NOTES_v2.0.0.md (lines 1,6,190,201)
📄 design_concepts/zyraflow_icon_concepts.md (lines 1,90,151)
```

### Asset Documentation
```
📄 assets/icons/icon_preview.html (lines 6,165)
📄 assets/design/logo_specification.md ← UPDATE
```

---

## 🛠️ BUILD & DEVELOPMENT FILES

### Scripts
```
📄 scripts/generate_icons.sh (lines 3,6,155)
📄 generate_android_icons.sh ← UPDATE
📄 generate_ios_icons.sh ← UPDATE
📄 create_flowsense_icon.py ← UPDATE/REPLACE
📄 create_logo.py ← UPDATE/REPLACE
```

### Development Configuration
```
📄 .vscode/launch.json (lines 5,12,19)
📄 .github/workflows/firebase-hosting-pull-request.yml (line 4)
📄 .github/workflows/firebase-hosting-merge.yml (line 4)
```

---

## 🧪 TEST FILES

### Integration Tests
```
📄 integration_test/app_test.dart (lines 10,17)
📄 test/flowai_integration_test.dart (line 76)
📄 lib/test_firebase.dart (line 29)
```

---

## 🎯 UI & FEATURE REFERENCES

### Screen References
```
📄 lib/features/onboarding/models/onboarding_step.dart (line 31)
📄 lib/features/onboarding/screens/splash_screen.dart (line 227)
📄 lib/features/onboarding/screens/welcome_step_screen.dart (line 71)
📄 lib/features/onboarding/providers/onboarding_provider.dart (line 146)
📄 lib/features/future_plans/screens/future_plans_screen.dart (lines 112,214,334)
📄 lib/features/settings/screens/settings_screen.dart (lines 370,506,508,517)
📄 lib/features/settings/screens/account_management_screen.dart (line 632)
📄 lib/features/auth/screens/auth_screen.dart (lines 157,158,169)
```

### Service References  
```
📄 lib/core/services/flowai_service.dart (lines 163,209)
📄 lib/core/services/auth_service.dart (line 183)
📄 lib/core/config/flowai_config.dart (line 101)
```

---

## 🔄 REBRANDING PROCESS STEPS

### Phase 1: Text References
1. ✅ **Backup Current Version** (COMPLETED)
2. 🔄 Replace "ZyraFlow" with "NEW_NAME" in all files above
3. 🔄 Update app display names in manifests
4. 🔄 Update localization files

### Phase 2: Visual Assets
1. 🔄 Create new master logo/icon (SVG format recommended)
2. 🔄 Replace all vector assets in `assets/` folders
3. 🔄 Generate new iOS icons using `generate_ios_icons.sh`
4. 🔄 Generate new Android icons using `generate_android_icons.sh`
5. 🔄 Update app icon sets in native folders

### Phase 3: Build & Test
1. 🔄 Run `flutter clean`
2. 🔄 Run `flutter pub get`  
3. 🔄 Generate localizations: `flutter gen-l10n`
4. 🔄 Build and test APK: `flutter build apk --release`
5. 🔄 Test installation on Android device
6. 🔄 Build and test iOS: `flutter build ios`

### Phase 4: Documentation
1. 🔄 Update all documentation files
2. 🔄 Update README.md with new app name
3. 🔄 Update any remaining references

---

## ⚠️ IMPORTANT NOTES

- **Keep Firebase Configuration:** Don't change package names in build.gradle.kts or AndroidManifest.xml package attribute
- **Preserve Working Config:** Current APK installs successfully - maintain same build configuration
- **Test Thoroughly:** After rebranding, test APK installation and core functionality
- **Backup Branch Available:** `backup/zyraflow-working-v1.0` contains the last working ZyraFlow version

---

## 🚀 READY FOR REBRANDING

**Status:** ✅ All files identified and backup completed  
**Next Step:** Provide new app name and logo assets to begin transformation

The current working version is safely backed up. Ready to transform ZyraFlow into the new brand while preserving all functionality!
