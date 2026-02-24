# Firebase Migration Guide: Flow Ai Rebranding

## Overview
This guide covers the complete migration from `zyraflow-production` to `flowai-production` Firebase project.

## 🔥 Step 1: Firebase Project Setup

### Option A: Create New Firebase Project (Recommended)
```bash
# Install Firebase CLI if not already installed
npm install -g firebase-tools

# Login to Firebase
firebase login

# Create new project (do this in Firebase Console)
# 1. Go to https://console.firebase.google.com/
# 2. Click "Add project"
# 3. Project name: "Flow Ai Production"
# 4. Project ID: "flowai-production"
# 5. Enable Google Analytics (recommended)
```

### Option B: Rename Existing Project
```bash
# Note: Firebase project IDs cannot be changed after creation
# You'll need to create a new project and migrate data
```

## 📱 Step 2: Configure Firebase Apps

### Android App Configuration
1. **Add Android App in Firebase Console:**
   - Package name: `com.flowai.health`
   - App nickname: `Flow Ai Android`
   - Download `google-services.json`

2. **Replace Configuration File:**
```bash
# Backup old file
cp android/app/google-services.json android/app/google-services.json.backup

# Replace with new file from Firebase Console
# Place new google-services.json in android/app/
```

### iOS App Configuration
1. **Add iOS App in Firebase Console:**
   - Bundle ID: `com.flowai.health`
   - App nickname: `Flow Ai iOS`
   - Download `GoogleService-Info.plist`

2. **Replace Configuration File:**
```bash
# Backup old file
cp ios/Runner/GoogleService-Info.plist ios/Runner/GoogleService-Info.plist.backup

# Replace with new file from Firebase Console
# Place new GoogleService-Info.plist in ios/Runner/
```

### macOS App Configuration
1. **Add macOS App in Firebase Console:**
   - Bundle ID: `com.flowai.app`
   - App nickname: `Flow Ai macOS`
   - Download `GoogleService-Info.plist`

2. **Replace Configuration File:**
```bash
# Backup old file
cp macos/Runner/GoogleService-Info.plist macos/Runner/GoogleService-Info.plist.backup

# Replace with new file from Firebase Console
# Place new GoogleService-Info.plist in macos/Runner/
```

### Web App Configuration
1. **Add Web App in Firebase Console:**
   - App nickname: `Flow Ai Web`
   - Hosting URL: `flowai-production.web.app`

2. **Update Firebase Options:**
```bash
# Generate new firebase_options.dart
flutter packages pub run firebase_core:generate

# Or update manually in lib/firebase_options.dart
```

## 🔧 Step 3: Update Firebase Configuration Files

### Update .firebaserc
```json
{
  "projects": {
    "default": "flowai-production"
  }
}
```

### Update firebase.json
```json
{
  "flutter": {
    "platforms": {
      "android": {
        "default": {
          "projectId": "flowai-production",
          "appId": "NEW_ANDROID_APP_ID"
        }
      },
      "ios": {
        "default": {
          "projectId": "flowai-production",
          "appId": "NEW_IOS_APP_ID"
        }
      },
      "macos": {
        "default": {
          "projectId": "flowai-production",
          "appId": "NEW_MACOS_APP_ID"
        }
      }
    }
  }
}
```

## 🚀 Step 4: Enable Firebase Services

### Essential Services to Enable:
1. **Authentication**
   - Enable Email/Password
   - Enable Google Sign-In
   - Enable Apple Sign-In (iOS)

2. **Firestore Database**
   - Create database in production mode
   - Set up security rules

3. **Firebase Storage**
   - Enable storage bucket
   - Set up security rules

4. **Firebase Hosting**
   - Enable hosting
   - Configure custom domain (flowai.app)

5. **Cloud Functions** (if used)
   - Deploy existing functions to new project

6. **Firebase Analytics**
   - Enable Google Analytics
   - Configure conversion events

7. **Crashlytics**
   - Enable crash reporting
   - Update build scripts

### Firebase Services Setup Commands:
```bash
# Initialize Firebase services
firebase init

# Select services:
# - Hosting
# - Firestore
# - Functions (if applicable)
# - Storage

# Deploy rules and indexes
firebase deploy --only firestore:rules,firestore:indexes
firebase deploy --only storage:rules

# Deploy hosting
firebase deploy --only hosting
```

## 🔒 Step 5: Update Security Rules

### Firestore Security Rules Example:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Subcollections for user data
      match /{document=**} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
    
    // Public data (if any)
    match /public/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### Storage Security Rules Example:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Users can only access their own files
    match /users/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

## 📊 Step 6: Data Migration (if needed)

### Export Data from Old Project:
```bash
# Export Firestore data
gcloud firestore export gs://zyraflow-production-backup/firestore-export

# Export Authentication users
firebase auth:export users.json --project zyraflow-production
```

### Import Data to New Project:
```bash
# Import Firestore data
gcloud firestore import gs://flowai-production-backup/firestore-export --project flowai-production

# Import Authentication users
firebase auth:import users.json --project flowai-production
```

## 🔐 Step 7: Update Environment Variables

### GitHub Secrets to Update:
- `FIREBASE_SERVICE_ACCOUNT_FLOWAI_PRODUCTION`
- Update workflow files with new secret names

### CI/CD Environment Variables:
- `FIREBASE_PROJECT_ID=flowai-production`
- `FIREBASE_WEB_API_KEY=new_web_api_key`
- `FIREBASE_APP_ID=new_app_id`

## ✅ Step 8: Verification Checklist

- [ ] Firebase Console shows new project with all apps
- [ ] All configuration files updated and committed
- [ ] Authentication working with new project
- [ ] Firestore rules deployed and working
- [ ] Storage rules deployed and working
- [ ] Hosting deployed to new project
- [ ] Analytics tracking properly
- [ ] Crashlytics reporting to new project
- [ ] CI/CD pipelines updated and working
- [ ] All platform apps (iOS, Android, macOS, Web) connecting properly

## 🚨 Rollback Plan

If issues occur during migration:

1. **Immediate Rollback:**
```bash
# Revert .firebaserc
git checkout HEAD~1 .firebaserc

# Revert firebase.json
git checkout HEAD~1 firebase.json

# Revert configuration files
git checkout HEAD~1 android/app/google-services.json
git checkout HEAD~1 ios/Runner/GoogleService-Info.plist
git checkout HEAD~1 macos/Runner/GoogleService-Info.plist
```

2. **Restore from backups:**
   - Restore configuration files from .backup files
   - Redeploy to original project

## 📞 Support Resources

- Firebase Console: https://console.firebase.google.com/
- Firebase CLI Reference: https://firebase.google.com/docs/cli
- Migration Documentation: https://firebase.google.com/docs/projects/learn-more#project-identifiers

---

**⚠️ Important Notes:**
- Test thoroughly in development before applying to production
- Keep backups of all configuration files
- Update team members about new project details
- Monitor error rates after migration
