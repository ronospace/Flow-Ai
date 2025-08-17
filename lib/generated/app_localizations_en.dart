// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'FlowSense';

  @override
  String get appTagline => 'AI-Powered Period & Cycle Tracking';

  @override
  String get appDescription =>
      'Track your menstrual cycle with AI-powered insights and personalized recommendations for better reproductive health.';

  @override
  String get home => 'Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get tracking => 'Tracking';

  @override
  String get insights => 'Insights';

  @override
  String get settings => 'Settings';

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
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

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
  String get welcome => 'Welcome to FlowSense';

  @override
  String get getStarted => 'Get Started';

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
  String get yes => 'Yes';

  @override
  String get no => 'No';

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
  String get moodAndEnergy => 'Mood & Energy';

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
}
