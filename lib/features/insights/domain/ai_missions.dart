enum MissionType {
  hydrate,
  rest,
  exercise,
  trackSymptoms,
  mindfulness,
}

class AiMission {
  final MissionType type;
  final String title;
  final String description;

  AiMission({
    required this.type,
    required this.title,
    required this.description,
  });
}

class AiMissionEngine {
  static List<AiMission> getMissions({
    required int cycleDay,
    required bool isOnPeriod,
  }) {
    if (isOnPeriod) {
      return [
        AiMission(
          type: MissionType.rest,
          title: "Prioritize rest",
          description: "Your body is recovering.",
        ),
        AiMission(
          type: MissionType.hydrate,
          title: "Stay hydrated",
          description: "Helps reduce cramps.",
        ),
      ];
    }

    if (cycleDay >= 12 && cycleDay <= 16) {
      return [
        AiMission(
          type: MissionType.exercise,
          title: "High energy window",
          description: "Great time to be active.",
        ),
      ];
    }

    return [
      AiMission(
        type: MissionType.mindfulness,
        title: "Check in with yourself",
        description: "Take a mindful moment.",
      ),
    ];
  }
}
