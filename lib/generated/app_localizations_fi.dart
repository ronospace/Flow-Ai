// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Finnish (`fi`).
class AppLocalizationsFi extends AppLocalizations {
  AppLocalizationsFi([String locale = 'fi']) : super(locale);

  @override
  String get appName => 'Flow Ai';

  @override
  String get appTagline => 'AI-pohjainen Kuukautiskierron Seuranta';

  @override
  String get appDescription =>
      'Track your menstrual cycle with intelligent insights and personalized recommendations for better reproductive health.';

  @override
  String get home => 'Koti';

  @override
  String get calendar => 'Kalenteri';

  @override
  String get tracking => 'Seuranta';

  @override
  String get insights => 'Oivallukset';

  @override
  String get settings => 'Asetukset';

  @override
  String cycleDay(int day) {
    return 'Day $day';
  }

  @override
  String cycleLength(int length) {
    return 'Cycle Length: $length days';
  }

  @override
  String daysUntilPeriod(int days) {
    return '$days days until period';
  }

  @override
  String daysUntilOvulation(int days) {
    return '$days days until ovulation';
  }

  @override
  String get currentPhase => 'Current Phase';

  @override
  String get menstrualPhase => 'Menstrual';

  @override
  String get follicularPhase => 'Follicular';

  @override
  String get ovulatoryPhase => 'Ovulatory';

  @override
  String get lutealPhase => 'Luteal';

  @override
  String get fertileWindow => 'Fertile Window';

  @override
  String get ovulationDay => 'Ovulation Day';

  @override
  String get periodStarted => 'Period Started';

  @override
  String get periodEnded => 'Period Ended';

  @override
  String get flowIntensity => 'Flow Intensity';

  @override
  String get flowNone => 'None';

  @override
  String get flowSpotting => 'Spotting';

  @override
  String get flowLight => 'Light';

  @override
  String get flowMedium => 'Medium';

  @override
  String get flowHeavy => 'Heavy';

  @override
  String get flowVeryHeavy => 'Very Heavy';

  @override
  String get symptoms => 'Symptoms';

  @override
  String get noSymptoms => 'No symptoms';

  @override
  String get cramps => 'Cramps';

  @override
  String get bloating => 'Bloating';

  @override
  String get headache => 'Headache';

  @override
  String get backPain => 'Back Pain';

  @override
  String get breastTenderness => 'Breast Tenderness';

  @override
  String get fatigue => 'Fatigue';

  @override
  String get moodSwings => 'Mood Swings';

  @override
  String get acne => 'Acne';

  @override
  String get nausea => 'Nausea';

  @override
  String get cravings => 'Cravings';

  @override
  String get insomnia => 'Insomnia';

  @override
  String get hotFlashes => 'Hot Flashes';

  @override
  String get coldFlashes => 'Cold Flashes';

  @override
  String get diarrhea => 'Diarrhea';

  @override
  String get constipation => 'Constipation';

  @override
  String get mood => 'Mood';

  @override
  String get energy => 'Energy';

  @override
  String get pain => 'Pain';

  @override
  String get moodHappy => 'Happy';

  @override
  String get moodNeutral => 'Neutral';

  @override
  String get moodSad => 'Sad';

  @override
  String get moodAnxious => 'Anxious';

  @override
  String get moodIrritated => 'Irritated';

  @override
  String get energyHigh => 'High Energy';

  @override
  String get energyMedium => 'Medium Energy';

  @override
  String get energyLow => 'Low Energy';

  @override
  String get painNone => 'No Pain';

  @override
  String get painMild => 'Mild Pain';

  @override
  String get painModerate => 'Moderate Pain';

  @override
  String get painSevere => 'Severe Pain';

  @override
  String get predictions => 'Predictions';

  @override
  String get nextPeriod => 'Next Period';

  @override
  String get nextOvulation => 'Next Ovulation';

  @override
  String predictedDate(String date) {
    return 'Predicted: $date';
  }

  @override
  String confidence(int percentage) {
    return 'Confidence: $percentage%';
  }

  @override
  String get aiPoweredPredictions => 'AI-Powered Predictions';

  @override
  String get advancedInsights => 'Advanced Insights';

  @override
  String get personalizedRecommendations => 'Personalized Recommendations';

  @override
  String get cycleInsights => 'Cycle Insights';

