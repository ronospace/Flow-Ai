// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appName => 'FlowSense';

  @override
  String get appTagline => 'KI-gestützte Menstruations- und Zyklus-Verfolgung';

  @override
  String get appDescription =>
      'Verfolgen Sie Ihren Menstruationszyklus mit KI-gestützten Einblicken und personalisierten Empfehlungen für bessere Fortpflanzungsgesundheit.';

  @override
  String get home => 'Startseite';

  @override
  String get calendar => 'Kalender';

  @override
  String get tracking => 'Verfolgung';

  @override
  String get insights => 'Einblicke';

  @override
  String get settings => 'Einstellungen';

  @override
  String cycleDay(int day) {
    return 'Tag $day';
  }

  @override
  String cycleLength(int length) {
    return 'Zykluslänge: $length Tage';
  }

  @override
  String daysUntilPeriod(int days) {
    return '$days Tage bis zur Periode';
  }

  @override
  String daysUntilOvulation(int days) {
    return '$days Tage bis zum Eisprung';
  }

  @override
  String get currentPhase => 'Aktuelle Phase';

  @override
  String get menstrualPhase => 'Menstruationsphase';

  @override
  String get follicularPhase => 'Follikelphase';

  @override
  String get ovulatoryPhase => 'Eisprungphase';

  @override
  String get lutealPhase => 'Gelbkörperphase';

  @override
  String get fertileWindow => 'Fruchtbare Tage';

  @override
  String get ovulationDay => 'Eisprungtag';

  @override
  String get periodStarted => 'Periode begonnen';

  @override
  String get periodEnded => 'Periode beendet';

  @override
  String get flowIntensity => 'Flussstärke';

  @override
  String get flowNone => 'Keine';

  @override
  String get flowSpotting => 'Schmierblutung';

  @override
  String get flowLight => 'Leicht';

  @override
  String get flowMedium => 'Mittel';

  @override
  String get flowHeavy => 'Stark';

  @override
  String get flowVeryHeavy => 'Sehr stark';

  @override
  String get symptoms => 'Symptome';

  @override
  String get noSymptoms => 'Keine Symptome';

  @override
  String get cramps => 'Krämpfe';

  @override
  String get bloating => 'Blähungen';

  @override
  String get headache => 'Kopfschmerzen';

  @override
  String get backPain => 'Rückenschmerzen';

  @override
  String get breastTenderness => 'Brustspannen';

  @override
  String get fatigue => 'Müdigkeit';

  @override
  String get moodSwings => 'Stimmungsschwankungen';

  @override
  String get acne => 'Akne';

  @override
  String get nausea => 'Übelkeit';

  @override
  String get cravings => 'Heißhunger';

  @override
  String get insomnia => 'Schlaflosigkeit';

  @override
  String get hotFlashes => 'Hitzewallungen';

  @override
  String get coldFlashes => 'Kälteschauer';

  @override
  String get diarrhea => 'Durchfall';

  @override
  String get constipation => 'Verstopfung';

  @override
  String get mood => 'Stimmung';

  @override
  String get energy => 'Energie';

  @override
  String get pain => 'Schmerz';

  @override
  String get moodHappy => 'Glücklich';

  @override
  String get moodNeutral => 'Neutral';

  @override
  String get moodSad => 'Traurig';

  @override
  String get moodAnxious => 'Ängstlich';

  @override
  String get moodIrritated => 'Gereizt';

  @override
  String get energyHigh => 'Hohe Energie';

  @override
  String get energyMedium => 'Mittlere Energie';

  @override
  String get energyLow => 'Niedrige Energie';

  @override
  String get painNone => 'Keine Schmerzen';

  @override
  String get painMild => 'Leichte Schmerzen';

  @override
  String get painModerate => 'Mittlere Schmerzen';

  @override
  String get painSevere => 'Starke Schmerzen';

  @override
  String get predictions => 'Vorhersagen';

  @override
  String get nextPeriod => 'Nächste Periode';

  @override
  String get nextOvulation => 'Nächster Eisprung';

  @override
  String predictedDate(String date) {
    return 'Vorhergesagt: $date';
  }

  @override
  String confidence(int percentage) {
    return 'Vertrauen: $percentage%';
  }

  @override
  String get aiPoweredPredictions => 'KI-gestützte Vorhersagen';

  @override
  String get advancedInsights => 'Erweiterte Einblicke';

  @override
  String get personalizedRecommendations => 'Personalisierte Empfehlungen';

  @override
  String get cycleInsights => 'Zyklus-Einblicke';

  @override
  String get patternAnalysis => 'Muster-Analyse';

  @override
  String get cycleTrends => 'Zyklus-Trends';

  @override
  String get symptomPatterns => 'Symptom-Muster';

  @override
  String get moodPatterns => 'Stimmungs-Muster';

  @override
  String get regularCycle => 'Ihr Zyklus ist regelmäßig';

  @override
  String get irregularCycle => 'Ihr Zyklus zeigt Unregelmäßigkeiten';

  @override
  String cycleVariation(int days) {
    return 'Zyklusvariation: ±$days Tage';
  }

  @override
  String averageCycleLength(int days) {
    return 'Durchschnittliche Zykluslänge: $days Tage';
  }

  @override
  String get lifestyle => 'Lebensstil';

  @override
  String get nutrition => 'Ernährung';

  @override
  String get exercise => 'Sport';

  @override
  String get wellness => 'Wohlbefinden';

  @override
  String get sleepBetter => 'Verbessern Sie Ihre Schlafqualität';

  @override
  String get stayHydrated => 'Bleiben Sie hydratisiert';

  @override
  String get gentleExercise => 'Versuchen Sie sanfte Übungen wie Yoga';

  @override
  String get eatIronRich => 'Essen Sie eisenreiche Lebensmittel';

  @override
  String get takeBreaks => 'Machen Sie regelmäßige Pausen';

  @override
  String get manageStress => 'Praktizieren Sie Stressmanagement';

  @override
  String get warmBath => 'Nehmen Sie ein warmes Bad';

  @override
  String get meditation => 'Versuchen Sie Meditation oder tiefe Atmung';

  @override
  String get logToday => 'Heute protokollieren';

  @override
  String get trackFlow => 'Fluss verfolgen';

  @override
  String get trackSymptoms => 'Symptome verfolgen';

  @override
  String get trackMood => 'Stimmung verfolgen';

  @override
  String get trackPain => 'Schmerz verfolgen';

  @override
  String get addNotes => 'Notizen hinzufügen';

  @override
  String get notes => 'Notizen';

  @override
  String get save => 'Speichern';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get update => 'Aktualisieren';

  @override
  String get confirm => 'Bestätigen';

  @override
  String get thisMonth => 'Dieser Monat';

  @override
  String get nextMonth => 'Nächster Monat';

  @override
  String get previousMonth => 'Vorheriger Monat';

  @override
  String get today => 'Heute';

  @override
  String get selectDate => 'Datum auswählen';

  @override
  String get periodDays => 'Perioden-Tage';

  @override
  String get fertileDays => 'Fruchtbare Tage';

  @override
  String get ovulationDays => 'Eisprung-Tage';

  @override
  String get symptomDays => 'Symptom-Tage';

  @override
  String get profile => 'Profil';

  @override
  String get notifications => 'Benachrichtigungen';

  @override
  String get privacy => 'Datenschutz';

  @override
  String get language => 'Sprache';

  @override
  String get theme => 'Design';

  @override
  String get export => 'Daten exportieren';

  @override
  String get backup => 'Sicherung';

  @override
  String get help => 'Hilfe';

  @override
  String get about => 'Über';

  @override
  String get version => 'Version';

  @override
  String get contactSupport => 'Support kontaktieren';

  @override
  String get rateApp => 'App bewerten';

  @override
  String get shareApp => 'App teilen';

  @override
  String get personalInfo => 'Persönliche Informationen';

  @override
  String get age => 'Alter';

  @override
  String get height => 'Größe';

  @override
  String get weight => 'Gewicht';

  @override
  String get cycleHistory => 'Zyklus-Geschichte';

  @override
  String get avgCycleLength => 'Durchschnittliche Zykluslänge';

  @override
  String get avgPeriodLength => 'Durchschnittliche Periodenlänge';

  @override
  String get lastPeriod => 'Letzte Periode';

  @override
  String get periodPreferences => 'Perioden-Präferenzen';

  @override
  String get trackingGoals => 'Verfolgungsziele';

  @override
  String get periodReminder => 'Perioden-Erinnerung';

  @override
  String get ovulationReminder => 'Eisprung-Erinnerung';

  @override
  String get pillReminder => 'Pillen-Erinnerung';

  @override
  String get symptomReminder => 'Symptom-Verfolgung Erinnerung';

  @override
  String get insightNotifications => 'Einblick-Benachrichtigungen';

  @override
  String get enableNotifications => 'Benachrichtigungen aktivieren';

  @override
  String get notificationTime => 'Benachrichtigungszeit';

  @override
  String reminderDays(int days) {
    return '$days Tage vorher';
  }

  @override
  String get healthData => 'Gesundheitsdaten';

  @override
  String get connectHealthApp => 'Mit Gesundheits-App verbinden';

  @override
  String get syncData => 'Daten synchronisieren';

  @override
  String get heartRate => 'Herzfrequenz';

  @override
  String get sleepData => 'Schlafdaten';

  @override
  String get steps => 'Schritte';

  @override
  String get temperature => 'Körpertemperatur';

  @override
  String get bloodPressure => 'Blutdruck';

  @override
  String get aiInsights => 'KI-Einblicke';

  @override
  String get smartPredictions => 'Intelligente Vorhersagen';

  @override
  String get personalizedTips => 'Personalisierte Tipps';

  @override
  String get patternRecognition => 'Mustererkennung';

  @override
  String get anomalyDetection => 'Anomalie-Erkennung';

  @override
  String get learningFromData => 'Lernen aus Ihren Daten...';

  @override
  String get improvingAccuracy => 'Vorhersagegenauigkeit verbessern';

  @override
  String get adaptingToPatterns => 'An Ihre Muster anpassen';

  @override
  String get welcome => 'Willkommen bei FlowSense';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get skipForNow => 'Vorerst überspringen';

  @override
  String get next => 'Weiter';

  @override
  String get previous => 'Zurück';

  @override
  String get finish => 'Fertig';

  @override
  String get setupProfile => 'Ihr Profil einrichten';

  @override
  String get trackingPermissions => 'Verfolgungs-Berechtigungen';

  @override
  String get notificationPermissions => 'Benachrichtigungs-Berechtigungen';

  @override
  String get healthPermissions => 'Gesundheits-App Berechtigungen';

  @override
  String get onboardingStep1 => 'Verfolgen Sie Ihren Zyklus präzise';

  @override
  String get onboardingStep2 => 'Erhalten Sie KI-gestützte Einblicke';

  @override
  String get onboardingStep3 => 'Erhalten Sie personalisierte Empfehlungen';

  @override
  String get onboardingStep4 => 'Überwachen Sie Ihre Fortpflanzungsgesundheit';

  @override
  String get error => 'Fehler';

  @override
  String get success => 'Erfolg';

  @override
  String get warning => 'Warnung';

  @override
  String get info => 'Info';

  @override
  String get loading => 'Lädt...';

  @override
  String get noData => 'Keine Daten verfügbar';

  @override
  String get noInternetConnection => 'Keine Internetverbindung';

  @override
  String get tryAgain => 'Erneut versuchen';

  @override
  String get somethingWentWrong => 'Etwas ist schief gelaufen';

  @override
  String get dataUpdated => 'Daten erfolgreich aktualisiert';

  @override
  String get dataSaved => 'Daten erfolgreich gespeichert';

  @override
  String get dataDeleted => 'Daten erfolgreich gelöscht';

  @override
  String get invalidInput => 'Ungültige Eingabe';

  @override
  String get fieldRequired => 'Dieses Feld ist erforderlich';

  @override
  String get selectAtLeastOne => 'Bitte wählen Sie mindestens eine Option';

  @override
  String get days => 'Tage';

  @override
  String get weeks => 'Wochen';

  @override
  String get months => 'Monate';

  @override
  String get years => 'Jahre';

  @override
  String get kg => 'kg';

  @override
  String get lbs => 'lbs';

  @override
  String get cm => 'cm';

  @override
  String get inches => 'Zoll';

  @override
  String get celsius => '°C';

  @override
  String get fahrenheit => '°F';

  @override
  String get morning => 'Morgen';

  @override
  String get afternoon => 'Nachmittag';

  @override
  String get evening => 'Abend';

  @override
  String get night => 'Nacht';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String get yesterday => 'Gestern';

  @override
  String get tomorrow => 'Morgen';

  @override
  String get thisWeek => 'Diese Woche';

  @override
  String get lastWeek => 'Letzte Woche';

  @override
  String get nextWeek => 'Nächste Woche';

  @override
  String get yes => 'Ja';

  @override
  String get no => 'Nein';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Fertig';

  @override
  String get close => 'Schließen';

  @override
  String get open => 'Öffnen';

  @override
  String get view => 'Ansehen';

  @override
  String get hide => 'Verstecken';

  @override
  String get show => 'Zeigen';

  @override
  String get enable => 'Aktivieren';

  @override
  String get disable => 'Deaktivieren';

  @override
  String get on => 'An';

  @override
  String get off => 'Aus';

  @override
  String get high => 'Hoch';

  @override
  String get medium => 'Mittel';

  @override
  String get low => 'Niedrig';

  @override
  String get none => 'Keine';

  @override
  String get all => 'Alle';

  @override
  String get search => 'Suchen';

  @override
  String get filter => 'Filter';

  @override
  String get sort => 'Sortieren';

  @override
  String get refresh => 'Aktualisieren';

  @override
  String get clear => 'Löschen';

  @override
  String get reset => 'Zurücksetzen';

  @override
  String get apply => 'Anwenden';

  @override
  String get loadingAiEngine => 'KI-Gesundheits-Engine wird initialisiert...';

  @override
  String get analyzingHealthPatterns =>
      'Ihre Gesundheitsmuster werden analysiert';

  @override
  String get goodMorning => 'Guten Morgen';

  @override
  String get goodAfternoon => 'Guten Tag';

  @override
  String get goodEvening => 'Guten Abend';

  @override
  String get aiActive => 'KI Aktiv';

  @override
  String get health => 'Gesundheit';

  @override
  String get optimal => 'Optimal';

  @override
  String get cycleStatus => 'Zyklus-Status';

  @override
  String get notStarted => 'Nicht gestartet';

  @override
  String get moodBalance => 'Stimmungs-Balance';

  @override
  String get notTracked => 'Nicht verfolgt';

  @override
  String get energyLevel => 'Energie-Level';

  @override
  String get flowIntensityMetric => 'Flussstärke';

  @override
  String get logSymptoms => 'Symptome protokollieren';

  @override
  String get trackYourHealth => 'Ihre Gesundheit verfolgen';

  @override
  String get periodTracker => 'Perioden-Tracker';

  @override
  String get startLogging => 'Protokollierung starten';

  @override
  String get moodAndEnergy => 'Stimmung & Energie';

  @override
  String get logWellness => 'Wohlbefinden protokollieren';

  @override
  String get viewAnalysis => 'Analyse anzeigen';

  @override
  String get accuracy => 'Genauigkeit';

  @override
  String get highConfidence => 'Hohe Vertrauenswürdigkeit';

  @override
  String get gatheringDataForPredictions => 'Daten für Vorhersagen sammeln';

  @override
  String get startTrackingForPredictions =>
      'Beginnen Sie mit der Verfolgung Ihrer Zyklen, um KI-Vorhersagen freizuschalten';

  @override
  String get aiLearningPatterns => 'KI lernt Ihre Muster';

  @override
  String get trackForInsights =>
      'Verfolgen Sie Ihre Zyklen, um personalisierte KI-Einblicke freizuschalten';

  @override
  String get cycleRegularity => 'Zyklus-Regelmäßigkeit';

  @override
  String get fromLastMonth => '+5% vom letzten Monat';

  @override
  String get avgCycle => 'Durchschn. Zyklus';

  @override
  String get avgMood => 'Durchschn. Stimmung';

  @override
  String get daysCycle => '28,5 Tage';

  @override
  String get moodRating => '4,2/5';

  @override
  String get chooseTheme => 'Design Wählen';

  @override
  String get lightTheme => 'Helles Design';

  @override
  String get lightThemeDescription => 'Helles und sauberes Erscheinungsbild';

  @override
  String get darkTheme => 'Dunkles Design';

  @override
  String get darkThemeDescription => 'Augenschonend bei schwachem Licht';

  @override
  String get biometricDashboard => 'Biometrisches Dashboard';

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
  String get physical => 'Körperlich';

  @override
  String get emotional => 'Emotional';

  @override
  String get skinAndHair => 'Haut & Haare';

  @override
  String get digestive => 'Verdauung';

  @override
  String get moodSwingsSymptom => 'Stimmungsschwankungen';

  @override
  String get irritability => 'Reizbarkeit';

  @override
  String get anxiety => 'Angst';

  @override
  String get depression => 'Depression';

  @override
  String get emotionalSensitivity => 'Emotionale Sensibilität';

  @override
  String get stress => 'Stress';

  @override
  String get oilySkin => 'Fettige Haut';

  @override
  String get drySkin => 'Trockene Haut';

  @override
  String get hairChanges => 'Haarveränderungen';

  @override
  String get foodCravings => 'Heißhungerattacken';

  @override
  String get lossOfAppetite => 'Appetitverlust';

  @override
  String selectedSymptoms(int count) {
    return 'Ausgewählte Symptome ($count)';
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
  String get systemTheme => 'System-Design';

  @override
  String get systemThemeDescription => 'Passt zu Ihren Geräteeinstellungen';

  @override
  String get themeChangedTo => 'Design geändert zu';

  @override
  String get chooseLanguage => 'Sprache Wählen';

  @override
  String get searchLanguages => 'Sprachen suchen...';

  @override
  String get languageChangedTo => 'Sprache geändert zu';

  @override
  String get appPreferences => 'App-Einstellungen';

  @override
  String get customizeAppearance => 'App-Erscheinungsbild anpassen';

  @override
  String get chooseYourLanguage => 'Wählen Sie Ihre Sprache';

  @override
  String get receiveReminders => 'Erinnerungen und Updates erhalten';

  @override
  String get dailyReminders => 'Wann tägliche Erinnerungen senden';

  @override
  String get unlockPremiumAiInsights => 'Premium KI-Einblicke freischalten';

  @override
  String get watchAdToUnlockInsights =>
      'Schaue eine Werbung, um erweiterte Einblicke freizuschalten';

  @override
  String get free => 'KOSTENLOS';

  @override
  String get watchAdUnlockInsights =>
      'Werbung ansehen & Einblicke freischalten';

  @override
  String get getAdditionalPremiumInsights =>
      'Erhalte 3 zusätzliche Premium-Einblicke';

  @override
  String get unlockAdvancedHealthRecommendations =>
      'Erweiterte Gesundheitsempfehlungen freischalten';

  @override
  String get premiumInsightsUnlocked => 'Premium-Einblicke freigeschaltet! 🎉';

  @override
  String day(int day) {
    return 'Tag $day';
  }

  @override
  String confidencePercentage(int percentage) {
    return '$percentage% Vertrauen';
  }

  @override
  String get quickActions => 'Schnellaktionen';

  @override
  String get logPeriod => 'Periode protokollieren';

  @override
  String get currentCycleTitle => 'Aktueller Zyklus';

  @override
  String get moodLabel => 'Stimmung';

  @override
  String get aiSmartFeatures => 'KI & Intelligente Funktionen';

  @override
  String get personalizedAiInsights => 'Personalisierte KI-Einblicke erhalten';

  @override
  String get hapticFeedback => 'Haptisches Feedback';

  @override
  String get vibrationInteractions => 'Vibrationen bei Interaktionen spüren';

  @override
  String get supportAbout => 'Support & Über';

  @override
  String get getHelpTutorials => 'Hilfe und Tutorials erhalten';

  @override
  String get versionInfoLegal => 'Versionsinformationen und Rechtliches';

  @override
  String get light => 'Hell';

  @override
  String get dark => 'Dunkel';

  @override
  String get system => 'System';

  @override
  String get flowIntensityNone => 'Keine';

  @override
  String get flowIntensityNoneSubtitle => 'Kein Menstruationsfluss';

  @override
  String get flowIntensityNoneDescription =>
      'Vollständiges Fehlen des Menstruationsflusses. Dies ist normal, bevor Ihre Periode beginnt oder nachdem sie endet.';

  @override
  String get flowIntensityNoneMedicalInfo => 'Keine Menstruation';

  @override
  String get flowIntensitySpotting => 'Schmierblutung';

  @override
  String get flowIntensitySpottingSubtitle => 'Minimaler Ausfluss';

  @override
  String get flowIntensitySpottingDescription =>
      'Sehr leichter rosa oder brauner Ausfluss. Tritt oft zu Beginn oder Ende Ihres Zyklus auf.';

  @override
  String get flowIntensitySpottingMedicalInfo => 'Weniger als 5ml pro Tag';

  @override
  String get flowIntensityLight => 'Leichter Fluss';

  @override
  String get flowIntensityLightSubtitle => 'Angenehmer Schutz';

  @override
  String get flowIntensityLightDescription =>
      'Leichter Menstruationsfluss, der minimalen Schutz erfordert. Dauert normalerweise 1-3 Tage.';

  @override
  String get flowIntensityLightMedicalInfo => '5-40ml pro Tag';

  @override
  String get flowIntensityMedium => 'Normaler Fluss';

  @override
  String get flowIntensityMediumSubtitle => 'Typische Menstruation';

  @override
  String get flowIntensityMediumDescription =>
      'Regelmäßiger Menstruationsfluss. Dies ist die häufigste Flussstärke für gesunde Zyklen.';

  @override
  String get flowIntensityMediumMedicalInfo => '40-70ml pro Tag';

  @override
  String get flowIntensityHeavy => 'Starker Fluss';

  @override
  String get flowIntensityHeavySubtitle =>
      'Hohe Absorptionsfähigkeit erforderlich';

  @override
  String get flowIntensityHeavyDescription =>
      'Starker Menstruationsfluss, der häufige Wechsel erfordert. Erwägen Sie eine Beratung durch einen Arzt.';

  @override
  String get flowIntensityHeavyMedicalInfo => '70-100ml pro Tag';

  @override
  String get flowIntensityVeryHeavy => 'Sehr stark';

  @override
  String get flowIntensityVeryHeavySubtitle => 'Ärztliche Betreuung empfohlen';

  @override
  String get flowIntensityVeryHeavyDescription =>
      'Sehr starker Fluss, der die täglichen Aktivitäten beeinträchtigen kann. Dringend empfohlene Beratung durch einen Arzt.';

  @override
  String get flowIntensityVeryHeavyMedicalInfo => 'Über 100ml pro Tag';

  @override
  String get aiHealthInsights => 'KI-Gesundheits-Einblicke';

  @override
  String get aboutThisFlowLevel => 'Über diese Flussstärke';

  @override
  String get recommendedProducts => 'Empfohlene Produkte';

  @override
  String hourlyChanges(int changes) {
    return '~$changes/Stunde Wechsel';
  }

  @override
  String get monitor => 'Überwachen';

  @override
  String get spottingInsight =>
      'Schmierblutungen sind oft normal zu Zyklusbeginn/-ende. Verfolgen Sie Muster für Einblicke.';

  @override
  String get lightFlowInsight =>
      'Leichter Fluss erkannt. Berücksichtigen Sie Stressniveau und Ernährung für optimale Gesundheit.';

  @override
  String get mediumFlowInsight =>
      'Normales Flussmuster. Ihr Zyklus scheint gesund und regelmäßig zu sein.';

  @override
  String get heavyFlowInsight =>
      'Starker Fluss erkannt. Überwachen Sie Symptome und erwägen Sie eisenreiche Nahrungsmittel.';

  @override
  String get veryHeavyFlowInsight =>
      'Sehr starker Fluss kann ärztliche Betreuung erfordern. Verfolgen Sie die Dauer sorgfältig.';

  @override
  String get noFlowInsight =>
      'Kein Fluss erkannt. Verfolgen Sie andere Symptome für umfassende Einblicke.';

  @override
  String get pantyLiners => 'Slipeinlagen';

  @override
  String get periodUnderwear => 'Periodenunterwäsche';

  @override
  String get lightPads => 'Leichte Binden';

  @override
  String get tamponsRegular => 'Tampons (normal)';

  @override
  String get menstrualCups => 'Menstruationstassen';

  @override
  String get regularPads => 'Normale Binden';

  @override
  String get tamponsSuper => 'Tampons (super)';

  @override
  String get periodUnderwearHeavy => 'Periodenunterwäsche (stark)';

  @override
  String get superPads => 'Super-Binden';

  @override
  String get tamponsSuperPlus => 'Tampons (super+)';

  @override
  String get menstrualCupsLarge => 'Menstruationstassen (groß)';

  @override
  String get ultraPads => 'Ultra-Binden';

  @override
  String get tamponsUltra => 'Tampons (ultra)';

  @override
  String get menstrualCupsXL => 'Menstruationstassen (XL)';

  @override
  String get medicalConsultation => 'Ärztliche Beratung';

  @override
  String get aiPoweredHealthInsights => 'KI-gestützte Gesundheits-Einblicke';

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
  String get sleepQuality => 'Sleep Quality';

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
}
