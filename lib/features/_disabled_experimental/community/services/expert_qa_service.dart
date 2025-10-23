import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/expert_profile.dart';
import '../models/question.dart';
import '../models/answer.dart';
import '../models/expert_verification.dart';
import '../models/knowledge_base_article.dart';

/// Community Expert Q&A Service
/// Provides expert verification, professional Q&A, and knowledge base features
class ExpertQAService {
  static final ExpertQAService _instance = ExpertQAService._internal();
  factory ExpertQAService() => _instance;
  ExpertQAService._internal();

  bool _isInitialized = false;
  final List<ExpertProfile> _verifiedExperts = [];
  final List<Question> _questions = [];
  final List<Answer> _answers = [];
  final List<KnowledgeBaseArticle> _knowledgeBase = [];
  final Map<String, List<String>> _expertSpecialties = {};

  /// Initialize the expert Q&A service
  Future<void> initialize() async {
    try {
      debugPrint('👩‍⚕️ Initializing Expert Q&A Service...');
      
      // Load verified experts and knowledge base
      await _loadVerifiedExperts();
      await _loadKnowledgeBase();
      await _loadQuestions();
      
      _isInitialized = true;
      debugPrint('✅ Expert Q&A Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Expert Q&A Service: $e');
      rethrow;
    }
  }

  // === EXPERT VERIFICATION SYSTEM ===

  /// Submit expert application for verification
  Future<ExpertVerification> submitExpertApplication({
    required String userId,
    required String fullName,
    required String email,
    required String specialty,
    required String licenseNumber,
    required String institution,
    required List<String> credentials,
    required String bio,
    required List<ExpertVerificationDocument> documents,
    String? linkedInProfile,
    String? websiteUrl,
  }) async {
    debugPrint('📝 Submitting expert application for verification...');
    
    final application = ExpertVerification(
      verificationId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      applicantInfo: ExpertApplicantInfo(
        fullName: fullName,
        email: email,
        specialty: specialty,
        licenseNumber: licenseNumber,
        institution: institution,
        credentials: credentials,
        bio: bio,
        linkedInProfile: linkedInProfile,
        websiteUrl: websiteUrl,
      ),
      documents: documents,
      status: VerificationStatus.pending,
      submittedDate: DateTime.now(),
    );

    // Store application for review
    await _storeVerificationApplication(application);
    
    // Notify moderation team
    await _notifyModerationTeam(application);
    
    debugPrint('✅ Expert application submitted: ${application.verificationId}');
    return application;
  }

  /// Get verification status for user
  Future<ExpertVerification?> getVerificationStatus(String userId) async {
    debugPrint('🔍 Checking verification status for user: $userId');
    
    // Simulate database lookup
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Return mock verification status
    return ExpertVerification(
      verificationId: 'verification_123',
      userId: userId,
      applicantInfo: ExpertApplicantInfo(
        fullName: 'Dr. Sarah Johnson',
        email: 'sarah.johnson@example.com',
        specialty: 'Obstetrics & Gynecology',
        licenseNumber: 'MD123456',
        institution: 'Women\'s Health Center',
        credentials: ['MD', 'Board Certified OB/GYN'],
        bio: 'Specializing in women\'s reproductive health with over 15 years of experience.',
      ),
      documents: [],
      status: VerificationStatus.approved,
      submittedDate: DateTime.now().subtract(const Duration(days: 7)),
      reviewedDate: DateTime.now().subtract(const Duration(days: 2)),
      reviewedBy: 'moderation_team',
    );
  }

  /// Get all verified experts
  List<ExpertProfile> getVerifiedExperts({
    String? specialty,
    int? limit,
  }) {
    var experts = List<ExpertProfile>.from(_verifiedExperts);
    
    // Filter by specialty
    if (specialty != null) {
      experts = experts.where((expert) => 
          expert.specialties.any((s) => s.toLowerCase().contains(specialty.toLowerCase()))
      ).toList();
    }
    
    // Sort by rating and response rate
    experts.sort((a, b) {
      final scoreA = a.rating * a.responseRate;
      final scoreB = b.rating * b.responseRate;
      return scoreB.compareTo(scoreA);
    });
    
    // Apply limit
    if (limit != null && experts.length > limit) {
      experts = experts.take(limit).toList();
    }
    
    return experts;
  }

