# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Flow Ai is an AI-powered period and cycle tracking Flutter application with comprehensive multi-platform support (iOS, Android, Web) and internationalization for 36 languages. The app focuses on advanced AI predictions, personalized insights, and healthcare integration.

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
├── ml_integration_service.dart # Advanced ML integration service
├── notification_service.dart   # Local notifications management
├── admob_service.dart          # Ad monetization service
└── biometric_engine.dart       # Health data integration
```

### Advanced ML System Architecture
```
lib/core/ml/
├── advanced_prediction_models.dart      # Core ML models and algorithms
├── advanced_prediction_models_impl.dart # Implementation extensions
└── lib/features/ml/providers/
    └── ml_prediction_provider.dart      # Flutter Provider integration
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
The AI engine uses multiple prediction models and advanced ML algorithms:

#### Legacy AI Models:
- **Cycle Length Prediction**: Weighted historical data with confidence scoring
- **Symptom Forecasting**: Pattern recognition for symptom timing
- **Mood & Energy Prediction**: Cycle phase correlation analysis  
- **Anomaly Detection**: Statistical variance analysis for health insights
- **Personalization Engine**: User feedback loops for improved accuracy

#### Advanced ML Models:
- **Cycle Irregularity Detection**: SVM, Random Forest, Neural Networks, Time Series analysis
- **Fertility Window Optimization**: LSTM, Gaussian Process, Bayesian inference, hormone-based models
- **Health Condition Detection**: PCOS and Endometriosis pattern recognition with risk scoring
- **Personalized Insights**: Multi-layered analysis with actionable recommendations
- **Symptom Prediction**: ML-based forecasting with timing, severity, and probability scores
- **Ensemble Predictions**: Weighted combination of multiple algorithms for maximum accuracy

#### ML Integration Features:
- **Real-time Learning**: Continuous model improvement through user feedback
- **Biometric Correlation**: Advanced health data pattern recognition
- **Medical Flags**: Automated detection of conditions requiring medical attention
- **Confidence Intervals**: All predictions include uncertainty quantification
- **Model Explainability**: Contributing factors and reasoning for each prediction

### Provider Hierarchy
```
MultiProvider
├── OnboardingProvider          # First-time user experience
├── CycleProvider              # Core cycle data and tracking
├── InsightsProvider           # AI insights and analytics
├── MLPredictionProvider       # Advanced ML predictions and analysis
├── HealthProvider             # Biometric and health data
└── SettingsProvider           # User preferences and theme
```

### Navigation Structure
- **Shell Route**: Main app with persistent bottom navigation (Home, Calendar, Tracking, Insights, Health, Settings)
- **Onboarding Flow**: Splash → Onboarding → Setup → Home
- **Modal Routes**: AI Coach screen as full-screen dialog

## Development Considerations

### Advanced ML Integration Focus
The app's competitive advantage lies in its advanced AI/ML capabilities:
- **Machine Learning Models**: Multiple algorithms (SVM, Random Forest, Neural Networks, LSTM)
- **Ensemble Predictions**: Combined predictions from multiple models for higher accuracy
- **Real-time Learning**: User feedback loops continuously improve model accuracy
- **Biometric Integration**: Advanced health data correlation and pattern recognition
- **Medical-grade Insights**: PCOS/Endometriosis detection, fertility optimization
- **Pattern Detection**: Complex cycle irregularities and health condition early warning
- **Confidence Scoring**: All predictions include confidence levels and contributing factors

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

### Advanced ML Development Workflow
#### Model Integration
```dart
// Initialize ML services
final mlProvider = MLPredictionProvider();

// Run comprehensive analysis
await mlProvider.analyzeCycle(
  user: userProfile,
  cycles: cycleData,
  trackingData: dailyTrackingData,
  biometricData: biometricData,
);

// Access ensemble predictions
final irregularityResult = mlProvider.irregularityResult;
final fertilityResult = mlProvider.fertilityResult;
final conditionResult = mlProvider.conditionResult;
```

