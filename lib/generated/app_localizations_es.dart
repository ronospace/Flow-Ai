// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'Flow Ai';

  @override
  String get appTagline => 'Seguimiento del Período y Ciclo con IA';

  @override
  String get appDescription =>
      'Rastrea tu ciclo menstrual con análisis de IA y recomendaciones personalizadas para una mejor salud reproductiva.';

  @override
  String get home => 'Inicio';

  @override
  String get calendar => 'Calendario';

  @override
  String get tracking => 'Seguimiento';

  @override
  String get insights => 'Análisis';

  @override
  String get settings => 'Configuración';

  @override
  String cycleDay(int day) {
    return 'Día $day';
  }

  @override
  String cycleLength(int length) {
    return 'Duración del ciclo: $length días';
  }

  @override
  String get cycleLengthLabel => 'Cycle Length';

  @override
  String daysUntilPeriod(int days) {
    return '$days días hasta el período';
  }

  @override
  String daysUntilOvulation(int days) {
    return '$days días hasta la ovulación';
  }

  @override
  String get currentPhase => 'Fase Actual';

  @override
  String get menstrualPhase => 'Menstrual';

  @override
  String get follicularPhase => 'Folicular';

  @override
  String get ovulatoryPhase => 'Ovulatoria';

  @override
  String get lutealPhase => 'Lútea';

  @override
  String get fertileWindow => 'Ventana Fértil';

  @override
  String get ovulationDay => 'Día de Ovulación';

  @override
  String get periodStarted => 'Período Iniciado';

  @override
  String get periodEnded => 'Período Finalizado';

  @override
  String get flowIntensity => 'Intensidad del Flujo';

  @override
  String get flowNone => 'Ninguno';

  @override
  String get flowSpotting => 'Manchado';

  @override
  String get flowLight => 'Ligero';

  @override
  String get flowMedium => 'Medio';

  @override
  String get flowHeavy => 'Abundante';

  @override
  String get flowVeryHeavy => 'Muy Abundante';

  @override
  String get symptoms => 'Síntomas';

  @override
  String get noSymptoms => 'Sin síntomas';

  @override
  String get cramps => 'Calambres';

  @override
  String get bloating => 'Hinchazón';

  @override
  String get headache => 'Dolor de cabeza';

  @override
  String get backPain => 'Dolor de espalda';

  @override
  String get breastTenderness => 'Sensibilidad en los senos';

  @override
  String get fatigue => 'Fatiga';

  @override
  String get moodSwings => 'Cambios de humor';

  @override
  String get acne => 'Acné';

  @override
  String get nausea => 'Náuseas';

  @override
  String get cravings => 'Antojos';

  @override
  String get insomnia => 'Insomnio';

  @override
  String get hotFlashes => 'Sofocos';

  @override
  String get coldFlashes => 'Escalofríos';

  @override
  String get diarrhea => 'Diarrea';

  @override
  String get constipation => 'Estreñimiento';

  @override
  String get mood => 'Estado de ánimo';

  @override
  String get energy => 'Energía';

  @override
  String get pain => 'Dolor';

  @override
  String get moodHappy => 'Feliz';

  @override
  String get moodNeutral => 'Neutral';

  @override
  String get moodSad => 'Triste';

  @override
  String get moodAnxious => 'Ansiosa';

  @override
  String get moodIrritated => 'Irritada';

  @override
  String get energyHigh => 'Alta Energía';

  @override
  String get energyMedium => 'Energía Media';

  @override
  String get energyLow => 'Baja Energía';

  @override
  String get painNone => 'Sin Dolor';

  @override
  String get painMild => 'Dolor Leve';

  @override
  String get painModerate => 'Dolor Moderado';

  @override
  String get painSevere => 'Dolor Intenso';

  @override
  String get predictions => 'Predicciones';

  @override
  String get nextPeriod => 'Próximo Período';

  @override
  String get nextOvulation => 'Próxima Ovulación';

  @override
  String predictedDate(String date) {
    return 'Predicción: $date';
  }

  @override
  String confidence(int percentage) {
    return 'Confianza: $percentage%';
  }

  @override
  String get aiPoweredPredictions => 'Predicciones con IA';

  @override
  String get advancedInsights => 'Análisis Avanzados';

  @override
  String get personalizedRecommendations => 'Recomendaciones Personalizadas';

  @override
  String get cycleInsights => 'Análisis del Ciclo';

  @override
  String get patternAnalysis => 'Análisis de Patrones';

  @override
  String get cycleTrends => 'Tendencias del Ciclo';

  @override
  String get symptomPatterns => 'Patrones de Síntomas';

  @override
  String get moodPatterns => 'Patrones de Estado de Ánimo';

  @override
  String get regularCycle => 'Tu ciclo es regular';

  @override
  String get irregularCycle => 'Tu ciclo muestra algunas irregularidades';

  @override
  String cycleVariation(int days) {
    return 'Variación del ciclo: ±$days días';
  }

  @override
  String averageCycleLength(int days) {
    return 'Duración promedio del ciclo: $days días';
  }

  @override
  String get lifestyle => 'Estilo de vida';

  @override
  String get nutrition => 'Nutrición';

  @override
  String get exercise => 'Ejercicio';

  @override
  String get wellness => 'Bienestar';

  @override
  String get sleepBetter => 'Mejora tu calidad de sueño';

  @override
  String get stayHydrated => 'Mantente hidratada';

  @override
  String get gentleExercise => 'Prueba ejercicios suaves como yoga';

  @override
  String get eatIronRich => 'Consume alimentos ricos en hierro';

  @override
  String get takeBreaks => 'Toma descansos regulares';

  @override
  String get manageStress => 'Practica el manejo del estrés';

  @override
  String get warmBath => 'Toma un baño caliente';

  @override
  String get meditation => 'Prueba la meditación o respiración profunda';

  @override
  String get logToday => 'Registrar Hoy';

  @override
  String get trackFlow => 'Registrar Flujo';

  @override
  String get trackSymptoms => 'Registrar Síntomas';

  @override
  String get trackMood => 'Registrar Estado de Ánimo';

  @override
  String get trackPain => 'Registrar Dolor';

  @override
  String get addNotes => 'Añadir Notas';

  @override
  String get notes => 'Notas';

  @override
  String get save => 'Guardar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Eliminar';

  @override
  String get edit => 'Editar';

  @override
  String get update => 'Actualizar';

  @override
  String get login => 'Login';

  @override
  String get signUp => 'Sign Up';

  @override
  String get confirm => 'Confirmar';

  @override
  String get thisMonth => 'Este Mes';

  @override
  String get nextMonth => 'Próximo Mes';

  @override
  String get previousMonth => 'Mes Anterior';

  @override
  String get today => 'Hoy';

  @override
  String get selectDate => 'Seleccionar Fecha';

  @override
  String get periodDays => 'Días de Período';

  @override
  String get fertileDays => 'Días Fértiles';

  @override
  String get ovulationDays => 'Días de Ovulación';

  @override
  String get symptomDays => 'Días con Síntomas';

  @override
  String get profile => 'Perfil';

  @override
  String get notifications => 'Notificaciones';

  @override
  String get privacy => 'Privacidad';

  @override
  String get language => 'Idioma';

  @override
  String get theme => 'Tema';

  @override
  String get export => 'Exportar Datos';

  @override
  String get backup => 'Copia de Seguridad';

  @override
  String get help => 'Ayuda';

  @override
  String get about => 'Acerca de';

  @override
  String get version => 'Versión';

  @override
  String get contactSupport => 'Contactar con Soporte';

  @override
  String get rateApp => 'Valorar App';

  @override
  String get shareApp => 'Compartir App';

  @override
  String get personalInfo => 'Información Personal';

  @override
  String get age => 'Edad';

  @override
  String get height => 'Altura';

  @override
  String get weight => 'Peso';

  @override
  String get cycleHistory => 'Historial de Ciclos';

  @override
  String get avgCycleLength => 'Duración Media del Ciclo';

  @override
  String get avgPeriodLength => 'Duración Media del Período';

  @override
  String get lastPeriod => 'Último Período';

  @override
  String get periodPreferences => 'Preferencias de Período';

  @override
  String get trackingGoals => 'Objetivos de Seguimiento';

  @override
  String get periodReminder => 'Recordatorio de Período';

  @override
  String get ovulationReminder => 'Recordatorio de Ovulación';

  @override
  String get pillReminder => 'Recordatorio de Píldora';

  @override
  String get symptomReminder => 'Recordatorio de Seguimiento de Síntomas';

  @override
  String get insightNotifications => 'Notificaciones de Análisis';

  @override
  String get enableNotifications => 'Activar Notificaciones';

  @override
  String get notificationTime => 'Hora de Notificación';

  @override
  String reminderDays(int days) {
    return '$days días antes';
  }

  @override
  String get healthData => 'Datos de Salud';

  @override
  String get connectHealthApp => 'Conectar con App de Salud';

  @override
  String get syncData => 'Sincronizar Datos';

  @override
  String get heartRate => 'Ritmo Cardíaco';

  @override
  String get sleepData => 'Datos de Sueño';

  @override
  String get steps => 'Pasos';

  @override
  String get temperature => 'Temperatura Corporal';

  @override
  String get bloodPressure => 'Presión Arterial';

  @override
  String get aiInsights => 'Análisis de IA';

  @override
  String get smartPredictions => 'Predicciones Inteligentes';

  @override
  String get personalizedTips => 'Consejos Personalizados';

  @override
  String get patternRecognition => 'Reconocimiento de Patrones';

  @override
  String get anomalyDetection => 'Detección de Anomalías';

  @override
  String get learningFromData => 'Aprendiendo de tus datos...';

  @override
  String get improvingAccuracy => 'Mejorando la precisión de predicción';

  @override
  String get adaptingToPatterns => 'Adaptándose a tus patrones';

  @override
  String get welcome => 'Bienvenida a Flow Ai';

  @override
  String get getStarted => 'Comenzar';

  @override
  String get skipForNow => 'Omitir por Ahora';

  @override
  String get next => 'Siguiente';

  @override
  String get previous => 'Anterior';

  @override
  String get finish => 'Finalizar';

  @override
  String get setupProfile => 'Configura tu Perfil';

  @override
  String get trackingPermissions => 'Permisos de Seguimiento';

  @override
  String get notificationPermissions => 'Permisos de Notificación';

  @override
  String get healthPermissions => 'Permisos de App de Salud';

  @override
  String get onboardingStep1 => 'Rastrea tu ciclo con precisión';

  @override
  String get onboardingStep2 => 'Obtén análisis con IA';

  @override
  String get onboardingStep3 => 'Recibe recomendaciones personalizadas';

  @override
  String get onboardingStep4 => 'Monitorea tu salud reproductiva';

  @override
  String get error => 'Error';

  @override
  String get success => 'Éxito';

  @override
  String get warning => 'Advertencia';

  @override
  String get info => 'Información';

  @override
  String get loading => 'Cargando...';

  @override
  String get noData => 'No hay datos disponibles';

  @override
  String get noInternetConnection => 'Sin conexión a internet';

  @override
  String get tryAgain => 'Intentar de Nuevo';

  @override
  String get somethingWentWrong => 'Algo salió mal';

  @override
  String get dataUpdated => 'Datos actualizados correctamente';

  @override
  String get dataSaved => 'Datos guardados correctamente';

  @override
  String get dataDeleted => 'Datos eliminados correctamente';

  @override
  String get invalidInput => 'Entrada inválida';

  @override
  String get fieldRequired => 'Este campo es obligatorio';

  @override
  String get selectAtLeastOne => 'Por favor, selecciona al menos una opción';

  @override
  String get days => 'días';

  @override
  String get weeks => 'semanas';

  @override
  String get months => 'meses';

  @override
  String get years => 'años';

  @override
  String get kg => 'kg';

  @override
  String get lbs => 'lb';

  @override
  String get cm => 'cm';

  @override
  String get inches => 'pulgadas';

  @override
  String get celsius => '°C';

  @override
  String get fahrenheit => '°F';

  @override
  String get morning => 'Mañana';

  @override
  String get afternoon => 'Tarde';

  @override
  String get evening => 'Noche';

  @override
  String get night => 'Madrugada';

  @override
  String get am => 'AM';

  @override
  String get pm => 'PM';

  @override
  String get trackingScreenTitle => 'Pantalla de Seguimiento';

  @override
  String get flowTab => 'Flujo';

  @override
  String get symptomsTab => 'Síntomas';

  @override
  String get moodTab => 'Estado de Ánimo';

  @override
  String get painTab => 'Dolor';

  @override
  String get notesTab => 'Notas';

  @override
  String get selectTodaysFlowIntensity => 'Select today\'s flow intensity';

  @override
  String get selectAllSymptoms => 'Select all symptoms you\'re experiencing';

  @override
  String get moodAndEnergy => 'Ánimo y Energía';

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
  String get yesterday => 'Ayer';

  @override
  String get tomorrow => 'Mañana';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get lastWeek => 'Semana Pasada';

  @override
  String get nextWeek => 'Próxima Semana';

  @override
  String get yes => 'Sí';

  @override
  String get no => 'No';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Hecho';

  @override
  String get close => 'Cerrar';

  @override
  String get open => 'Abrir';

  @override
  String get view => 'Ver';

  @override
  String get hide => 'Ocultar';

  @override
  String get show => 'Mostrar';

  @override
  String get enable => 'Activar';

  @override
  String get disable => 'Desactivar';

  @override
  String get on => 'Encendido';

  @override
  String get off => 'Apagado';

  @override
  String get high => 'Alto';

  @override
  String get medium => 'Medio';

  @override
  String get low => 'Bajo';

  @override
  String get none => 'Ninguno';

  @override
  String get all => 'Todo';

  @override
  String get search => 'Buscar';

  @override
  String get filter => 'Filtrar';

  @override
  String get sort => 'Ordenar';

  @override
  String get refresh => 'Actualizar';

  @override
  String get clear => 'Limpiar';

  @override
  String get reset => 'Restablecer';

  @override
  String get apply => 'Aplicar';

  @override
  String get loadingAiEngine => 'Inicializando Motor de Salud IA...';

  @override
  String get analyzingHealthPatterns => 'Analizando tus patrones de salud';

  @override
  String get goodMorning => 'Buenos días';

  @override
  String get goodAfternoon => 'Buenas tardes';

  @override
  String get goodEvening => 'Buenas noches';

  @override
  String get aiActive => 'IA Activa';

  @override
  String get health => 'Salud';

  @override
  String get optimal => 'Óptimo';

  @override
  String get cycleStatus => 'Estado del Ciclo';

  @override
  String get notStarted => 'No Iniciado';

  @override
  String get moodBalance => 'Balance de Ánimo';

  @override
  String get notTracked => 'No Registrado';

  @override
  String get energyLevel => 'Nivel de Energía';

  @override
  String get flowIntensityMetric => 'Intensidad del Flujo';

  @override
  String get logSymptoms => 'Registrar Síntomas';

  @override
  String get trackYourHealth => 'Rastrea tu salud';

  @override
  String get periodTracker => 'Rastreador de Período';

  @override
  String get startLogging => 'Comenzar registro';

  @override
  String get logWellness => 'Registrar bienestar';

  @override
  String get viewAnalysis => 'Ver análisis';

  @override
  String get accuracy => 'Precisión';

  @override
  String get highConfidence => 'Alta confianza';

  @override
  String get gatheringDataForPredictions =>
      'Recopilando Datos para Predicciones';

  @override
  String get startTrackingForPredictions =>
      'Comienza a rastrear tus ciclos para desbloquear predicciones IA';

  @override
  String get aiLearningPatterns => 'IA Aprendiendo tus Patrones';

  @override
  String get trackForInsights =>
      'Rastrea tus ciclos para desbloquear análisis IA personalizados';

  @override
  String get cycleRegularity => 'Regularidad del Ciclo';

  @override
  String get fromLastMonth => '+5% desde el mes pasado';

  @override
  String get avgCycle => 'Ciclo Promedio';

  @override
  String get avgMood => 'Ánimo Promedio';

  @override
  String get daysCycle => '28.5 días';

  @override
  String get moodRating => '4.2/5';

  @override
  String get chooseTheme => 'Elegir Tema';

  @override
  String get lightTheme => 'Tema Claro';

  @override
  String get lightThemeDescription => 'Apariencia brillante y limpia';

  @override
  String get darkTheme => 'Tema Oscuro';

  @override
  String get darkThemeDescription => 'Suave para los ojos en poca luz';

  @override
  String get biometricDashboard => 'Panel Biométrico';

  @override
  String get currentCycle => 'Ciclo Actual';

  @override
  String get noActiveCycle => 'Sin ciclo activo';

  @override
  String get startTracking => 'Comenzar seguimiento';

  @override
  String get aiPrediction => 'Predicción IA';

  @override
  String inDays(int days) {
    return 'In $days days';
  }

  @override
  String get smartActionCommandCenter =>
      'Centro de Comandos de Acción Inteligente';

  @override
  String get quickAccessToEssentialFeatures =>
      'Acceso rápido a funciones esenciales';

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
  String get systemTheme => 'Tema del Sistema';

  @override
  String get systemThemeDescription =>
      'Coincide con la configuración de tu dispositivo';

  @override
  String get themeChangedTo => 'Tema cambiado a';

  @override
  String get chooseLanguage => 'Elegir Idioma';

  @override
  String get searchLanguages => 'Buscar idiomas...';

  @override
  String get languageChangedTo => 'Idioma cambiado a';

  @override
  String get appPreferences => 'Preferencias de la App';

  @override
  String get customizeAppearance => 'Personalizar la apariencia de la app';

  @override
  String get chooseYourLanguage => 'Elige tu idioma';

  @override
  String get receiveReminders => 'Recibir recordatorios y actualizaciones';

  @override
  String get dailyReminders => 'Cuándo enviar recordatorios diarios';

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
  String get aiSmartFeatures => 'IA y Funciones Inteligentes';

  @override
  String get personalizedAiInsights => 'Obtener análisis de IA personalizados';

  @override
  String get hapticFeedback => 'Retroalimentación Háptica';

  @override
  String get vibrationInteractions => 'Sentir vibraciones en las interacciones';

  @override
  String get supportAbout => 'Soporte y Acerca de';

  @override
  String get getHelpTutorials => 'Obtener ayuda y tutoriales';

  @override
  String get versionInfoLegal => 'Información de versión y legal';

  @override
  String get light => 'Claro';

  @override
  String get dark => 'Oscuro';

  @override
  String get system => 'Sistema';

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
  String get overview => 'Resumen';

  @override
  String get metrics => 'Métricas';

  @override
  String get sync => 'Sincronizar';

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
  String get faqAndKnowledgeBase =>
      'Preguntas Frecuentes y Base de Conocimiento';

  @override
  String get findAnswersToCommonQuestions =>
      'Encuentra respuestas a preguntas comunes';

  @override
  String get searchFAQs => 'Buscar preguntas frecuentes...';

  @override
  String get allCategories => 'Todas';

  @override
  String searchResults(int count) {
    return '$count resultados de búsqueda';
  }

  @override
  String faqsInCategory(int count, String category) {
    return '$count preguntas en $category';
  }

  @override
  String totalFAQs(int count) {
    return '$count preguntas totales';
  }

  @override
  String get askZyra => 'Preguntar a Zyra';

  @override
  String get askRelatedQuestion => 'Hacer pregunta relacionada';

  @override
  String get verified => 'Verificado';

  @override
  String get askZyraAI => 'Preguntar a Zyra IA';

  @override
  String get getPersonalizedAnswers =>
      'Obtén respuestas personalizadas a tus preguntas';

  @override
  String get fullChatExperienceComingSoon =>
      '¡La experiencia de chat completa llegará pronto!';

  @override
  String get useFloatingChatInInsights =>
      'Por ahora, usa el chat flotante en la pantalla de análisis';

  @override
  String get goToAIChat => 'Ir al Chat IA';

  @override
  String get faqAndHelp => 'Preguntas y Ayuda';

  @override
  String get getAnswers => 'Obtener respuestas';

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
  String get learnYourPatterns => 'Powered by Machine Learning';

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
  String get healthDashboardMatrix => 'Health Dashboard Matrix';

  @override
  String get realTimeBiometricAnalysis => 'Real-time Biometric Analysis';

  @override
  String get predictiveAnalyticsCenter => 'Predictive Analytics Center';

  @override
  String get aiPoweredCycleForecast => 'AI-Powered Cycle Forecast';
}