  /// Search experts by query
  Future<List<ExpertProfile>> searchExperts(String query) async {
    debugPrint('🔍 Searching experts with query: $query');
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    final queryLower = query.toLowerCase();
    return _verifiedExperts.where((expert) {
      return expert.fullName.toLowerCase().contains(queryLower) ||
             expert.specialties.any((s) => s.toLowerCase().contains(queryLower)) ||
             expert.bio.toLowerCase().contains(queryLower);
    }).toList();
  }

  // === QUESTION & ANSWER SYSTEM ===

  /// Submit a question to experts
  Future<Question> submitQuestion({
    required String userId,
    required String title,
    required String content,
    required QuestionCategory category,
    List<String>? tags,
    String? preferredExpertId,
    bool isAnonymous = false,
    bool isUrgent = false,
  }) async {
    debugPrint('❓ Submitting new question...');
    
    final question = Question(
      questionId: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: userId,
      title: title,
      content: content,
      category: category,
      tags: tags ?? [],
      preferredExpertId: preferredExpertId,
      isAnonymous: isAnonymous,
      isUrgent: isUrgent,
      status: QuestionStatus.open,
      submittedDate: DateTime.now(),
      viewCount: 0,
      upvotes: 0,
      downvotes: 0,
    );

    _questions.add(question);
    
    // Notify relevant experts
    await _notifyRelevantExperts(question);
    
    // Update knowledge base suggestions
    await _updateKnowledgeBaseSuggestions(question);
    
    debugPrint('✅ Question submitted: ${question.questionId}');
    return question;
  }

  /// Get questions for browsing
  List<Question> getQuestions({
    QuestionCategory? category,
    QuestionStatus? status,
    String? expertId,
    int page = 0,
    int limit = 20,
  }) {
    var questions = List<Question>.from(_questions);
    
    // Apply filters
    if (category != null) {
      questions = questions.where((q) => q.category == category).toList();
    }
    
    if (status != null) {
      questions = questions.where((q) => q.status == status).toList();
    }
    
    if (expertId != null) {
      questions = questions.where((q) => 
          q.preferredExpertId == expertId ||
          q.answers.any((a) => a.expertId == expertId)
      ).toList();
    }
    
    // Sort by urgency, then by recency
    questions.sort((a, b) {
      if (a.isUrgent && !b.isUrgent) return -1;
      if (!a.isUrgent && b.isUrgent) return 1;
      return b.submittedDate.compareTo(a.submittedDate);
    });
    
    // Apply pagination
    final startIndex = page * limit;
    if (startIndex >= questions.length) return [];
    
    final endIndex = (startIndex + limit).clamp(0, questions.length);
    return questions.sublist(startIndex, endIndex);
  }

  /// Submit an answer to a question
  Future<Answer> submitAnswer({
    required String questionId,
    required String expertId,
    required String content,
    List<String>? references,
    List<String>? attachments,
  }) async {
    debugPrint('💬 Submitting answer to question: $questionId');
    
    final answer = Answer(
      answerId: DateTime.now().millisecondsSinceEpoch.toString(),
      questionId: questionId,
      expertId: expertId,
      content: content,
      references: references ?? [],
      attachments: attachments ?? [],
      submittedDate: DateTime.now(),
      upvotes: 0,
      downvotes: 0,
      isVerifiedAnswer: true, // Since it's from a verified expert
    );

    _answers.add(answer);
    
    // Update question status
    final question = _questions.firstWhere((q) => q.questionId == questionId);
    question.answers.add(answer);
    
    if (question.status == QuestionStatus.open) {
      question.status = QuestionStatus.answered;
    }
    
    // Notify question author
    await _notifyQuestionAuthor(question, answer);
    
    // Update expert stats
    await _updateExpertStats(expertId, answer);
    
    debugPrint('✅ Answer submitted: ${answer.answerId}');
    return answer;
  }