  @override
  String get patternAnalysis => 'Pattern Analysis';

  @override
  String get cycleTrends => 'Cycle Trends';

  @override
  String get symptomPatterns => 'Symptom Patterns';

  @override
  String get moodPatterns => 'Mood Patterns';

  @override
  String get regularCycle => 'Your cycle is regular';

  @override
  String get irregularCycle => 'Your cycle shows some irregularity';

  @override
  String cycleVariation(int days) {
    return 'Cycle variation: ±$days days';
  }

  @override
  String averageCycleLength(int days) {
    return 'Average cycle length: $days days';
  }

  @override
  String get lifestyle => 'Lifestyle';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get exercise => 'Exercise';

  @override
  String get wellness => 'Wellness';

  @override
  String get sleepBetter => 'Improve your sleep quality';

  @override
  String get stayHydrated => 'Stay hydrated';

  @override
  String get gentleExercise => 'Try gentle exercise like yoga';

  @override
  String get eatIronRich => 'Eat iron-rich foods';

  @override
  String get takeBreaks => 'Take regular breaks';

  @override
  String get manageStress => 'Practice stress management';

  @override
  String get warmBath => 'Take a warm bath';

  @override
  String get meditation => 'Try meditation or deep breathing';

  @override
  String get logToday => 'Log Today';

  @override
  String get trackFlow => 'Track Flow';

  @override
  String get trackSymptoms => 'Track Symptoms';

  @override
  String get trackMood => 'Track Mood';

  @override
  String get trackPain => 'Track Pain';

  @override
  String get addNotes => 'Add Notes';

  @override
  String get notes => 'Notes';

  @override
  String get save => 'Tallenna';

  @override
  String get cancel => 'Peruuta';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get update => 'Update';

  @override
  String get confirm => 'Confirm';

  @override
  String get thisMonth => 'This Month';

  @override
  String get nextMonth => 'Next Month';

  @override
  String get previousMonth => 'Previous Month';

  @override
  String get today => 'Today';

  @override
  String get selectDate => 'Select Date';

  @override
  String get periodDays => 'Period Days';

  @override
  String get fertileDays => 'Fertile Days';

  @override
  String get ovulationDays => 'Ovulation Days';

  @override
  String get symptomDays => 'Symptom Days';

  @override
  String get profile => 'Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Privacy';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get export => 'Export Data';

  @override
  String get backup => 'Backup';

  @override
  String get help => 'Help';

  @override
  String get about => 'About';

  @override
  String get version => 'Version';

  @override
  String get contactSupport => 'Contact Support';

  @override
  String get rateApp => 'Rate App';

  @override
  String get shareApp => 'Share App';

  @override
  String get personalInfo => 'Personal Information';

  @override
  String get age => 'Age';

  @override
  String get height => 'Height';

  @override
  String get weight => 'Weight';

  @override
  String get cycleHistory => 'Cycle History';

  @override
  String get avgCycleLength => 'Average Cycle Length';

  @override
  String get avgPeriodLength => 'Average Period Length';

  @override
  String get lastPeriod => 'Last Period';

  @override
  String get periodPreferences => 'Period Preferences';

  @override
  String get trackingGoals => 'Tracking Goals';

  @override
  String get periodReminder => 'Period Reminder';

  @override
  String get ovulationReminder => 'Ovulation Reminder';

  @override
  String get pillReminder => 'Pill Reminder';

  @override
  String get symptomReminder => 'Symptom Tracking Reminder';

  @override
  String get insightNotifications => 'Insight Notifications';

  @override
  String get enableNotifications => 'Enable Notifications';

  @override
  String get notificationTime => 'Notification Time';

  @override
  String reminderDays(int days) {
    return '$days days before';
  }

  @override
  String get healthData => 'Health Data';

  @override
  String get connectHealthApp => 'Connect to Health App';

  @override
  String get syncData => 'Sync Data';

  @override
  String get heartRate => 'Heart Rate';

  @override
  String get sleepData => 'Sleep Data';

  @override
  String get steps => 'Steps';

  @override
  String get temperature => 'Body Temperature';

  @override
  String get bloodPressure => 'Blood Pressure';

  @override
  String get aiInsights => 'AI Insights';

  @override
  String get smartPredictions => 'Smart Predictions';

  @override
  String get personalizedTips => 'Personalized Tips';

  @override
  String get patternRecognition => 'Pattern Recognition';

