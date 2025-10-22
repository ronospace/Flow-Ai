/// Trend direction enumeration for data analysis
enum TrendDirection {
  increasing,
  decreasing,
  stable,
  volatile,
  unknown;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case TrendDirection.increasing:
        return 'Increasing';
      case TrendDirection.decreasing:
        return 'Decreasing';
      case TrendDirection.stable:
        return 'Stable';
      case TrendDirection.volatile:
        return 'Volatile';
      case TrendDirection.unknown:
        return 'Unknown';
    }
  }

  /// Icon for UI representation
  String get icon {
    switch (this) {
      case TrendDirection.increasing:
        return '📈';
      case TrendDirection.decreasing:
        return '📉';
      case TrendDirection.stable:
        return '➡️';
      case TrendDirection.volatile:
        return '📊';
      case TrendDirection.unknown:
        return '❓';
    }
  }

  /// Color representation
  String get colorCode {
    switch (this) {
      case TrendDirection.increasing:
        return '#4CAF50'; // Green
      case TrendDirection.decreasing:
        return '#F44336'; // Red
      case TrendDirection.stable:
        return '#2196F3'; // Blue
      case TrendDirection.volatile:
        return '#FF9800'; // Orange
      case TrendDirection.unknown:
        return '#9E9E9E'; // Grey
    }
  }
}

/// Mood category enumeration for emotional analysis
enum MoodCategory {
  happy,
  sad,
  anxious,
  calm,
  energetic,
  tired,
  irritable,
  content,
  stressed,
  excited,
  frustrated,
  peaceful,
  overwhelmed,
  confident,
  moody,
  neutral;

  /// Display name for UI
  String get displayName {
    switch (this) {
      case MoodCategory.happy:
        return 'Happy';
      case MoodCategory.sad:
        return 'Sad';
      case MoodCategory.anxious:
        return 'Anxious';
      case MoodCategory.calm:
        return 'Calm';
      case MoodCategory.energetic:
        return 'Energetic';
      case MoodCategory.tired:
        return 'Tired';
      case MoodCategory.irritable:
        return 'Irritable';
      case MoodCategory.content:
        return 'Content';
      case MoodCategory.stressed:
        return 'Stressed';
      case MoodCategory.excited:
        return 'Excited';
      case MoodCategory.frustrated:
        return 'Frustrated';
      case MoodCategory.peaceful:
        return 'Peaceful';
      case MoodCategory.overwhelmed:
        return 'Overwhelmed';
      case MoodCategory.confident:
        return 'Confident';
      case MoodCategory.moody:
        return 'Moody';
      case MoodCategory.neutral:
        return 'Neutral';
    }
  }

  /// Emoji representation
  String get emoji {
    switch (this) {
      case MoodCategory.happy:
        return '😊';
      case MoodCategory.sad:
        return '😢';
      case MoodCategory.anxious:
        return '😰';
      case MoodCategory.calm:
        return '😌';
      case MoodCategory.energetic:
        return '⚡';
      case MoodCategory.tired:
        return '😴';
      case MoodCategory.irritable:
        return '😤';
      case MoodCategory.content:
        return '😊';
      case MoodCategory.stressed:
        return '😣';
      case MoodCategory.excited:
        return '🤗';
      case MoodCategory.frustrated:
        return '😠';
      case MoodCategory.peaceful:
        return '🕊️';
      case MoodCategory.overwhelmed:
        return '😵';
      case MoodCategory.confident:
        return '💪';
      case MoodCategory.moody:
        return '🙄';
      case MoodCategory.neutral:
        return '😐';
    }
  }

  /// Intensity level (1-5 scale)
  int get intensity {
    switch (this) {
      case MoodCategory.happy:
        return 4;
      case MoodCategory.sad:
        return 2;
      case MoodCategory.anxious:
        return 2;
      case MoodCategory.calm:
        return 4;
      case MoodCategory.energetic:
        return 5;
      case MoodCategory.tired:
        return 2;
      case MoodCategory.irritable:
        return 2;
      case MoodCategory.content:
        return 4;
      case MoodCategory.stressed:
        return 1;
      case MoodCategory.excited:
        return 5;
      case MoodCategory.frustrated:
        return 2;
      case MoodCategory.peaceful:
        return 5;
      case MoodCategory.overwhelmed:
        return 1;
      case MoodCategory.confident:
        return 5;
      case MoodCategory.moody:
        return 2;
      case MoodCategory.neutral:
        return 3;
    }
  }
}