  /// Vote on a question or answer
  Future<void> vote({
    required String userId,
    required String targetId,
    required VoteType voteType,
    required bool isUpvote,
  }) async {
    debugPrint('👍 Processing vote: $targetId - ${isUpvote ? 'upvote' : 'downvote'}');
    
    switch (voteType) {
      case VoteType.question:
        final question = _questions.firstWhere((q) => q.questionId == targetId);
        if (isUpvote) {
          question.upvotes++;
        } else {
          question.downvotes++;
        }
        break;
      
      case VoteType.answer:
        final answer = _answers.firstWhere((a) => a.answerId == targetId);
        if (isUpvote) {
          answer.upvotes++;
        } else {
          answer.downvotes++;
        }
        
        // Update expert reputation based on answer votes
        await _updateExpertReputation(answer.expertId, isUpvote);
        break;
    }
    
    // Store vote to prevent duplicate voting
    await _storeUserVote(userId, targetId, voteType, isUpvote);
  }

  /// Mark answer as helpful/accepted
  Future<void> markAnswerAsAccepted(String questionId, String answerId) async {
    debugPrint('✅ Marking answer as accepted: $answerId');
    
    final question = _questions.firstWhere((q) => q.questionId == questionId);
    final answer = _answers.firstWhere((a) => a.answerId == answerId);
    
    // Mark question as resolved
    question.status = QuestionStatus.resolved;
    question.acceptedAnswerId = answerId;
    
    // Mark answer as accepted
    answer.isAccepted = true;
    
    // Update expert stats for accepted answer
    await _updateExpertStats(answer.expertId, answer, isAccepted: true);
  }

  // === KNOWLEDGE BASE SYSTEM ===

  /// Get knowledge base articles
  List<KnowledgeBaseArticle> getKnowledgeBaseArticles({
    String? category,
    String? query,
    int limit = 50,
  }) {
    var articles = List<KnowledgeBaseArticle>.from(_knowledgeBase);
    
    // Filter by category
    if (category != null) {
      articles = articles.where((a) => 
          a.category.toLowerCase() == category.toLowerCase()
      ).toList();
    }
    
    // Filter by search query
    if (query != null && query.isNotEmpty) {
      final queryLower = query.toLowerCase();
      articles = articles.where((a) =>
          a.title.toLowerCase().contains(queryLower) ||
          a.content.toLowerCase().contains(queryLower) ||
          a.tags.any((tag) => tag.toLowerCase().contains(queryLower))
      ).toList();
    }
    
    // Sort by relevance and views
    articles.sort((a, b) {
      final scoreA = a.views * (a.rating ?? 0);
      final scoreB = b.views * (b.rating ?? 0);
      return scoreB.compareTo(scoreA);
    });
    
    return articles.take(limit).toList();
  }

  /// Create knowledge base article from expert answer
  Future<KnowledgeBaseArticle> createKnowledgeBaseArticle({
    required String expertId,
    required String title,
    required String content,
    required String category,
    required List<String> tags,
    String? sourceQuestionId,
    String? sourceAnswerId,
  }) async {
    debugPrint('📚 Creating knowledge base article...');
    
    final article = KnowledgeBaseArticle(
      articleId: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      category: category,
      tags: tags,
      authorId: expertId,
      createdDate: DateTime.now(),
      lastUpdated: DateTime.now(),
      views: 0,
      sourceQuestionId: sourceQuestionId,
      sourceAnswerId: sourceAnswerId,
      isPublished: true,
    );
    
    _knowledgeBase.add(article);
    
    debugPrint('✅ Knowledge base article created: ${article.articleId}');
    return article;
  }

