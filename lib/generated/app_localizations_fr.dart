// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'FlowSense';

  @override
  String get appTagline => 'Suivi des Règles et du Cycle avec IA';

  @override
  String get appDescription =>
      'Suivez votre cycle menstruel avec des analyses alimentées par l\'IA et des recommandations personnalisées pour une meilleure santé reproductive.';

  @override
  String get home => 'Accueil';

  @override
  String get calendar => 'Calendrier';

  @override
  String get tracking => 'Suivi';

  @override
  String get insights => 'Analyses';

  @override
  String get settings => 'Paramètres';

  @override
  String cycleDay(int day) {
    return 'Jour $day';
  }

  @override
  String cycleLength(int length) {
    return 'Durée du Cycle : $length jours';
  }

  @override
  String daysUntilPeriod(int days) {
    return '$days jours avant les règles';
  }

  @override
  String daysUntilOvulation(int days) {
    return '$days jours avant l\'ovulation';
  }

  @override
  String get currentPhase => 'Phase Actuelle';

  @override
  String get menstrualPhase => 'Menstruelle';

  @override
  String get follicularPhase => 'Folliculaire';

  @override
  String get ovulatoryPhase => 'Ovulatoire';

  @override
  String get lutealPhase => 'Lutéale';

  @override
  String get fertileWindow => 'Période Fertile';

  @override
  String get ovulationDay => 'Jour d\'Ovulation';

  @override
  String get periodStarted => 'Règles Commencées';

  @override
  String get periodEnded => 'Règles Terminées';

  @override
  String get flowIntensity => 'Intensité du Flux';

  @override
  String get flowNone => 'Aucun';

  @override
  String get flowSpotting => 'Spotting';

  @override
  String get flowLight => 'Léger';

  @override
  String get flowMedium => 'Moyen';

  @override
  String get flowHeavy => 'Abondant';

  @override
  String get flowVeryHeavy => 'Très Abondant';

  @override
  String get symptoms => 'Symptômes';

  @override
  String get noSymptoms => 'Aucun symptôme';

  @override
  String get cramps => 'Crampes';

  @override
  String get bloating => 'Ballonnements';

  @override
  String get headache => 'Mal de Tête';

  @override
  String get backPain => 'Mal de Dos';

  @override
  String get breastTenderness => 'Sensibilité des Seins';

  @override
  String get fatigue => 'Fatigue';

  @override
  String get moodSwings => 'Sautes d\'Humeur';

  @override
  String get acne => 'Acné';

  @override
  String get nausea => 'Nausées';

  @override
  String get cravings => 'Fringales';

  @override
  String get insomnia => 'Insomnie';

  @override
  String get hotFlashes => 'Bouffées de Chaleur';

  @override
  String get coldFlashes => 'Frissons';

  @override
  String get diarrhea => 'Diarrhée';

  @override
  String get constipation => 'Constipation';

  @override
  String get mood => 'Humeur';

  @override
  String get energy => 'Énergie';

  @override
  String get pain => 'Douleur';

  @override
  String get moodHappy => 'Heureuse';

  @override
  String get moodNeutral => 'Neutre';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodAnxious => 'Anxieuse';

  @override
  String get moodIrritated => 'Irritée';

  @override
  String get energyHigh => 'Énergie Élevée';

  @override
  String get energyMedium => 'Énergie Moyenne';

  @override
  String get energyLow => 'Énergie Faible';

  @override
  String get painNone => 'Aucune Douleur';

  @override
  String get painMild => 'Douleur Légère';

  @override
  String get painModerate => 'Douleur Modérée';

  @override
  String get painSevere => 'Douleur Sévère';

  @override
  String get predictions => 'Prédictions';

  @override
  String get nextPeriod => 'Prochaines Règles';

  @override
  String get nextOvulation => 'Prochaine Ovulation';

  @override
  String predictedDate(String date) {
    return 'Prédit : $date';
  }

  @override
  String confidence(int percentage) {
    return 'Confiance : $percentage%';
  }

  @override
  String get aiPoweredPredictions => 'Prédictions Alimentées par l\'IA';

  @override
  String get advancedInsights => 'Analyses Avancées';

  @override
  String get personalizedRecommendations => 'Recommandations Personnalisées';

  @override
  String get cycleInsights => 'Analyses du Cycle';

  @override
  String get patternAnalysis => 'Analyse des Tendances';

  @override
  String get cycleTrends => 'Tendances du Cycle';

  @override
  String get symptomPatterns => 'Schémas de Symptômes';

  @override
  String get moodPatterns => 'Schémas d\'Humeur';

  @override
  String get regularCycle => 'Votre cycle est régulier';

  @override
  String get irregularCycle => 'Votre cycle montre quelques irrégularités';

  @override
  String cycleVariation(int days) {
    return 'Variation du cycle : ±$days jours';
  }

  @override
  String averageCycleLength(int days) {
    return 'Durée moyenne du cycle : $days jours';
  }

  @override
  String get lifestyle => 'Mode de Vie';

  @override
  String get nutrition => 'Nutrition';

  @override
  String get exercise => 'Exercice';

  @override
  String get wellness => 'Bien-être';

  @override
  String get sleepBetter => 'Améliorez la qualité de votre sommeil';

  @override
  String get stayHydrated => 'Restez hydratée';

  @override
  String get gentleExercise => 'Essayez un exercice doux comme le yoga';

  @override
  String get eatIronRich => 'Mangez des aliments riches en fer';

  @override
  String get takeBreaks => 'Prenez des pauses régulières';

  @override
  String get manageStress => 'Pratiquez la gestion du stress';

  @override
  String get warmBath => 'Prenez un bain chaud';

  @override
  String get meditation => 'Essayez la méditation ou la respiration profonde';

  @override
  String get logToday => 'Enregistrer Aujourd\'hui';

  @override
  String get trackFlow => 'Suivre le Flux';

  @override
  String get trackSymptoms => 'Suivre les Symptômes';

  @override
  String get trackMood => 'Suivre l\'Humeur';

  @override
  String get trackPain => 'Suivre la Douleur';

  @override
  String get addNotes => 'Ajouter des Notes';

  @override
  String get notes => 'Notes';

  @override
  String get save => 'Sauvegarder';

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get edit => 'Modifier';

  @override
  String get update => 'Mettre à Jour';

  @override
  String get confirm => 'Confirmer';

  @override
  String get thisMonth => 'Ce Mois';

  @override
  String get nextMonth => 'Mois Prochain';

  @override
  String get previousMonth => 'Mois Précédent';

  @override
  String get today => 'Aujourd\'hui';

  @override
  String get selectDate => 'Sélectionner une Date';

  @override
  String get periodDays => 'Jours de Règles';

  @override
  String get fertileDays => 'Jours Fertiles';

  @override
  String get ovulationDays => 'Jours d\'Ovulation';

  @override
  String get symptomDays => 'Jours avec Symptômes';

  @override
  String get profile => 'Profil';

  @override
  String get notifications => 'Notifications';

  @override
  String get privacy => 'Confidentialité';

  @override
  String get language => 'Langue';

  @override
  String get theme => 'Thème';

  @override
  String get export => 'Exporter les Données';

  @override
  String get backup => 'Sauvegarde';

  @override
  String get help => 'Aide';

  @override
  String get about => 'À Propos';

  @override
  String get version => 'Version';

  @override
  String get contactSupport => 'Contacter le Support';

  @override
  String get rateApp => 'Évaluer l\'App';

  @override
  String get shareApp => 'Partager l\'App';

  @override
  String get personalInfo => 'Informations Personnelles';

  @override
  String get age => 'Âge';

  @override
  String get height => 'Taille';

  @override
  String get weight => 'Poids';

  @override
  String get cycleHistory => 'Historique du Cycle';

  @override
  String get avgCycleLength => 'Durée Moyenne du Cycle';

  @override
  String get avgPeriodLength => 'Durée Moyenne des Règles';

  @override
  String get lastPeriod => 'Dernières Règles';

  @override
  String get periodPreferences => 'Préférences des Règles';

  @override
  String get trackingGoals => 'Objectifs de Suivi';

  @override
  String get periodReminder => 'Rappel des Règles';

  @override
  String get ovulationReminder => 'Rappel d\'Ovulation';

  @override
  String get pillReminder => 'Rappel de Pilule';

  @override
  String get symptomReminder => 'Rappel de Suivi des Symptômes';

  @override
  String get insightNotifications => 'Notifications d\'Analyses';

  @override
  String get enableNotifications => 'Activer les Notifications';

  @override
  String get notificationTime => 'Heure de Notification';

  @override
  String reminderDays(int days) {
    return '$days jours avant';
  }

  @override
  String get healthData => 'Données de Santé';

  @override
  String get connectHealthApp => 'Connecter à l\'App Santé';

  @override
  String get syncData => 'Synchroniser les Données';

  @override
  String get heartRate => 'Fréquence Cardiaque';

  @override
  String get sleepData => 'Données de Sommeil';

  @override
  String get steps => 'Pas';

  @override
  String get temperature => 'Température Corporelle';

  @override
  String get bloodPressure => 'Tension Artérielle';

  @override
  String get aiInsights => 'Analyses IA';

  @override
  String get smartPredictions => 'Prédictions Intelligentes';

  @override
  String get personalizedTips => 'Conseils Personnalisés';

  @override
  String get patternRecognition => 'Reconnaissance des Tendances';

  @override
  String get anomalyDetection => 'Détection d\'Anomalies';

  @override
  String get learningFromData => 'Apprentissage de vos données...';

  @override
  String get improvingAccuracy =>
      'Amélioration de la précision des prédictions';

  @override
  String get adaptingToPatterns => 'Adaptation à vos schémas';

  @override
  String get welcome => 'Bienvenue dans FlowSense';

  @override
  String get getStarted => 'Commencer';

  @override
  String get skipForNow => 'Passer pour Maintenant';

  @override
  String get next => 'Suivant';

  @override
  String get previous => 'Précédent';

  @override
  String get finish => 'Terminer';

  @override
  String get setupProfile => 'Configurer Votre Profil';

  @override
  String get trackingPermissions => 'Permissions de Suivi';

  @override
  String get notificationPermissions => 'Permissions de Notification';

  @override
  String get healthPermissions => 'Permissions de l\'App Santé';

  @override
  String get onboardingStep1 => 'Suivez votre cycle avec précision';

  @override
  String get onboardingStep2 => 'Obtenez des analyses alimentées par l\'IA';

  @override
  String get onboardingStep3 => 'Recevez des recommandations personnalisées';

  @override
  String get onboardingStep4 => 'Surveillez votre santé reproductive';

  @override
  String get error => 'Erreur';

  @override
  String get success => 'Succès';

  @override
  String get warning => 'Avertissement';

  @override
  String get info => 'Info';

  @override
  String get loading => 'Chargement...';

  @override
  String get noData => 'Aucune donnée disponible';

  @override
  String get noInternetConnection => 'Pas de connexion internet';

  @override
  String get tryAgain => 'Réessayer';

  @override
  String get somethingWentWrong => 'Quelque chose s\'est mal passé';

  @override
  String get dataUpdated => 'Données mises à jour avec succès';

  @override
  String get dataSaved => 'Données sauvegardées avec succès';

  @override
  String get dataDeleted => 'Données supprimées avec succès';

  @override
  String get invalidInput => 'Saisie invalide';

  @override
  String get fieldRequired => 'Ce champ est requis';

  @override
  String get selectAtLeastOne => 'Veuillez sélectionner au moins une option';

  @override
  String get days => 'jours';

  @override
  String get weeks => 'semaines';

  @override
  String get months => 'mois';

  @override
  String get years => 'années';

  @override
  String get kg => 'kg';

  @override
  String get lbs => 'lbs';

  @override
  String get cm => 'cm';

  @override
  String get inches => 'pouces';

  @override
  String get celsius => '°C';

  @override
  String get fahrenheit => '°F';

  @override
  String get morning => 'Matin';

  @override
  String get afternoon => 'Après-midi';

  @override
  String get evening => 'Soir';

  @override
  String get night => 'Nuit';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String get yesterday => 'Hier';

  @override
  String get tomorrow => 'Demain';

  @override
  String get thisWeek => 'Cette Semaine';

  @override
  String get lastWeek => 'Semaine Dernière';

  @override
  String get nextWeek => 'Semaine Prochaine';

  @override
  String get yes => 'Oui';

  @override
  String get no => 'Non';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Terminé';

  @override
  String get close => 'Fermer';

  @override
  String get open => 'Ouvrir';

  @override
  String get view => 'Voir';

  @override
  String get hide => 'Masquer';

  @override
  String get show => 'Afficher';

  @override
  String get enable => 'Activer';

  @override
  String get disable => 'Désactiver';

  @override
  String get on => 'Activé';

  @override
  String get off => 'Désactivé';

  @override
  String get high => 'Élevé';

  @override
  String get medium => 'Moyen';

  @override
  String get low => 'Faible';

  @override
  String get none => 'Aucun';

  @override
  String get all => 'Tout';

  @override
  String get search => 'Rechercher';

  @override
  String get filter => 'Filtrer';

  @override
  String get sort => 'Trier';

  @override
  String get refresh => 'Actualiser';

  @override
  String get clear => 'Effacer';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get apply => 'Appliquer';

  @override
  String get loadingAiEngine => 'Initialisation du Moteur de Santé IA...';

  @override
  String get analyzingHealthPatterns => 'Analyse de vos schémas de santé';

  @override
  String get goodMorning => 'Bonjour';

  @override
  String get goodAfternoon => 'Bon après-midi';

  @override
  String get goodEvening => 'Bonsoir';

  @override
  String get aiActive => 'IA Active';

  @override
  String get health => 'Santé';

  @override
  String get optimal => 'Optimal';

  @override
  String get cycleStatus => 'État du Cycle';

  @override
  String get notStarted => 'Pas Commencé';

  @override
  String get moodBalance => 'Équilibre de l\'Humeur';

  @override
  String get notTracked => 'Non Suivi';

  @override
  String get energyLevel => 'Niveau d\'Énergie';

  @override
  String get flowIntensityMetric => 'Intensité du Flux';

  @override
  String get logSymptoms => 'Enregistrer les Symptômes';

  @override
  String get trackYourHealth => 'Suivez votre santé';

  @override
  String get periodTracker => 'Traceur de Règles';

  @override
  String get startLogging => 'Commencer l\'enregistrement';

  @override
  String get moodAndEnergy => 'Humeur et Énergie';

  @override
  String get logWellness => 'Enregistrer le bien-être';

  @override
  String get viewAnalysis => 'Voir l\'analyse';

  @override
  String get accuracy => 'Précision';

  @override
  String get highConfidence => 'Haute confiance';

  @override
  String get gatheringDataForPredictions =>
      'Collecte de Données pour les Prédictions';

  @override
  String get startTrackingForPredictions =>
      'Commencez à suivre vos cycles pour débloquer les prédictions IA';

  @override
  String get aiLearningPatterns => 'IA Apprenant Vos Schémas';

  @override
  String get trackForInsights =>
      'Suivez vos cycles pour débloquer des analyses IA personnalisées';

  @override
  String get cycleRegularity => 'Régularité du Cycle';

  @override
  String get fromLastMonth => '+5% par rapport au mois dernier';

  @override
  String get avgCycle => 'Cycle Moyen';

  @override
  String get avgMood => 'Humeur Moyenne';

  @override
  String get daysCycle => '28,5 jours';

  @override
  String get moodRating => '4,2/5';

  @override
  String get chooseTheme => 'Choisir le Thème';

  @override
  String get lightTheme => 'Thème Clair';

  @override
  String get lightThemeDescription => 'Apparence lumineuse et nette';

  @override
  String get darkTheme => 'Thème Sombre';

  @override
  String get darkThemeDescription => 'Doux pour les yeux en faible lumière';

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
  String get foodCravings => 'Food cravings';

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
  String get systemTheme => 'Thème Système';

  @override
  String get systemThemeDescription =>
      'Correspond aux paramètres de votre appareil';

  @override
  String get themeChangedTo => 'Thème changé en';

  @override
  String get chooseLanguage => 'Choisir la Langue';

  @override
  String get searchLanguages => 'Rechercher des langues...';

  @override
  String get languageChangedTo => 'Langue changée en';

  @override
  String get appPreferences => 'Préférences de l\'App';

  @override
  String get customizeAppearance => 'Personnaliser l\'apparence de l\'app';

  @override
  String get chooseYourLanguage => 'Choisissez votre langue';

  @override
  String get receiveReminders => 'Recevoir des rappels et mises à jour';

  @override
  String get dailyReminders => 'Quand envoyer les rappels quotidiens';

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
  String get aiSmartFeatures => 'IA et Fonctionnalités Intelligentes';

  @override
  String get personalizedAiInsights => 'Obtenir des analyses IA personnalisées';

  @override
  String get hapticFeedback => 'Retour Haptique';

  @override
  String get vibrationInteractions =>
      'Sentir les vibrations lors des interactions';

  @override
  String get supportAbout => 'Support et À Propos';

  @override
  String get getHelpTutorials => 'Obtenir de l\'aide et des tutoriels';

  @override
  String get versionInfoLegal => 'Informations de version et légal';

  @override
  String get light => 'Clair';

  @override
  String get dark => 'Sombre';

  @override
  String get system => 'Système';

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
