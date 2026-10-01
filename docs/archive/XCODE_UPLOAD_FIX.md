# Fix: Invalid Provisioning Profile Error
## Upload via Xcode Organizer

**Error:** Invalid Provisioning Profile - Missing code-signing certificate  
**Solution:** Use Xcode Organizer which handles App Store signing automatically

---

## ✅ **Xcode is Now Open**

The workspace `ios/Runner.xcworkspace` is now open in Xcode.

---

## 🔧 **Step-by-Step Upload Process**

### **Step 1: Select Device Target**
In Xcode toolbar (top), next to the Run/Stop buttons:
1. Click the device selector dropdown
2. Select **"Any iOS Device (arm64)"**
3. Do NOT select a specific simulator or device

### **Step 2: Archive the App**
1. Go to **Product** menu → **Archive**
2. Wait 2-3 minutes for archive to complete
3. Xcode will automatically open Organizer when done

**Shortcut:** `⌘ + Shift + B` (Command + Shift + B)

### **Step 3: Distribute App**
When Organizer opens:

1. Your archive should be selected (shows as "Runner" with today's date)
2. Click **"Distribute App"** button (blue, on the right)
3. Choose **"App Store Connect"**
4. Click **"Next"**

### **Step 4: Select Distribution Method**
1. Choose **"Upload"** (not "Export")
2. Click **"Next"**

### **Step 5: Distribution Options**
Keep default settings:
- ✅ Upload your app's symbols
- ✅ Manage Version and Build Number (Xcode will handle this)
- Click **"Next"**

### **Step 6: Automatic Signing**
1. Select **"Automatically manage signing"**
2. Xcode will create/download the correct App Store provisioning profile
3. Click **"Next"**
4. Wait for Xcode to prepare the app (30 seconds - 2 minutes)

### **Step 7: Review & Upload**
1. Review the summary screen
2. Verify:
   - App: **Flow Ai (Runner)**
   - Bundle ID: **com.flowai.health**
   - Version: **2.1.1**
   - Build: **10**
3. Click **"Upload"**
4. Wait for upload to complete (5-10 minutes depending on connection)

### **Step 8: Upload Success**
When you see "Upload Successful":
1. Click **"Done"**
2. You'll receive an email from Apple when build is processed

---

## 📧 **After Upload**

### **1. Check App Store Connect**
```
https://appstoreconnect.apple.com
```

1. Go to **My Apps** → **Flow Ai**
2. Click **TestFlight** tab
3. Wait 10-30 minutes for "Processing" to complete
4. You'll get email: "Your build has been processed"

### **2. Create New Version (if needed)**
1. Go to **App Store** tab
2. Click **"+ Version"** or select existing version
3. Set version number: **2.1.1**
4. Select the uploaded build from dropdown

### **3. Fill in Required Info**

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
Password: <REDACTED>

Key Features to Test:
- Cycle tracking with AI predictions (Home screen)
- Symptom and mood tracking (Tracking tab)
- AI insights with medical citations (Insights tab)
- Calendar view with predictions (Calendar tab)
- Medical disclaimers visible on all AI predictions

Technical Notes:
- On-device AI: Works in airplane mode (TensorFlow Lite)
- No cloud data transmission for predictions
- Data export available in Settings

Contact: ronos.ai@icloud.com
```

### **4. Submit for Review**
1. Complete all required fields (screenshots, description, etc.)
2. Click **"Submit for Review"**
3. Wait 24-48 hours for Apple review

---

## ⚠️ **If Archive Fails**

### **Common Issues:**

#### **1. "No signing identity found"**
**Solution:**
1. Xcode → Preferences → Accounts
2. Select your Apple ID
3. Click "Download Manual Profiles"
4. Try archiving again

#### **2. "Provisioning profile doesn't match"**
**Solution:**
1. Select Runner target in Xcode
2. Go to "Signing & Capabilities" tab
3. Check "Automatically manage signing"
4. Select your team
5. Try archiving again

#### **3. "Build input file cannot be found"**
**Solution:**
```bash
# Clean and rebuild
flutter clean
flutter pub get
open ios/Runner.xcworkspace
# Then Product → Clean Build Folder (⌘+Shift+K)
# Then Product → Archive
```

---

## 🔍 **Verify Signing Before Archive**

Before archiving, check signing in Xcode:

1. Click **Runner** project in left sidebar
2. Select **Runner** target
3. Click **"Signing & Capabilities"** tab
4. Verify:
   - ✅ **Automatically manage signing** is checked
   - ✅ Team is selected (your Apple Developer account)
   - ✅ Provisioning Profile shows: "Xcode Managed Profile"
   - ✅ Signing Certificate shows: "Apple Distribution"

If any issues, click "Repair" button or uncheck/recheck "Automatically manage signing"

---

## 📊 **Checklist**

- [x] Xcode workspace opened: `ios/Runner.xcworkspace`
- [ ] Device target set to "Any iOS Device (arm64)"
- [ ] Product → Archive started
- [ ] Archive completed successfully
- [ ] Organizer opened automatically
- [ ] "Distribute App" clicked
- [ ] "App Store Connect" → "Upload" selected
- [ ] "Automatically manage signing" selected
- [ ] Upload completed successfully
- [ ] Email received from Apple (build processed)
- [ ] Version 2.1.1 created in App Store Connect
- [ ] Release notes added
- [ ] Demo account credentials added
- [ ] Submit for Review clicked

---

## 💡 **Why Xcode Organizer vs. Command Line?**

**Xcode Organizer automatically:**
- ✅ Creates correct App Store provisioning profile
- ✅ Signs with Apple Distribution certificate
- ✅ Validates bundle structure
- ✅ Handles entitlements correctly
- ✅ Uploads symbols for crash reports

**Command line export:**
- ❌ Requires manual provisioning profile setup
- ❌ Can create development-signed IPAs by mistake
- ❌ More prone to signing errors

**Result:** Xcode Organizer is the recommended method for App Store uploads.

---

## 🎯 **Current Status**

✅ Xcode workspace opened  
⏳ Ready to archive for App Store upload  
📝 Instructions provided above

**Next action:** Follow steps 1-8 above to archive and upload via Xcode Organizer.

---

## 📞 **Need Help?**

### **Apple Developer Support**
- https://developer.apple.com/support/
- App Store Connect Help: https://help.apple.com/app-store-connect/

### **Common Questions**
1. **"How long does archive take?"** → 2-3 minutes
2. **"How long does upload take?"** → 5-10 minutes
3. **"When can I submit for review?"** → After build processing (10-30 minutes)
4. **"How long is review?"** → Typically 24-48 hours

---

**You're ready to archive and upload!** Follow the steps above in Xcode. 🚀

---

**Created:** October 27, 2025  
**Issue:** Invalid provisioning profile  
**Solution:** Xcode Organizer with automatic signing