  /// Get suggested articles based on question content
  Future<List<KnowledgeBaseArticle>> getSuggestedArticles(String questionContent) async {
    debugPrint('🔍 Getting suggested articles for question content');
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Simple keyword matching (in a real app, this would use NLP/ML)
    final keywords = questionContent.toLowerCase().split(' ');
    final suggestions = <KnowledgeBaseArticle>[];
    
    for (final article in _knowledgeBase) {
      var relevanceScore = 0;
      
      for (final keyword in keywords) {
        if (keyword.length < 3) continue; // Skip short words
        
        if (article.title.toLowerCase().contains(keyword)) {
          relevanceScore += 3;
        }
        if (article.content.toLowerCase().contains(keyword)) {
          relevanceScore += 1;
        }
        if (article.tags.any((tag) => tag.toLowerCase().contains(keyword))) {
          relevanceScore += 2;
        }
      }
      
      if (relevanceScore > 3) {
        suggestions.add(article);
      }
    }
    
    // Sort by relevance and return top 5
    suggestions.sort((a, b) => b.views.compareTo(a.views));
    return suggestions.take(5).toList();
  }

  // === MODERATION SYSTEM ===

  /// Report inappropriate content
  Future<void> reportContent({
    required String reporterId,
    required String contentId,
    required ContentType contentType,
    required ReportReason reason,
    String? additionalDetails,
  }) async {
    debugPrint('⚠️ Content reported: $contentId');
    
    final report = ContentReport(
      reportId: DateTime.now().millisecondsSinceEpoch.toString(),
      reporterId: reporterId,
      contentId: contentId,
      contentType: contentType,
      reason: reason,
      additionalDetails: additionalDetails,
      reportDate: DateTime.now(),
      status: ReportStatus.pending,
    );
    
    // Store report and notify moderation team
    await _storeContentReport(report);
    await _notifyModerationTeam(report);
    
    // Auto-hide content if multiple reports for serious violations
    await _checkAutoModeration(contentId, contentType, reason);
  }

  /// Get community guidelines
  CommunityGuidelines getCommunityGuidelines() {
    return CommunityGuidelines(
      lastUpdated: DateTime(2024, 1, 1),
      sections: [
        GuidelineSection(
          title: 'Professional Conduct',
          content: 'All experts must maintain professional standards in their interactions. Provide evidence-based information and acknowledge limitations of online advice.',
          examples: [
            'Do: Provide sources for medical claims',
            'Don\'t: Give specific medical diagnoses without examination',
          ],
        ),
        GuidelineSection(
          title: 'Question Quality',
          content: 'Questions should be clear, specific, and relevant to menstrual health. Include relevant context and symptoms.',
          examples: [
            'Do: Describe symptoms with timeline and severity',
            'Don\'t: Ask vague questions without context',
          ],
        ),
        GuidelineSection(
          title: 'Privacy and Safety',
          content: 'Protect personal information and maintain confidentiality. Never share identifying medical information.',
          examples: [
            'Do: Use anonymous examples when relevant',
            'Don\'t: Share personal medical records or identifying information',
          ],
        ),
      ],
    );
  }

  // === STATISTICS AND ANALYTICS ===

  /// Get community statistics
  Future<CommunityStats> getCommunityStats() async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final now = DateTime.now();
    final thisMonth = DateTime(now.year, now.month);
    final lastMonth = DateTime(now.year, now.month - 1);
    
