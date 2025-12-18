// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appName => 'Flow Ai';

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
  String get cycleLengthLabel => 'Cycle Length';

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
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

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
  String get welcome => 'Bienvenue dans Flow Ai';

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
  String get trackingScreenTitle => 'Écran de Suivi';

  @override
  String get flowTab => 'Flux';

  @override
  String get symptomsTab => 'Symptômes';

  @override
  String get moodTab => 'Humeur';

  @override
  String get painTab => 'Douleur';

  @override
  String get notesTab => 'Notes';

  @override
  String get selectTodaysFlowIntensity =>
      'Sélectionnez l\'intensité du flux d\'aujourd\'hui';

  @override
  String get selectAllSymptoms =>
      'Sélectionnez tous les symptômes que vous ressentez';

  @override
  String get moodAndEnergy => 'Humeur et Énergie';

  @override
  String get howAreYouFeelingToday => 'Comment vous sentez-vous aujourd\'hui ?';

  @override
  String get painLevel => 'Niveau de Douleur';

  @override
  String get rateOverallPainLevel => 'Évaluez votre niveau de douleur global';

  @override
  String get personalNotes => 'Notes Personnelles';

  @override
  String get captureThoughtsAndFeelings =>
      'Capturez vos pensées, sentiments et observations sur votre cycle';

  @override
  String get todaysJournalEntry => 'Entrée de journal d\'aujourd\'hui';

  @override
  String get quickNotes => 'Notes rapides';

  @override
  String get notesPlaceholder =>
      'Comment vous sentez-vous aujourd\'hui ? Des symptômes, changements d\'humeur ou observations que vous aimeriez retenir ?\n\nAstuce : Enregistrer vos pensées aide à identifier les tendances au fil du temps.';

  @override
  String charactersCount(int count) {
    return '$count caractères';
  }

  @override
  String get sleepQuality => 'Qualité du sommeil';

  @override
  String get foodCravings => 'Envies alimentaires';

  @override
  String get hydration => 'Hydratation';

  @override
  String get energyLevels => 'Niveaux d\'énergie';

  @override
  String get stressManagement => 'Gestion du stress';

  @override
  String get saveTrackingData => 'Sauvegarder les Données de Suivi';

  @override
  String get noChangesToSave => 'Aucun Changement à Sauvegarder';

  @override
  String trackingDataSaved(String date) {
    return 'Données de suivi sauvegardées pour $date';
  }

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
  String get biometricDashboard => 'Tableau de Bord Biométrique';

  @override
  String get currentCycle => 'Cycle Actuel';

  @override
  String get noActiveCycle => 'Aucun cycle actif';

  @override
  String get startTracking => 'Commencer le suivi';

  @override
  String get aiPrediction => 'Prédiction IA';

  @override
  String inDays(int days) {
    return 'Dans $days jours';
  }

  @override
  String get smartActionCommandCenter =>
      'Centre de Commande d\'Action Intelligente';

  @override
  String get quickAccessToEssentialFeatures =>
      'Accès rapide aux fonctionnalités essentielles';

  @override
  String get physical => 'Physique';

  @override
  String get emotional => 'Émotionnel';

  @override
  String get skinAndHair => 'Peau et Cheveux';

  @override
  String get digestive => 'Digestif';

  @override
  String get moodSwingsSymptom => 'Sautes d\'humeur';

  @override
  String get irritability => 'Irritabilité';

  @override
  String get anxiety => 'Anxiété';

  @override
  String get depression => 'Dépression';

  @override
  String get emotionalSensitivity => 'Sensibilité émotionnelle';

  @override
  String get stress => 'Stress';

  @override
  String get oilySkin => 'Peau grasse';

  @override
  String get drySkin => 'Peau sèche';

  @override
  String get hairChanges => 'Changements capillaires';

  @override
  String get lossOfAppetite => 'Perte d\'appétit';

  @override
  String selectedSymptoms(int count) {
    return 'Symptômes Sélectionnés ($count)';
  }

  @override
  String get noMenstrualFlow => 'Aucun flux menstruel';

  @override
  String get minimalDischarge => 'Décharge minimale';

  @override
  String get comfortableProtection => 'Protection confortable';

  @override
  String get lightFlow => 'Flux Léger';

  @override
  String get normalFlow => 'Flux Normal';

  @override
  String get typicalMenstruation => 'Menstruation typique';

  @override
  String get heavyFlow => 'Flux Abondant';

  @override
  String get highAbsorptionNeeded => 'Forte absorption nécessaire';

  @override
  String get veryHeavy => 'Très Abondant';

  @override
  String get medicalAttentionAdvised => 'Attention médicale conseillée';

  @override
  String get spotting => 'Spotting';

  @override
  String get flow => 'Flux';

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
  String get unlockPremiumAiInsights => 'Déverrouillez les Analyses IA Premium';

  @override
  String get watchAdToUnlockInsights =>
      'Regardez une publicité pour débloquer des analyses avancées';

  @override
  String get free => 'GRATUIT';

  @override
  String get watchAdUnlockInsights => 'Regarder Pub et Débloquer Analyses';

  @override
  String get getAdditionalPremiumInsights =>
      'Obtenez 3 analyses premium supplémentaires';

  @override
  String get unlockAdvancedHealthRecommendations =>
      'Déverrouillez des recommandations de santé avancées';

  @override
  String get premiumInsightsUnlocked => 'Analyses premium déverrouillées ! 🎉';

  @override
  String day(int day) {
    return 'Jour $day';
  }

  @override
  String confidencePercentage(int percentage) {
    return '$percentage% de confiance';
  }

  @override
  String get quickActions => 'Actions Rapides';

  @override
  String get logPeriod => 'Enregistrer les Règles';

  @override
  String get currentCycleTitle => 'Cycle Actuel';

  @override
  String get moodLabel => 'Humeur';

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
  String get flowIntensityNone => 'Aucun';

  @override
  String get flowIntensityNoneSubtitle => 'Aucun flux menstruel';

  @override
  String get flowIntensityNoneDescription =>
      'Absence complète de flux menstruel. C\'est normal avant le début de vos règles ou après leur fin.';

  @override
  String get flowIntensityNoneMedicalInfo => 'Aucune menstruation en cours';

  @override
  String get flowIntensitySpotting => 'Spotting';

  @override
  String get flowIntensitySpottingSubtitle => 'Décharge minimale';

  @override
  String get flowIntensitySpottingDescription =>
      'Très légère décharge rose ou brune. Se produit souvent au début ou à la fin de votre cycle.';

  @override
  String get flowIntensitySpottingMedicalInfo => 'Moins de 5ml par jour';

  @override
  String get flowIntensityLight => 'Flux Léger';

  @override
  String get flowIntensityLightSubtitle => 'Protection confortable';

  @override
  String get flowIntensityLightDescription =>
      'Flux menstruel léger nécessitant une protection minimale. Dure généralement 1-3 jours.';

  @override
  String get flowIntensityLightMedicalInfo => '5-40ml par jour';

  @override
  String get flowIntensityMedium => 'Flux Normal';

  @override
  String get flowIntensityMediumSubtitle => 'Menstruation typique';

  @override
  String get flowIntensityMediumDescription =>
      'Flux menstruel régulier. C\'est l\'intensité de flux la plus courante pour des cycles sains.';

  @override
  String get flowIntensityMediumMedicalInfo => '40-70ml par jour';

  @override
  String get flowIntensityHeavy => 'Flux Abondant';

  @override
  String get flowIntensityHeavySubtitle => 'Forte absorption nécessaire';

  @override
  String get flowIntensityHeavyDescription =>
      'Flux menstruel abondant nécessitant des changements fréquents. Considérez consulter un professionnel de santé.';

  @override
  String get flowIntensityHeavyMedicalInfo => '70-100ml par jour';

  @override
  String get flowIntensityVeryHeavy => 'Très Abondant';

  @override
  String get flowIntensityVeryHeavySubtitle => 'Attention médicale conseillée';

  @override
  String get flowIntensityVeryHeavyDescription =>
      'Flux très abondant qui peut interférer avec les activités quotidiennes. Fortement recommandé de consulter un professionnel de santé.';

  @override
  String get flowIntensityVeryHeavyMedicalInfo => 'Plus de 100ml par jour';

  @override
  String get aiHealthInsights => 'Analyses de Santé IA';

  @override
  String get aboutThisFlowLevel => 'À Propos de ce Niveau de Flux';

  @override
  String get recommendedProducts => 'Produits Recommandés';

  @override
  String hourlyChanges(int changes) {
    return '~$changes/heure changements';
  }

  @override
  String get monitor => 'Surveiller';

  @override
  String get spottingInsight =>
      'Le spotting est souvent normal au début/fin du cycle. Suivez les tendances pour des analyses.';

  @override
  String get lightFlowInsight =>
      'Flux léger détecté. Considérez les niveaux de stress et la nutrition pour une santé optimale.';

  @override
  String get mediumFlowInsight =>
      'Schéma de flux normal. Votre cycle semble sain et régulier.';

  @override
  String get heavyFlowInsight =>
      'Flux abondant détecté. Surveillez les symptômes et considérez les aliments riches en fer.';

  @override
  String get veryHeavyFlowInsight =>
      'Flux très abondant peut nécessiter une attention médicale. Suivez la durée attentivement.';

  @override
  String get noFlowInsight =>
      'Aucun flux détecté. Suivez d\'autres symptômes pour des analyses complètes.';

  @override
  String get pantyLiners => 'Protège-slips';

  @override
  String get periodUnderwear => 'Culotte menstruelle';

  @override
  String get lightPads => 'Serviettes légères';

  @override
  String get tamponsRegular => 'Tampons (réguliers)';

  @override
  String get menstrualCups => 'Coupes menstruelles';

  @override
  String get regularPads => 'Serviettes régulières';

  @override
  String get tamponsSuper => 'Tampons (super)';

  @override
  String get periodUnderwearHeavy => 'Culotte menstruelle (abondante)';

  @override
  String get superPads => 'Serviettes super';

  @override
  String get tamponsSuperPlus => 'Tampons (super+)';

  @override
  String get menstrualCupsLarge => 'Coupes menstruelles (grande)';

  @override
  String get ultraPads => 'Serviettes ultra';

  @override
  String get tamponsUltra => 'Tampons (ultra)';

  @override
  String get menstrualCupsXL => 'Coupes menstruelles (XL)';

  @override
  String get medicalConsultation => 'Consultation médicale';

  @override
  String get aiPoweredHealthInsights =>
      'Analyses de Santé Alimentées par l\'IA';

  @override
  String get healthDataAccessNotGranted =>
      'Accès aux données de santé non accordé. Veuillez activer dans les paramètres.';

  @override
  String get failedToInitializeBiometricDashboard =>
      'Échec de l\'initialisation du tableau de bord biométrique';

  @override
  String get failedToLoadBiometricData =>
      'Échec du chargement des données biométriques';

  @override
  String biometricDataRefreshedAt(String time) {
    return 'Données biométriques actualisées à $time';
  }

  @override
  String get failedToRefreshData => 'Échec de l\'actualisation des données';

  @override
  String get overview => 'Vue d\'ensemble';

  @override
  String get metrics => 'Métriques';

  @override
  String get sync => 'Synchroniser';

  @override
  String get healthDataConnected => 'Données de Santé Connectées';

  @override
  String get limitedHealthData => 'Données de Santé Limitées';

  @override
  String dataCompleteness(int percentage) {
    return 'Complétude des données : $percentage%';
  }

  @override
  String get connectMoreDevicesForBetterInsights =>
      'Connectez plus d\'appareils pour de meilleures analyses';

  @override
  String updatedAt(String time) {
    return 'Mis à jour $time';
  }

  @override
  String get overallHealthScore => 'Score de Santé Global';

  @override
  String get avgHeartRate => 'Fréquence Cardiaque Moy.';

  @override
  String get bodyTemp => 'Temp. Corporelle';

  @override
  String get stressLevel => 'Niveau de Stress';

  @override
  String get bpm => 'BPM';

  @override
  String get percent => '%';

  @override
  String get degreesF => '°F';

  @override
  String get outOfTen => '/10';

  @override
  String get recentTrends => 'Tendances Récentes';

  @override
  String basedOnLastDaysOfData(int days) {
    return 'Basé sur les $days derniers jours de données';
  }

  @override
  String get sleepQualityImproving => 'Qualité du sommeil';

  @override
  String get improving => 'En amélioration';

  @override
  String get stressLevels => 'Niveaux de stress';

  @override
  String get stable => 'Stable';

  @override
  String get heartRateMetric => 'Fréquence cardiaque';

  @override
  String get slightlyElevated => 'Légèrement élevée';

  @override
  String get heartRateChart => 'Fréquence Cardiaque';

  @override
  String get sleepQualityChart => 'Qualité du Sommeil';

  @override
  String get bodyTemperatureChart => 'Température Corporelle';

  @override
  String get heartRateVariabilityChart =>
      'Variabilité de la Fréquence Cardiaque';

  @override
  String get stressLevelChart => 'Niveau de Stress';

  @override
  String get aiHealthInsightsTitle => 'Analyses de Santé IA';

  @override
  String get personalizedInsightsBasedOnBiometricPatterns =>
      'Analyses personnalisées basées sur vos schémas biométriques';

  @override
  String get noInsightsAvailable => 'Aucune Analyse Disponible';

  @override
  String get keepTrackingHealthDataForAiInsights =>
      'Continuez à suivre vos données de santé pour obtenir des analyses IA personnalisées';

  @override
  String get connectedDevices => 'Appareils Connectés';

  @override
  String get iphoneHealth => 'Santé iPhone';

  @override
  String get connected => 'Connecté';

  @override
  String get appleWatch => 'Apple Watch';

  @override
  String get syncing => 'Synchronisation';

  @override
  String get garminConnect => 'Garmin Connect';

  @override
  String get notConnected => 'Non connecté';

  @override
  String get syncSettings => 'Paramètres de Synchronisation';

  @override
  String get autoSync => 'Synchronisation Auto';

  @override
  String get automaticallySyncHealthData =>
      'Synchroniser automatiquement les données de santé';

  @override
  String get backgroundSync => 'Synchronisation en Arrière-plan';

  @override
  String get syncDataInBackground => 'Synchroniser les données en arrière-plan';

  @override
  String get loadingBiometricData => 'Chargement des données biométriques...';

  @override
  String get errorLoadingData => 'Erreur de Chargement des Données';

  @override
  String get anUnexpectedErrorOccurred =>
      'Une erreur inattendue s\'est produite';

  @override
  String get retry => 'Réessayer';

  @override
  String get noHealthData => 'Aucune Donnée de Santé';

  @override
  String get connectHealthDevicesForBiometricInsights =>
      'Connectez vos appareils de santé pour voir les analyses biométriques';

  @override
  String get healthAccessRequired => 'Accès Santé Requis';

  @override
  String get pleaseGrantAccessToHealthDataForBiometricInsights =>
      'Veuillez accorder l\'accès aux données de santé pour voir les analyses biométriques';

  @override
  String get grantAccess => 'Accorder l\'Accès';

  @override
  String get excellentHealthMetrics => 'Excellentes métriques de santé';

  @override
  String get veryGoodHealthPatterns => 'Très bons schémas de santé';

  @override
  String get goodOverallHealth => 'Bonne santé globale';

  @override
  String get moderateHealthIndicators => 'Indicateurs de santé modérés';

  @override
  String get focusOnHealthImprovement =>
      'Concentrez-vous sur l\'amélioration de la santé';

  @override
  String get calendarTitle => 'Calendrier';

  @override
  String get todayButton => 'Aujourd\'hui';

  @override
  String get faqAndKnowledgeBase => 'FAQ et Base de Connaissances';

  @override
  String get findAnswersToCommonQuestions =>
      'Trouvez des réponses aux questions courantes';

  @override
  String get searchFAQs => 'Rechercher FAQ...';

  @override
  String get allCategories => 'Toutes';

  @override
  String searchResults(int count) {
    return '$count résultats de recherche';
  }

  @override
  String faqsInCategory(int count, String category) {
    return '$count FAQ dans $category';
  }

  @override
  String totalFAQs(int count) {
    return '$count FAQ au total';
  }

  @override
  String get askMira => 'Demander à Mira';

  @override
  String get askRelatedQuestion => 'Poser une question liée';

  @override
  String get verified => 'Vérifié';

  @override
  String get askMiraAI => 'Demander à Mira IA';

  @override
  String get getPersonalizedAnswers =>
      'Obtenez des réponses personnalisées à vos questions';

  @override
  String get fullChatExperienceComingSoon =>
      'L\'expérience de chat complète arrive bientôt !';

  @override
  String get useFloatingChatInInsights =>
      'Pour l\'instant, utilisez le chat flottant dans l\'écran d\'analyses';

  @override
  String get goToAIChat => 'Aller au Chat IA';

  @override
  String get faqAndHelp => 'FAQ et Aide';

  @override
  String get getAnswers => 'Obtenir des réponses';

  @override
  String get medicalDisclaimer =>
      'This information is AI-generated for awareness purposes only and not a substitute for professional medical advice. Consult a qualified healthcare provider for medical concerns.';

  @override
  String get medicalDisclaimerShort =>
      'AI-generated information. Not medical advice.';

  @override
  String get aiGeneratedContent => 'AI-Generated Content';

  @override
  String get notMedicalAdvice => 'Not Medical Advice';

  @override
  String get consultHealthcareProvider =>
      'Consult a healthcare provider for medical advice';

  @override
  String get cycleAwarenessInsights => 'Cycle Awareness & Personal Insights';

  @override
  String get learnYourPatterns =>
      'Learn your patterns. Understand your rhythm. Powered by AI.';

  @override
  String get basedOnYourLoggedData => 'Based on your logged information';

  @override
  String get personalizedEstimates => 'Personalized Estimations';

  @override
  String get cyclePatternAwareness => 'Cycle Pattern Awareness';

  @override
  String get mayHelpIncreaseAwareness =>
      'May help increase awareness of your body\'s patterns';

  @override
  String get estimatedBasedOnPatterns =>
      'Estimated based on your logged patterns';

  @override
  String get healthDashboardMatrix => 'Matrice du Tableau de Bord Santé';

  @override
  String get realTimeBiometricAnalysis => 'Analyse biométrique en temps réel';

  @override
  String get predictiveAnalyticsCenter => 'Centre d\'Analyses Prédictives';

  @override
  String get aiPoweredCycleForecast =>
      'Prévisions de cycle alimentées par l\'IA';
}
