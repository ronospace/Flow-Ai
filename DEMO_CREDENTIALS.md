# Flow Ai - Demo Account Credentials

## For App Store Review Teams (Apple & Google)

### Primary Demo Account
```
Email:    demo@flowai.app
Password: FlowAiDemo2024!
```

### Account Details
- **Display Name**: Demo User for App Review
- **Username**: demo_reviewer
- **Pre-configured**: Yes (auto-created on first app launch)
- **Onboarding**: Already completed for immediate access
- **Sample Data**: Includes 28-day cycle data, symptoms, and AI insights

---

## Alternative Testing Method

If the demo account doesn't work for any reason:

### Create a New Test Account
1. Open the app
2. Tap **"Sign Up"** instead of "Sign In"
3. Enter ANY email address (e.g., `reviewer@test.com`)
4. Enter ANY password (minimum 8 characters, e.g., `Test1234!`)
5. Enter a display name (e.g., "Test Reviewer")
6. Tap "Create Account"

**Important**: 
- ✅ No email verification required
- ✅ Any email address will work (even fake ones)
- ✅ Instant account creation
- ✅ The app uses local authentication for demo/testing

---

## Demo Account Location in Code

The demo account is automatically created in:
```
File: lib/core/services/local_user_service.dart
Lines: 316-373
```

### Auto-Creation Logic
```dart
const demoEmail = 'demo@flowai.app';
const demoPassword = 'FlowAiDemo2024!';
```

The account is created with:
- Sample cycle tracking data (28-day cycle)
- Sample symptoms and mood logs
- AI-generated insights
- Completed onboarding for smooth testing

---

## App Logs Verification

When the app starts, you should see these logs:

### If Demo Account Exists:
```
✅ Demo account already exists for App Store review
```

### If Demo Account Created:
```
✅ Demo account auto-created for App Store review with sample data
📧 Demo credentials: demo@flowai.app / FlowAiDemo2024!
```

### User Authentication Success:
```
📱 User authenticated and onboarding complete -> /home
🚀 Navigating to: /home
```

---

## Testing Checklist for Reviewers

### ✅ Login Flow
- [ ] Open app
- [ ] Enter demo credentials
- [ ] Tap "Sign In"
- [ ] App should navigate to home screen

### ✅ Core Features to Test
- [ ] View cycle calendar
- [ ] Check AI insights (with medical citations)
- [ ] Log symptoms
- [ ] Chat with AI assistant
- [ ] View predictions
- [ ] Check settings and privacy controls

### ✅ Medical Citations
- [ ] Navigate to "Insights" tab
- [ ] Tap any AI insight card
- [ ] Scroll to bottom to see "Medical Sources" section
- [ ] Tap "View Source" to open research links
- [ ] Verify citations from ACOG, WHO, NIH, etc.

---

## Troubleshooting

### Problem: "No account found with this email"
**Solution**: 
1. Force quit the app
2. Relaunch the app (demo account auto-creates on launch)
3. Try logging in again
4. OR use the alternative method (create new account)

### Problem: "Incorrect password"
**Solution**: 
- Verify password is exactly: `FlowAiDemo2024!` (case-sensitive)
- Include the exclamation mark at the end
- OR use the alternative method (create new account)

### Problem: App crashes on launch
**Solution**: 
- Check iOS version (requires iOS 16.0+)
- Check Android version (requires Android 8.0+)
- Contact developer at ronos.ai@icloud.com

---

## For Developers: Password Reset

If you need to reset the demo account password:

```dart
// In lib/core/services/local_user_service.dart
// Line 330
password: 'YourNewPassword123!',
```

After changing, rebuild and reinstall the app.

---

## Contact Information

### Developer Support
- **Email**: ronos.ai@icloud.com
- **Response Time**: Within 24 hours
- **GitHub**: https://github.com/ronospace/ZyraFlow

### App Support
- **Email**: support@flowai.app
- **Privacy Policy**: https://flowai.app/privacy
- **Terms of Service**: https://flowai.app/terms

---

## Version Information

- **Last Updated**: October 27, 2025
- **App Version**: 2.1.1 (build 10)
- **Compatible Platforms**: iOS 16.0+, Android 8.0+

---

**Note for Review Teams**: If you experience any issues with the demo account or have questions about app functionality, please don't hesitate to reach out at ronos.ai@icloud.com. We're committed to ensuring a smooth review process.
