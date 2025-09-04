/// Expert Question Model - For Q&A features
class ExpertQuestion {
  final String id;
  final String title;
  final String content;
  final String category;
  final String authorId;
  final String? authorName;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int upvoteCount;
  final int answerCount;
  final int viewCount;
  final String? selectedAnswerId;
  final bool hasUpvoted;
  final String status; // pending, answered, closed
  final String? preferredExpertId;

  const ExpertQuestion({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.authorId,
    this.authorName,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
    required this.upvoteCount,
    required this.answerCount,
    required this.viewCount,
    this.selectedAnswerId,
    this.hasUpvoted = false,
    this.status = 'pending',
    this.preferredExpertId,
  });

  ExpertQuestion copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    String? authorId,
    String? authorName,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? upvoteCount,
    int? answerCount,
    int? viewCount,
    String? selectedAnswerId,
    bool? hasUpvoted,
    String? status,
    String? preferredExpertId,
  }) {
    return ExpertQuestion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      answerCount: answerCount ?? this.answerCount,
      viewCount: viewCount ?? this.viewCount,
      selectedAnswerId: selectedAnswerId ?? this.selectedAnswerId,
      hasUpvoted: hasUpvoted ?? this.hasUpvoted,
      status: status ?? this.status,
      preferredExpertId: preferredExpertId ?? this.preferredExpertId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'authorId': authorId,
      'authorName': authorName,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'upvoteCount': upvoteCount,
      'answerCount': answerCount,
      'viewCount': viewCount,
      'selectedAnswerId': selectedAnswerId,
      'hasUpvoted': hasUpvoted,
      'status': status,
      'preferredExpertId': preferredExpertId,
    };
  }

  factory ExpertQuestion.fromJson(Map<String, dynamic> json) {
    return ExpertQuestion(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String?,
      isAnonymous: json['isAnonymous'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      upvoteCount: json['upvoteCount'] as int,
      answerCount: json['answerCount'] as int,
      viewCount: json['viewCount'] as int,
      selectedAnswerId: json['selectedAnswerId'] as String?,
      hasUpvoted: json['hasUpvoted'] as bool? ?? false,
      status: json['status'] as String? ?? 'pending',
      preferredExpertId: json['preferredExpertId'] as String?,
    );
  }
}

/// Expert model
class Expert {
  final String id;
  final String name;
  final String profession;
  final String specialty;
  final String? photoUrl;
  final String bio;
  final int yearsOfExperience;
  final int answersCount;
  final int ratingsCount;
  final double rating;
  final List<String> credentials;
  final bool isVerified;
  final DateTime joinedAt;

  const Expert({
    required this.id,
    required this.name,
    required this.profession,
    required this.specialty,
    this.photoUrl,
    required this.bio,
    required this.yearsOfExperience,
    required this.answersCount,
    required this.ratingsCount,
    required this.rating,
    required this.credentials,
    required this.isVerified,
    required this.joinedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profession': profession,
      'specialty': specialty,
      'photoUrl': photoUrl,
      'bio': bio,
      'yearsOfExperience': yearsOfExperience,
      'answersCount': answersCount,
      'ratingsCount': ratingsCount,
      'rating': rating,
      'credentials': credentials,
      'isVerified': isVerified,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  factory Expert.fromJson(Map<String, dynamic> json) {
    return Expert(
      id: json['id'] as String,
      name: json['name'] as String,
      profession: json['profession'] as String,
      specialty: json['specialty'] as String,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String,
      yearsOfExperience: json['yearsOfExperience'] as int,
      answersCount: json['answersCount'] as int,
      ratingsCount: json['ratingsCount'] as int,
      rating: json['rating'] as double,
      credentials: List<String>.from(json['credentials'] as List),
      isVerified: json['isVerified'] as bool,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
    );
  }
}
