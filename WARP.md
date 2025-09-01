# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Flow iQ is an AI-powered period and cycle tracking Flutter application with comprehensive multi-platform support (iOS, Android, Web) and internationalization for 36 languages. The app focuses on advanced AI predictions, personalized insights, and healthcare integration.

## Development Commands

### Essential Flutter Commands
```bash
# Install dependencies and generate code
flutter pub get
flutter gen-l10n

# Run development builds
flutter run                           # Debug mode on connected device
flutter run -d chrome                 # Web development
flutter run --release                 # Release mode for performance testing

# Code quality and testing
flutter analyze                       # Static analysis
flutter test                         # Run unit tests
flutter test test/widget_test.dart    # Run specific test

# Build for production
flutter build apk --release          # Android APK
flutter build appbundle --release    # Android App Bundle (Google Play)
flutter build ios --release --no-codesign  # iOS build
flutter build web --release          # Web build
```

### Localization Management
```bash
# Generate all 36 language ARB files
dart generate_languages.dart

# Clean ARB files (remove invalid comment keys)
dart clean_arb_files.dart

# Generate localization files after ARB updates
flutter gen-l10n
```

### Deployment Scripts
```bash
# Interactive deployment launcher
./deploy.sh

# Multi-platform deployment with options
./scripts/deploy-all.sh

# Platform-specific deployments
./scripts/deploy-web.sh
./scripts/deploy-android.sh
./scripts/deploy-ios.sh
```

## High-Level Architecture

### Core Architecture Pattern
- **State Management**: Provider pattern with dedicated providers for each feature domain
- **Navigation**: GoRouter with shell routes for bottom navigation and modal routes for full-screen dialogs
- **AI Engine**: Singleton service with enhanced prediction algorithms and pattern detection
- **Internationalization**: 36-language support with automated ARB generation and Flutter's built-in l10n

### Key Service Layer
```
lib/core/services/
├── ai_engine.dart              # Main AI service with predictive algorithms
├── enhanced_ai_engine.dart     # Advanced AI with biometric integration
├── notification_service.dart   # Local notifications management
├── admob_service.dart          # Ad monetization service
└── biometric_engine.dart       # Health data integration
```

### Feature-Based Organization
```
lib/features/
├── onboarding/                 # App introduction and setup
├── cycle/                      # Core tracking functionality
├── insights/                   # AI-generated insights and predictions
├── health/                     # Biometric data and health integration
├── biometric/                  # Advanced biometric dashboard
├── settings/                   # User preferences and configuration
├── community/                  # Social features (planned)
└── healthcare/                 # Healthcare provider integration (planned)
```

### AI Engine Architecture
The AI engine uses multiple prediction models:
- **Cycle Length Prediction**: Weighted historical data with confidence scoring
- **Symptom Forecasting**: Pattern recognition for symptom timing
- **Mood & Energy Prediction**: Cycle phase correlation analysis  
- **Anomaly Detection**: Statistical variance analysis for health insights
- **Personalization Engine**: User feedback loops for improved accuracy

### Provider Hierarchy
```
MultiProvider
├── OnboardingProvider          # First-time user experience
├── CycleProvider              # Core cycle data and tracking
├── InsightsProvider           # AI insights and analytics
├── HealthProvider             # Biometric and health data
└── SettingsProvider           # User preferences and theme
```

### Navigation Structure
- **Shell Route**: Main app with persistent bottom navigation (Home, Calendar, Tracking, Insights, Health, Settings)
- **Onboarding Flow**: Splash → Onboarding → Setup → Home
- **Modal Routes**: AI Coach screen as full-screen dialog

## Development Considerations

### AI Integration Focus
The app's competitive advantage lies in its AI capabilities. When working on predictions or insights:
- AI confidence scores should be prominently displayed
- User feedback loops are essential for improving accuracy  
- Biometric data integration is prepared but optional
- Pattern detection should surface actionable insights

### Internationalization Workflow
1. Update base English ARB files in `lib/l10n/`
2. Run `dart generate_languages.dart` to propagate to 36 languages
3. Run `flutter gen-l10n` to regenerate Dart localization code
4. All UI strings should use `AppLocalizations.of(context)`

### Multi-Platform Deployment
The deployment system supports all platforms simultaneously:
- **Web**: Firebase/Netlify/Vercel ready
- **Android**: Both APK and App Bundle generation with signing support
- **iOS**: Requires macOS for builds, handles code signing requirements

### Performance Considerations
- AI predictions use caching to avoid repeated calculations
- Biometric data sync happens in background with progress indicators
- Large datasets use pagination and lazy loading
- Image assets are optimized for different screen densities

### Testing Strategy
- Unit tests focus on AI prediction accuracy and data models
- Widget tests cover critical user flows (tracking, predictions)
- Integration tests verify AI engine initialization and provider interactions

## Key Dependencies
- **Provider**: State management across all features
- **GoRouter**: Type-safe navigation with deep linking support
- **flutter_localizations**: Built-in i18n support for 36 languages
- **table_calendar**: Customizable calendar widget for cycle visualization
- **fl_chart**: Data visualization for insights and analytics
- **health**: iOS/Android health data integration
- **sqflite**: Local SQLite database for cycle data persistence
- **flutter_local_notifications**: Reminder and prediction notifications

## Development Tips

### AI Engine Development
- Prediction confidence below 60% should trigger data collection prompts
- New AI models should be A/B tested against existing predictions
- User feedback on prediction accuracy is stored for model improvement

### Localization Development
- Use semantic keys in ARB files (`cycleStartDate` not `text1`)
- Gender-neutral language is preferred across all 36 languages
- Regional date/time formatting handled by Flutter's intl package

### Performance Optimization  
- Use `flutter build --analyze-size` to monitor app size across platforms
- AI calculations are debounced to avoid excessive computation
- Large language assets are loaded lazily based on user locale
