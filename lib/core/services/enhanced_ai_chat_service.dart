import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../features/premium/models/subscription_models.dart';
import '../../features/premium/services/subscription_service.dart';
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import 'dart:async';

import 'ai_conversation_memory.dart';
import '../identity/active_account_scope.dart';
import '../database/database_service.dart';
import 'cycle_calculation_engine.dart';
import 'flowai_service.dart';
import '../config/flowiq_config.dart';
import '../../generated/app_localizations.dart';
import '../../core/models/medical_citation.dart';

/// Enhanced AI Chat Service with comprehensive FAQ and general knowledge
class EnhancedAIChatService {
  String _buildWelcomeMessage(String userName) =>
      "Hi $userName! 👋\n\nI'm Zyra, your menstrual health assistant. How can I help you today? 🌸";
  static final EnhancedAIChatService _instance =
      EnhancedAIChatService._internal();
  factory EnhancedAIChatService() => _instance;
  EnhancedAIChatService._internal();

  final List<types.Message> _messages = [];
  final StreamController<List<types.Message>> _messagesController =
      StreamController<List<types.Message>>.broadcast();
  final Uuid _uuid = const Uuid();

  // AI User representation
  types.User? _aiUser;
  types.User? _currentUser;
  AIConversationMemory? _conversationMemory;
  bool _isInitialized = false;
  String? _initializedUserId;
  int _sessionGeneration = 0;
  // ignore: unused_field
  AppLocalizations? _localizations;

  // FlowAI Integration
  final FlowAIService _flowAIService = FlowAIService();
  bool _useFlowAI = false;

  // Serializes the authoritative AI quota/execution/accounting window.
  // Without this, parallel free requests could both observe the same
  // remaining insight before either request records its usage.
  Future<void> _aiExecutionTail = Future<void>.value();

  // FAQ Knowledge Base
  final Map<String, List<FAQItem>> _faqDatabase = {
    'health': [
      FAQItem(
        'What is a normal menstrual cycle?',
        'A normal menstrual cycle is typically 21-35 days long, with menstrual flow lasting 2-7 days. The average cycle length is 28 days.',
      ),
      FAQItem(
        'What causes irregular periods?',
        'Irregular periods can be caused by stress, significant weight changes, hormonal imbalances, certain medications, underlying health conditions, or lifestyle factors.',
      ),
      FAQItem(
        'How can I track my fertility?',
        'You can track fertility by monitoring your menstrual cycle, basal body temperature, cervical mucus changes, and using ovulation prediction kits.',
      ),
      FAQItem(
        'What are common PMS symptoms?',
        'Common PMS symptoms include mood swings, bloating, breast tenderness, headaches, fatigue, food cravings, and irritability.',
      ),
      FAQItem(
        'When should I see a doctor about my period?',
        'See a doctor if you have severe pain, very heavy bleeding, periods lasting longer than 7 days, or if your cycle changes significantly.',
      ),
    ],
    'general': [
      FAQItem(
        'What is artificial intelligence?',
        'Artificial Intelligence (AI) is the simulation of human intelligence in machines that are programmed to think and learn like humans.',
      ),
      FAQItem(
        'How does machine learning work?',
        'Machine learning is a subset of AI where computers learn to make predictions or decisions by finding patterns in data without being explicitly programmed.',
      ),
      FAQItem(
        'What is the difference between weather and climate?',
        'Weather refers to short-term atmospheric conditions, while climate is the long-term average of weather patterns in a region over many years.',
      ),
      FAQItem(
        'How do vaccines work?',
        'Vaccines work by training your immune system to recognize and fight specific diseases by exposing it to a safe version of the virus or bacteria.',
      ),
      FAQItem(
        'What causes seasons?',
        'Seasons are caused by the tilt of Earth\'s axis as it orbits the sun, creating different amounts of sunlight in different parts of the world throughout the year.',
      ),
    ],
    'technology': [
      FAQItem(
        'What is cloud computing?',
        'Cloud computing is the delivery of computing services like servers, storage, databases, and software over the internet (the cloud).',
      ),
      FAQItem(
        'How does GPS work?',
        'GPS works using a network of satellites that send signals to GPS receivers, which calculate location based on the time it takes to receive signals from multiple satellites.',
      ),
      FAQItem(
        'What is cryptocurrency?',
        'Cryptocurrency is a digital currency that uses cryptography for security and operates independently of traditional banks and governments.',
      ),
      FAQItem(
        'How do smartphones work?',
        'Smartphones combine cellular communication, computing capabilities, and internet connectivity to provide a portable communication and computing device.',
      ),
      FAQItem(
        'What is the internet of things?',
        'The Internet of Things (IoT) refers to the network of physical devices connected to the internet that can collect and share data.',
      ),
    ],
    'science': [
      FAQItem(
        'What is DNA?',
        'DNA (Deoxyribonucleic acid) is the molecule that carries genetic information in all living things, determining inherited traits.',
      ),
      FAQItem(
        'How does photosynthesis work?',
        'Photosynthesis is the process plants use to convert sunlight, carbon dioxide, and water into glucose and oxygen.',
      ),
      FAQItem(
        'What is gravity?',
        'Gravity is a fundamental force that attracts objects with mass toward each other, keeping us on Earth and planets in orbit around the sun.',
      ),
      FAQItem(
        'Why is the sky blue?',
        'The sky appears blue because when sunlight enters Earth\'s atmosphere, blue light is scattered more than other colors due to its shorter wavelength.',
      ),
      FAQItem(
        'What are black holes?',
        'Black holes are extremely dense regions in space where gravity is so strong that nothing, not even light, can escape once it crosses the event horizon.',
      ),
    ],
    'lifestyle': [
      FAQItem(
        'How much sleep do I need?',
        'Most adults need 7-9 hours of sleep per night for optimal health and well-being.',
      ),
      FAQItem(
        'What is a balanced diet?',
        'A balanced diet includes a variety of foods from all food groups: fruits, vegetables, whole grains, lean proteins, and healthy fats.',
      ),
      FAQItem(
        'How much water should I drink daily?',
        'The general recommendation is about 8 cups (64 ounces) of water per day, but individual needs vary based on activity level and climate.',
      ),
      FAQItem(
        'What are the benefits of exercise?',
        'Regular exercise improves cardiovascular health, strengthens muscles and bones, boosts mood, helps with weight management, and reduces disease risk.',
      ),
      FAQItem(
        'How can I manage stress?',
        'Effective stress management techniques include regular exercise, adequate sleep, meditation, deep breathing, time management, and social support.',
      ),
    ],
  };

