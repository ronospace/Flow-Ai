# Flow Ai Firebase Setup Guide

## 🔥 Firebase Project Structure

### Production Environment
**Project ID**: `flowai-production`

#### App Configurations:
```
Platform    | Package Name           | App Name
------------|----------------------|------------------
Android     | com.flowai.app     | Flow Ai
iOS         | com.flowai.app     | Flow Ai  
Web         | flowai-web         | Flow Ai Web
```

### Development Environment  
**Project ID**: `flowai-development`
- Same package names with `.dev` suffix
- Separate Firestore database
- Test Analytics

## 🔧 Required Firebase Services

### Essential Services (Free Tier Sufficient Initially):
- ✅ **Authentication** (Google, Apple, Email)
- ✅ **Firestore Database** (User data, cycles, predictions)
- ✅ **Cloud Storage** (Profile pictures, documents)
- ✅ **Analytics** (User behavior, feature usage)
- ✅ **Crashlytics** (Error reporting)
- ✅ **Performance Monitoring** (App performance)

### Premium Services (As You Scale):
- 🔄 **Cloud Functions** (AI processing, notifications)
- 🔄 **Cloud Messaging** (Push notifications)
- 🔄 **Remote Config** (Feature flags, A/B testing)
- 🔄 **App Distribution** (Beta testing)

## 📊 Database Structure

### Firestore Collections:
```
users/
├── {userId}/
    ├── profile: { name, email, settings }
    ├── cycles: { startDate, endDate, symptoms }
    ├── predictions: { nextPeriod, confidence }
    ├── subscription: { tier, expiry, features }
    └── biometrics: { heartRate, temperature }

analytics/
├── usage_stats
├── feature_adoption
└── conversion_metrics
```

## 🔐 Security Rules Example:
```javascript
// Firestore Security Rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      match /cycles/{cycleId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

## 💳 Subscription Management

### Firestore Schema for Subscriptions:
```typescript
interface UserSubscription {
  userId: string;
  tier: 'free' | 'premium' | 'professional';
  status: 'active' | 'canceled' | 'expired';
  startDate: Timestamp;
  endDate: Timestamp;
  platform: 'ios' | 'android' | 'web';
  features: string[];
  autoRenew: boolean;
}
```

## 📱 Setup Commands

### 1. Install Firebase CLI
```bash
npm install -g firebase-tools
firebase login
```

### 2. Initialize Firebase in Project
```bash
cd /Users/ronos/development/Flow Ai
firebase init
# Select: Functions, Firestore, Hosting, Storage, Emulators
```

### 3. Configure Flutter
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Configure Firebase for Flutter
flutterfire configure
```

## 🎯 Cost Estimation (Monthly)

### Free Tier Limits:
- **Authentication**: 50,000 users/month
- **Firestore**: 50k reads, 20k writes/day
- **Storage**: 5GB
- **Analytics**: Unlimited

### Estimated Costs at Scale:
```
Users     | Firestore | Storage | Functions | Total/Month
----------|-----------|---------|-----------|------------
1K        | $0        | $0      | $0        | $0 (Free)
10K       | $25       | $5      | $10       | $40
50K       | $200      | $25     | $100      | $325
100K      | $500      | $50     | $300      | $850
```

## 🔄 Migration Strategy

### Phase 1: Basic Setup
1. Create Firebase project
2. Add Authentication
3. Basic Firestore structure
4. Analytics integration

### Phase 2: Premium Features
1. Add Cloud Functions for AI processing
2. Implement subscription management
3. Add Cloud Messaging
4. Advanced analytics

### Phase 3: Enterprise
1. Multiple environment setup
2. Advanced security rules  
3. Custom domains
4. Professional tier features

## 📈 Analytics Events to Track

### User Engagement:
```typescript
// Track key user actions
firebase.analytics.logEvent('cycle_logged', {
  cycle_day: 5,
  flow_intensity: 'medium',
  symptoms_count: 3
});

firebase.analytics.logEvent('prediction_viewed', {
  confidence_level: 'high',
  days_ahead: 7
});

firebase.analytics.logEvent('premium_feature_attempted', {
  feature_name: 'biometric_sync',
  user_tier: 'free'
});
```

### Conversion Tracking:
```typescript
firebase.analytics.logEvent('subscription_started', {
  tier: 'premium',
  price: 4.99,
  trial_duration: 7
});
```
