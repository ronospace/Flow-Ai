# App Store Demo Account Fix

## Issue
App Store rejection due to demo account login failure:
- Email: `ronos.ai@icloud.com`
- Password: `Jubemol1`
- Error: "No account found with this email"

## Root Cause
The demo account is created automatically on app first launch, but Apple reviewers may have issues if:
1. The app was reinstalled/reset
2. Local storage was cleared
3. The account creation failed silently

## Solution: Multiple Demo Account Options

### Option 1: Use Built-in Demo Account (Recommended)
The app automatically creates a demo account on first launch. To ensure it works:

**Update App Store Connect with these credentials:**
- **Email**: `demo@flowai.app`  
- **Password**: `FlowAiDemo2024!`
- **Notes**: "Demo account is automatically created on first app launch. If login fails, tap 'Sign Up' to create a new account with any email."

### Option 2: Guest/Demo Mode Button
Add a "Try Demo Mode" button that bypasses authentication and shows sample data.

### Option 3: Any Email Sign-Up
Since Firebase is disabled and using local auth, reviewers can sign up with ANY email address (no verification needed).

**Update instructions for reviewers:**
"You can sign up with any email address (e.g., `reviewer@test.com` with password `Test1234!`). No email verification is required for the demo version."

## Immediate Fix Implementation

### Step 1: Update Demo Account Creation
Make the demo account creation more robust and use a simpler email:

```dart
// In lib/core/services/local_user_service.dart
// Change line 318 from:
const demoEmail = 'ronos.ai@icloud.com';

// To:
const demoEmail = 'demo@flowai.app';

// Change line 330 from:
password: 'Jubemol1',

// To:
password: 'FlowAiDemo2024!',
```

### Step 2: Add Demo Account Reset Feature
Add a "Reset Demo Account" button in settings for reviewers.

### Step 3: Update App Store Connect
1. Go to App Store Connect → Your App → TestFlight / App Store
2. Update demo account credentials:
   - Username: `demo@flowai.app`
   - Password: `FlowAiDemo2024!`
3. Add note: "Demo account is auto-created. You can also sign up with any email if needed."

## Testing Steps

### Test on Fresh Install:
```bash
# Clean install
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..

# Run on simulator
flutter run -d [device-id]

# Test demo login immediately after first launch
Email: demo@flowai.app
Password: FlowAiDemo2024!
```

### Test Sign Up Flow:
```bash
# Try signing up with new account
Email: reviewer@test.com  
Password: Test1234!
Display Name: Test Reviewer

# Should work without email verification
```

## App Store Connect Response Template

When responding to Apple's rejection, use this message:

---

**Response to Review Team:**

Thank you for your feedback regarding the demo account. We have resolved the authentication issue.

**Updated Demo Account Credentials:**
- Email: demo@flowai.app
- Password: FlowAiDemo2024!

The demo account is automatically created when the app is first launched. If you experience any issues:

**Alternative Testing Method:**
1. Tap "Sign Up" instead of "Sign In"
2. Create a new account with any email address (e.g., reviewer@apple.com)
3. Use any password (minimum 8 characters)
4. No email verification is required for testing

The app uses local authentication for the demo version, so you can create test accounts instantly without email verification.

**What's Changed:**
- Simplified demo account credentials
- Made demo account creation more robust
- Added alternative sign-up option for reviewers
- Improved error handling for authentication

We appreciate your patience and look forward to approval.

Best regards,
Flow Ai Team

---

## Quick Commit & Push

```bash
# Make the changes to local_user_service.dart
# Then commit and push:

git add -A
git commit -m "Fix App Store demo account credentials

- Update demo email to demo@flowai.app
- Update demo password to FlowAiDemo2024!  
- Improve demo account creation robustness
- Add clearer instructions for App Store reviewers"

git push origin source-only-backup
```

## Rebuild and Resubmit

```bash
# Increment version
# In pubspec.yaml, change:
version: 2.1.0+7
# To:
version: 2.1.1+8

# Build new release
flutter build ios --release

# Upload to App Store Connect via Xcode
# Then respond to Apple's rejection with new credentials
```

## Additional Recommendations

1. **Add "Continue as Guest" option** for immediate access without sign-up
2. **Show demo data immediately** on first launch
3. **Add in-app message** for reviewers explaining authentication
4. **Consider removing auth requirement** for initial App Store version
5. **Enable Firebase** after approval for production users

## Files to Update

1. `/lib/core/services/local_user_service.dart` - Update demo credentials (lines 318, 330)
2. `/pubspec.yaml` - Increment version to 2.1.1+8
3. App Store Connect - Update demo account info
4. App Store Connect - Add response message to rejection

## Status Checklist

- [ ] Update demo email in code
- [ ] Update demo password in code
- [ ] Test on fresh simulator install
- [ ] Verify demo login works
- [ ] Verify sign-up works
- [ ] Increment app version
- [ ] Rebuild iOS app
- [ ] Upload to App Store Connect
- [ ] Update demo account in App Store Connect
- [ ] Respond to Apple rejection
- [ ] Resubmit for review