  @override
  String get anomalyDetection => 'Anomaly Detection';

  @override
  String get learningFromData => 'Learning from your data...';

  @override
  String get improvingAccuracy => 'Improving prediction accuracy';

  @override
  String get adaptingToPatterns => 'Adapting to your patterns';

  @override
  String get welcome => 'Tervetuloa Flow Aien';

  @override
  String get getStarted => 'Aloita';

  @override
  String get skipForNow => 'Skip for Now';

  @override
  String get next => 'Next';

  @override
  String get previous => 'Previous';

  @override
  String get finish => 'Finish';

  @override
  String get setupProfile => 'Setup Your Profile';

  @override
  String get trackingPermissions => 'Tracking Permissions';

  @override
  String get notificationPermissions => 'Notification Permissions';

  @override
  String get healthPermissions => 'Health App Permissions';

  @override
  String get onboardingStep1 => 'Track your cycle with precision';

  @override
  String get onboardingStep2 => 'Get AI-powered insights';

  @override
  String get onboardingStep3 => 'Receive personalized recommendations';

  @override
  String get onboardingStep4 => 'Monitor your reproductive health';

  @override
  String get error => 'Error';

  @override
  String get success => 'Success';

  @override
  String get warning => 'Warning';

  @override
  String get info => 'Info';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data available';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get tryAgain => 'Try Again';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get dataUpdated => 'Data updated successfully';

  @override
  String get dataSaved => 'Data saved successfully';

  @override
  String get dataDeleted => 'Data deleted successfully';

  @override
  String get invalidInput => 'Invalid input';

  @override
  String get fieldRequired => 'This field is required';

  @override
  String get selectAtLeastOne => 'Please select at least one option';

  @override
  String get days => 'days';

  @override
  String get weeks => 'weeks';

  @override
  String get months => 'months';

  @override
  String get years => 'years';

  @override
  String get kg => 'kg';

  @override
  String get lbs => 'lbs';

  @override
  String get cm => 'cm';

  @override
  String get inches => 'inches';

  @override
  String get celsius => '°C';

  @override
  String get fahrenheit => '°F';

  @override
  String get morning => 'Morning';

  @override
  String get afternoon => 'Afternoon';

  @override
  String get evening => 'Evening';

  @override
  String get night => 'Night';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String get trackingScreenTitle => 'Tracking';

  @override
  String get flowTab => 'Flow';

  @override
  String get symptomsTab => 'Symptoms';

  @override
  String get moodTab => 'Mood';

  @override
  String get painTab => 'Pain';

  @override
  String get notesTab => 'Notes';

  @override
  String get selectTodaysFlowIntensity => 'Select today\'s flow intensity';

  @override
  String get selectAllSymptoms => 'Select all symptoms you\'re experiencing';

  @override
  String get moodAndEnergy => 'Mood & Energy';

  @override
  String get howAreYouFeelingToday => 'How are you feeling today?';

  @override
  String get painLevel => 'Pain Level';

  @override
  String get rateOverallPainLevel => 'Rate your overall pain level';

  @override
  String get personalNotes => 'Personal Notes';

  @override
  String get captureThoughtsAndFeelings =>
      'Capture your thoughts, feelings, and observations about your cycle';

  @override
  String get todaysJournalEntry => 'Today\'s Journal Entry';

  @override
  String get quickNotes => 'Quick Notes';

  @override
  String get notesPlaceholder =>
      'How are you feeling today? Any symptoms, mood changes, or observations you\'d like to remember?\n\nTip: Recording your thoughts helps identify patterns over time.';

  @override
  String charactersCount(int count) {
    return '$count chars';
  }

  @override
  String get sleepQuality => 'Sleep Quality';

  @override
  String get foodCravings => 'Food cravings';

  @override
  String get hydration => 'Hydration';

  @override
  String get energyLevels => 'Energy levels';

  @override
  String get stressManagement => 'Stress management';

  @override
  String get saveTrackingData => 'Save Tracking Data';

  @override
  String get noChangesToSave => 'No Changes to Save';

  @override
  String trackingDataSaved(String date) {
    return 'Tracking data saved for $date';
  }

  @override
  String get yesterday => 'Yesterday';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get thisWeek => 'This Week';

  @override
  String get lastWeek => 'Last Week';

  @override
  String get nextWeek => 'Next Week';

