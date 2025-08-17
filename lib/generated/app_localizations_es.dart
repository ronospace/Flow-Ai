// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'FlowSense';

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
  String get welcome => 'Bienvenida a FlowSense';

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
  String get moodAndEnergy => 'Ánimo y Energía';

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
}