#### ML Model Types & Usage
- **Ensemble Models**: Combine SVM (30%), Random Forest (25%), Neural Networks (30%), Time Series (15%)
- **LSTM Networks**: For sequential cycle pattern prediction with 12-cycle memory
- **Gaussian Processes**: For ovulation prediction with uncertainty quantification
- **Bayesian Models**: For fertility window optimization with prior belief updates
- **Feature Engineering**: Automated extraction of seasonal, trend, and biometric features
- **Model Explainability**: All predictions include contributing factors and confidence scores

#### Feedback Loop Implementation
```dart
// Submit user feedback for continuous learning
await mlProvider.submitFeedback(PredictionFeedback(
  type: FeedbackType.cyclePrediction,
  predictionId: 'prediction_123',
  accuracy: 0.85,
  userNotes: 'Prediction was accurate',
));
```

#### Performance Monitoring
- Model accuracy tracking with A/B testing capabilities
- Real-time confidence scoring for all predictions
- Automatic model retraining based on user feedback
- Ensemble weight optimization for improved accuracy

### Localization Development
- Use semantic keys in ARB files (`cycleStartDate` not `text1`)
- Gender-neutral language is preferred across all 36 languages
- Regional date/time formatting handled by Flutter's intl package

### Performance Optimization  
- Use `flutter build --analyze-size` to monitor app size across platforms
- AI calculations are debounced to avoid excessive computation
- Large language assets are loaded lazily based on user locale

## Advanced ML Features (COMPLETED)

### ✅ Cycle Irregularity Detection
- **Multi-Algorithm Approach**: SVM, Random Forest, Neural Networks, Time Series Analysis
- **Ensemble Predictions**: Weighted combination of multiple models (ML 50%, Enhanced 30%, Legacy 20%)
- **Pattern Analysis**: Seasonal trends, variability scoring, anomaly detection
- **Medical Flags**: Automatic detection of concerning patterns requiring medical attention
- **Risk Levels**: Low, Moderate, High, Critical with actionable recommendations

### ✅ Fertility Window Optimization
- **LSTM Networks**: Sequential pattern learning with 12-cycle memory for ovulation prediction
- **Gaussian Process Models**: Uncertainty quantification for fertility window predictions
- **Bayesian Inference**: Prior belief updates based on individual cycle history
- **Hormone-based Adjustments**: Temperature and heart rate correlation analysis
- **Biometric Integration**: Advanced health data pattern recognition
- **Probability Mapping**: Daily ovulation probability scores with confidence intervals

### ✅ Health Condition Detection
- **PCOS Pattern Recognition**: Advanced scoring algorithm with risk assessment
- **Endometriosis Detection**: Symptom correlation and cycle pattern analysis
- **Medical Attention Flags**: Automated alerts for conditions requiring healthcare consultation
- **Risk Factor Analysis**: Contributing factors identification with explanations
- **Condition Scoring**: Continuous risk assessment with threshold-based alerts

### ✅ Personalized Health Insights
- **Multi-layered Analysis**: Combining cycle data, symptoms, biometrics, and lifestyle factors
- **Actionable Recommendations**: Specific, personalized health guidance
- **Health Trend Analysis**: Long-term pattern recognition and projection
- **Confidence Scoring**: All insights include reliability and contributing factor analysis
- **Severity Categorization**: Critical, Warning, Informational insight classification

### ✅ Symptom Prediction
- **ML-based Forecasting**: Probability, timing, and severity prediction for upcoming symptoms
- **Contributing Factor Analysis**: Identification of triggers and patterns
- **30-day Prediction Horizon**: Extended symptom forecasting with confidence intervals
- **Ensemble Prediction**: Legacy + ML model combination for enhanced accuracy

### ✅ Advanced Integration Architecture
- **MLIntegrationService**: Seamless integration with existing AI engines
- **Event-driven Architecture**: Real-time ML prediction events and state management
- **Flutter Provider Integration**: Complete state management for UI integration
- **Legacy Compatibility**: Backward compatibility with existing AI systems
- **Performance Optimization**: Caching, debouncing, and efficient computation

### ✅ User Feedback & Learning System
- **Continuous Learning**: Real-time model improvement through user feedback
- **Prediction Accuracy Tracking**: Individual model performance monitoring
- **A/B Testing Ready**: Framework for testing new ML models against existing ones
- **Model Weight Optimization**: Dynamic ensemble weight adjustment based on performance
- **Explainable AI**: All predictions include reasoning and contributing factors