  @override
  String get yes => 'Kyllä';

  @override
  String get no => 'Ei';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Done';

  @override
  String get close => 'Close';

  @override
  String get open => 'Open';

  @override
  String get view => 'View';

  @override
  String get hide => 'Hide';

  @override
  String get show => 'Show';

  @override
  String get enable => 'Enable';

  @override
  String get disable => 'Disable';

  @override
  String get on => 'On';

  @override
  String get off => 'Off';

  @override
  String get high => 'High';

  @override
  String get medium => 'Medium';

  @override
  String get low => 'Low';

  @override
  String get none => 'None';

  @override
  String get all => 'All';

  @override
  String get search => 'Search';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sort';

  @override
  String get refresh => 'Refresh';

  @override
  String get clear => 'Clear';

  @override
  String get reset => 'Reset';

  @override
  String get apply => 'Apply';

  @override
  String get loadingAiEngine => 'Initializing AI Health Engine...';

  @override
  String get analyzingHealthPatterns => 'Analyzing your health patterns';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get aiActive => 'AI Active';

  @override
  String get health => 'Health';

  @override
  String get optimal => 'Optimal';

  @override
  String get cycleStatus => 'Cycle Status';

  @override
  String get notStarted => 'Not Started';

  @override
  String get moodBalance => 'Mood Balance';

  @override
  String get notTracked => 'Not Tracked';

  @override
  String get energyLevel => 'Energy Level';

  @override
  String get flowIntensityMetric => 'Flow Intensity';

  @override
  String get logSymptoms => 'Log Symptoms';

  @override
  String get trackYourHealth => 'Track your health';

  @override
  String get periodTracker => 'Period Tracker';

  @override
  String get startLogging => 'Start logging';

  @override
  String get logWellness => 'Log wellness';

  @override
  String get viewAnalysis => 'View analysis';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get highConfidence => 'High confidence';

  @override
  String get gatheringDataForPredictions => 'Gathering Data for Predictions';

  @override
  String get startTrackingForPredictions =>
      'Start tracking your cycles to unlock AI predictions';

  @override
  String get aiLearningPatterns => 'AI Learning Your Patterns';

  @override
  String get trackForInsights =>
      'Track your cycles to unlock personalized AI insights';

  @override
  String get cycleRegularity => 'Cycle Regularity';

  @override
  String get fromLastMonth => '+5% from last month';

  @override
  String get avgCycle => 'Avg Cycle';

  @override
  String get avgMood => 'Avg Mood';

  @override
  String get daysCycle => '28.5 days';

  @override
  String get moodRating => '4.2/5';

  @override
  String get chooseTheme => 'Choose Theme';

  @override
  String get lightTheme => 'Light Theme';

  @override
  String get lightThemeDescription => 'Bright and clean appearance';

  @override
  String get darkTheme => 'Dark Theme';

  @override
  String get darkThemeDescription => 'Easy on the eyes in low light';

  @override
  String get biometricDashboard => 'Biometric Dashboard';

  @override
  String get currentCycle => 'Current Cycle';

  @override
  String get noActiveCycle => 'No active cycle';

  @override
  String get startTracking => 'Start Tracking';

  @override
  String get aiPrediction => 'AI Prediction';

  @override
  String inDays(int days) {
    return 'In $days days';
  }

  @override
  String get smartActionCommandCenter => 'Smart Action Command Center';

  @override
  String get quickAccessToEssentialFeatures =>
      'Quick access to essential features';

  @override
  String get physical => 'Physical';

  @override
  String get emotional => 'Emotional';

  @override
  String get skinAndHair => 'Skin & Hair';

  @override
  String get digestive => 'Digestive';

  @override
  String get moodSwingsSymptom => 'Mood swings';

  @override
  String get irritability => 'Irritability';

  @override
  String get anxiety => 'Anxiety';

  @override
  String get depression => 'Depression';

  @override
  String get emotionalSensitivity => 'Emotional sensitivity';

  @override
  String get stress => 'Stress';

  @override
  String get oilySkin => 'Oily skin';

  @override
  String get drySkin => 'Dry skin';

  @override
  String get hairChanges => 'Hair changes';

  @override
  String get lossOfAppetite => 'Loss of appetite';

  @override
  String selectedSymptoms(int count) {
    return 'Selected Symptoms ($count)';
  }

