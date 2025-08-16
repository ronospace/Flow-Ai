/// FlowSense Localizations
///
/// This file is auto-generated. Do not edit manually.
/// Generated from ARB files in lib/l10n/

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_bg.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_cs.dart';
import 'app_localizations_cy.dart';
import 'app_localizations_da.dart';
import 'app_localizations_de.dart';
import 'app_localizations_el.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_et.dart';
import 'app_localizations_fi.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ga.dart';
import 'app_localizations_he.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_hr.dart';
import 'app_localizations_hu.dart';
import 'app_localizations_is.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_lt.dart';
import 'app_localizations_lv.dart';
import 'app_localizations_mt.dart';
import 'app_localizations_nl.dart';
import 'app_localizations_no.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ro.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sk.dart';
import 'app_localizations_sl.dart';
import 'app_localizations_sv.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_uk.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('it'),
    Locale('pt'),
    Locale('ru'),
    Locale('ja'),
    Locale('ko'),
    Locale('zh'),
    Locale('ar'),
    Locale('hi'),
    Locale('bn'),
    Locale('tr'),
    Locale('vi'),
    Locale('th'),
    Locale('pl'),
    Locale('nl'),
    Locale('sv'),
    Locale('da'),
    Locale('no'),
    Locale('fi'),
    Locale('he'),
    Locale('cs'),
    Locale('hu'),
    Locale('uk'),
    Locale('el'),
    Locale('bg'),
    Locale('ro'),
    Locale('hr'),
    Locale('sk'),
    Locale('sl'),
    Locale('lt'),
    Locale('lv'),
    Locale('et'),
    Locale('mt'),
    Locale('is'),
    Locale('ga'),
    Locale('cy'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'FlowSense'**
  String get appName;

  /// The tagline of the application
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Period & Cycle Tracking'**
  String get appTagline;

  /// The description of the application
  ///
  /// In en, this message translates to:
  /// **'Track your menstrual cycle with AI-powered insights and personalized recommendations for better reproductive health.'**
  String get appDescription;

  /// Home screen navigation label
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Calendar screen navigation label
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// Tracking screen navigation label
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get tracking;

  /// Insights screen navigation label
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insights;

  /// Settings screen navigation label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Current day of the cycle
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String cycleDay(int day);

  /// Length of the menstrual cycle
  ///
  /// In en, this message translates to:
  /// **'Cycle Length: {length} days'**
  String cycleLength(int length);

  /// Days remaining until next period
  ///
  /// In en, this message translates to:
  /// **'{days} days until period'**
  String daysUntilPeriod(int days);

  /// Days remaining until ovulation
  ///
  /// In en, this message translates to:
  /// **'{days} days until ovulation'**
  String daysUntilOvulation(int days);

  /// No description provided for @currentPhase.
  ///
  /// In en, this message translates to:
  /// **'Current Phase'**
  String get currentPhase;

  /// No description provided for @menstrualPhase.
  ///
  /// In en, this message translates to:
  /// **'Menstrual'**
  String get menstrualPhase;

  /// No description provided for @follicularPhase.
  ///
  /// In en, this message translates to:
  /// **'Follicular'**
  String get follicularPhase;

  /// No description provided for @ovulatoryPhase.
  ///
  /// In en, this message translates to:
  /// **'Ovulatory'**
  String get ovulatoryPhase;

  /// No description provided for @lutealPhase.
  ///
  /// In en, this message translates to:
  /// **'Luteal'**
  String get lutealPhase;

  /// No description provided for @fertileWindow.
  ///
  /// In en, this message translates to:
  /// **'Fertile Window'**
  String get fertileWindow;

  /// No description provided for @ovulationDay.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Day'**
  String get ovulationDay;

  /// No description provided for @periodStarted.
  ///
  /// In en, this message translates to:
  /// **'Period Started'**
  String get periodStarted;

  /// No description provided for @periodEnded.
  ///
  /// In en, this message translates to:
  /// **'Period Ended'**
  String get periodEnded;

  /// No description provided for @flowIntensity.
  ///
  /// In en, this message translates to:
  /// **'Flow Intensity'**
  String get flowIntensity;

  /// No description provided for @flowNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get flowNone;

  /// No description provided for @flowSpotting.
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get flowSpotting;

  /// No description provided for @flowLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get flowLight;

  /// No description provided for @flowMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get flowMedium;

  /// No description provided for @flowHeavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get flowHeavy;

  /// No description provided for @flowVeryHeavy.
  ///
  /// In en, this message translates to:
  /// **'Very Heavy'**
  String get flowVeryHeavy;

  /// No description provided for @symptoms.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptoms;

  /// No description provided for @noSymptoms.
  ///
  /// In en, this message translates to:
  /// **'No symptoms'**
  String get noSymptoms;

  /// No description provided for @cramps.
  ///
  /// In en, this message translates to:
  /// **'Cramps'**
  String get cramps;

  /// No description provided for @bloating.
  ///
  /// In en, this message translates to:
  /// **'Bloating'**
  String get bloating;

  /// No description provided for @headache.
  ///
  /// In en, this message translates to:
  /// **'Headache'**
  String get headache;

  /// No description provided for @backPain.
  ///
  /// In en, this message translates to:
  /// **'Back Pain'**
  String get backPain;

  /// No description provided for @breastTenderness.
  ///
  /// In en, this message translates to:
  /// **'Breast Tenderness'**
  String get breastTenderness;

  /// No description provided for @fatigue.
  ///
  /// In en, this message translates to:
  /// **'Fatigue'**
  String get fatigue;

  /// No description provided for @moodSwings.
  ///
  /// In en, this message translates to:
  /// **'Mood Swings'**
  String get moodSwings;

  /// No description provided for @acne.
  ///
  /// In en, this message translates to:
  /// **'Acne'**
  String get acne;

  /// No description provided for @nausea.
  ///
  /// In en, this message translates to:
  /// **'Nausea'**
  String get nausea;

  /// No description provided for @cravings.
  ///
  /// In en, this message translates to:
  /// **'Cravings'**
  String get cravings;

  /// No description provided for @insomnia.
  ///
  /// In en, this message translates to:
  /// **'Insomnia'**
  String get insomnia;

  /// No description provided for @hotFlashes.
  ///
  /// In en, this message translates to:
  /// **'Hot Flashes'**
  String get hotFlashes;

  /// No description provided for @coldFlashes.
  ///
  /// In en, this message translates to:
  /// **'Cold Flashes'**
  String get coldFlashes;

  /// No description provided for @diarrhea.
  ///
  /// In en, this message translates to:
  /// **'Diarrhea'**
  String get diarrhea;

  /// No description provided for @constipation.
  ///
  /// In en, this message translates to:
  /// **'Constipation'**
  String get constipation;

  /// No description provided for @mood.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get mood;

  /// No description provided for @energy.
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get energy;

  /// No description provided for @pain.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get pain;

  /// No description provided for @moodHappy.
  ///
  /// In en, this message translates to:
  /// **'Happy'**
  String get moodHappy;

  /// No description provided for @moodNeutral.
  ///
  /// In en, this message translates to:
  /// **'Neutral'**
  String get moodNeutral;

  /// No description provided for @moodSad.
  ///
  /// In en, this message translates to:
  /// **'Sad'**
  String get moodSad;

  /// No description provided for @moodAnxious.
  ///
  /// In en, this message translates to:
  /// **'Anxious'**
  String get moodAnxious;

  /// No description provided for @moodIrritated.
  ///
  /// In en, this message translates to:
  /// **'Irritated'**
  String get moodIrritated;

  /// No description provided for @energyHigh.
  ///
  /// In en, this message translates to:
  /// **'High Energy'**
  String get energyHigh;

  /// No description provided for @energyMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium Energy'**
  String get energyMedium;

  /// No description provided for @energyLow.
  ///
  /// In en, this message translates to:
  /// **'Low Energy'**
  String get energyLow;

  /// No description provided for @painNone.
  ///
  /// In en, this message translates to:
  /// **'No Pain'**
  String get painNone;

  /// No description provided for @painMild.
  ///
  /// In en, this message translates to:
  /// **'Mild Pain'**
  String get painMild;

  /// No description provided for @painModerate.
  ///
  /// In en, this message translates to:
  /// **'Moderate Pain'**
  String get painModerate;

  /// No description provided for @painSevere.
  ///
  /// In en, this message translates to:
  /// **'Severe Pain'**
  String get painSevere;

  /// No description provided for @predictions.
  ///
  /// In en, this message translates to:
  /// **'Predictions'**
  String get predictions;

  /// No description provided for @nextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next Period'**
  String get nextPeriod;

  /// No description provided for @nextOvulation.
  ///
  /// In en, this message translates to:
  /// **'Next Ovulation'**
  String get nextOvulation;

  /// Predicted date for an event
  ///
  /// In en, this message translates to:
  /// **'Predicted: {date}'**
  String predictedDate(String date);

  /// Confidence level of a prediction
  ///
  /// In en, this message translates to:
  /// **'Confidence: {percentage}%'**
  String confidence(int percentage);

  /// No description provided for @aiPoweredPredictions.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Predictions'**
  String get aiPoweredPredictions;

  /// No description provided for @advancedInsights.
  ///
  /// In en, this message translates to:
  /// **'Advanced Insights'**
  String get advancedInsights;

  /// No description provided for @personalizedRecommendations.
  ///
  /// In en, this message translates to:
  /// **'Personalized Recommendations'**
  String get personalizedRecommendations;

  /// No description provided for @cycleInsights.
  ///
  /// In en, this message translates to:
  /// **'Cycle Insights'**
  String get cycleInsights;

  /// No description provided for @patternAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Pattern Analysis'**
  String get patternAnalysis;

  /// No description provided for @cycleTrends.
  ///
  /// In en, this message translates to:
  /// **'Cycle Trends'**
  String get cycleTrends;

  /// No description provided for @symptomPatterns.
  ///
  /// In en, this message translates to:
  /// **'Symptom Patterns'**
  String get symptomPatterns;

  /// No description provided for @moodPatterns.
  ///
  /// In en, this message translates to:
  /// **'Mood Patterns'**
  String get moodPatterns;

  /// No description provided for @regularCycle.
  ///
  /// In en, this message translates to:
  /// **'Your cycle is regular'**
  String get regularCycle;

  /// No description provided for @irregularCycle.
  ///
  /// In en, this message translates to:
  /// **'Your cycle shows some irregularity'**
  String get irregularCycle;

  /// Variation in cycle length
  ///
  /// In en, this message translates to:
  /// **'Cycle variation: ±{days} days'**
  String cycleVariation(int days);

  /// Average length of menstrual cycles
  ///
  /// In en, this message translates to:
  /// **'Average cycle length: {days} days'**
  String averageCycleLength(int days);

  /// No description provided for @lifestyle.
  ///
  /// In en, this message translates to:
  /// **'Lifestyle'**
  String get lifestyle;

  /// No description provided for @nutrition.
  ///
  /// In en, this message translates to:
  /// **'Nutrition'**
  String get nutrition;

  /// No description provided for @exercise.
  ///
  /// In en, this message translates to:
  /// **'Exercise'**
  String get exercise;

  /// No description provided for @wellness.
  ///
  /// In en, this message translates to:
  /// **'Wellness'**
  String get wellness;

  /// No description provided for @sleepBetter.
  ///
  /// In en, this message translates to:
  /// **'Improve your sleep quality'**
  String get sleepBetter;

  /// No description provided for @stayHydrated.
  ///
  /// In en, this message translates to:
  /// **'Stay hydrated'**
  String get stayHydrated;

  /// No description provided for @gentleExercise.
  ///
  /// In en, this message translates to:
  /// **'Try gentle exercise like yoga'**
  String get gentleExercise;

  /// No description provided for @eatIronRich.
  ///
  /// In en, this message translates to:
  /// **'Eat iron-rich foods'**
  String get eatIronRich;

  /// No description provided for @takeBreaks.
  ///
  /// In en, this message translates to:
  /// **'Take regular breaks'**
  String get takeBreaks;

  /// No description provided for @manageStress.
  ///
  /// In en, this message translates to:
  /// **'Practice stress management'**
  String get manageStress;

  /// No description provided for @warmBath.
  ///
  /// In en, this message translates to:
  /// **'Take a warm bath'**
  String get warmBath;

  /// No description provided for @meditation.
  ///
  /// In en, this message translates to:
  /// **'Try meditation or deep breathing'**
  String get meditation;

  /// No description provided for @logToday.
  ///
  /// In en, this message translates to:
  /// **'Log Today'**
  String get logToday;

  /// No description provided for @trackFlow.
  ///
  /// In en, this message translates to:
  /// **'Track Flow'**
  String get trackFlow;

  /// No description provided for @trackSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Track Symptoms'**
  String get trackSymptoms;

  /// No description provided for @trackMood.
  ///
  /// In en, this message translates to:
  /// **'Track Mood'**
  String get trackMood;

  /// No description provided for @trackPain.
  ///
  /// In en, this message translates to:
  /// **'Track Pain'**
  String get trackPain;

  /// No description provided for @addNotes.
  ///
  /// In en, this message translates to:
  /// **'Add Notes'**
  String get addNotes;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get update;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next Month'**
  String get nextMonth;

  /// No description provided for @previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous Month'**
  String get previousMonth;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @selectDate.
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// No description provided for @periodDays.
  ///
  /// In en, this message translates to:
  /// **'Period Days'**
  String get periodDays;

  /// No description provided for @fertileDays.
  ///
  /// In en, this message translates to:
  /// **'Fertile Days'**
  String get fertileDays;

  /// No description provided for @ovulationDays.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Days'**
  String get ovulationDays;

  /// No description provided for @symptomDays.
  ///
  /// In en, this message translates to:
  /// **'Symptom Days'**
  String get symptomDays;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacy;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @export.
  ///
  /// In en, this message translates to:
  /// **'Export Data'**
  String get export;

  /// No description provided for @backup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get backup;

  /// No description provided for @help.
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate App'**
  String get rateApp;

  /// No description provided for @shareApp.
  ///
  /// In en, this message translates to:
  /// **'Share App'**
  String get shareApp;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @weight.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weight;

  /// No description provided for @cycleHistory.
  ///
  /// In en, this message translates to:
  /// **'Cycle History'**
  String get cycleHistory;

  /// No description provided for @avgCycleLength.
  ///
  /// In en, this message translates to:
  /// **'Average Cycle Length'**
  String get avgCycleLength;

  /// No description provided for @avgPeriodLength.
  ///
  /// In en, this message translates to:
  /// **'Average Period Length'**
  String get avgPeriodLength;

  /// No description provided for @lastPeriod.
  ///
  /// In en, this message translates to:
  /// **'Last Period'**
  String get lastPeriod;

  /// No description provided for @periodPreferences.
  ///
  /// In en, this message translates to:
  /// **'Period Preferences'**
  String get periodPreferences;

  /// No description provided for @trackingGoals.
  ///
  /// In en, this message translates to:
  /// **'Tracking Goals'**
  String get trackingGoals;

  /// No description provided for @periodReminder.
  ///
  /// In en, this message translates to:
  /// **'Period Reminder'**
  String get periodReminder;

  /// No description provided for @ovulationReminder.
  ///
  /// In en, this message translates to:
  /// **'Ovulation Reminder'**
  String get ovulationReminder;

  /// No description provided for @pillReminder.
  ///
  /// In en, this message translates to:
  /// **'Pill Reminder'**
  String get pillReminder;

  /// No description provided for @symptomReminder.
  ///
  /// In en, this message translates to:
  /// **'Symptom Tracking Reminder'**
  String get symptomReminder;

  /// No description provided for @insightNotifications.
  ///
  /// In en, this message translates to:
  /// **'Insight Notifications'**
  String get insightNotifications;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable Notifications'**
  String get enableNotifications;

  /// No description provided for @notificationTime.
  ///
  /// In en, this message translates to:
  /// **'Notification Time'**
  String get notificationTime;

  /// Number of days before to send reminder
  ///
  /// In en, this message translates to:
  /// **'{days} days before'**
  String reminderDays(int days);

  /// No description provided for @healthData.
  ///
  /// In en, this message translates to:
  /// **'Health Data'**
  String get healthData;

  /// No description provided for @connectHealthApp.
  ///
  /// In en, this message translates to:
  /// **'Connect to Health App'**
  String get connectHealthApp;

  /// No description provided for @syncData.
  ///
  /// In en, this message translates to:
  /// **'Sync Data'**
  String get syncData;

  /// No description provided for @heartRate.
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRate;

  /// No description provided for @sleepData.
  ///
  /// In en, this message translates to:
  /// **'Sleep Data'**
  String get sleepData;

  /// No description provided for @steps.
  ///
  /// In en, this message translates to:
  /// **'Steps'**
  String get steps;

  /// No description provided for @temperature.
  ///
  /// In en, this message translates to:
  /// **'Body Temperature'**
  String get temperature;

  /// No description provided for @bloodPressure.
  ///
  /// In en, this message translates to:
  /// **'Blood Pressure'**
  String get bloodPressure;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsights;

  /// No description provided for @smartPredictions.
  ///
  /// In en, this message translates to:
  /// **'Smart Predictions'**
  String get smartPredictions;

  /// No description provided for @personalizedTips.
  ///
  /// In en, this message translates to:
  /// **'Personalized Tips'**
  String get personalizedTips;

  /// No description provided for @patternRecognition.
  ///
  /// In en, this message translates to:
  /// **'Pattern Recognition'**
  String get patternRecognition;

  /// No description provided for @anomalyDetection.
  ///
  /// In en, this message translates to:
  /// **'Anomaly Detection'**
  String get anomalyDetection;

  /// No description provided for @learningFromData.
  ///
  /// In en, this message translates to:
  /// **'Learning from your data...'**
  String get learningFromData;

  /// No description provided for @improvingAccuracy.
  ///
  /// In en, this message translates to:
  /// **'Improving prediction accuracy'**
  String get improvingAccuracy;

  /// No description provided for @adaptingToPatterns.
  ///
  /// In en, this message translates to:
  /// **'Adapting to your patterns'**
  String get adaptingToPatterns;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome to FlowSense'**
  String get welcome;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @skipForNow.
  ///
  /// In en, this message translates to:
  /// **'Skip for Now'**
  String get skipForNow;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @setupProfile.
  ///
  /// In en, this message translates to:
  /// **'Setup Your Profile'**
  String get setupProfile;

  /// No description provided for @trackingPermissions.
  ///
  /// In en, this message translates to:
  /// **'Tracking Permissions'**
  String get trackingPermissions;

  /// No description provided for @notificationPermissions.
  ///
  /// In en, this message translates to:
  /// **'Notification Permissions'**
  String get notificationPermissions;

  /// No description provided for @healthPermissions.
  ///
  /// In en, this message translates to:
  /// **'Health App Permissions'**
  String get healthPermissions;

  /// No description provided for @onboardingStep1.
  ///
  /// In en, this message translates to:
  /// **'Track your cycle with precision'**
  String get onboardingStep1;

  /// No description provided for @onboardingStep2.
  ///
  /// In en, this message translates to:
  /// **'Get AI-powered insights'**
  String get onboardingStep2;

  /// No description provided for @onboardingStep3.
  ///
  /// In en, this message translates to:
  /// **'Receive personalized recommendations'**
  String get onboardingStep3;

  /// No description provided for @onboardingStep4.
  ///
  /// In en, this message translates to:
  /// **'Monitor your reproductive health'**
  String get onboardingStep4;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @warning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get warning;

  /// No description provided for @info.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get info;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data available'**
  String get noData;

  /// No description provided for @noInternetConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noInternetConnection;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @dataUpdated.
  ///
  /// In en, this message translates to:
  /// **'Data updated successfully'**
  String get dataUpdated;

  /// No description provided for @dataSaved.
  ///
  /// In en, this message translates to:
  /// **'Data saved successfully'**
  String get dataSaved;

  /// No description provided for @dataDeleted.
  ///
  /// In en, this message translates to:
  /// **'Data deleted successfully'**
  String get dataDeleted;

  /// No description provided for @invalidInput.
  ///
  /// In en, this message translates to:
  /// **'Invalid input'**
  String get invalidInput;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @selectAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Please select at least one option'**
  String get selectAtLeastOne;

  /// No description provided for @days.
  ///
  /// In en, this message translates to:
  /// **'days'**
  String get days;

  /// No description provided for @weeks.
  ///
  /// In en, this message translates to:
  /// **'weeks'**
  String get weeks;

  /// No description provided for @months.
  ///
  /// In en, this message translates to:
  /// **'months'**
  String get months;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'years'**
  String get years;

  /// No description provided for @kg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get kg;

  /// No description provided for @lbs.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get lbs;

  /// No description provided for @cm.
  ///
  /// In en, this message translates to:
  /// **'cm'**
  String get cm;

  /// No description provided for @inches.
  ///
  /// In en, this message translates to:
  /// **'inches'**
  String get inches;

  /// No description provided for @celsius.
  ///
  /// In en, this message translates to:
  /// **'°C'**
  String get celsius;

  /// No description provided for @fahrenheit.
  ///
  /// In en, this message translates to:
  /// **'°F'**
  String get fahrenheit;

  /// No description provided for @morning.
  ///
  /// In en, this message translates to:
  /// **'Morning'**
  String get morning;

  /// No description provided for @afternoon.
  ///
  /// In en, this message translates to:
  /// **'Afternoon'**
  String get afternoon;

  /// No description provided for @evening.
  ///
  /// In en, this message translates to:
  /// **'Evening'**
  String get evening;

  /// No description provided for @night.
  ///
  /// In en, this message translates to:
  /// **'Night'**
  String get night;

  /// No description provided for @am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get am;

  /// No description provided for @pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get pm;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @tomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get tomorrow;

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get thisWeek;

  /// No description provided for @lastWeek.
  ///
  /// In en, this message translates to:
  /// **'Last Week'**
  String get lastWeek;

  /// No description provided for @nextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next Week'**
  String get nextWeek;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @enable.
  ///
  /// In en, this message translates to:
  /// **'Enable'**
  String get enable;

  /// No description provided for @disable.
  ///
  /// In en, this message translates to:
  /// **'Disable'**
  String get disable;

  /// No description provided for @on.
  ///
  /// In en, this message translates to:
  /// **'On'**
  String get on;

  /// No description provided for @off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get off;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @low.
  ///
  /// In en, this message translates to:
  /// **'Low'**
  String get low;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filter;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// Loading message for AI initialization
  ///
  /// In en, this message translates to:
  /// **'Initializing AI Health Engine...'**
  String get loadingAiEngine;

  /// Secondary loading message for health analysis
  ///
  /// In en, this message translates to:
  /// **'Analyzing your health patterns'**
  String get analyzingHealthPatterns;

  /// Morning greeting
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// Afternoon greeting
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// Evening greeting
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// Status indicator for AI functionality
  ///
  /// In en, this message translates to:
  /// **'AI Active'**
  String get aiActive;

  /// Health indicator label
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get health;

  /// Optimal health status
  ///
  /// In en, this message translates to:
  /// **'Optimal'**
  String get optimal;

  /// Cycle status metric card title
  ///
  /// In en, this message translates to:
  /// **'Cycle Status'**
  String get cycleStatus;

  /// Status when cycle has not started
  ///
  /// In en, this message translates to:
  /// **'Not Started'**
  String get notStarted;

  /// Mood balance metric card title
  ///
  /// In en, this message translates to:
  /// **'Mood Balance'**
  String get moodBalance;

  /// Status when data is not being tracked
  ///
  /// In en, this message translates to:
  /// **'Not Tracked'**
  String get notTracked;

  /// Energy level metric card title
  ///
  /// In en, this message translates to:
  /// **'Energy Level'**
  String get energyLevel;

  /// Flow intensity metric card title
  ///
  /// In en, this message translates to:
  /// **'Flow Intensity'**
  String get flowIntensityMetric;

  /// Action card for logging symptoms
  ///
  /// In en, this message translates to:
  /// **'Log Symptoms'**
  String get logSymptoms;

  /// Subtitle for symptoms tracking
  ///
  /// In en, this message translates to:
  /// **'Track your health'**
  String get trackYourHealth;

  /// Action card for period tracking
  ///
  /// In en, this message translates to:
  /// **'Period Tracker'**
  String get periodTracker;

  /// Subtitle for period tracking
  ///
  /// In en, this message translates to:
  /// **'Start logging'**
  String get startLogging;

  /// Action card for mood and energy tracking
  ///
  /// In en, this message translates to:
  /// **'Mood & Energy'**
  String get moodAndEnergy;

  /// Subtitle for mood and energy tracking
  ///
  /// In en, this message translates to:
  /// **'Log wellness'**
  String get logWellness;

  /// Subtitle for AI insights
  ///
  /// In en, this message translates to:
  /// **'View analysis'**
  String get viewAnalysis;

  /// Accuracy label for predictions
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// High confidence indicator
  ///
  /// In en, this message translates to:
  /// **'High confidence'**
  String get highConfidence;

  /// Title when no prediction data available
  ///
  /// In en, this message translates to:
  /// **'Gathering Data for Predictions'**
  String get gatheringDataForPredictions;

  /// Message encouraging users to start tracking
  ///
  /// In en, this message translates to:
  /// **'Start tracking your cycles to unlock AI predictions'**
  String get startTrackingForPredictions;

  /// Title when AI is learning patterns
  ///
  /// In en, this message translates to:
  /// **'AI Learning Your Patterns'**
  String get aiLearningPatterns;

  /// Message encouraging users to track for insights
  ///
  /// In en, this message translates to:
  /// **'Track your cycles to unlock personalized AI insights'**
  String get trackForInsights;

  /// Cycle regularity trend metric
  ///
  /// In en, this message translates to:
  /// **'Cycle Regularity'**
  String get cycleRegularity;

  /// Trend comparison from previous month
  ///
  /// In en, this message translates to:
  /// **'+5% from last month'**
  String get fromLastMonth;

  /// Average cycle length label
  ///
  /// In en, this message translates to:
  /// **'Avg Cycle'**
  String get avgCycle;

  /// Average mood label
  ///
  /// In en, this message translates to:
  /// **'Avg Mood'**
  String get avgMood;

  /// Example cycle days
  ///
  /// In en, this message translates to:
  /// **'28.5 days'**
  String get daysCycle;

  /// Example mood rating
  ///
  /// In en, this message translates to:
  /// **'4.2/5'**
  String get moodRating;

  /// Choose theme modal title
  ///
  /// In en, this message translates to:
  /// **'Choose Theme'**
  String get chooseTheme;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// Light theme description
  ///
  /// In en, this message translates to:
  /// **'Bright and clean appearance'**
  String get lightThemeDescription;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// Dark theme description
  ///
  /// In en, this message translates to:
  /// **'Easy on the eyes in low light'**
  String get darkThemeDescription;

  /// System theme option
  ///
  /// In en, this message translates to:
  /// **'System Theme'**
  String get systemTheme;

  /// System theme description
  ///
  /// In en, this message translates to:
  /// **'Matches your device settings'**
  String get systemThemeDescription;

  /// Theme change confirmation message
  ///
  /// In en, this message translates to:
  /// **'Theme changed to'**
  String get themeChangedTo;

  /// Choose language modal title
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get chooseLanguage;

  /// Search languages placeholder
  ///
  /// In en, this message translates to:
  /// **'Search languages...'**
  String get searchLanguages;

  /// Language change confirmation message
  ///
  /// In en, this message translates to:
  /// **'Language changed to'**
  String get languageChangedTo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'bg',
    'bn',
    'cs',
    'cy',
    'da',
    'de',
    'el',
    'en',
    'es',
    'et',
    'fi',
    'fr',
    'ga',
    'he',
    'hi',
    'hr',
    'hu',
    'is',
    'it',
    'ja',
    'ko',
    'lt',
    'lv',
    'mt',
    'nl',
    'no',
    'pl',
    'pt',
    'ro',
    'ru',
    'sk',
    'sl',
    'sv',
    'th',
    'tr',
    'uk',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'bg':
      return AppLocalizationsBg();
    case 'bn':
      return AppLocalizationsBn();
    case 'cs':
      return AppLocalizationsCs();
    case 'cy':
      return AppLocalizationsCy();
    case 'da':
      return AppLocalizationsDa();
    case 'de':
      return AppLocalizationsDe();
    case 'el':
      return AppLocalizationsEl();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'et':
      return AppLocalizationsEt();
    case 'fi':
      return AppLocalizationsFi();
    case 'fr':
      return AppLocalizationsFr();
    case 'ga':
      return AppLocalizationsGa();
    case 'he':
      return AppLocalizationsHe();
    case 'hi':
      return AppLocalizationsHi();
    case 'hr':
      return AppLocalizationsHr();
    case 'hu':
      return AppLocalizationsHu();
    case 'is':
      return AppLocalizationsIs();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'lt':
      return AppLocalizationsLt();
    case 'lv':
      return AppLocalizationsLv();
    case 'mt':
      return AppLocalizationsMt();
    case 'nl':
      return AppLocalizationsNl();
    case 'no':
      return AppLocalizationsNo();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ro':
      return AppLocalizationsRo();
    case 'ru':
      return AppLocalizationsRu();
    case 'sk':
      return AppLocalizationsSk();
    case 'sl':
      return AppLocalizationsSl();
    case 'sv':
      return AppLocalizationsSv();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'uk':
      return AppLocalizationsUk();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
