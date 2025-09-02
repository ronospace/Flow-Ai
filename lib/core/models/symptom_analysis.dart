/// Symptom analysis models for multimodal analysis
abstract class SymptomAnalysis {
  final String userId;
  final DateTime timestamp;
  final double confidenceScore;

  SymptomAnalysis({
    required this.userId,
    required this.timestamp,
    required this.confidenceScore,
  });
}

class TextSymptomAnalysisResult extends SymptomAnalysis {
  final String inputText;
  final List<DetectedSymptom> detectedSymptoms;
  final MoodAnalysis moodAnalysis;
  final EnergyLevelAnalysis energyAnalysis;

  TextSymptomAnalysisResult({
    required super.userId,
    required super.timestamp,
    required super.confidenceScore,
    required this.inputText,
    required this.detectedSymptoms,
    required this.moodAnalysis,
    required this.energyAnalysis,
  });
}

class VoiceSymptomAnalysisResult extends SymptomAnalysis {
  final String audioFilePath;
  final String transcription;
  final TextSymptomAnalysisResult textAnalysis;
  final VoiceEmotionAnalysis emotionAnalysis;
  final double voiceStressLevel;

  VoiceSymptomAnalysisResult({
    required super.userId,
    required super.timestamp,
    required super.confidenceScore,
    required this.audioFilePath,
    required this.transcription,
    required this.textAnalysis,
    required this.emotionAnalysis,
    required this.voiceStressLevel,
  });
}

class ImageSymptomAnalysisResult extends SymptomAnalysis {
  final String imageFilePath;
  final ImageAnalysisType analysisType;
  final SkinConditionAnalysis? skinAnalysis;
  final FacialMoodAnalysis? moodAnalysis;

  ImageSymptomAnalysisResult({
    required super.userId,
    required super.timestamp,
    required super.confidenceScore,
    required this.imageFilePath,
    required this.analysisType,
    this.skinAnalysis,
    this.moodAnalysis,
  });
}

enum ImageAnalysisType { skin, mood, general }

class DetectedSymptom {
  final String symptomName;
  final String category;
  final double intensity; // 1-10 scale
  final double confidence;
  final String context;

  DetectedSymptom({
    required this.symptomName,
    required this.category,
    required this.intensity,
    required this.confidence,
    required this.context,
  });
}

class MoodAnalysis {
  final String dominantMood;
  final Map<String, double> moodScores;
  final double overallPositivity;
  final double confidence;

  MoodAnalysis({
    required this.dominantMood,
    required this.moodScores,
    required this.overallPositivity,
    required this.confidence,
  });
}

class EnergyLevelAnalysis {
  final double energyLevel; // 1-10 scale
  final String energyDescription;
  final double confidence;

  EnergyLevelAnalysis({
    required this.energyLevel,
    required this.energyDescription,
    required this.confidence,
  });
}

class VoiceEmotionAnalysis {
  final Map<String, double> emotionScores;
  final double voiceStrain;
  final double breathingPattern;
  final double confidence;

  VoiceEmotionAnalysis({
    required this.emotionScores,
    required this.voiceStrain,
    required this.breathingPattern,
    required this.confidence,
  });
}

class SkinConditionAnalysis {
  final double acneSeverity; // 0-1 scale
  final double inflammation; // 0-1 scale
  final String skinTone;
  final Map<String, double> skinMetrics;
  final double confidence;

  SkinConditionAnalysis({
    required this.acneSeverity,
    required this.inflammation,
    required this.skinTone,
    required this.skinMetrics,
    required this.confidence,
  });
}

class FacialMoodAnalysis {
  final String detectedMood;
  final Map<String, double> emotionScores;
  final double stressLevel;
  final double confidence;

  FacialMoodAnalysis({
    required this.detectedMood,
    required this.emotionScores,
    required this.stressLevel,
    required this.confidence,
  });
}
