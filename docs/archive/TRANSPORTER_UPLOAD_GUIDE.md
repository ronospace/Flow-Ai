# Transporter Upload Guide for Flow Ai
## iOS App Store Submission

**Date:** October 27, 2025  
**Version:** 2.1.1 (Build 10)  
**IPA File:** Flow Ai.ipa (15 MB)

---

## ✅ **IPA Ready for Upload**

### 📦 **File Information**
- **Filename:** `Flow Ai.ipa`
- **Size:** 15 MB
- **Location:** `build/ios/ipa/Flow Ai.ipa`
- **Status:** ✅ **FINDER WINDOW OPENED**

---

## 🚀 **Upload Methods**

### **Method 1: Transporter App (Recommended)**

#### Step 1: Open Transporter
```bash
# If not installed, download from Mac App Store
open -a Transporter
```

Or search for "Transporter" in Spotlight/Launchpad

#### Step 2: Sign In
- Sign in with your Apple Developer account
- Email: ronos.ai@icloud.com (or your Apple ID)

#### Step 3: Upload IPA
1. Click the **"+"** button or drag & drop
2. Select `Flow Ai.ipa` from the opened Finder window
3. Location: `/Users/ronos/Workspace/Projects/Active/ZyraFlow/build/ios/ipa/Flow Ai.ipa`
4. Click **"Deliver"**
5. Wait for upload to complete (may take 5-10 minutes)

#### Step 4: Check Status
- Green checkmark = Success ✅
- Error = Review logs and fix issues

---

### **Method 2: Command Line (Alternative)**

```bash
# Upload using altool (if you prefer terminal)
xcrun altool --upload-app \
  --type ios \
  --file "build/ios/ipa/Flow Ai.ipa" \
  --username "ronos.ai@icloud.com" \
  --password "@keychain:AC_PASSWORD"
```

**Note:** You'll need to set up app-specific password in Keychain

---

### **Method 3: Xcode Organizer (Full Control)**

If you prefer the full Xcode flow:

```bash
# Open Xcode workspace
open ios/Runner.xcworkspace
```

Then:
1. **Product** → **Archive** (will take 2-3 minutes)
2. **Window** → **Organizer**
3. Select the archive
4. Click **"Distribute App"**
5. Choose **"App Store Connect"**
6. Choose **"Upload"**
7. Follow prompts (automatic signing)
8. **Upload** and wait for completion

---

## 📋 **After Upload Success**

### 1. **Go to App Store Connect**
```
https://appstoreconnect.apple.com
```

### 2. **Check Build Processing**
- Go to **My Apps** → **Flow Ai**
- Click **"TestFlight"** tab
- Wait for build to finish processing (10-30 minutes)
- You'll receive email when ready

### 3. **Create App Store Version**
- Go to **App Store** tab
- Click **"+ Version"** or select existing version
- Select the uploaded build
- Fill in all required information:

#### **Required Information:**

**Version Number:** 2.1.1

**What's New in This Version:**
```
Medical Compliance Update:

✅ Added Medical Disclaimers
• Clear notices that this app is for informational purposes only
• Recommendations to consult healthcare professionals
• Not intended for medical diagnosis or treatment

✅ Medical Source Citations
• All health information now cites reputable sources (ACOG, WHO, NIH)
• Clickable links to original medical research
• Transparent AI prediction methodology

✅ Improved AI Transparency
• Confidence scores visible for all predictions
• Contributing factors explained
• User-friendly AI disclaimers

✅ Enhanced Privacy
• On-device AI processing (no cloud data transmission)
• Local data encryption
• User controls for all data

This update ensures compliance with Apple's health app guidelines while maintaining our commitment to accurate, evidence-based menstrual health tracking.
```

**App Review Information:**
```
Demo Account:
Email: demo@flowai.app
Password: REDACTED_DEMO_PW!

This account has pre-populated sample data to demonstrate all features.

Key Features:
- Cycle tracking with AI predictions
- Symptom and mood tracking
- Medical citations from ACOG, WHO, NIH
- Medical disclaimers visible on all health info
- On-device AI (test in airplane mode)

Contact: ronos.ai@icloud.com
```

### 4. **Submit for Review**
- Review all sections
- Click **"Submit for Review"**
- Wait for Apple review (typically 24-48 hours)

---

## ⚠️ **Important Notes**

### **IPA Export Method**
The current IPA was exported with **development** signing. For production App Store upload, you may need to:

1. **Update ExportOptions.plist** to use `app-store` method:
   ```xml
   <key>method</key>
   <string>app-store</string>
   ```

2. **Re-export with App Store signing:**
   ```bash
   xcodebuild -exportArchive \
     -archivePath build/ios/Runner.xcarchive \
     -exportOptionsPlist ios/ExportOptionsAppStore.plist \
     -exportPath build/ios/ipa-appstore \
     -allowProvisioningUpdates
   ```

### **If Transporter Shows Error**
Common issues:
- **"Invalid Signature"** → Re-archive with proper App Store provisioning
- **"Missing Info.plist"** → Check bundle structure
- **"Invalid Bundle"** → Rebuild with Xcode directly

**Solution:** Use Xcode Organizer (Method 3) which handles signing automatically

---

## 🔍 **Troubleshooting**

### **Transporter Won't Accept IPA**
```bash
# Use Xcode Organizer instead
open ios/Runner.xcworkspace
# Then Product → Archive → Distribute
```

### **Signing Issues**
```bash
# Check code signing
codesign -vv --deep --strict "build/ios/ipa/Payload/Runner.app"
```

### **View IPA Contents**
```bash
# Unzip to inspect
unzip -l "build/ios/ipa/Flow Ai.ipa"
```

---

## ✅ **Recommended Approach**

For easiest upload with proper signing:

### **Use Xcode Organizer:**

1. ```bash
   open ios/Runner.xcworkspace
   ```

2. Select **"Any iOS Device (arm64)"** in scheme selector

3. **Product** → **Archive**

4. **Window** → **Organizer**

5. Click **"Distribute App"** → **"App Store Connect"** → **"Upload"**

6. Xcode will handle all signing automatically ✅

This is more reliable than command-line IPA export for App Store submission.

---

## 📊 **Upload Checklist**

- [ ] IPA file ready: `Flow Ai.ipa` (15 MB)
- [ ] Transporter app installed
- [ ] Apple ID credentials ready
- [ ] Internet connection stable
- [ ] Release notes prepared (copy from above)
- [ ] Demo account credentials ready
- [ ] Screenshots uploaded (if first submission)

---

## 📞 **If You Need Help**

### Apple Support
- **Developer Support:** https://developer.apple.com/support/
- **App Store Connect Help:** https://help.apple.com/app-store-connect/

### Common Upload Issues
1. **"Authentication failed"** → Check Apple ID password, enable 2FA
2. **"Invalid bundle"** → Use Xcode Organizer method instead
3. **"Processing error"** → Wait 30 mins and try again

---

## 🎯 **Current Status**

✅ Archive created: `build/ios/Runner.xcarchive`  
✅ IPA exported: `build/ios/ipa/Flow Ai.ipa` (15 MB)  
✅ Finder window opened showing IPA file  
⏳ Ready for Transporter upload

**Next step:** Open Transporter and drag `Flow Ai.ipa` to upload!

---

**Pro Tip:** If Transporter gives any issues, use Xcode Organizer (Method 3) - it's the most reliable method for App Store submissions.

---

**Created:** October 27, 2025  
**IPA Size:** 15 MB  
**Location:** `build/ios/ipa/Flow Ai.ipa`