  @override
  String get noMenstrualFlow => 'No menstrual flow';

  @override
  String get minimalDischarge => 'Minimal discharge';

  @override
  String get comfortableProtection => 'Comfortable protection';

  @override
  String get lightFlow => 'Light Flow';

  @override
  String get normalFlow => 'Normal Flow';

  @override
  String get typicalMenstruation => 'Typical menstruation';

  @override
  String get heavyFlow => 'Heavy Flow';

  @override
  String get highAbsorptionNeeded => 'High absorption needed';

  @override
  String get veryHeavy => 'Very Heavy';

  @override
  String get medicalAttentionAdvised => 'Medical attention advised';

  @override
  String get spotting => 'Spotting';

  @override
  String get flow => 'Flow';

  @override
  String get systemTheme => 'System Theme';

  @override
  String get systemThemeDescription => 'Matches your device settings';

  @override
  String get themeChangedTo => 'Theme changed to';

  @override
  String get chooseLanguage => 'Choose Language';

  @override
  String get searchLanguages => 'Search languages...';

  @override
  String get languageChangedTo => 'Language changed to';

  @override
  String get appPreferences => 'App Preferences';

  @override
  String get customizeAppearance => 'Customize app appearance';

  @override
  String get chooseYourLanguage => 'Choose your language';

  @override
  String get receiveReminders => 'Receive reminders and updates';

  @override
  String get dailyReminders => 'When to send daily reminders';

  @override
  String get unlockPremiumAiInsights => 'Unlock Premium AI Insights';

  @override
  String get watchAdToUnlockInsights =>
      'Watch an ad to unlock advanced insights';

  @override
  String get free => 'FREE';

  @override
  String get watchAdUnlockInsights => 'Watch Ad & Unlock Insights';

  @override
  String get getAdditionalPremiumInsights =>
      'Get 3 additional premium insights';

  @override
  String get unlockAdvancedHealthRecommendations =>
      'Unlock advanced health recommendations';

  @override
  String get premiumInsightsUnlocked => 'Premium insights unlocked! 🎉';

  @override
  String day(int day) {
    return 'Day $day';
  }

  @override
  String confidencePercentage(int percentage) {
    return '$percentage% confidence';
  }

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get logPeriod => 'Log Period';

  @override
  String get currentCycleTitle => 'Current Cycle';

  @override
  String get moodLabel => 'Mood';

  @override
  String get aiSmartFeatures => 'AI & Smart Features';

  @override
  String get personalizedAiInsights => 'Get personalized AI insights';

  @override
  String get hapticFeedback => 'Haptic Feedback';

  @override
  String get vibrationInteractions => 'Feel vibrations on interactions';

  @override
  String get supportAbout => 'Support & About';

  @override
  String get getHelpTutorials => 'Get help and tutorials';

  @override
  String get versionInfoLegal => 'Version info and legal';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get flowIntensityNone => 'None';

  @override
  String get flowIntensityNoneSubtitle => 'No menstrual flow';

  @override
  String get flowIntensityNoneDescription =>
      'Complete absence of menstrual flow. This is normal before your period starts or after it ends.';

  @override
  String get flowIntensityNoneMedicalInfo => 'No menstruation occurring';

  @override
  String get flowIntensitySpotting => 'Spotting';

  @override
  String get flowIntensitySpottingSubtitle => 'Minimal discharge';

  @override
  String get flowIntensitySpottingDescription =>
      'Very light pink or brown discharge. Often occurs at the beginning or end of your cycle.';

  @override
  String get flowIntensitySpottingMedicalInfo => 'Less than 5ml per day';

  @override
  String get flowIntensityLight => 'Light Flow';

  @override
  String get flowIntensityLightSubtitle => 'Comfortable protection';

  @override
  String get flowIntensityLightDescription =>
      'Light menstrual flow requiring minimal protection. Usually lasts 1-3 days.';

  @override
  String get flowIntensityLightMedicalInfo => '5-40ml per day';

  @override
  String get flowIntensityMedium => 'Normal Flow';

  @override
  String get flowIntensityMediumSubtitle => 'Typical menstruation';

  @override
  String get flowIntensityMediumDescription =>
      'Regular menstrual flow. This is the most common flow intensity for healthy cycles.';

  @override
  String get flowIntensityMediumMedicalInfo => '40-70ml per day';

  @override
  String get flowIntensityHeavy => 'Heavy Flow';

