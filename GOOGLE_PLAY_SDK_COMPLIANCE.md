# Google Play SDK & 3rd Party Code Compliance - Flow Ai

**App Name**: Flow Ai  
**Package**: com.flowai.health  
**Date**: October 27, 2025

---

## SDKs Used and Justification

### 1. **Google Mobile Ads SDK** (v5.3.1)
**Purpose**: Monetization through non-intrusive ads in free tier  
**User Data Collected**: 
- Advertising ID (for personalized ads, optional)
- Device info (model, OS version)
- App usage patterns (for ad frequency capping)

**Why Necessary**: 
- Supports free tier for users who cannot afford premium
- Enables access to menstrual health tracking for underserved communities
- Revenue funds ongoing development and medical research citations

**Compliance**:
- ✅ Google's own SDK - fully compliant with Play policies
- ✅ Users can opt-out of personalized ads
- ✅ No ads shown during sensitive health data entry
- ✅ GDPR/CCPA compliant
- ✅ AdMob data safety documentation: https://support.google.com/admob/answer/10362485

---

### 2. **Google Play Services** (Latest)
**Purpose**: Core Android functionality and authentication  
**User Data Collected**:
- Account info (optional, for Google Sign-In)
- Device ID (for app integrity)

**Why Necessary**:
- Essential for Android app functionality
- Provides secure authentication
- App integrity verification

**Compliance**:
- ✅ Google's own SDK - fully compliant
- ✅ Minimal data collection
- ✅ User control over sign-in

---

### 3. **Health Connect SDK** (v13.1.4)
**Purpose**: Integration with user's health data (heart rate, temperature, sleep)  
**User Data Collected**:
- Biometric data (only with explicit user permission)
- Health metrics from other apps/devices

**Why Necessary**:
- Enhances cycle prediction accuracy
- Correlates biometric patterns with menstrual cycle
- Provides holistic health insights

**Compliance**:
- ✅ All data stored locally on device
- ✅ Explicit user permission required
- ✅ User can revoke access anytime
- ✅ No data sent to external servers
- ✅ Compliant with health data regulations (HIPAA architecture)

---

### 4. **Local Notifications SDK** (v17.2.4)
**Purpose**: Period reminders, fertile window alerts  
**User Data Collected**:
- None (notifications based on locally stored cycle data)

**Why Necessary**:
- Critical for period tracking functionality
- User-requested reminders for health awareness
- No tracking beyond app usage

**Compliance**:
- ✅ User grants notification permission
- ✅ All processing done locally
- ✅ No external data transmission
- ✅ User can disable anytime

---

### 5. **Analytics SDK** (Custom Implementation)
**Purpose**: App performance monitoring and crash reporting  
**User Data Collected**:
- Anonymous app usage metrics
- Device specs (for bug fixing)
- Crash logs (anonymized)

**Why Necessary**:
- Identify and fix bugs affecting user experience
- Optimize performance
- Improve app stability

**Compliance**:
- ✅ No personally identifiable information (PII)
- ✅ All data anonymized
- ✅ Opt-in analytics (users can disable)
- ✅ Local-first implementation

---

### 6. **TensorFlow Lite** (v0.10.4)
**Purpose**: On-device machine learning for cycle predictions  
**User Data Collected**:
- None (all ML processing on-device)

**Why Necessary**:
- Core app functionality (AI predictions)
- Advanced cycle irregularity detection
- PCOS/Endometriosis pattern recognition

**Compliance**:
- ✅ Open-source SDK (Apache 2.0 license)
- ✅ 100% on-device processing
- ✅ Zero external data transmission
- ✅ Privacy-preserving AI

---

### 7. **SQLite** (v2.3.0)
**Purpose**: Local database for cycle data storage  
**User Data Collected**:
- All user cycle data (stored locally only)

**Why Necessary**:
- Core data persistence
- Offline functionality
- Fast data retrieval

**Compliance**:
- ✅ All data stored on user's device
- ✅ No cloud sync without explicit opt-in
- ✅ Encrypted storage (AES-256)
- ✅ User can export/delete all data

---

### 8. **Biometric Authentication SDK** (v2.3.0)
**Purpose**: Face ID/Fingerprint for app security  
**User Data Collected**:
- None (biometric data never leaves device)

**Why Necessary**:
- Protect sensitive menstrual health data
- Secure app access
- Privacy protection

**Compliance**:
- ✅ Biometric data never transmitted
- ✅ Android/iOS system-level security
- ✅ Optional (user can use PIN instead)
- ✅ Industry standard security

---

## SDK Compliance Verification Process

### 1. **Pre-Integration Review**
Before adding any SDK, we:
- ✅ Review SDK's privacy policy
- ✅ Check Play Store policy compliance
- ✅ Verify open-source licenses (if applicable)
- ✅ Test data collection behavior
- ✅ Ensure SDK is actively maintained

### 2. **Implementation Guidelines**
When integrating SDKs:
- ✅ Use latest stable versions
- ✅ Minimize permissions requested
- ✅ Implement SDK data controls
- ✅ Add user opt-out mechanisms
- ✅ Document all data flows