    return CommunityStats(
      totalExperts: _verifiedExperts.length,
      totalQuestions: _questions.length,
      totalAnswers: _answers.length,
      totalKnowledgeBaseArticles: _knowledgeBase.length,
      questionsThisMonth: _questions.where((q) => q.submittedDate.isAfter(thisMonth)).length,
      questionsLastMonth: _questions.where((q) => 
          q.submittedDate.isAfter(lastMonth) && q.submittedDate.isBefore(thisMonth)).length,
      averageResponseTime: const Duration(hours: 4, minutes: 30),
      expertResponseRate: 0.87,
      userSatisfactionRate: 0.92,
      topCategories: [
        CategoryStat(category: 'Cycle Irregularities', count: 45),
        CategoryStat(category: 'PCOS/Hormonal Issues', count: 32),
        CategoryStat(category: 'Fertility', count: 28),
        CategoryStat(category: 'General Health', count: 21),
      ],
    );
  }

  /// Get expert leaderboard
  List<ExpertProfile> getExpertLeaderboard({int limit = 10}) {
    final experts = List<ExpertProfile>.from(_verifiedExperts);
    
    // Sort by composite score of rating, response rate, and total answers
    experts.sort((a, b) {
      final scoreA = a.rating * a.responseRate * a.totalAnswers;
      final scoreB = b.rating * b.responseRate * b.totalAnswers;
      return scoreB.compareTo(scoreA);
    });
    
    return experts.take(limit).toList();
  }

  // === PRIVATE HELPER METHODS ===

  Future<void> _loadVerifiedExperts() async {
    // Load sample verified experts
    _verifiedExperts.addAll([
      ExpertProfile(
        expertId: 'expert_1',
        userId: 'user_expert_1',
        fullName: 'Dr. Sarah Johnson',
        title: 'OB/GYN',
        specialties: ['Obstetrics & Gynecology', 'Reproductive Endocrinology'],
        credentials: ['MD', 'Board Certified OB/GYN'],
        institution: 'Women\'s Health Center',
        licenseNumber: 'MD123456',
        bio: 'Specializing in women\'s reproductive health with over 15 years of experience.',
        profileImageUrl: 'https://example.com/doctor1.jpg',
        rating: 4.9,
        totalAnswers: 127,
        acceptedAnswers: 98,
        responseRate: 0.95,
        averageResponseTime: const Duration(hours: 2, minutes: 15),
        joinedDate: DateTime(2023, 6, 1),
        isAvailable: true,
        languages: ['English', 'Spanish'],
      ),
      ExpertProfile(
        expertId: 'expert_2',
        userId: 'user_expert_2',
        fullName: 'Dr. Michael Chen',
        title: 'Endocrinologist',
        specialties: ['Endocrinology', 'PCOS Treatment', 'Hormone Disorders'],
        credentials: ['MD', 'PhD', 'Board Certified Endocrinologist'],
        institution: 'Metro Medical Center',
        licenseNumber: 'MD789012',
        bio: 'Expert in hormonal disorders affecting women\'s reproductive health.',
        profileImageUrl: 'https://example.com/doctor2.jpg',
        rating: 4.8,
        totalAnswers: 89,
        acceptedAnswers: 72,
        responseRate: 0.92,
        averageResponseTime: const Duration(hours: 3, minutes: 45),
        joinedDate: DateTime(2023, 8, 15),
        isAvailable: true,
        languages: ['English', 'Mandarin'],
      ),
    ]);
  }

  Future<void> _loadKnowledgeBase() async {
    // Load sample knowledge base articles
    _knowledgeBase.addAll([
      KnowledgeBaseArticle(
        articleId: 'kb_1',
        title: 'Understanding Irregular Menstrual Cycles',
        content: 'Irregular menstrual cycles can be caused by various factors including stress, weight changes, hormonal imbalances, and underlying medical conditions...',
        category: 'Cycle Health',
        tags: ['irregular cycles', 'hormones', 'PCOS', 'stress'],
        authorId: 'expert_1',
        createdDate: DateTime(2024, 1, 15),
        lastUpdated: DateTime(2024, 1, 15),
        views: 1247,
        rating: 4.7,
        isPublished: true,
      ),
      KnowledgeBaseArticle(
        articleId: 'kb_2',
        title: 'PCOS: Symptoms, Diagnosis, and Management',
        content: 'Polycystic Ovary Syndrome (PCOS) is a common hormonal disorder affecting women of reproductive age...',
        category: 'Medical Conditions',
        tags: ['PCOS', 'hormones', 'insulin resistance', 'fertility'],
        authorId: 'expert_2',
        createdDate: DateTime(2024, 2, 1),
        lastUpdated: DateTime(2024, 2, 1),
        views: 892,
        rating: 4.8,
        isPublished: true,
      ),
    ]);
  }

  Future<void> _loadQuestions() async {
    // Load sample questions
    _questions.addAll([
      Question(
        questionId: 'q1',
        userId: 'user_1',
        title: 'Irregular cycles after stopping birth control',
        content: 'I stopped taking birth control 3 months ago and my cycles have been irregular. Is this normal?',
        category: QuestionCategory.cycleHealth,
        tags: ['birth control', 'irregular cycles'],
        isAnonymous: false,
        isUrgent: false,
        status: QuestionStatus.answered,
        submittedDate: DateTime.now().subtract(const Duration(days: 2)),
        viewCount: 23,
        upvotes: 5,
        downvotes: 0,
        answers: [],
      ),
    ]);
  }

  Future<void> _storeVerificationApplication(ExpertVerification application) async {
    // Store in database
  }

  Future<void> _notifyModerationTeam(dynamic content) async {
    // Send notification to moderation team
  }

  Future<void> _notifyRelevantExperts(Question question) async {
    // Notify experts based on specialties matching question category
  }

  Future<void> _updateKnowledgeBaseSuggestions(Question question) async {
    // Update ML suggestions based on question content
  }

  Future<void> _notifyQuestionAuthor(Question question, Answer answer) async {
    // Send notification to question author
  }

  Future<void> _updateExpertStats(String expertId, Answer answer, {bool isAccepted = false}) async {
    // Update expert statistics and reputation
  }

  Future<void> _updateExpertReputation(String expertId, bool isPositive) async {
    // Update expert reputation based on votes
  }

  Future<void> _storeUserVote(String userId, String targetId, VoteType voteType, bool isUpvote) async {
    // Store vote to prevent duplicate voting
  }

  Future<void> _storeContentReport(ContentReport report) async {
    // Store content report for moderation review
  }

  Future<void> _checkAutoModeration(String contentId, ContentType contentType, ReportReason reason) async {
    // Check if content should be auto-hidden based on reports
  }
}

