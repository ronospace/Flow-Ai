/// Discussion model for community discussions
class Discussion {
  final String id;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final String authorId;
  final String? authorName;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int likeCount;
  final int replyCount;
  final int participantCount;
  final int viewCount;
  final bool hasLiked;
  final bool hasJoined;
  final bool isBookmarked;
  final bool isFeatured;
  final bool isLocked;
  final String status; // active, locked, archived

  const Discussion({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    required this.tags,
    required this.authorId,
    this.authorName,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
    required this.likeCount,
    required this.replyCount,
    required this.participantCount,
    required this.viewCount,
    this.hasLiked = false,
    this.hasJoined = false,
    this.isBookmarked = false,
    this.isFeatured = false,
    this.isLocked = false,
    this.status = 'active',
  });

  Discussion copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    String? authorId,
    String? authorName,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? replyCount,
    int? participantCount,
    int? viewCount,
    bool? hasLiked,
    bool? hasJoined,
    bool? isBookmarked,
    bool? isFeatured,
    bool? isLocked,
    String? status,
  }) {
    return Discussion(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      replyCount: replyCount ?? this.replyCount,
      participantCount: participantCount ?? this.participantCount,
      viewCount: viewCount ?? this.viewCount,
      hasLiked: hasLiked ?? this.hasLiked,
      hasJoined: hasJoined ?? this.hasJoined,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isFeatured: isFeatured ?? this.isFeatured,
      isLocked: isLocked ?? this.isLocked,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'tags': tags,
      'authorId': authorId,
      'authorName': authorName,
      'isAnonymous': isAnonymous,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'likeCount': likeCount,
      'replyCount': replyCount,
      'participantCount': participantCount,
      'viewCount': viewCount,
      'hasLiked': hasLiked,
      'hasJoined': hasJoined,
      'isBookmarked': isBookmarked,
      'isFeatured': isFeatured,
      'isLocked': isLocked,
      'status': status,
    };
  }

  factory Discussion.fromJson(Map<String, dynamic> json) {
    return Discussion(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      category: json['category'] as String,
      tags: List<String>.from(json['tags'] as List),
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String?,
      isAnonymous: json['isAnonymous'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      likeCount: json['likeCount'] as int,
      replyCount: json['replyCount'] as int,
      participantCount: json['participantCount'] as int,
      viewCount: json['viewCount'] as int,
      hasLiked: json['hasLiked'] as bool? ?? false,
      hasJoined: json['hasJoined'] as bool? ?? false,
      isBookmarked: json['isBookmarked'] as bool? ?? false,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isLocked: json['isLocked'] as bool? ?? false,
      status: json['status'] as String? ?? 'active',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Discussion && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Discussion(id: $id, title: $title, category: $category)';
  }
}
