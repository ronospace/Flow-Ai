import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart' deferred as app_localizations_ar;
import 'app_localizations_bg.dart' deferred as app_localizations_bg;
import 'app_localizations_bn.dart' deferred as app_localizations_bn;
import 'app_localizations_cs.dart' deferred as app_localizations_cs;
import 'app_localizations_cy.dart' deferred as app_localizations_cy;
import 'app_localizations_da.dart' deferred as app_localizations_da;
import 'app_localizations_de.dart' deferred as app_localizations_de;
import 'app_localizations_el.dart' deferred as app_localizations_el;
import 'app_localizations_en.dart' deferred as app_localizations_en;
import 'app_localizations_es.dart' deferred as app_localizations_es;
import 'app_localizations_et.dart' deferred as app_localizations_et;
import 'app_localizations_fi.dart' deferred as app_localizations_fi;
import 'app_localizations_fr.dart' deferred as app_localizations_fr;
import 'app_localizations_ga.dart' deferred as app_localizations_ga;
import 'app_localizations_he.dart' deferred as app_localizations_he;
import 'app_localizations_hi.dart' deferred as app_localizations_hi;
import 'app_localizations_hr.dart' deferred as app_localizations_hr;
import 'app_localizations_hu.dart' deferred as app_localizations_hu;
import 'app_localizations_is.dart' deferred as app_localizations_is;
import 'app_localizations_it.dart' deferred as app_localizations_it;
import 'app_localizations_ja.dart' deferred as app_localizations_ja;
import 'app_localizations_ko.dart' deferred as app_localizations_ko;
import 'app_localizations_lt.dart' deferred as app_localizations_lt;
import 'app_localizations_lv.dart' deferred as app_localizations_lv;
import 'app_localizations_mt.dart' deferred as app_localizations_mt;
import 'app_localizations_nl.dart' deferred as app_localizations_nl;
import 'app_localizations_no.dart' deferred as app_localizations_no;
import 'app_localizations_pl.dart' deferred as app_localizations_pl;
import 'app_localizations_pt.dart' deferred as app_localizations_pt;
import 'app_localizations_ro.dart' deferred as app_localizations_ro;
import 'app_localizations_ru.dart' deferred as app_localizations_ru;
import 'app_localizations_sk.dart' deferred as app_localizations_sk;
import 'app_localizations_sl.dart' deferred as app_localizations_sl;
import 'app_localizations_sv.dart' deferred as app_localizations_sv;
import 'app_localizations_th.dart' deferred as app_localizations_th;
import 'app_localizations_tr.dart' deferred as app_localizations_tr;
import 'app_localizations_uk.dart' deferred as app_localizations_uk;
import 'app_localizations_vi.dart' deferred as app_localizations_vi;
import 'app_localizations_zh.dart' deferred as app_localizations_zh;

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('pt'),
    Locale('de'),
    Locale('it'),
    Locale('ar'),
    Locale('hi'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('ru'),
    Locale('bg'),
    Locale('bn'),
    Locale('cs'),
    Locale('cy'),
    Locale('da'),
    Locale('el'),
    Locale('et'),
    Locale('fi'),
    Locale('ga'),
    Locale('he'),
    Locale('hr'),
    Locale('hu'),
    Locale('is'),
    Locale('lt'),
    Locale('lv'),
    Locale('mt'),
    Locale('nl'),
    Locale('no'),
    Locale('pl'),
    Locale('ro'),
    Locale('sk'),
    Locale('sl'),
    Locale('sv'),
    Locale('th'),
    Locale('tr'),
    Locale('uk'),
    Locale('vi'),
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Flow Ai'**
  String get appName;

  /// The tagline of the application
  ///
  /// In en, this message translates to:
  /// **'Cycle Awareness & Personal Insights'**
  String get appTagline;

  /// The description of the application
  ///
  /// In en, this message translates to:
  /// **'Learn your patterns. Understand your rhythm. Track your menstrual cycle with AI-powered awareness tools and personalized insights.'**
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

  /// Enable notifications setting title
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
  /// **'Welcome to Flow Ai'**
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

  /// No description provided for @trackingScreenTitle.
  ///
  /// In en, this message translates to:
  /// **'Tracking'**
  String get trackingScreenTitle;

  /// No description provided for @flowTab.
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get flowTab;

  /// No description provided for @symptomsTab.
  ///
  /// In en, this message translates to:
  /// **'Symptoms'**
  String get symptomsTab;

  /// No description provided for @moodTab.
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get moodTab;

  /// No description provided for @painTab.
  ///
  /// In en, this message translates to:
  /// **'Pain'**
  String get painTab;

  /// No description provided for @notesTab.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notesTab;

  /// No description provided for @selectTodaysFlowIntensity.
  ///
  /// In en, this message translates to:
  /// **'Select today\'s flow intensity'**
  String get selectTodaysFlowIntensity;

  /// No description provided for @selectAllSymptoms.
  ///
  /// In en, this message translates to:
  /// **'Select all symptoms you\'re experiencing'**
  String get selectAllSymptoms;

  /// Action card for mood and energy tracking
  ///
  /// In en, this message translates to:
  /// **'Mood & Energy'**
  String get moodAndEnergy;

  /// No description provided for @howAreYouFeelingToday.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today?'**
  String get howAreYouFeelingToday;

  /// No description provided for @painLevel.
  ///
  /// In en, this message translates to:
  /// **'Pain Level'**
  String get painLevel;

  /// No description provided for @rateOverallPainLevel.
  ///
  /// In en, this message translates to:
  /// **'Rate your overall pain level'**
  String get rateOverallPainLevel;

  /// No description provided for @personalNotes.
  ///
  /// In en, this message translates to:
  /// **'Personal Notes'**
  String get personalNotes;

  /// No description provided for @captureThoughtsAndFeelings.
  ///
  /// In en, this message translates to:
  /// **'Capture your thoughts, feelings, and observations about your cycle'**
  String get captureThoughtsAndFeelings;

  /// No description provided for @todaysJournalEntry.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Journal Entry'**
  String get todaysJournalEntry;

  /// No description provided for @quickNotes.
  ///
  /// In en, this message translates to:
  /// **'Quick Notes'**
  String get quickNotes;

  /// No description provided for @notesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'How are you feeling today? Any symptoms, mood changes, or observations you\'d like to remember?\n\nTip: Recording your thoughts helps identify patterns over time.'**
  String get notesPlaceholder;

  /// Character count for notes
  ///
  /// In en, this message translates to:
  /// **'{count} chars'**
  String charactersCount(int count);

  /// Sleep quality metric
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get sleepQuality;

  /// Food cravings symptom
  ///
  /// In en, this message translates to:
  /// **'Food cravings'**
  String get foodCravings;

  /// No description provided for @hydration.
  ///
  /// In en, this message translates to:
  /// **'Hydration'**
  String get hydration;

  /// No description provided for @energyLevels.
  ///
  /// In en, this message translates to:
  /// **'Energy levels'**
  String get energyLevels;

  /// No description provided for @stressManagement.
  ///
  /// In en, this message translates to:
  /// **'Stress management'**
  String get stressManagement;

  /// No description provided for @saveTrackingData.
  ///
  /// In en, this message translates to:
  /// **'Save Tracking Data'**
  String get saveTrackingData;

  /// No description provided for @noChangesToSave.
  ///
  /// In en, this message translates to:
  /// **'No Changes to Save'**
  String get noChangesToSave;

  /// Success message when tracking data is saved
  ///
  /// In en, this message translates to:
  /// **'Tracking data saved for {date}'**
  String trackingDataSaved(String date);

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

  /// Biometric dashboard title
  ///
  /// In en, this message translates to:
  /// **'Biometric Dashboard'**
  String get biometricDashboard;

  /// Title for current cycle card
  ///
  /// In en, this message translates to:
  /// **'Current Cycle'**
  String get currentCycle;

  /// Message when no active cycle
  ///
  /// In en, this message translates to:
  /// **'No active cycle'**
  String get noActiveCycle;

  /// Start tracking button
  ///
  /// In en, this message translates to:
  /// **'Start Tracking'**
  String get startTracking;

  /// AI prediction card title
  ///
  /// In en, this message translates to:
  /// **'AI Prediction'**
  String get aiPrediction;

  /// Days until next event
  ///
  /// In en, this message translates to:
  /// **'In {days} days'**
  String inDays(int days);

  /// Smart action center title
  ///
  /// In en, this message translates to:
  /// **'Smart Action Command Center'**
  String get smartActionCommandCenter;

  /// Smart action center subtitle
  ///
  /// In en, this message translates to:
  /// **'Quick access to essential features'**
  String get quickAccessToEssentialFeatures;

  /// Physical symptom category
  ///
  /// In en, this message translates to:
  /// **'Physical'**
  String get physical;

  /// Emotional symptom category
  ///
  /// In en, this message translates to:
  /// **'Emotional'**
  String get emotional;

  /// Skin and hair symptom category
  ///
  /// In en, this message translates to:
  /// **'Skin & Hair'**
  String get skinAndHair;

  /// Digestive symptom category
  ///
  /// In en, this message translates to:
  /// **'Digestive'**
  String get digestive;

  /// Mood swings symptom
  ///
  /// In en, this message translates to:
  /// **'Mood swings'**
  String get moodSwingsSymptom;

  /// Irritability symptom
  ///
  /// In en, this message translates to:
  /// **'Irritability'**
  String get irritability;

  /// Anxiety symptom
  ///
  /// In en, this message translates to:
  /// **'Anxiety'**
  String get anxiety;

  /// Depression symptom
  ///
  /// In en, this message translates to:
  /// **'Depression'**
  String get depression;

  /// Emotional sensitivity symptom
  ///
  /// In en, this message translates to:
  /// **'Emotional sensitivity'**
  String get emotionalSensitivity;

  /// Stress symptom
  ///
  /// In en, this message translates to:
  /// **'Stress'**
  String get stress;

  /// Oily skin symptom
  ///
  /// In en, this message translates to:
  /// **'Oily skin'**
  String get oilySkin;

  /// Dry skin symptom
  ///
  /// In en, this message translates to:
  /// **'Dry skin'**
  String get drySkin;

  /// Hair changes symptom
  ///
  /// In en, this message translates to:
  /// **'Hair changes'**
  String get hairChanges;

  /// Loss of appetite symptom
  ///
  /// In en, this message translates to:
  /// **'Loss of appetite'**
  String get lossOfAppetite;

  /// Selected symptoms count
  ///
  /// In en, this message translates to:
  /// **'Selected Symptoms ({count})'**
  String selectedSymptoms(int count);

  /// Description for no flow
  ///
  /// In en, this message translates to:
  /// **'No menstrual flow'**
  String get noMenstrualFlow;

  /// Description for spotting
  ///
  /// In en, this message translates to:
  /// **'Minimal discharge'**
  String get minimalDischarge;

  /// Description for light flow
  ///
  /// In en, this message translates to:
  /// **'Comfortable protection'**
  String get comfortableProtection;

  /// Light flow intensity title
  ///
  /// In en, this message translates to:
  /// **'Light Flow'**
  String get lightFlow;

  /// Normal flow intensity title
  ///
  /// In en, this message translates to:
  /// **'Normal Flow'**
  String get normalFlow;

  /// Description for normal flow
  ///
  /// In en, this message translates to:
  /// **'Typical menstruation'**
  String get typicalMenstruation;

  /// Heavy flow intensity title
  ///
  /// In en, this message translates to:
  /// **'Heavy Flow'**
  String get heavyFlow;

  /// Description for heavy flow
  ///
  /// In en, this message translates to:
  /// **'High absorption needed'**
  String get highAbsorptionNeeded;

  /// Very heavy flow intensity title
  ///
  /// In en, this message translates to:
  /// **'Very Heavy'**
  String get veryHeavy;

  /// Description for very heavy flow
  ///
  /// In en, this message translates to:
  /// **'Medical attention advised'**
  String get medicalAttentionAdvised;

  /// Spotting flow intensity title
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get spotting;

  /// Flow label
  ///
  /// In en, this message translates to:
  /// **'Flow'**
  String get flow;

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

  /// App preferences section title
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get appPreferences;

  /// Theme customization subtitle
  ///
  /// In en, this message translates to:
  /// **'Customize app appearance'**
  String get customizeAppearance;

  /// Language selection subtitle
  ///
  /// In en, this message translates to:
  /// **'Choose your language'**
  String get chooseYourLanguage;

  /// Enable notifications setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Receive reminders and updates'**
  String get receiveReminders;

  /// Daily reminders setting subtitle
  ///
  /// In en, this message translates to:
  /// **'When to send daily reminders'**
  String get dailyReminders;

  /// Title for premium insights unlock widget
  ///
  /// In en, this message translates to:
  /// **'Unlock Premium AI Insights'**
  String get unlockPremiumAiInsights;

  /// Subtitle for premium insights unlock widget
  ///
  /// In en, this message translates to:
  /// **'Watch an ad to unlock advanced insights'**
  String get watchAdToUnlockInsights;

  /// Free label for premium unlock widget
  ///
  /// In en, this message translates to:
  /// **'FREE'**
  String get free;

  /// Button text for watching ad to unlock insights
  ///
  /// In en, this message translates to:
  /// **'Watch Ad & Unlock Insights'**
  String get watchAdUnlockInsights;

  /// Benefit text for premium insights unlock
  ///
  /// In en, this message translates to:
  /// **'Get 3 additional premium insights'**
  String get getAdditionalPremiumInsights;

  /// Benefit text for advanced health recommendations
  ///
  /// In en, this message translates to:
  /// **'Unlock advanced health recommendations'**
  String get unlockAdvancedHealthRecommendations;

  /// Success message when premium insights are unlocked
  ///
  /// In en, this message translates to:
  /// **'Premium insights unlocked! 🎉'**
  String get premiumInsightsUnlocked;

  /// Day number in cycle
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String day(int day);

  /// Confidence percentage for predictions
  ///
  /// In en, this message translates to:
  /// **'{percentage}% confidence'**
  String confidencePercentage(int percentage);

  /// Title for quick actions section
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Quick action to log period
  ///
  /// In en, this message translates to:
  /// **'Log Period'**
  String get logPeriod;

  /// Current cycle section title
  ///
  /// In en, this message translates to:
  /// **'Current Cycle'**
  String get currentCycleTitle;

  /// Mood info label in current cycle
  ///
  /// In en, this message translates to:
  /// **'Mood'**
  String get moodLabel;

  /// AI features section title
  ///
  /// In en, this message translates to:
  /// **'AI & Smart Features'**
  String get aiSmartFeatures;

  /// AI insights setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Get personalized AI insights'**
  String get personalizedAiInsights;

  /// Haptic feedback setting title
  ///
  /// In en, this message translates to:
  /// **'Haptic Feedback'**
  String get hapticFeedback;

  /// Haptic feedback setting subtitle
  ///
  /// In en, this message translates to:
  /// **'Feel vibrations on interactions'**
  String get vibrationInteractions;

  /// Support and about section title
  ///
  /// In en, this message translates to:
  /// **'Support & About'**
  String get supportAbout;

  /// Help section subtitle
  ///
  /// In en, this message translates to:
  /// **'Get help and tutorials'**
  String get getHelpTutorials;

  /// About section subtitle
  ///
  /// In en, this message translates to:
  /// **'Version info and legal'**
  String get versionInfoLegal;

  /// Light theme name
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get light;

  /// Dark theme name
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get dark;

  /// System theme name
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No menstrual flow intensity
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get flowIntensityNone;

  /// Subtitle for no flow
  ///
  /// In en, this message translates to:
  /// **'No menstrual flow'**
  String get flowIntensityNoneSubtitle;

  /// Description for no flow intensity
  ///
  /// In en, this message translates to:
  /// **'Complete absence of menstrual flow. This is normal before your period starts or after it ends.'**
  String get flowIntensityNoneDescription;

  /// Medical info for no flow
  ///
  /// In en, this message translates to:
  /// **'No menstruation occurring'**
  String get flowIntensityNoneMedicalInfo;

  /// Spotting flow intensity
  ///
  /// In en, this message translates to:
  /// **'Spotting'**
  String get flowIntensitySpotting;

  /// Subtitle for spotting
  ///
  /// In en, this message translates to:
  /// **'Minimal discharge'**
  String get flowIntensitySpottingSubtitle;

  /// Description for spotting intensity
  ///
  /// In en, this message translates to:
  /// **'Very light pink or brown discharge. Often occurs at the beginning or end of your cycle.'**
  String get flowIntensitySpottingDescription;

  /// Medical info for spotting
  ///
  /// In en, this message translates to:
  /// **'Less than 5ml per day'**
  String get flowIntensitySpottingMedicalInfo;

  /// Light flow intensity
  ///
  /// In en, this message translates to:
  /// **'Light Flow'**
  String get flowIntensityLight;

  /// Subtitle for light flow
  ///
  /// In en, this message translates to:
  /// **'Comfortable protection'**
  String get flowIntensityLightSubtitle;

  /// Description for light flow intensity
  ///
  /// In en, this message translates to:
  /// **'Light menstrual flow requiring minimal protection. Usually lasts 1-3 days.'**
  String get flowIntensityLightDescription;

  /// Medical info for light flow
  ///
  /// In en, this message translates to:
  /// **'5-40ml per day'**
  String get flowIntensityLightMedicalInfo;

  /// Medium/normal flow intensity
  ///
  /// In en, this message translates to:
  /// **'Normal Flow'**
  String get flowIntensityMedium;

  /// Subtitle for normal flow
  ///
  /// In en, this message translates to:
  /// **'Typical menstruation'**
  String get flowIntensityMediumSubtitle;

  /// Description for medium flow intensity
  ///
  /// In en, this message translates to:
  /// **'Regular menstrual flow. This is the most common flow intensity for healthy cycles.'**
  String get flowIntensityMediumDescription;

  /// Medical info for medium flow
  ///
  /// In en, this message translates to:
  /// **'40-70ml per day'**
  String get flowIntensityMediumMedicalInfo;

  /// Heavy flow intensity
  ///
  /// In en, this message translates to:
  /// **'Heavy Flow'**
  String get flowIntensityHeavy;

  /// Subtitle for heavy flow
  ///
  /// In en, this message translates to:
  /// **'High absorption needed'**
  String get flowIntensityHeavySubtitle;

  /// Description for heavy flow intensity
  ///
  /// In en, this message translates to:
  /// **'Heavy menstrual flow requiring frequent changes. Consider consulting a healthcare provider.'**
  String get flowIntensityHeavyDescription;

  /// Medical info for heavy flow
  ///
  /// In en, this message translates to:
  /// **'70-100ml per day'**
  String get flowIntensityHeavyMedicalInfo;

  /// Very heavy flow intensity
  ///
  /// In en, this message translates to:
  /// **'Very Heavy'**
  String get flowIntensityVeryHeavy;

  /// Subtitle for very heavy flow
  ///
  /// In en, this message translates to:
  /// **'Medical attention advised'**
  String get flowIntensityVeryHeavySubtitle;

  /// Description for very heavy flow intensity
  ///
  /// In en, this message translates to:
  /// **'Very heavy flow that may interfere with daily activities. Strongly recommend consulting a healthcare provider.'**
  String get flowIntensityVeryHeavyDescription;

  /// Medical info for very heavy flow
  ///
  /// In en, this message translates to:
  /// **'Over 100ml per day'**
  String get flowIntensityVeryHeavyMedicalInfo;

  /// AI health insights title
  ///
  /// In en, this message translates to:
  /// **'AI Health Insights'**
  String get aiHealthInsights;

  /// Modal title for flow level info
  ///
  /// In en, this message translates to:
  /// **'About This Flow Level'**
  String get aboutThisFlowLevel;

  /// Recommended products section title
  ///
  /// In en, this message translates to:
  /// **'Recommended Products'**
  String get recommendedProducts;

  /// Hourly product changes indicator
  ///
  /// In en, this message translates to:
  /// **'~{changes}/hour changes'**
  String hourlyChanges(int changes);

  /// Monitor indicator for heavy flows
  ///
  /// In en, this message translates to:
  /// **'Monitor'**
  String get monitor;

  /// AI insight for spotting
  ///
  /// In en, this message translates to:
  /// **'Spotting is often normal at cycle start/end. Track patterns for insights.'**
  String get spottingInsight;

  /// AI insight for light flow
  ///
  /// In en, this message translates to:
  /// **'Light flow detected. Consider stress levels and nutrition for optimal health.'**
  String get lightFlowInsight;

  /// AI insight for medium flow
  ///
  /// In en, this message translates to:
  /// **'Normal flow pattern. Your cycle appears healthy and regular.'**
  String get mediumFlowInsight;

  /// AI insight for heavy flow
  ///
  /// In en, this message translates to:
  /// **'Heavy flow detected. Monitor symptoms and consider iron-rich foods.'**
  String get heavyFlowInsight;

  /// AI insight for very heavy flow
  ///
  /// In en, this message translates to:
  /// **'Very heavy flow may need medical attention. Track duration carefully.'**
  String get veryHeavyFlowInsight;

  /// AI insight for no flow
  ///
  /// In en, this message translates to:
  /// **'No flow detected. Track other symptoms for comprehensive insights.'**
  String get noFlowInsight;

  /// Panty liners product
  ///
  /// In en, this message translates to:
  /// **'Panty liners'**
  String get pantyLiners;

  /// Period underwear product
  ///
  /// In en, this message translates to:
  /// **'Period underwear'**
  String get periodUnderwear;

  /// Light pads product
  ///
  /// In en, this message translates to:
  /// **'Light pads'**
  String get lightPads;

  /// Regular tampons product
  ///
  /// In en, this message translates to:
  /// **'Tampons (regular)'**
  String get tamponsRegular;

  /// Menstrual cups product
  ///
  /// In en, this message translates to:
  /// **'Menstrual cups'**
  String get menstrualCups;

  /// Regular pads product
  ///
  /// In en, this message translates to:
  /// **'Regular pads'**
  String get regularPads;

  /// Super tampons product
  ///
  /// In en, this message translates to:
  /// **'Tampons (super)'**
  String get tamponsSuper;

  /// Heavy period underwear product
  ///
  /// In en, this message translates to:
  /// **'Period underwear (heavy)'**
  String get periodUnderwearHeavy;

  /// Super pads product
  ///
  /// In en, this message translates to:
  /// **'Super pads'**
  String get superPads;

  /// Super plus tampons product
  ///
  /// In en, this message translates to:
  /// **'Tampons (super+)'**
  String get tamponsSuperPlus;

  /// Large menstrual cups product
  ///
  /// In en, this message translates to:
  /// **'Menstrual cups (large)'**
  String get menstrualCupsLarge;

  /// Ultra pads product
  ///
  /// In en, this message translates to:
  /// **'Ultra pads'**
  String get ultraPads;

  /// Ultra tampons product
  ///
  /// In en, this message translates to:
  /// **'Tampons (ultra)'**
  String get tamponsUltra;

  /// XL menstrual cups product
  ///
  /// In en, this message translates to:
  /// **'Menstrual cups (XL)'**
  String get menstrualCupsXL;

  /// Medical consultation product
  ///
  /// In en, this message translates to:
  /// **'Medical consultation'**
  String get medicalConsultation;

  /// Biometric dashboard subtitle
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Health Insights'**
  String get aiPoweredHealthInsights;

  /// Error message when health data access is denied
  ///
  /// In en, this message translates to:
  /// **'Health data access not granted. Please enable in settings.'**
  String get healthDataAccessNotGranted;

  /// Error message when dashboard fails to initialize
  ///
  /// In en, this message translates to:
  /// **'Failed to initialize biometric dashboard'**
  String get failedToInitializeBiometricDashboard;

  /// Error message when data fails to load
  ///
  /// In en, this message translates to:
  /// **'Failed to load biometric data'**
  String get failedToLoadBiometricData;

  /// Success message for data refresh with time
  ///
  /// In en, this message translates to:
  /// **'Biometric data refreshed at {time}'**
  String biometricDataRefreshedAt(String time);

  /// Error message when refresh fails
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh data'**
  String get failedToRefreshData;

  /// Overview tab label
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// Metrics tab label
  ///
  /// In en, this message translates to:
  /// **'Metrics'**
  String get metrics;

  /// Sync tab label
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get sync;

  /// Status when health data is connected
  ///
  /// In en, this message translates to:
  /// **'Health Data Connected'**
  String get healthDataConnected;

  /// Status when health data is limited
  ///
  /// In en, this message translates to:
  /// **'Limited Health Data'**
  String get limitedHealthData;

  /// Data completeness percentage
  ///
  /// In en, this message translates to:
  /// **'Data completeness: {percentage}%'**
  String dataCompleteness(int percentage);

  /// Message encouraging device connection
  ///
  /// In en, this message translates to:
  /// **'Connect more devices for better insights'**
  String get connectMoreDevicesForBetterInsights;

  /// Last update time
  ///
  /// In en, this message translates to:
  /// **'Updated {time}'**
  String updatedAt(String time);

  /// Overall health score card title
  ///
  /// In en, this message translates to:
  /// **'Overall Health Score'**
  String get overallHealthScore;

  /// Average heart rate metric
  ///
  /// In en, this message translates to:
  /// **'Avg Heart Rate'**
  String get avgHeartRate;

  /// Body temperature metric
  ///
  /// In en, this message translates to:
  /// **'Body Temp'**
  String get bodyTemp;

  /// Stress level metric
  ///
  /// In en, this message translates to:
  /// **'Stress Level'**
  String get stressLevel;

  /// Beats per minute unit
  ///
  /// In en, this message translates to:
  /// **'BPM'**
  String get bpm;

  /// Percentage unit
  ///
  /// In en, this message translates to:
  /// **'%'**
  String get percent;

  /// Degrees Fahrenheit unit
  ///
  /// In en, this message translates to:
  /// **'°F'**
  String get degreesF;

  /// Out of ten scale unit
  ///
  /// In en, this message translates to:
  /// **'/10'**
  String get outOfTen;

  /// Recent trends card title
  ///
  /// In en, this message translates to:
  /// **'Recent Trends'**
  String get recentTrends;

  /// Trend analysis period
  ///
  /// In en, this message translates to:
  /// **'Based on the last {days} days of data'**
  String basedOnLastDaysOfData(int days);

  /// Sleep quality trend item
  ///
  /// In en, this message translates to:
  /// **'Sleep quality'**
  String get sleepQualityImproving;

  /// Improving trend status
  ///
  /// In en, this message translates to:
  /// **'Improving'**
  String get improving;

  /// Stress levels trend item
  ///
  /// In en, this message translates to:
  /// **'Stress levels'**
  String get stressLevels;

  /// Stable trend status
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// Heart rate trend item
  ///
  /// In en, this message translates to:
  /// **'Heart rate'**
  String get heartRateMetric;

  /// Slightly elevated trend status
  ///
  /// In en, this message translates to:
  /// **'Slightly elevated'**
  String get slightlyElevated;

  /// Heart rate chart title
  ///
  /// In en, this message translates to:
  /// **'Heart Rate'**
  String get heartRateChart;

  /// Sleep quality chart title
  ///
  /// In en, this message translates to:
  /// **'Sleep Quality'**
  String get sleepQualityChart;

  /// Body temperature chart title
  ///
  /// In en, this message translates to:
  /// **'Body Temperature'**
  String get bodyTemperatureChart;

  /// Heart rate variability chart title
  ///
  /// In en, this message translates to:
  /// **'Heart Rate Variability'**
  String get heartRateVariabilityChart;

  /// Stress level chart title
  ///
  /// In en, this message translates to:
  /// **'Stress Level'**
  String get stressLevelChart;

  /// AI insights section title
  ///
  /// In en, this message translates to:
  /// **'AI Health Insights'**
  String get aiHealthInsightsTitle;

  /// AI insights section description
  ///
  /// In en, this message translates to:
  /// **'Personalized insights based on your biometric patterns'**
  String get personalizedInsightsBasedOnBiometricPatterns;

  /// No insights card title
  ///
  /// In en, this message translates to:
  /// **'No Insights Available'**
  String get noInsightsAvailable;

  /// No insights card message
  ///
  /// In en, this message translates to:
  /// **'Keep tracking your health data to get personalized AI insights'**
  String get keepTrackingHealthDataForAiInsights;

  /// Connected devices card title
  ///
  /// In en, this message translates to:
  /// **'Connected Devices'**
  String get connectedDevices;

  /// iPhone Health device
  ///
  /// In en, this message translates to:
  /// **'iPhone Health'**
  String get iphoneHealth;

  /// Connected device status
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Apple Watch device
  ///
  /// In en, this message translates to:
  /// **'Apple Watch'**
  String get appleWatch;

  /// Syncing device status
  ///
  /// In en, this message translates to:
  /// **'Syncing'**
  String get syncing;

  /// Garmin Connect device
  ///
  /// In en, this message translates to:
  /// **'Garmin Connect'**
  String get garminConnect;

  /// Not connected device status
  ///
  /// In en, this message translates to:
  /// **'Not connected'**
  String get notConnected;

  /// Sync settings card title
  ///
  /// In en, this message translates to:
  /// **'Sync Settings'**
  String get syncSettings;

  /// Auto sync setting
  ///
  /// In en, this message translates to:
  /// **'Auto Sync'**
  String get autoSync;

  /// Auto sync setting description
  ///
  /// In en, this message translates to:
  /// **'Automatically sync health data'**
  String get automaticallySyncHealthData;

  /// Background sync setting
  ///
  /// In en, this message translates to:
  /// **'Background Sync'**
  String get backgroundSync;

  /// Background sync setting description
  ///
  /// In en, this message translates to:
  /// **'Sync data in the background'**
  String get syncDataInBackground;

  /// Loading state message
  ///
  /// In en, this message translates to:
  /// **'Loading biometric data...'**
  String get loadingBiometricData;

  /// Error state title
  ///
  /// In en, this message translates to:
  /// **'Error Loading Data'**
  String get errorLoadingData;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred'**
  String get anUnexpectedErrorOccurred;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Empty state title
  ///
  /// In en, this message translates to:
  /// **'No Health Data'**
  String get noHealthData;

  /// Empty state message
  ///
  /// In en, this message translates to:
  /// **'Connect your health devices to see biometric insights'**
  String get connectHealthDevicesForBiometricInsights;

  /// Permission state title
  ///
  /// In en, this message translates to:
  /// **'Health Access Required'**
  String get healthAccessRequired;

  /// Permission state message
  ///
  /// In en, this message translates to:
  /// **'Please grant access to health data to view biometric insights'**
  String get pleaseGrantAccessToHealthDataForBiometricInsights;

  /// Grant access button
  ///
  /// In en, this message translates to:
  /// **'Grant Access'**
  String get grantAccess;

  /// Health score description for excellent health
  ///
  /// In en, this message translates to:
  /// **'Excellent health metrics'**
  String get excellentHealthMetrics;

  /// Health score description for very good health
  ///
  /// In en, this message translates to:
  /// **'Very good health patterns'**
  String get veryGoodHealthPatterns;

  /// Health score description for good health
  ///
  /// In en, this message translates to:
  /// **'Good overall health'**
  String get goodOverallHealth;

  /// Health score description for moderate health
  ///
  /// In en, this message translates to:
  /// **'Moderate health indicators'**
  String get moderateHealthIndicators;

  /// Health score description for poor health
  ///
  /// In en, this message translates to:
  /// **'Focus on health improvement'**
  String get focusOnHealthImprovement;

  /// Calendar screen title
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTitle;

  /// Today button label
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayButton;

  /// FAQ browser screen title
  ///
  /// In en, this message translates to:
  /// **'FAQ & Knowledge Base'**
  String get faqAndKnowledgeBase;

  /// FAQ browser screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Find answers to common questions'**
  String get findAnswersToCommonQuestions;

  /// Search field placeholder for FAQs
  ///
  /// In en, this message translates to:
  /// **'Search FAQs...'**
  String get searchFAQs;

  /// All categories filter chip label
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get allCategories;

  /// Number of search results found
  ///
  /// In en, this message translates to:
  /// **'{count} search results'**
  String searchResults(int count);

  /// Number of FAQs in a specific category
  ///
  /// In en, this message translates to:
  /// **'{count} FAQs in {category}'**
  String faqsInCategory(int count, String category);

  /// Total number of FAQs available
  ///
  /// In en, this message translates to:
  /// **'{count} total FAQs'**
  String totalFAQs(int count);

  /// Button label to ask AI assistant
  ///
  /// In en, this message translates to:
  /// **'Ask Mira'**
  String get askMira;

  /// Button to ask AI about related topics
  ///
  /// In en, this message translates to:
  /// **'Ask related question'**
  String get askRelatedQuestion;

  /// Verified content indicator
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// AI chat dialog title
  ///
  /// In en, this message translates to:
  /// **'Ask Mira AI'**
  String get askMiraAI;

  /// AI chat dialog subtitle
  ///
  /// In en, this message translates to:
  /// **'Get personalized answers to your questions'**
  String get getPersonalizedAnswers;

  /// Message indicating full chat is coming soon
  ///
  /// In en, this message translates to:
  /// **'Full chat experience coming soon!'**
  String get fullChatExperienceComingSoon;

  /// Instructions for current chat functionality
  ///
  /// In en, this message translates to:
  /// **'For now, use the floating chat in the insights screen'**
  String get useFloatingChatInInsights;

  /// Button to navigate to AI chat
  ///
  /// In en, this message translates to:
  /// **'Go to AI Chat'**
  String get goToAIChat;

  /// FAQ and help section title
  ///
  /// In en, this message translates to:
  /// **'FAQ & Help'**
  String get faqAndHelp;

  /// Action button subtitle for FAQ
  ///
  /// In en, this message translates to:
  /// **'Get answers'**
  String get getAnswers;

  /// Medical disclaimer for health information
  ///
  /// In en, this message translates to:
  /// **'This information is AI-generated for awareness purposes only and not a substitute for professional medical advice. Consult a qualified healthcare provider for medical concerns.'**
  String get medicalDisclaimer;

  /// Short medical disclaimer
  ///
  /// In en, this message translates to:
  /// **'AI-generated information. Not medical advice.'**
  String get medicalDisclaimerShort;

  /// AI content indicator
  ///
  /// In en, this message translates to:
  /// **'AI-Generated Content'**
  String get aiGeneratedContent;

  /// Not medical advice indicator
  ///
  /// In en, this message translates to:
  /// **'Not Medical Advice'**
  String get notMedicalAdvice;

  /// Recommendation to consult healthcare provider
  ///
  /// In en, this message translates to:
  /// **'Consult a healthcare provider for medical advice'**
  String get consultHealthcareProvider;

  /// Non-medical app positioning
  ///
  /// In en, this message translates to:
  /// **'Cycle Awareness & Personal Insights'**
  String get cycleAwarenessInsights;

  /// Safe app tagline focused on awareness
  ///
  /// In en, this message translates to:
  /// **'Learn your patterns. Understand your rhythm. Powered by AI.'**
  String get learnYourPatterns;

  /// Clarification that insights are based on user data
  ///
  /// In en, this message translates to:
  /// **'Based on your logged information'**
  String get basedOnYourLoggedData;

  /// Safe term instead of predictions
  ///
  /// In en, this message translates to:
  /// **'Personalized Estimations'**
  String get personalizedEstimates;

  /// Safe term for cycle insights
  ///
  /// In en, this message translates to:
  /// **'Cycle Pattern Awareness'**
  String get cyclePatternAwareness;

  /// Safe benefit statement
  ///
  /// In en, this message translates to:
  /// **'May help increase awareness of your body\'s patterns'**
  String get mayHelpIncreaseAwareness;

  /// Safe prediction language
  ///
  /// In en, this message translates to:
  /// **'Estimated based on your logged patterns'**
  String get estimatedBasedOnPatterns;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return lookupAppLocalizations(locale);
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

Future<AppLocalizations> lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return app_localizations_ar.loadLibrary().then(
        (dynamic _) => app_localizations_ar.AppLocalizationsAr(),
      );
    case 'bg':
      return app_localizations_bg.loadLibrary().then(
        (dynamic _) => app_localizations_bg.AppLocalizationsBg(),
      );
    case 'bn':
      return app_localizations_bn.loadLibrary().then(
        (dynamic _) => app_localizations_bn.AppLocalizationsBn(),
      );
    case 'cs':
      return app_localizations_cs.loadLibrary().then(
        (dynamic _) => app_localizations_cs.AppLocalizationsCs(),
      );
    case 'cy':
      return app_localizations_cy.loadLibrary().then(
        (dynamic _) => app_localizations_cy.AppLocalizationsCy(),
      );
    case 'da':
      return app_localizations_da.loadLibrary().then(
        (dynamic _) => app_localizations_da.AppLocalizationsDa(),
      );
    case 'de':
      return app_localizations_de.loadLibrary().then(
        (dynamic _) => app_localizations_de.AppLocalizationsDe(),
      );
    case 'el':
      return app_localizations_el.loadLibrary().then(
        (dynamic _) => app_localizations_el.AppLocalizationsEl(),
      );
    case 'en':
      return app_localizations_en.loadLibrary().then(
        (dynamic _) => app_localizations_en.AppLocalizationsEn(),
      );
    case 'es':
      return app_localizations_es.loadLibrary().then(
        (dynamic _) => app_localizations_es.AppLocalizationsEs(),
      );
    case 'et':
      return app_localizations_et.loadLibrary().then(
        (dynamic _) => app_localizations_et.AppLocalizationsEt(),
      );
    case 'fi':
      return app_localizations_fi.loadLibrary().then(
        (dynamic _) => app_localizations_fi.AppLocalizationsFi(),
      );
    case 'fr':
      return app_localizations_fr.loadLibrary().then(
        (dynamic _) => app_localizations_fr.AppLocalizationsFr(),
      );
    case 'ga':
      return app_localizations_ga.loadLibrary().then(
        (dynamic _) => app_localizations_ga.AppLocalizationsGa(),
      );
    case 'he':
      return app_localizations_he.loadLibrary().then(
        (dynamic _) => app_localizations_he.AppLocalizationsHe(),
      );
    case 'hi':
      return app_localizations_hi.loadLibrary().then(
        (dynamic _) => app_localizations_hi.AppLocalizationsHi(),
      );
    case 'hr':
      return app_localizations_hr.loadLibrary().then(
        (dynamic _) => app_localizations_hr.AppLocalizationsHr(),
      );
    case 'hu':
      return app_localizations_hu.loadLibrary().then(
        (dynamic _) => app_localizations_hu.AppLocalizationsHu(),
      );
    case 'is':
      return app_localizations_is.loadLibrary().then(
        (dynamic _) => app_localizations_is.AppLocalizationsIs(),
      );
    case 'it':
      return app_localizations_it.loadLibrary().then(
        (dynamic _) => app_localizations_it.AppLocalizationsIt(),
      );
    case 'ja':
      return app_localizations_ja.loadLibrary().then(
        (dynamic _) => app_localizations_ja.AppLocalizationsJa(),
      );
    case 'ko':
      return app_localizations_ko.loadLibrary().then(
        (dynamic _) => app_localizations_ko.AppLocalizationsKo(),
      );
    case 'lt':
      return app_localizations_lt.loadLibrary().then(
        (dynamic _) => app_localizations_lt.AppLocalizationsLt(),
      );
    case 'lv':
      return app_localizations_lv.loadLibrary().then(
        (dynamic _) => app_localizations_lv.AppLocalizationsLv(),
      );
    case 'mt':
      return app_localizations_mt.loadLibrary().then(
        (dynamic _) => app_localizations_mt.AppLocalizationsMt(),
      );
    case 'nl':
      return app_localizations_nl.loadLibrary().then(
        (dynamic _) => app_localizations_nl.AppLocalizationsNl(),
      );
    case 'no':
      return app_localizations_no.loadLibrary().then(
        (dynamic _) => app_localizations_no.AppLocalizationsNo(),
      );
    case 'pl':
      return app_localizations_pl.loadLibrary().then(
        (dynamic _) => app_localizations_pl.AppLocalizationsPl(),
      );
    case 'pt':
      return app_localizations_pt.loadLibrary().then(
        (dynamic _) => app_localizations_pt.AppLocalizationsPt(),
      );
    case 'ro':
      return app_localizations_ro.loadLibrary().then(
        (dynamic _) => app_localizations_ro.AppLocalizationsRo(),
      );
    case 'ru':
      return app_localizations_ru.loadLibrary().then(
        (dynamic _) => app_localizations_ru.AppLocalizationsRu(),
      );
    case 'sk':
      return app_localizations_sk.loadLibrary().then(
        (dynamic _) => app_localizations_sk.AppLocalizationsSk(),
      );
    case 'sl':
      return app_localizations_sl.loadLibrary().then(
        (dynamic _) => app_localizations_sl.AppLocalizationsSl(),
      );
    case 'sv':
      return app_localizations_sv.loadLibrary().then(
        (dynamic _) => app_localizations_sv.AppLocalizationsSv(),
      );
    case 'th':
      return app_localizations_th.loadLibrary().then(
        (dynamic _) => app_localizations_th.AppLocalizationsTh(),
      );
    case 'tr':
      return app_localizations_tr.loadLibrary().then(
        (dynamic _) => app_localizations_tr.AppLocalizationsTr(),
      );
    case 'uk':
      return app_localizations_uk.loadLibrary().then(
        (dynamic _) => app_localizations_uk.AppLocalizationsUk(),
      );
    case 'vi':
      return app_localizations_vi.loadLibrary().then(
        (dynamic _) => app_localizations_vi.AppLocalizationsVi(),
      );
    case 'zh':
      return app_localizations_zh.loadLibrary().then(
        (dynamic _) => app_localizations_zh.AppLocalizationsZh(),
      );
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
