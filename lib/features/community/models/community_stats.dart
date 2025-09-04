/// Community statistics model
class CommunityStats {
  final int totalMembers;
  final int totalDiscussions;
  final int totalAnswers;
  final int activeBuddyPairs;
  final int expertQuestions;
  final double engagementRate;

  const CommunityStats({
    required this.totalMembers,
    required this.totalDiscussions,
    required this.totalAnswers,
    required this.activeBuddyPairs,
    required this.expertQuestions,
    required this.engagementRate,
  });

  void incrementDiscussions() {
    // This would be handled by the backend in a real implementation
  }

  CommunityStats copyWith({
    int? totalMembers,
    int? totalDiscussions,
    int? totalAnswers,
    int? activeBuddyPairs,
    int? expertQuestions,
    double? engagementRate,
  }) {
    return CommunityStats(
      totalMembers: totalMembers ?? this.totalMembers,
      totalDiscussions: totalDiscussions ?? this.totalDiscussions,
      totalAnswers: totalAnswers ?? this.totalAnswers,
      activeBuddyPairs: activeBuddyPairs ?? this.activeBuddyPairs,
      expertQuestions: expertQuestions ?? this.expertQuestions,
      engagementRate: engagementRate ?? this.engagementRate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMembers': totalMembers,
      'totalDiscussions': totalDiscussions,
      'totalAnswers': totalAnswers,
      'activeBuddyPairs': activeBuddyPairs,
      'expertQuestions': expertQuestions,
      'engagementRate': engagementRate,
    };
  }

  factory CommunityStats.fromJson(Map<String, dynamic> json) {
    return CommunityStats(
      totalMembers: json['totalMembers'] as int,
      totalDiscussions: json['totalDiscussions'] as int,
      totalAnswers: json['totalAnswers'] as int,
      activeBuddyPairs: json['activeBuddyPairs'] as int,
      expertQuestions: json['expertQuestions'] as int,
      engagementRate: json['engagementRate'] as double,
    );
  }
}
