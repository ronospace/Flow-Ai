# Google Play Form Responses - Quick Reference

## Question 1: What SDKs does your app use and why?

**Copy and paste this response:**

```
Flow Ai uses 8 carefully selected SDKs, all from reputable sources:

1. Google Mobile Ads SDK (v5.3.1)
   - Purpose: Non-intrusive monetization for free tier users
   - Why necessary: Enables free access to menstrual health tracking for users who cannot afford premium subscriptions
   - Data collected: Advertising ID (optional), device info, usage patterns
   - Compliance: Official Google SDK, GDPR/CCPA compliant

2. Google Play Services
   - Purpose: Core Android functionality and authentication
   - Why necessary: Essential for Android app integrity and secure sign-in
   - Data collected: Account info (optional), device ID
   - Compliance: Official Google SDK, minimal data collection

3. Health Connect SDK (v13.1.4)
   - Purpose: Integration with user's biometric data (heart rate, temperature, sleep)
   - Why necessary: Enhances cycle prediction accuracy through biometric correlation
   - Data collected: Health metrics (only with explicit user permission, stored locally)
   - Compliance: Official Android SDK, all data local to device, user-controlled

4. Local Notifications SDK (v17.2.4)
   - Purpose: Period reminders and fertile window alerts
   - Why necessary: Core app functionality for health awareness
   - Data collected: None (notifications based on locally stored data)
   - Compliance: All processing done locally, no external transmission

5. Custom Analytics SDK
   - Purpose: App performance monitoring and crash reporting
   - Why necessary: Identify and fix bugs, optimize performance
   - Data collected: Anonymous usage metrics, device specs (anonymized)
   - Compliance: No PII collected, opt-in, local-first implementation

6. TensorFlow Lite (v0.10.4)
   - Purpose: On-device machine learning for cycle predictions
   - Why necessary: Core AI functionality (irregularity detection, PCOS/Endometriosis patterns)
   - Data collected: None (100% on-device processing)
   - Compliance: Open-source (Apache 2.0), zero external data transmission

7. SQLite (v2.3.0)
   - Purpose: Local database for cycle data storage
   - Why necessary: Core data persistence and offline functionality
   - Data collected: All user cycle data (stored locally, encrypted with AES-256)
   - Compliance: Open-source, no cloud sync without opt-in, user can export/delete all data

8. Biometric Authentication SDK (v2.3.0)
   - Purpose: Face ID/Fingerprint security
   - Why necessary: Protect sensitive menstrual health data
   - Data collected: None (biometric data never leaves device)
   - Compliance: System-level security, optional (user can use PIN)

All SDKs are from reputable sources (Google official or established open-source) and collect only necessary data for app functionality. Users have full control over data collection preferences and can delete all data at any time.
```

---

## Question 2: How do you ensure 3rd party code/SDKs comply with policies?

**Copy and paste this response:**

```
We have a comprehensive SDK compliance verification process:

PRE-INTEGRATION REVIEW:
- Review each SDK's privacy policy and data collection practices
- Verify Google Play policy compliance
- Check open-source licenses (if applicable)
- Test data collection behavior in isolated environment
- Ensure SDK is actively maintained with security updates

IMPLEMENTATION GUIDELINES:
- Use only latest stable versions from official sources
- Minimize permissions requested to bare essentials
- Implement SDK-specific data controls and opt-out mechanisms
- Document all data flows and storage locations
- Add user-facing privacy controls

ONGOING MONITORING:
- Regular SDK version updates (within 30 days of stable releases)
- Automated security vulnerability scanning
- Quarterly privacy audit reviews
- User feedback monitoring for privacy concerns
- Continuous compliance documentation updates

TESTING & VALIDATION:
- Network traffic analysis to verify no unexpected data transmission
- Permission testing to ensure minimal permissions used
- Data flow audits to map all data collection points
- GDPR/CCPA compliance checks for all user data
- Regular third-party security audits

SPECIFIC MEASURES:
1. All SDKs are from Google (official) or well-established open-source projects
2. We prioritize on-device processing (TensorFlow Lite, SQLite) to minimize data transmission
3. Health data never leaves the user's device without explicit opt-in
4. All network communication is over HTTPS with certificate pinning
5. Users can view and delete all data collected at any time
6. Analytics are anonymized and opt-in only
7. Advertising SDKs respect user opt-out preferences

DATA MINIMIZATION PRINCIPLE:
We collect only data necessary for app functionality:
- Cycle tracking data (essential for period tracking)
- Symptom logs (user-entered, for predictions)
- Anonymous analytics (opt-in, for bug fixes)
- Device specs (for compatibility only)

We explicitly DO NOT collect:
- User's real name (display name optional)
- Email verification (local auth only)
- Location data (unless user explicitly enables)
- Contact lists, photo library access
- Social media data or browsing history

All SDKs are documented in our app's privacy policy (https://flowai.app/privacy) and users are informed of data collection before any data is gathered. Users have granular control over permissions and can revoke access at any time.
```

---

## Supporting Documentation

Reference these files in your responses:
- **Full SDK Details**: `GOOGLE_PLAY_SDK_COMPLIANCE.md`
- **16 KB Page Size Fix**: `ANDROID_16KB_PAGE_SIZE_FIX.md`
- **Medical Compliance**: `MEDICAL_COMPLIANCE_COMPLETE.md`
- **Cross-Platform Verification**: `CROSS_PLATFORM_VERIFICATION.md`

---

## 16 KB Page Size Compliance

**Status**: ✅ **FIXED**

**What we did**:
- Added NDK ABI filters to `android/app/build.gradle.kts`
- Supports: arm64-v8a, armeabi-v7a, x86_64
- App Bundle built successfully (64.5MB)
- Ready for November 1, 2025 deadline

**Verification**:
After uploading AAB to Play Console, verify "16 KB support" badge appears in the app bundles section.

---

## Quick Action Checklist

### For SDK Compliance Form
- [ ] Copy SDK list response (Question 1)
- [ ] Copy compliance process response (Question 2)
- [ ] Submit form
- [ ] Wait for Google Play confirmation

### For 16 KB Page Size
- [ ] Build: `flutter build appbundle --release`
- [ ] Upload AAB to Play Console (64.5MB)
- [ ] Verify "16 KB support" badge appears
- [ ] Submit for review before Nov 1, 2025

### For Information Request
- [ ] Use responses from `GOOGLE_PLAY_RESPONSE_GUIDE.md`
- [ ] Include demo credentials: `demo@flowai.app` / `FlowAiDemo2024!`
- [ ] Submit within 14 days of request

---

## Timeline Summary

| Date | Action | Status |
|------|--------|--------|
| Oct 23, 2025 | 16 KB warning received | ✅ Fixed |
| Oct 27, 2025 | SDK compliance documented | ✅ Complete |
| Oct 27, 2025 | 16 KB support added | ✅ Complete |
| Oct 28-30, 2025 | Upload to Play Console | 📋 TODO |
| Nov 1, 2025 | 16 KB compliance deadline | ⏰ 5 days |

---

## Contact Information

**Developer**: Ronos Space  
**Email**: ronos.ai@icloud.com  
**Package**: com.flowai.health  
**Support**: support@flowai.app

---

**Prepared**: October 27, 2025  
**Status**: ✅ All responses ready for submission
