# 🌸 Flow Ai

**AI-Powered Menstrual Health & Cycle Tracking Platform**

Flow Ai is a comprehensive period tracking application featuring advanced machine learning predictions, intelligent insights, biometric integration, and personalized health analytics.

[![Flutter](https://img.shields.io/badge/Flutter-3.8.1-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.0.0-0175C2?logo=dart)](https://dart.dev)
[![iOS](https://img.shields.io/badge/iOS-16.0+-000000?logo=apple)](https://www.apple.com/ios)
[![Android](https://img.shields.io/badge/Android-7.0+-3DDC84?logo=android)](https://www.android.com)

## ✨ Current Version: 2.1.2

### 🆕 Latest Features (v2.1.2)

#### **AI Transparency & Citations**
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
- 🔒 **Privacy-First**: Local data storage with optional cloud sync
- ♿ **Accessibility**: Screen reader support and inclusive design
- 🎭 **Beautiful UI**: Feminine gradients and smooth animations

## 🏗️ Architecture

### **State Management**
- Provider pattern for feature-domain separation
- MLPredictionProvider for advanced ML integration
- CycleProvider, InsightsProvider, HealthProvider hierarchy

### **AI Engine**
```
lib/core/
├── services/
│   ├── ai_engine.dart              # Legacy AI with cycle predictions
│   ├── enhanced_ai_engine.dart     # Advanced AI with biometrics
│   └── ml_integration_service.dart # Ensemble ML models
├── ml/
│   ├── advanced_prediction_models.dart
│   └── advanced_prediction_models_impl.dart
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
flutter run
```

### Build for Production

```bash
# Android App Bundle (Google Play)
flutter build appbundle --release

# Android APK
flutter build apk --release

# iOS IPA (macOS only)
flutter build ipa --release
```

## 📦 Release Builds

**Version 2.1.2+11**
- **Android App Bundle**: 61 MB (`build/app/outputs/bundle/release/app-release.aab`)
- **Android APK**: 87 MB (`build/app/outputs/flutter-apk/app-release.apk`)
- **iOS IPA**: 29 MB (`build/ios/ipa/Flow Ai.ipa`)

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
1. Build IPA: `flutter build ipa --release`
2. Open **Transporter** app
3. Upload `Flow Ai.ipa` from `build/ios/ipa/`
4. Submit via [App Store Connect](https://appstoreconnect.apple.com)

### Google Play (Android)
1. Build AAB: `flutter build appbundle --release`
2. Upload `app-release.aab` to [Play Console](https://play.google.com/console)
3. Complete store listing and submit for review

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

## 📝 Release Notes

- [v2.1.2 - AI Transparency & Citations](RELEASE_NOTES_v2.1.2.md)
- [v2.0.0 - Production Release](RELEASE_NOTES_v2.0.0.md)

## 🤝 Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

## 📄 License

This project is proprietary software. All rights reserved.

## 💜 Built With

- Flutter & Dart
- Machine Learning (SVM, Random Forest, Neural Networks, LSTM)
- Apple HealthKit & Google Fit
- Provider State Management
- Firebase (optional cloud sync)

---

**Flow Ai - Building trust through AI transparency** 🌸