  Stream<List<types.Message>> get messagesStream => _messagesController.stream;
  List<types.Message> get messages => List.unmodifiable(_messages);

  Future<void> initialize({
    required String userId,
    required String userName,
    AppLocalizations? localizations,
    String? flowAIApiKey,
  }) async {
    final requestedUserId = userId.trim();
    final activeUserId = await ActiveAccountScope.instance.requireUserId();

    if (requestedUserId.isEmpty || requestedUserId != activeUserId) {
      throw StateError(
        'Enhanced AI chat ownership does not match the active account.',
      );
    }

    final sameOwner = _isInitialized && _initializedUserId == activeUserId;

    _localizations = localizations;
    _currentUser = types.User(id: activeUserId, firstName: userName);

    if (sameOwner) {
      if (_messages.isNotEmpty &&
          _messages.first.author.id == 'ai_flowai_enhanced' &&
          _messages.first is types.TextMessage) {
        _messages[0] = (_messages.first as types.TextMessage).copyWith(
          text: _buildWelcomeMessage(userName),
        );
        _notifyListeners();
      }
      return;
    }

    _sessionGeneration++;
    _messages.clear();
    _notifyListeners();

    _aiUser ??= types.User(
      id: 'ai_flowai_enhanced',
      firstName: 'Zyra',
      lastName: 'AI',
      imageUrl: 'https://i.pravatar.cc/300?img=47',
    );

    if (flowAIApiKey != null && flowAIApiKey.isNotEmpty) {
      try {
        await _initializeFlowAI(flowAIApiKey);
      } catch (_) {}
    } else if (FlowIQConfig.isConfigured) {
      try {
        await _initializeFlowAI(FlowIQConfig.apiKey!);
      } catch (_) {}
    }

    await ActiveAccountScope.instance.requireOwnership(activeUserId);

    _conversationMemory = AIConversationMemory();
    await _conversationMemory!.initialize(userId: activeUserId);

    await ActiveAccountScope.instance.requireOwnership(activeUserId);

    _initializedUserId = activeUserId;
    _isInitialized = true;

    final restoredMessages = _conversationMemory!.getRelevantContext(
      maxMessages: 100,
    );

    if (restoredMessages.isNotEmpty) {
      _messages
        ..clear()
        ..addAll(restoredMessages);
      _notifyListeners();
    } else {
      await _addAIMessage(_buildWelcomeMessage(userName));
    }
  }