  @override
  String get flowIntensityHeavySubtitle => 'High absorption needed';

  @override
  String get flowIntensityHeavyDescription =>
      'Heavy menstrual flow requiring frequent changes. Consider consulting a healthcare provider.';

  @override
  String get flowIntensityHeavyMedicalInfo => '70-100ml per day';

  @override
  String get flowIntensityVeryHeavy => 'Very Heavy';

  @override
  String get flowIntensityVeryHeavySubtitle => 'Medical attention advised';

  @override
  String get flowIntensityVeryHeavyDescription =>
      'Very heavy flow that may interfere with daily activities. Strongly recommend consulting a healthcare provider.';

  @override
  String get flowIntensityVeryHeavyMedicalInfo => 'Over 100ml per day';

  @override
  String get aiHealthInsights => 'AI Health Insights';

  @override
  String get aboutThisFlowLevel => 'About This Flow Level';

  @override
  String get recommendedProducts => 'Recommended Products';

  @override
  String hourlyChanges(int changes) {
    return '~$changes/hour changes';
  }

  @override
  String get monitor => 'Monitor';

  @override
  String get spottingInsight =>
      'Spotting is often normal at cycle start/end. Track patterns for insights.';

  @override
  String get lightFlowInsight =>
      'Light flow detected. Consider stress levels and nutrition for optimal health.';

  @override
  String get mediumFlowInsight =>
      'Normal flow pattern. Your cycle appears healthy and regular.';

  @override
  String get heavyFlowInsight =>
      'Heavy flow detected. Monitor symptoms and consider iron-rich foods.';

  @override
  String get veryHeavyFlowInsight =>
      'Very heavy flow may need medical attention. Track duration carefully.';

  @override
  String get noFlowInsight =>
      'No flow detected. Track other symptoms for comprehensive insights.';

  @override
  String get pantyLiners => 'Panty liners';

  @override
  String get periodUnderwear => 'Period underwear';

  @override
  String get lightPads => 'Light pads';

  @override
  String get tamponsRegular => 'Tampons (regular)';

  @override
  String get menstrualCups => 'Menstrual cups';

  @override
  String get regularPads => 'Regular pads';

  @override
  String get tamponsSuper => 'Tampons (super)';

  @override
  String get periodUnderwearHeavy => 'Period underwear (heavy)';

  @override
  String get superPads => 'Super pads';

  @override
  String get tamponsSuperPlus => 'Tampons (super+)';

  @override
  String get menstrualCupsLarge => 'Menstrual cups (large)';

  @override
  String get ultraPads => 'Ultra pads';

  @override
  String get tamponsUltra => 'Tampons (ultra)';

  @override
  String get menstrualCupsXL => 'Menstrual cups (XL)';

  @override
  String get medicalConsultation => 'Medical consultation';

  @override
  String get aiPoweredHealthInsights => 'AI-Powered Health Insights';

  @override
  String get healthDataAccessNotGranted =>
      'Health data access not granted. Please enable in settings.';

  @override
  String get failedToInitializeBiometricDashboard =>
      'Failed to initialize biometric dashboard';

  @override
  String get failedToLoadBiometricData => 'Failed to load biometric data';

  @override
  String biometricDataRefreshedAt(String time) {
    return 'Biometric data refreshed at $time';
  }

  @override
  String get failedToRefreshData => 'Failed to refresh data';

  @override
  String get overview => 'Overview';

  @override
  String get metrics => 'Metrics';

  @override
  String get sync => 'Sync';

  @override
  String get healthDataConnected => 'Health Data Connected';

  @override
  String get limitedHealthData => 'Limited Health Data';

  @override
  String dataCompleteness(int percentage) {
    return 'Data completeness: $percentage%';
  }

  @override
  String get connectMoreDevicesForBetterInsights =>
      'Connect more devices for better insights';

  @override
  String updatedAt(String time) {
    return 'Updated $time';
  }

  @override
  String get overallHealthScore => 'Overall Health Score';

  @override
  String get avgHeartRate => 'Avg Heart Rate';

  @override
  String get bodyTemp => 'Body Temp';

  @override
  String get stressLevel => 'Stress Level';

  @override
  String get bpm => 'BPM';

  @override
  String get percent => '%';

  @override
  String get degreesF => '°F';

  @override
  String get outOfTen => '/10';

