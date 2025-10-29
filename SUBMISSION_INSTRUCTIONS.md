# Flow Ai - Apple App Store Submission Guide

**Date**: 29 October 2025  
**Version**: 2.1.2 (Build 11)  
**Archive Location**: `build/ios/archive/Runner.xcarchive`

---

## Quick Steps for Transporter Upload

### 1. Open Xcode and Export IPA

```bash
# The archive is ready at:
/Users/ronos/Workspace/Projects/Active/ZyraFlow/build/ios/archive/Runner.xcarchive
```

**Steps**:
1. Open Xcode
2. Go to Window → Organizer
3. Select the "Runner.xcarchive" (created today)
4. Click "Distribute App"
5. Choose "App Store Connect"
6. Select "Upload"
7. Follow prompts to sign and export IPA

### 2. Upload via Transporter

1. Open **Transporter** app (from Mac App Store)
2. Sign in with Apple ID: **your-apple-id@email.com**
3. Click **"+"** or drag & drop the exported IPA
4. Click **"Deliver"**
5. Wait for upload to complete

---

## Demo Account Information to Submit

Copy this into App Store Connect "App Review Information" → "Notes":

```
DEMO ACCOUNT FOR TESTING:

Email: demo@flowai.app
Password: FlowAiDemo2025!

This demo account includes 6 months of pre-loaded cycle data for comprehensive
testing of all app features including:
- Period tracking and predictions
- AI-powered cycle insights
- Symptom correlation analysis
- Health dashboard with statistics
- Data export functionality (PDF/CSV/JSON)

TESTING INSTRUCTIONS:
1. Login with credentials above
2. Home screen shows current cycle status and next period prediction
3. Calendar tab displays 6 months of historical cycle data
4. Insights tab shows AI predictions with confidence scores
5. Settings tab includes theme switcher, language selection, data export

App works fully offline. Cloud sync is optional and can be disabled.

For detailed testing guide, see attached comprehensive demo logs document.

Contact: geoffrey.rono@ue-germany.de for any questions.
```

---

## Files to Include in Submission

### 1. Main Demo Logs
📄 `APPLE_DEMO_LOGS.txt` - Comprehensive testing guide with:
- Demo account credentials
- Step-by-step testing instructions
- Expected behavior for each feature
- Sample data included in demo account
- Troubleshooting guide
- Privacy and data handling information

### 2. This Quick Reference
📄 `SUBMISSION_INSTRUCTIONS.md` - Upload steps and quick notes

---

## App Information Summary

**App Name**: Flow Ai  
**Bundle ID**: com.flowai.health  
**Version**: 2.1.2  
**Build**: 11  
**Category**: Health & Fitness  
**Age Rating**: 13+ (with parental consent)  

**Primary Language**: English  
**Additional Languages**: 35 more languages supported  

**Key Features**:
- Menstrual cycle tracking
- AI-powered predictions
- Symptom logging (70+ symptoms)
- Mood and energy tracking
- Health insights and analytics
- Data export (PDF/CSV/JSON)
- Biometric authentication
- Dark mode support

**Privacy Highlights**:
- Offline-first design
- Local data storage (encrypted)
- Optional cloud sync (GDPR-compliant EU storage)
- No third-party tracking
- Complete data export and deletion

---

## What's New in 2.1.2

- Enhanced theme switcher with prominent card design
- Improved UI polish across all screens
- Updated to Flutter 3.35.2
- Better dark mode support
- Performance optimizations
- Bug fixes and stability improvements

---

## Support Information

**Developer**: Geoffrey Rono  
**Support Email**: support@flowai.app  
**Website**: https://flow-iq-app.web.app  
**Response Time**: Within 24 hours  

---

## Submission Checklist

- [x] Archive built successfully (Runner.xcarchive)
- [x] Demo account created and tested
- [x] Comprehensive demo logs prepared
- [x] Testing instructions documented
- [x] Privacy policy updated
- [x] Terms of service available
- [x] App screenshots prepared
- [x] App description ready
- [ ] Export IPA via Xcode Organizer
- [ ] Upload via Transporter
- [ ] Submit demo logs to App Review
- [ ] Monitor submission status

---

## Common Issues & Solutions

### Issue: Export fails with "No signing certificate"
**Solution**: Use Xcode Organizer → Distribute App → Upload to App Store Connect (it will manage signing automatically)

### Issue: Transporter upload fails
**Solution**: 
1. Check internet connection
2. Verify Apple ID has App Manager or Admin role
3. Try exporting IPA again from Xcode

### Issue: Demo account doesn't work for reviewer
**Solution**: 
- Ensure credentials are exactly: demo@flowai.app / FlowAiDemo2025!
- Password is case-sensitive
- If still failing, account may need to be recreated in Firebase

---

## Next Steps After Upload

1. Go to App Store Connect
2. Select Flow Ai app
3. Go to "App Review Information"
4. Paste demo account info
5. Attach `APPLE_DEMO_LOGS.txt` as additional notes
6. Submit for review
7. Monitor email for review updates

---

**Good luck with the submission!** 🚀
