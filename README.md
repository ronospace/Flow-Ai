# 🌸 Flow Ai

**AI-Powered Menstrual Health & Cycle Tracking Platform**

Flow Ai is a comprehensive period tracking application featuring advanced machine learning predictions, intelligent insights, biometric integration, and personalized health analytics.

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0.0-0175C2?logo=dart)](https://dart.dev)
[![iOS](https://img.shields.io/badge/iOS-16.0+-000000?logo=apple)](https://www.apple.com/ios)
[![Android](https://img.shields.io/badge/Android-7.0+-3DDC84?logo=android)](https://www.android.com)

## ✨ Current Version: 2.1.2+13

### 📱 App Store Status
- **iOS**: Submitted for review (Build 13) - Addressing privacy policy and demo account requirements
- **Android**: Ready for release
- **Privacy Policy**: [https://ronospace.github.io/ZyraFlow/](https://ronospace.github.io/ZyraFlow/)

### 🆕 Latest Features (v2.2.0 - November 2024)

#### **App Store Compliance & Privacy**
- 🔒 **Privacy Policy**: Comprehensive GDPR/CCPA/HIPAA compliant privacy policy
- 👤 **Demo Account**: Auto-created reviewer account (`demo@flowai.app`)
- 🛡️ **HealthKit Integration**: Full privacy disclosure and user consent flows
- 📄 **Data Export**: Complete user data export in PDF, CSV, JSON formats
- 🗑️ **Right to Delete**: GDPR-compliant account deletion with 30-day retention

#### **Enhanced Onboarding & User Experience**
- 🎓 **Progressive Disclosure**: Smart onboarding with interactive tutorials and feature discovery
- 🎭 **Demo Data Mode**: Pre-populated realistic cycle data for app review and testing
- ✨ **Improved Tracking Flow**: Manual tab control for better subcategory completion
- 📱 **iOS Optimization**: Local-first architecture with Firebase workaround for Xcode 15.5+
- 🎯 **Enhanced Visual Feedback**: Celebration animations and real-time sync indicators

#### **AI Transparency & Citations (v2.1.2)**
- 🔬 **View Sources**: Tap to see the science behind every prediction
- 📚 **Citation Dialogs**: Detailed methodology explanations for AI insights
- 🎯 **Cycle Regularity Sources**: Statistical analysis, ML models, medical guidelines (ACOG/WHO)
- 📊 **Prediction Accuracy Sources**: Ensemble ML models, biometric integration, continuous learning
- 🧠 **Explainable AI**: Full transparency into prediction algorithms and confidence scoring

## 🎯 Key Features

### 🤖 Advanced AI & Machine Learning
- **Ensemble Prediction Models**: SVM, Random Forest, Neural Networks, LSTM
- **Cycle Irregularity Detection**: Advanced pattern recognition and anomaly detection
- **Fertility Window Optimization**: Gaussian Process models with uncertainty quantification
- **Health Condition Detection**: PCOS and Endometriosis pattern analysis
- **Real-time Learning**: Continuous model improvement through user feedback
- **Confidence Scoring**: All predictions include reliability metrics

### 📊 Core Functionality
- 🩸 **Period Tracking**: Comprehensive cycle and flow monitoring
- 📅 **Calendar View**: Visual cycle timeline with predictions
- 💭 **Mood & Energy**: Emotional wellbeing tracking
- 🎯 **Pain Mapping**: Interactive body map for symptom tracking
- 🏥 **Biometric Integration**: Health data sync with Apple Health/Google Fit
- 📈 **Insights Dashboard**: AI-generated health insights and analytics

### 🎨 User Experience
- 🌗 **Dark/Light Themes**: Full theme support with smooth transitions
- 🌍 **Multi-Language Support**: 36 languages with complete localization
- 🔒 **Privacy-First**: Local data storage with optional encrypted EU cloud sync
- ♿ **Accessibility**: Screen reader support and inclusive design
- 🎭 **Beautiful UI**: Feminine gradients and smooth animations
- 🔐 **Biometric Auth**: Face ID, Touch ID, Fingerprint authentication
- 📤 **Data Portability**: Export all your data in multiple formats (PDF, CSV, JSON)

## 🏗️ Architecture

### **State Management**
- Provider pattern for feature-domain separation
- MLPredictionProvider for advanced ML integration
- CycleProvider, InsightsProvider, HealthProvider hierarchy

### **AI Engine Architecture**
```
lib/core/
├── services/
│   ├── ai_engine.dart                    # Legacy AI with cycle predictions
│   ├── enhanced_ai_engine.dart           # Advanced AI with biometrics
│   ├── ml_integration_service.dart       # Ensemble ML models
│   ├── auth_service.dart                 # Multi-provider authentication
│   ├── local_user_service.dart           # Offline-first local auth
│   ├── data_export_service.dart          # GDPR-compliant data export
│   └── progressive_disclosure_service.dart # Tutorial system
├── ml/
│   ├── advanced_prediction_models.dart      # Core ML algorithms
│   └── advanced_prediction_models_impl.dart # Implementation extensions
```

### **Feature Organization**
```
lib/features/
├── onboarding/        # App introduction & setup
├── cycle/             # Core tracking functionality
├── insights/          # AI insights & predictions
├── health/            # Biometric data integration
├── settings/          # User preferences
└── ml/                # ML prediction provider
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.8.1+
- Dart 3.0.0+
- iOS 16.0+ / Android 7.0+ (API 24+)
- Xcode 14+ (for iOS development)
- Android Studio / VS Code

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/ZyraFlow.git
cd ZyraFlow

# Install dependencies
flutter pub get

# Generate localizations
flutter gen-l10n

# Run the app
flutter run                           # Default device
flutter run -d chrome                 # Web
flutter run -d "iPhone 16 Pro Max"    # iOS Simulator (Firebase disabled)
```

### iOS Development Notes

**Firebase Workaround**: Due to Firebase Core 3.15.2 compatibility issues with Xcode 15.5+, Firebase is temporarily disabled for iOS builds. The app uses local authentication and offline-first architecture.

```bash
# Clean rebuild for iOS (if pods fail)
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
flutter run -d "iPhone 16 Pro Max"
```

### Build for Production

```bash
# Android App Bundle (Google Play)
flutter build appbundle --release

# Android APK
flutter build apk --release

# iOS IPA (macOS only, Firebase disabled)
flutter build ipa --release --no-codesign

# Web
flutter build web --release
```

## 📦 Release Builds

**Version 2.1.2+13** (Latest App Store Submission)
- **iOS IPA**: 29 MB (`build/ios/ipa/Flow Ai.ipa`) - Build 13 with updated demo account and privacy policy
- **Android App Bundle**: 61 MB (`build/app/outputs/bundle/release/app-release.aab`) - Build 12
- **Android APK**: 87 MB (`build/app/outputs/flutter-apk/app-release.apk`) - Build 12
- **Web**: Optimized PWA build available

**App Store Submission Status**:
- ✅ Privacy policy published: [https://ronospace.github.io/ZyraFlow/](https://ronospace.github.io/ZyraFlow/)
- ✅ Demo account configured: `demo@flowai.app` / `FlowAiDemo2025!`
- ✅ HealthKit usage description provided
- ✅ GDPR/CCPA/HIPAA compliance documented
- ⏳ iOS review pending (Build 13 submitted)
- ✅ Android ready for deployment

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run specific test
flutter test test/widget_test.dart

# Code analysis
flutter analyze
```

## 📱 Deployment

### App Store (iOS)
1. Update version in `pubspec.yaml`: `version: 2.1.2+XX`
2. Build IPA: `flutter build ipa --release`
3. Archive in Xcode: `open ios/Runner.xcworkspace` → Product → Archive
4. Open **Transporter** app
5. Upload `Flow Ai.ipa` from `build/ios/ipa/`
6. Submit via [App Store Connect](https://appstoreconnect.apple.com)
7. **Required for Review**:
   - Privacy Policy URL: `https://ronospace.github.io/ZyraFlow/`
   - Demo Account: `demo@flowai.app` / `FlowAiDemo2025!`
   - Review Notes: See `APP_STORE_RESUBMISSION_INSTRUCTIONS.md`

### Google Play (Android)
1. Update version in `pubspec.yaml`: `version: 2.1.2+XX`
2. Build AAB: `flutter build appbundle --release`
3. Upload `app-release.aab` to [Play Console](https://play.google.com/console)
4. Complete store listing with privacy policy link
5. Submit for review

## 🌍 Internationalization

**Supported Languages**: 36 languages including English, Spanish, French, German, Italian, Portuguese, Russian, Japanese, Chinese, Korean, Arabic, Hindi, Turkish, and more.

```bash
# Generate all language ARB files
dart generate_languages.dart

# Clean ARB files
dart clean_arb_files.dart

# Regenerate localization code
flutter gen-l10n
```

## 🔑 Key Dependencies

- **provider**: State management
- **go_router**: Type-safe navigation
- **table_calendar**: Cycle visualization
- **fl_chart**: Data visualization
- **health**: Biometric data integration
- **sqflite**: Local database
- **flutter_local_notifications**: Reminders
- **google_mobile_ads**: Monetization
- **in_app_purchase**: Premium subscriptions

## 📊 Project Structure

```
Flow Ai/
├── lib/
│   ├── core/               # Core services & utilities
│   │   ├── services/       # AI engines, notifications, ads
│   │   ├── ml/             # ML models & algorithms
│   │   ├── theme/          # App theme & styling
│   │   └── router/         # Navigation configuration
│   ├── features/           # Feature modules
│   │   ├── onboarding/
│   │   ├── cycle/
│   │   ├── insights/
│   │   ├── health/
│   │   └── settings/
│   └── l10n/               # Localization files
├── assets/                 # Images, icons, logos
├── android/                # Android platform code
├── ios/                    # iOS platform code
└── test/                   # Unit & widget tests
```

## 🛣️ Roadmap

See [MISSIONS_PENDING.md](MISSIONS_PENDING.md) and [COMING_SOON.md](COMING_SOON.md) for upcoming features.

## 📝 Documentation

### Release Notes
- [v2.1.2+13 - App Store Compliance & Privacy](RELEASE_NOTES_v2.1.2.md) ⭐ Latest
- [v2.2.0 - Enhanced Onboarding & iOS Optimization](RELEASE_NOTES_v2.2.0.md)
- [v2.0.0 - Production Release](RELEASE_NOTES_v2.0.0.md)
- [Complete Changelog](CHANGELOG.md)

### App Store Submission
- [Privacy Policy (Web)](https://ronospace.github.io/ZyraFlow/)
- [Privacy Policy (Markdown)](PRIVACY_POLICY.md)
- [App Store Resubmission Instructions](APP_STORE_RESUBMISSION_INSTRUCTIONS.md)
- [Quick Action Checklist](QUICK_ACTIONS_NEEDED.md)
- [App Store Marketing Copy](APP_STORE_COPY.txt)

### Project Planning
- [Pending Missions](MISSIONS_PENDING.md)
- [Coming Soon Features](COMING_SOON.md)
- [MSc Thesis Research Plan](THESIS_CONCEPT_FINAL.md)

## 🔒 Privacy & Security

### Data Protection
- **Local-First**: All health data stored locally by default
- **AES-256 Encryption**: Industry-standard encryption for sensitive data
- **Optional Cloud Sync**: EU-hosted Firebase with end-to-end encryption
- **Biometric Access Control**: Face ID, Touch ID, Fingerprint authentication
- **GDPR Compliant**: Right to access, export, rectify, and delete
- **CCPA Compliant**: California Consumer Privacy Act compliance
- **HIPAA Considerations**: Health data protection for US users

### User Rights
- **Data Export**: Download your data in PDF, CSV, or JSON format
- **Account Deletion**: Permanent deletion within 30 days
- **HealthKit Control**: Revoke access anytime in iOS Settings
- **Transparency**: Full AI model explainability and source citations

📄 **Full Privacy Policy**: [https://ronospace.github.io/ZyraFlow/](https://ronospace.github.io/ZyraFlow/)

## 🤝 Contributing

This is a private development project. For collaboration inquiries, please contact the maintainer.

## 📄 License

This project is proprietary software developed and maintained by **ZyraFlow Inc.™**

© 2025 ZyraFlow Inc.™ All rights reserved.

## 📧 Contact

- **Privacy Inquiries**: privacy@flowai.app
- **Data Protection Officer**: dpo@flowai.app
- **General Support**: [GitHub Issues](https://github.com/ronospace/Flow-Ai/issues)

## 💜 Built With

- Flutter & Dart
- Machine Learning (SVM, Random Forest, Neural Networks, LSTM)
- Apple HealthKit & Google Fit
- Provider State Management
- Firebase (optional cloud sync)

---

**Flow Ai - Building trust through AI transparency** 🌸

---

### 🏢 About ZyraFlow Inc.

ZyraFlow Inc.™ is dedicated to empowering women through innovative AI-powered health technology. Our mission is to provide accessible, privacy-first menstrual health tracking with transparency and scientific rigor.

**Developed and Maintained by ZyraFlow Inc.™**  
© 2025 ZyraFlow Inc. All rights reserved.

**Related Projects:**
- **Flow iQ** - [AI-powered clinical app for healthcare providers](https://github.com/ronospace/Flow-iQ)
- **Flow Ai** - Consumer menstrual health tracking (this project)