  Future<bool> _isCurrentSession(String userId, int generation) async {
    if (!_isInitialized ||
        _initializedUserId != userId ||
        _sessionGeneration != generation) {
      return false;
    }

    try {
      await ActiveAccountScope.instance.requireOwnership(userId);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> resetSession() async {
    _sessionGeneration++;
    _messages.clear();
    _currentUser = null;
    _initializedUserId = null;
    _isInitialized = false;
    await _conversationMemory?.resetSession();
    _conversationMemory = null;
    _notifyListeners();
  }

  /// Send user message and get AI response
  Future<void> sendMessage(types.TextMessage message) async {
    final ownerId = _initializedUserId;
    final generation = _sessionGeneration;

    if (ownerId == null ||
        message.author.id != ownerId ||
        !await _isCurrentSession(ownerId, generation)) {
      throw StateError(
        'AI chat message ownership does not match the active account.',
      );
    }

    _messages.insert(0, message);
    _notifyListeners();

    await _conversationMemory?.storeMessage(message);

    if (!await _isCurrentSession(ownerId, generation)) return;

    final contextPrompt = _conversationMemory?.getContextualPrompt(
      message.text,
    );
    final response = await _generateEnhancedAIResponse(
      message.text,
      contextPrompt: contextPrompt,
      ownerId: ownerId,
      generation: generation,
    );

    if (!await _isCurrentSession(ownerId, generation)) return;

    await _streamAIResponse(response, ownerId: ownerId, generation: generation);
  }

  Future<void> _streamAIResponse(
    String text, {
    required String ownerId,
    required int generation,
  }) async {
    if (_aiUser == null || !await _isCurrentSession(ownerId, generation)) {
      return;
    }

    final words = text.split(' ');
    String current = '';

    final message = types.TextMessage(
      author: _aiUser!,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: '',
    );

    _messages.insert(0, message);
    _notifyListeners();

    for (final word in words) {
      if (!await _isCurrentSession(ownerId, generation)) return;

      current += (current.isEmpty ? '' : ' ') + word;

      if (_messages.isEmpty || _messages.first.id != message.id) return;

      _messages[0] = types.TextMessage(
        author: _aiUser!,
        createdAt: message.createdAt,
        id: message.id,
        text: current,
      );

      _notifyListeners();
      await Future.delayed(const Duration(milliseconds: 45));
    }

    if (!await _isCurrentSession(ownerId, generation) ||
        _messages.isEmpty ||
        _messages.first.id != message.id) {
      return;
    }

    await _conversationMemory?.storeMessage(_messages.first);
  }

  /// Add AI message to conversation
  Future<void> _addAIMessage(String text) async {
    final ownerId = _initializedUserId;
    final generation = _sessionGeneration;

    if (_aiUser == null ||
        ownerId == null ||
        !await _isCurrentSession(ownerId, generation)) {
      return;
    }

    final aiMessage = types.TextMessage(
      author: _aiUser!,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: text,
    );

    _messages.insert(0, aiMessage);
    _notifyListeners();

    if (!await _isCurrentSession(ownerId, generation)) return;

    await _conversationMemory?.storeMessage(aiMessage);
  }

  /// Generate enhanced AI response with comprehensive knowledge
  Future<String> _generateEnhancedAIResponse(
    String userMessage, {
    String? contextPrompt,
    required String ownerId,
    required int generation,
  }) {
    final result = Completer<String>();

    _aiExecutionTail = _aiExecutionTail.then((_) async {
      try {
        result.complete(
          await _generateEnhancedAIResponseUnlocked(
            userMessage,
            contextPrompt: contextPrompt,
            ownerId: ownerId,
            generation: generation,
          ),
        );
      } catch (error, stackTrace) {
        result.completeError(error, stackTrace);
      }
    });

    return result.future;
  }

  Future<String> _generateEnhancedAIResponseUnlocked(
    String userMessage, {
    String? contextPrompt,
    required String ownerId,
    required int generation,
  }) async {
    final currentUser = _currentUser;
    if (currentUser == null ||
        currentUser.id != ownerId ||
        !await _isCurrentSession(ownerId, generation)) {
      return 'AI is temporarily unavailable. Please try again.';
    }

    final subscriptionService = SubscriptionService();
    final subscription = subscriptionService.currentSubscription;

    // AI execution must never inherit another account's entitlement and must
    // fail closed while subscription ownership is unresolved.
    if (subscription == null || subscription.userId != currentUser.id) {
      return 'AI access is temporarily unavailable while your account access '
          'is being verified. Please try again.';
    }

    final hasUnlimitedInsights = subscriptionService.canAccessFeature(
      PremiumFeature.unlimitedInsights,
    );

    if (!hasUnlimitedInsights &&
        subscriptionService.getRemainingFreeInsights() <= 0) {
      return 'You have used all of your free AI insights. '
          'Upgrade to Flow Ai Premium for unlimited AI insights.';
    }

    // Try the real FlowAI service. A failed/unavailable service must never
    // silently fall back to synthetic or canned content presented as AI.
    if (_useFlowAI && _currentUser != null) {
      try {
        final flowAIResponse = await _getFlowAIResponse(
          userMessage,
          contextPrompt,
          ownerId: ownerId,
          generation: generation,
        );
        if (flowAIResponse != null && flowAIResponse.isNotEmpty) {
          if (!await _isCurrentSession(ownerId, generation)) {
            return 'AI is temporarily unavailable. Please try again.';
          }

          final latestSubscription = subscriptionService.currentSubscription;
          if (latestSubscription == null ||
              latestSubscription.userId != ownerId) {
            return 'AI access is temporarily unavailable while your account '
                'access is being verified. Please try again.';
          }

          final hasUnlimitedInsightsAtDelivery = subscriptionService
              .canAccessFeature(PremiumFeature.unlimitedInsights);

          if (!hasUnlimitedInsightsAtDelivery) {
            // Entitlement may have changed while the online request was
            // running. Re-check the authoritative free quota before delivery.
            if (subscriptionService.getRemainingFreeInsights() <= 0) {
              return 'You have used all of your free AI insights. '
                  'Upgrade to Flow Ai Premium for unlimited AI insights.';
            }

            await subscriptionService.incrementInsightsUsageForUser(ownerId);

            if (!await _isCurrentSession(ownerId, generation)) {
              return 'AI is temporarily unavailable. Please try again.';
            }
          }

          // Add medical citations to real FlowAI health responses.
          return _addMedicalCitationToHealthResponse(
            flowAIResponse,
            userMessage.toLowerCase(),
          );
        }
      } catch (e) {}
    }

    return 'I can’t generate an AI response right now because the online '
        'Flow Ai service is unavailable. Your saved data and FAQ content '
        'remain available, and you can try the AI request again later.';
  }

  /// Add medical citation to health responses
  String _addMedicalCitationToHealthResponse(
    String response,
    String userMessage,
  ) {
    final lowerResponse = response.toLowerCase();

    // Check if response contains medical/health content that needs citation support
    final hasMedicalContent =
        lowerResponse.contains('period') ||
        lowerResponse.contains('menstrual') ||
        lowerResponse.contains('cycle') ||
        lowerResponse.contains('fertility') ||
        lowerResponse.contains('ovulation') ||
        lowerResponse.contains('symptom') ||
        lowerResponse.contains('hormone') ||
        lowerResponse.contains('pms') ||
        lowerResponse.contains('cramp') ||
        lowerResponse.contains('health') ||
        lowerResponse.contains('medical') ||
        lowerResponse.contains('pregnancy');

    // If no medical content detected, return as-is (non-medical questions)
    if (!hasMedicalContent) {
      return response;
    }

    String? citationCategory;

    // Determine citation category based on both message and response content
    if (userMessage.contains('period') ||
        userMessage.contains('menstruation') ||
        lowerResponse.contains('cycle length') ||
        lowerResponse.contains('cycle pattern')) {
      citationCategory = 'cycle_length';
    } else if (userMessage.contains('fertile') ||
        userMessage.contains('ovulation') ||
        userMessage.contains('pregnancy') ||
        lowerResponse.contains('fertility window')) {
      citationCategory = 'fertility_window';
    } else if (userMessage.contains('mood') ||
        userMessage.contains('pms') ||
        userMessage.contains('cramp') ||
        userMessage.contains('symptom') ||
        lowerResponse.contains('symptom') ||
        lowerResponse.contains('cramp')) {
      citationCategory = 'menstrual_symptoms';
    } else if (userMessage.contains('health') ||
        userMessage.contains('exercise') ||
        userMessage.contains('diet') ||
        userMessage.contains('lifestyle') ||
        lowerResponse.contains('lifestyle') ||
        lowerResponse.contains('exercise')) {
      citationCategory = 'lifestyle_recommendations';
    } else {
      // Default to general health tracking citation
      citationCategory = 'health_tracking';
    }

    final citations = MedicalCitationsDatabase.getCitationsForInsightType(
      citationCategory,
    );
    if (citations.isEmpty) {
      // Still add disclaimer even if no specific citation found
      return '$response\n\n\n\n\n\nAI-generated insight. Not medical advice.\n\n\n';
    }

    final citation = citations.first;
    return '$response\n\n\n\n\n\nSource: ${citation.source}\n📝 ${citation.title}${citation.year != null ? ' (${citation.year})' : ''}\n  ${citation.url}\n\n⚠️ This information is for awareness only. Not medical advice. Consult a healthcare provider for medical concerns.\n\n💡 View all medical sources: Settings → Medical Sources & Citations\n';
  }

  // FAQ Database search
  String? _searchFAQDatabase(String query) {
    final keywords = query.split(' ');

    for (final category in _faqDatabase.keys) {
      final faqs = _faqDatabase[category]!;

      for (final faq in faqs) {
        // Check if question matches closely
        if (_calculateSimilarity(query, faq.question.toLowerCase()) > 0.6) {
          return "${faq.answer}\n\n💡 This is from my $category knowledge base. Feel free to ask follow-up questions!";
        }

        // Check if answer contains relevant keywords
        final questionWords = faq.question.toLowerCase().split(' ');
        final answerWords = faq.answer.toLowerCase().split(' ');

        int matchCount = 0;
        for (final keyword in keywords) {
          if (questionWords.any((word) => word.contains(keyword)) ||
              answerWords.any((word) => word.contains(keyword))) {
            matchCount++;
          }
        }

        if (matchCount >= 2 && keywords.length >= 2) {
          return "${faq.answer}\n\n📚 Related question: \"${faq.question}\"\n\nWould you like to know more about this topic?";
        }
      }
    }

    return null;
  }

  // Helper methods for topic detection
  bool _isHealthRelated(String message) {
    final healthKeywords = [
      'period',
      'menstruation',
      'cycle',
      'ovulation',
      'fertility',
      'pms',
      'cramps',
      'symptoms',
      'pain',
      'bloating',
      'mood',
      'hormone',
      'pregnancy',
      'contraception',
    ];
    return healthKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isTechnologyRelated(String message) {
    final techKeywords = [
      'computer',
      'smartphone',
      'internet',
      'wifi',
      'bluetooth',
      'app',
      'software',
      'hardware',
      'ai',
      'artificial intelligence',
      'machine learning',
      'cloud',
      'bitcoin',
    ];
    return techKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isScienceRelated(String message) {
    final scienceKeywords = [
      'science',
      'physics',
      'chemistry',
      'biology',
      'dna',
      'atoms',
      'gravity',
      'photosynthesis',
      'evolution',
      'space',
      'planets',
      'solar system',
    ];
    return scienceKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isLifestyleRelated(String message) {
    final lifestyleKeywords = [
      'diet',
      'exercise',
      'sleep',
      'nutrition',
      'fitness',
      'meditation',
      'stress',
      'wellness',
      'health',
      'lifestyle',
      'habits',
    ];
    return lifestyleKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isMathRelated(String message) {
    final mathKeywords = [
      'calculate',
      'math',
      'mathematics',
      'equation',
      'formula',
      'percentage',
      'statistics',
      'probability',
      'geometry',
      'algebra',
    ];
    return mathKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isGeneralKnowledgeRelated(String message) {
    final generalKeywords = [
      'history',
      'geography',
      'culture',
      'language',
      'country',
      'capital',
      'population',
      'economy',
      'politics',
      'current events',
    ];
    return generalKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isEntertainmentRelated(String message) {
    final entertainmentKeywords = [
      'movie',
      'music',
      'book',
      'game',
      'sport',
      'celebrity',
      'entertainment',
      'fun fact',
      'trivia',
      'joke',
    ];
    return entertainmentKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isPersonalRelated(String message) {
    final personalKeywords = [
      'who are you',
      'your name',
      'about you',
      'hello',
      'hi',
      'thank',
      'how are you',
      'what can you do',
      'help me',
    ];
    return personalKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isAppRelated(String message) {
    final appKeywords = [
      'app',
      'track',
      'log',
      'feature',
      'how to use',
      'navigation',
      'settings',
    ];
    return appKeywords.any((keyword) => message.contains(keyword));
  }

  // Response generators for different topics

  // ignore: unused_element
  String _getPersonalResponse(String message) {
    if (message.contains('who are you') || message.contains('about you')) {
      return "I'm Zyra. I can help with cycle tracking, health topics, and general questions. What would you like to explore?";
    } else if (message.contains('hello') || message.contains('hi')) {
      return "Hello. I can help with cycle tracking, health information, science, technology, and app guidance. What’s on your mind?";
    } else if (message.contains('thank')) {
      return "You're welcome. I'm here if you’d like to explore more.";
    } else {
      return "I'm here and ready to help! 😊 As your AI companion, I can discuss health topics, answer questions about science and technology, share interesting facts, or help you navigate the app. What would you like to explore?";
    }
  }

  /// Enhanced personal response with memory

  /// Enhance response with contextual information and personalized insights

  // Random fact generators

  // String similarity calculation
  double _calculateSimilarity(String str1, String str2) {
    if (str1.isEmpty || str2.isEmpty) return 0.0;

    final words1 = str1.toLowerCase().split(' ');
    final words2 = str2.toLowerCase().split(' ');

    int matches = 0;
    for (final word1 in words1) {
      for (final word2 in words2) {
        if (word1.contains(word2) || word2.contains(word1)) {
          matches++;
          break;
        }
      }
    }

    return matches / math.max(words1.length, words2.length);
  }

  /// Get enhanced suggested replies based on conversation context
  List<String> getSuggestedReplies() {
    return [
      "When will my next period start?",
      "Am I in my fertile window today?",
      "Why is my period late or early?",
      "What phase of my cycle am I in?",
      "What do my current symptoms mean?",
      "How can I reduce cramps naturally?",
      "Is my cycle regular or irregular?",
      "Can I get pregnant right now?",
      "How long is my luteal phase?",
      "What affects my hormonal balance?",
    ];
  }

  /// Search FAQ database with specific query
  List<FAQItem> searchFAQs(String query, {String? category}) {
    final results = <FAQItem>[];
    final lowerQuery = query.toLowerCase();

    final categoriesToSearch = category != null
        ? [category]
        : _faqDatabase.keys;

    for (final cat in categoriesToSearch) {
      final faqs = _faqDatabase[cat] ?? [];

      for (final faq in faqs) {
        final similarity = _calculateSimilarity(
          lowerQuery,
          faq.question.toLowerCase(),
        );
        if (similarity > 0.3 ||
            faq.question.toLowerCase().contains(lowerQuery) ||
            faq.answer.toLowerCase().contains(lowerQuery)) {
          results.add(faq);
        }
      }
    }

    return results;
  }

  /// Get all FAQ categories
  List<String> getFAQCategories() {
    return _faqDatabase.keys.toList();
  }

  /// Get FAQs by category
  List<FAQItem> getFAQsByCategory(String category) {
    return _faqDatabase[category] ?? [];
  }

  /// Clear conversation history
  Future<void> clearMessages() async {
    _messages.clear();
    _notifyListeners();

    // Clear conversation memory
    await _conversationMemory?.clearMemory();

    // Re-add enhanced welcome message
    await _addAIMessage(
      "Hello again. I can help with health information, science, technology, and app guidance. What would you like to explore today?",
    );
  }

  void _notifyListeners() {
    _messagesController.add(List.from(_messages));
  }

  void dispose() {
    _messagesController.close();
  }

  // FlowAI Integration Methods (same as original)
  Future<void> _initializeFlowAI(String apiKey) async {
    try {
      await _flowAIService.initialize(apiKey: apiKey);
      _useFlowAI = _flowAIService.isInitialized;
    } catch (e) {
      _useFlowAI = false;
    }
  }

  Future<String?> _getFlowAIResponse(
    String userMessage,
    String? contextPrompt, {
    required String ownerId,
    required int generation,
  }) async {
    if (!_useFlowAI ||
        _currentUser?.id != ownerId ||
        !await _isCurrentSession(ownerId, generation)) {
      return null;
    }

    try {
      final database = DatabaseService.instance;

      await ActiveAccountScope.instance.requireOwnership(ownerId);

      final currentCycle = await database.getCurrentCycle();
      if (!await _isCurrentSession(ownerId, generation)) return null;

      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));
      final recentTracking = await database.getDailyTrackingRange(
        startDate,
        endDate,
      );
      if (!await _isCurrentSession(ownerId, generation)) return null;

      final predictions = await CycleCalculationEngine(
        database,
      ).calculatePredictions(referenceDate: endDate, monthsOfHistory: 12);
      if (!await _isCurrentSession(ownerId, generation)) return null;

      final recentSymptoms = <String>[];
      for (final row in recentTracking.reversed) {
        final symptoms = row['symptoms'];
        if (symptoms is! List) continue;

        for (final symptom in symptoms) {
          final value = symptom.toString().trim();
          if (value.isNotEmpty && !recentSymptoms.contains(value)) {
            recentSymptoms.add(value);
          }
        }
      }

      Map<String, dynamic>? cycleData;
      if (currentCycle != null) {
        final currentCycleDay =
            endDate.difference(currentCycle.startDate).inDays + 1;

        cycleData = <String, dynamic>{
          'startDate': currentCycle.startDate.toIso8601String(),
          if (currentCycle.endDate != null)
            'endDate': currentCycle.endDate!.toIso8601String(),
          if (currentCycleDay > 0) 'currentCycleDay': currentCycleDay,
        };
      }

      final currentPhase =
          predictions != null && predictions.currentPhase.name != 'unknown'
          ? predictions.currentPhase.name
          : null;

      final conversationContext = _buildHealthContext(contextPrompt);

      // Private health context must never cross an account transition.
      if (!await _isCurrentSession(ownerId, generation)) return null;
      await ActiveAccountScope.instance.requireOwnership(ownerId);

      final response = await _flowAIService.sendHealthChatMessage(
        message: userMessage,
        userId: ownerId,
        conversationContext: conversationContext,
        cycleData: cycleData,
        recentSymptoms: recentSymptoms.isEmpty ? null : recentSymptoms,
        currentPhase: currentPhase,
      );

      if (!await _isCurrentSession(ownerId, generation)) return null;

      return response.content;
    } on FlowAIException {
      return null;
    } catch (_) {
      return null;
    }
  }

  String? _buildHealthContext(String? conversationContext) {
    final contextParts = <String>[];

    if (conversationContext != null && conversationContext.isNotEmpty) {
      contextParts.add('Previous conversation: $conversationContext');
    }

    final personalizedInsights =
        _conversationMemory?.getPersonalizedInsights() ?? {};
    if (personalizedInsights.isNotEmpty) {
      final insightsText = personalizedInsights.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      contextParts.add('User insights: $insightsText');
    }

    return contextParts.isNotEmpty ? contextParts.join('; ') : null;
  }

  /// Get current user for message composition
  types.User? get currentUser => _currentUser;

  /// Get memory statistics for debugging
  Future<Map<String, dynamic>> getMemoryStats() async {
    return await _conversationMemory?.getMemoryStats() ?? {};
  }

  /// Store a personalized insight about the user
  Future<void> storePersonalizedInsight(String key, String insight) async {
    await _conversationMemory?.storePersonalizedInsight(key, insight);
  }

  /// Get a personalized insight about the user
  String? getPersonalizedInsight(String key) {
    return _conversationMemory?.getPersonalizedInsight(key);
  }

  /// Check if FlowAI is available and working
  bool get isFlowAIEnabled => _useFlowAI && _flowAIService.isInitialized;

  /// Get FlowAI service status
  String get aiServiceStatus {
    if (!_isInitialized) return 'Not initialized';
    if (_useFlowAI && _flowAIService.isInitialized) return 'FlowAI enabled';
    return 'Online Flow Ai unavailable';
  }
}

/// FAQ Item model
class FAQItem {
  final String question;
  final String answer;

  FAQItem(this.question, this.answer);

  @override
  String toString() =>
      'FAQItem(question: $question, answer: ${answer.substring(0, math.min(50, answer.length))}...)';
}