  @override
  String get recentTrends => 'Recent Trends';

  @override
  String basedOnLastDaysOfData(int days) {
    return 'Based on the last $days days of data';
  }

  @override
  String get sleepQualityImproving => 'Sleep quality';

  @override
  String get improving => 'Improving';

  @override
  String get stressLevels => 'Stress levels';

  @override
  String get stable => 'Stable';

  @override
  String get heartRateMetric => 'Heart rate';

  @override
  String get slightlyElevated => 'Slightly elevated';

  @override
  String get heartRateChart => 'Heart Rate';

  @override
  String get sleepQualityChart => 'Sleep Quality';

  @override
  String get bodyTemperatureChart => 'Body Temperature';

  @override
  String get heartRateVariabilityChart => 'Heart Rate Variability';

  @override
  String get stressLevelChart => 'Stress Level';

  @override
  String get aiHealthInsightsTitle => 'AI Health Insights';

  @override
  String get personalizedInsightsBasedOnBiometricPatterns =>
      'Personalized insights based on your biometric patterns';

  @override
  String get noInsightsAvailable => 'No Insights Available';

  @override
  String get keepTrackingHealthDataForAiInsights =>
      'Keep tracking your health data to get personalized AI insights';

  @override
  String get connectedDevices => 'Connected Devices';

  @override
  String get iphoneHealth => 'iPhone Health';

  @override
  String get connected => 'Connected';

  @override
  String get appleWatch => 'Apple Watch';

  @override
  String get syncing => 'Syncing';

  @override
  String get garminConnect => 'Garmin Connect';

  @override
  String get notConnected => 'Not connected';

  @override
  String get syncSettings => 'Sync Settings';

  @override
  String get autoSync => 'Auto Sync';

  @override
  String get automaticallySyncHealthData => 'Automatically sync health data';

  @override
  String get backgroundSync => 'Background Sync';

  @override
  String get syncDataInBackground => 'Sync data in the background';

  @override
  String get loadingBiometricData => 'Loading biometric data...';

  @override
  String get errorLoadingData => 'Error Loading Data';

  @override
  String get anUnexpectedErrorOccurred => 'An unexpected error occurred';

  @override
  String get retry => 'Retry';

  @override
  String get noHealthData => 'No Health Data';

  @override
  String get connectHealthDevicesForBiometricInsights =>
      'Connect your health devices to see biometric insights';

  @override
  String get healthAccessRequired => 'Health Access Required';

  @override
  String get pleaseGrantAccessToHealthDataForBiometricInsights =>
      'Please grant access to health data to view biometric insights';

  @override
  String get grantAccess => 'Grant Access';

  @override
  String get excellentHealthMetrics => 'Excellent health metrics';

  @override
  String get veryGoodHealthPatterns => 'Very good health patterns';

  @override
  String get goodOverallHealth => 'Good overall health';

  @override
  String get moderateHealthIndicators => 'Moderate health indicators';

  @override
  String get focusOnHealthImprovement => 'Focus on health improvement';

  @override
  String get calendarTitle => 'Calendar';

  @override
  String get todayButton => 'Today';

  @override
  String get faqAndKnowledgeBase => 'FAQ & Knowledge Base';

  @override
  String get findAnswersToCommonQuestions => 'Find answers to common questions';

  @override
  String get searchFAQs => 'Search FAQs...';

  @override
  String get allCategories => 'All';

  @override
  String searchResults(int count) {
    return '$count search results';
  }

  @override
  String faqsInCategory(int count, String category) {
    return '$count FAQs in $category';
  }

  @override
  String totalFAQs(int count) {
    return '$count total FAQs';
  }

  @override
  String get askMira => 'Ask Mira';

  @override
  String get askRelatedQuestion => 'Ask related question';

  @override
  String get verified => 'Verified';

  @override
  String get askMiraAI => 'Ask Mira AI';

  @override
  String get getPersonalizedAnswers =>
      'Get personalized answers to your questions';

  @override
  String get fullChatExperienceComingSoon =>
      'Full chat experience coming soon!';

  @override
  String get useFloatingChatInInsights =>
      'For now, use the floating chat in the insights screen';

  @override
  String get goToAIChat => 'Go to AI Chat';

  @override
  String get faqAndHelp => 'FAQ & Help';

  @override
  String get getAnswers => 'Get answers';
}
