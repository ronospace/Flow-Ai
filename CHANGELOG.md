# Changelog

All notable changes to Flow Ai will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0] - 2024-12-28

### Added
- **Progressive Disclosure Onboarding**: Interactive tutorials with smart skip logic and contextual help
- **Demo Data Mode**: Pre-populated realistic cycle data for app review and testing
- **iOS Firebase Workaround**: Local-first architecture for Xcode 15.5+ compatibility
- **Enhanced Visual Feedback**: Celebration animations on successful data saves
- **Real-time Sync Status**: Live Unsaved/Synced indicators in tracking UI
- **iOS Clean Build Documentation**: Step-by-step pod installation process

### Changed
- **Tracking Navigation**: Removed automatic tab switching for better user control
- **Symptom Tracking Flow**: Users can now properly complete Physical and Emotional subcategories
- **iOS Architecture**: Switched to local authentication and SQLite for offline-first design
- **Tab Animations**: Improved page transitions with custom 300ms animations
- **Save Feedback**: Enhanced success messages with emojis and visual celebrations

### Fixed
- **Auto-navigation Issue**: Fixed tabs automatically skipping symptom subcategories
- **iOS Build Errors**: Resolved Firebase Core 3.15.2 Objective-C parse errors on Xcode 15.5+
- **Tab Controller Sync**: Fixed page controller and tab controller synchronization
- **State Persistence**: Improved unsaved changes detection and warning dialogs
- **Animation Timing**: Adjusted celebration animation delays for better UX
- **Memory Management**: Better disposal of controllers and timers

### Technical
- Updated WARP.md with comprehensive Firebase workaround documentation
- Enhanced README.md with iOS-specific development notes
- Improved error handling for database operations
- Optimized offline-first data persistence layer
- Added inline documentation for tracking flow logic

### Performance
- ~500ms faster app launch on iOS without Firebase initialization overhead
- Enhanced save operation with visual feedback in <1s
- Smooth 300ms animated tab transitions
- Reduced memory usage from Firebase SDK removal on iOS

## [2.1.2] - 2024-11-15

### Added
- **AI Transparency**: View sources button for all AI predictions
- **Citation Dialogs**: Detailed methodology explanations with scientific references
- **Cycle Regularity Sources**: Statistical analysis, ML models, ACOG/WHO guidelines
- **Prediction Accuracy Sources**: Ensemble ML, biometric integration, continuous learning
- **Explainable AI**: Full transparency into prediction algorithms and confidence scoring

### Changed
- Enhanced insights UI with source attribution
- Improved AI prediction confidence display
- Updated prediction cards with citation links

### Fixed
- Minor UI inconsistencies in insights dashboard
- Prediction tooltip positioning issues

## [2.1.1] - 2024-10-30

### Added
- **Enhanced Biometric Integration**: Advanced health data pattern recognition
- **PCOS Detection**: Pattern recognition with risk scoring
- **Endometriosis Detection**: Symptom correlation analysis

### Changed
- Improved ML prediction accuracy with ensemble models
- Enhanced biometric data visualization

### Fixed
- Health data sync timing issues
- Biometric correlation calculation edge cases

## [2.1.0] - 2024-10-01

### Added
- **Advanced ML Models**: LSTM, Gaussian Process, Bayesian inference
- **Cycle Irregularity Detection**: Multi-algorithm approach with ensemble predictions
- **Fertility Window Optimization**: Hormone-based adjustments and uncertainty quantification
- **30-day Symptom Forecasting**: ML-based prediction with probability scores

### Changed
- Upgraded prediction engine to use ensemble of 4+ algorithms
- Enhanced AI confidence scoring with contributing factors
- Improved real-time learning feedback loops

### Technical
- Implemented MLIntegrationService for seamless AI engine coordination
- Added A/B testing framework for model comparison
- Enhanced model explainability features

## [2.0.0] - 2024-09-01

### Added
- **Production Release**: First stable version
- **36 Language Support**: Complete internationalization
- **Dark/Light Themes**: Full theme support with smooth transitions
- **AdMob Integration**: Monetization with non-intrusive ads
- **In-App Purchases**: Premium subscription features
- **Local Notifications**: Reminder system for tracking and predictions

### Changed
- Complete UI/UX redesign with feminine gradients
- Optimized performance across all platforms
- Enhanced accessibility with screen reader support

### Technical
- Implemented Provider state management
- GoRouter navigation with deep linking
- SQLite local database for offline-first architecture
- Firebase optional cloud sync

## [1.5.0] - 2024-07-15

### Added
- **Biometric Integration**: Apple Health and Google Fit sync
- **Pain Body Map**: Interactive symptom location tracking
- **Mood & Energy Tracking**: Emotional wellbeing monitoring
- **Calendar View**: Visual cycle timeline

## [1.0.0] - 2024-05-01

### Added
- **Initial Release**: Basic period and cycle tracking
- **Flow Intensity Tracking**: Spotting to very heavy flow levels
- **Symptom Tracking**: Common PMS and menstrual symptoms
- **Basic Predictions**: Cycle length and period start date
- **Notes**: Daily journal entries

---

## Version Naming Convention

- **Major** (X.0.0): Breaking changes, major feature releases
- **Minor** (x.Y.0): New features, enhancements, backward compatible
- **Patch** (x.y.Z): Bug fixes, minor improvements

## Build Number Format

Build numbers increment with each release: `Version 2.2.0` = Build `12`

---

**For detailed release information, see individual release notes:**
- [v2.2.0 Release Notes](RELEASE_NOTES_v2.2.0.md)
- [v2.1.2 Release Notes](RELEASE_NOTES_v2.1.2.md)
- [v2.0.0 Release Notes](RELEASE_NOTES_v2.0.0.md)