// Enums and additional classes for the expert Q&A system
enum VoteType { question, answer }
enum ContentType { question, answer, article }
enum ReportReason { inappropriate, spam, misinformation, harassment, other }
enum ReportStatus { pending, reviewed, resolved, dismissed }

class ContentReport {
  final String reportId;
  final String reporterId;
  final String contentId;
  final ContentType contentType;
  final ReportReason reason;
  final String? additionalDetails;
  final DateTime reportDate;
  final ReportStatus status;

  ContentReport({
    required this.reportId,
    required this.reporterId,
    required this.contentId,
    required this.contentType,
    required this.reason,
    this.additionalDetails,
    required this.reportDate,
    required this.status,
  });
}

class CommunityGuidelines {
  final DateTime lastUpdated;
  final List<GuidelineSection> sections;

  CommunityGuidelines({
    required this.lastUpdated,
    required this.sections,
  });
}

class GuidelineSection {
  final String title;
  final String content;
  final List<String> examples;

  GuidelineSection({
    required this.title,
    required this.content,
    required this.examples,
  });
}

class CommunityStats {
  final int totalExperts;
  final int totalQuestions;
  final int totalAnswers;
  final int totalKnowledgeBaseArticles;
  final int questionsThisMonth;
  final int questionsLastMonth;
  final Duration averageResponseTime;
  final double expertResponseRate;
  final double userSatisfactionRate;
  final List<CategoryStat> topCategories;

  CommunityStats({
    required this.totalExperts,
    required this.totalQuestions,
    required this.totalAnswers,
    required this.totalKnowledgeBaseArticles,
    required this.questionsThisMonth,
    required this.questionsLastMonth,
    required this.averageResponseTime,
    required this.expertResponseRate,
    required this.userSatisfactionRate,
    required this.topCategories,
  });
}

class CategoryStat {
  final String category;
  final int count;

  CategoryStat({
    required this.category,
    required this.count,
  });
}