### 3. **Ongoing Monitoring**
- ✅ Regular SDK version updates
- ✅ Security vulnerability scanning
- ✅ Privacy audit reviews
- ✅ User feedback monitoring
- ✅ Compliance documentation updates

### 4. **Testing & Validation**
- ✅ Network traffic analysis (verify no unexpected data transmission)
- ✅ Permission testing (ensure minimal permissions)
- ✅ Data flow audits
- ✅ GDPR/CCPA compliance checks

---

## Data Minimization Principle

### What We DON'T Collect
- ❌ User's real name (optional display name only)
- ❌ Email verification (local auth only)
- ❌ Location data (optional, user-controlled)
- ❌ Contact lists
- ❌ Photo library (except user-initiated imports)
- ❌ Microphone/camera (unless user explicitly uses features)
- ❌ Social media data
- ❌ Browsing history
- ❌ Financial information

### What We DO Collect (Only When Necessary)
- ✅ Cycle tracking data (essential app function)
- ✅ Symptom logs (user-entered, for predictions)
- ✅ App usage analytics (anonymous, opt-in)
- ✅ Crash reports (anonymous, for bug fixes)
- ✅ Device specs (for compatibility)

### User Control
- ✅ Users can delete all data anytime
- ✅ Users can export data (PDF/CSV)
- ✅ Users can disable analytics
- ✅ Users can opt-out of ads
- ✅ Users can revoke permissions

---

## Third-Party SDK Compliance Assurance

### Google Mobile Ads
**Compliance Verification**:
- Official Google SDK (v5.3.1)
- Documented at: https://developers.google.com/admob/android/privacy
- Complies with: GDPR, CCPA, COPPA
- Users can opt-out via Google Ads Settings
- No ads on sensitive screens (tracking, insights)

### TensorFlow Lite
**Compliance Verification**:
- Open-source (Apache 2.0): https://github.com/tensorflow/tensorflow
- 100% on-device processing
- Zero network communication
- No data collection
- Maintained by Google

### Health Connect
**Compliance Verification**:
- Official Android Health Connect SDK
- Documented at: https://developer.android.com/health-and-fitness/guides/health-connect
- User grants explicit permissions
- All data local to device
- Complies with health data regulations

### SQLite
**Compliance Verification**:
- Open-source, public domain: https://www.sqlite.org/
- Local database only
- No network communication
- Widely audited and trusted
- Industry standard for mobile apps

---

## Policy Compliance Statement

**We certify that:**

1. ✅ All SDKs used comply with Google Play Developer Program Policies
2. ✅ All 3rd party code has been reviewed for policy compliance
3. ✅ User data is collected only when necessary for app functionality
4. ✅ Users have control over their data collection preferences
5. ✅ All data collection is disclosed in our Privacy Policy
6. ✅ No SDKs collect data without user awareness
7. ✅ All SDKs are from reputable sources (Google, open-source)
8. ✅ We regularly update SDKs for security and compliance
9. ✅ No malicious or deceptive SDKs are used
10. ✅ All health data handling follows medical privacy standards

---

## Data Safety Declaration Summary

### Data Collected
1. **Health & Fitness Data**: Cycle tracking, symptoms (local storage)
2. **App Activity**: Anonymous usage metrics (optional)
3. **Device Info**: Model, OS version (for compatibility)
4. **Advertising ID**: For ad personalization (optional)

### Data NOT Shared
- ✅ User health data is NEVER shared with 3rd parties
- ✅ All cycle data stays on user's device
- ✅ No data selling
- ✅ No data brokering

### Data Security
- ✅ AES-256 encryption
- ✅ Biometric authentication
- ✅ Local-first storage
- ✅ Optional cloud backup (user-controlled)

---

## Contact & Accountability

**Developer**: Ronos Space  
**Email**: ronos.ai@icloud.com  
**Privacy Policy**: https://flowai.app/privacy  
**Data Deletion**: support@flowai.app  

**Compliance Officer**: Ronos Space  
**Last Review**: October 27, 2025  
**Next Review**: December 27, 2025 (quarterly)

---

## SDK Version Tracking

| SDK | Current Version | Latest Available | Update Status |
|-----|----------------|------------------|---------------|
| Google Mobile Ads | 5.3.1 | 6.0.0 | Planned for v2.2.0 |
| Health Connect | 13.1.4 | 13.2.1 | Planned for v2.2.0 |
| TensorFlow Lite | 0.10.4 | 0.11.0 | Planned for v2.2.0 |
| Local Notifications | 17.2.4 | 19.5.0 | Planned for v2.2.0 |
| SQLite | 2.3.0 | 2.3.0 | ✅ Up to date |
| Biometric Auth | 2.3.0 | 3.0.0 | Planned for v2.2.0 |

**Update Policy**: We update all SDKs within 30 days of stable releases for security and compliance.

---

**Prepared for**: Google Play Developer Program  
**Submission**: Flow Ai (com.flowai.health)  
**Date**: October 27, 2025
