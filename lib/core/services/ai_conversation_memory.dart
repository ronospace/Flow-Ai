import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'conversation_cloud_sync.dart';

/// AI Conversation Memory service to maintain context and user preferences
/// Now with complete user data isolation
class AIConversationMemory {
  static final AIConversationMemory _instance = AIConversationMemory._internal();
  factory AIConversationMemory() => _instance;
  AIConversationMemory._internal();

  late SharedPreferences _prefs;
  String? _currentUserId; // Track current user for data isolation
  final ConversationCloudSync _cloudSync = ConversationCloudSync();
  
  // Base memory keys (will be suffixed with user ID)
  static const String _conversationHistoryKey = 'ai_conversation_history';
  static const String _userPreferencesKey = 'ai_user_preferences';
  static const String _topicsOfInterestKey = 'ai_topics_interest';
  static const String _frequentQuestionsKey = 'ai_frequent_questions';
  static const String _personalizedInsightsKey = 'ai_personalized_insights';

  // In-memory caches for fast access
  List<types.Message> _conversationHistory = [];
  Map<String, dynamic> _userPreferences = {};
  Set<String> _topicsOfInterest = {};
  Map<String, int> _frequentQuestions = {};
  Map<String, String> _personalizedInsights = {};

  Future<void> initialize({String? userId}) async {
    _prefs = await SharedPreferences.getInstance();
    _currentUserId = userId;
    
    // Initialize cloud sync service
    await _cloudSync.initialize(userId: userId);
    
    // Try to restore from cloud first (for new device)
    final restored = await _cloudSync.restoreFromCloud();
    if (restored) {
      // Reload data after cloud restore
      await _loadMemoryData();
    } else {
      // Load from local storage
      await _loadMemoryData();
    }
    
    // Start auto-sync for cross-device persistence
    _cloudSync.startAutoSync();
  }

  /// Store a conversation message in memory
  Future<void> storeMessage(types.Message message) async {
    _conversationHistory.insert(0, message);
    
    // Keep only last 100 messages to manage memory
    if (_conversationHistory.length > 100) {
      _conversationHistory = _conversationHistory.take(100).toList();
    }

    // Extract insights from user messages
    if (message.author.id != 'ai_flowai' && message is types.TextMessage) {
      await _analyzeUserMessage(message.text);
    }

    await _saveConversationHistory();
    
    // Sync message to cloud immediately for cross-device persistence
    await _cloudSync.syncMessage(message);
  }

  /// Get relevant conversation context for AI response generation
  List<types.Message> getRelevantContext({int maxMessages = 10}) {
    return _conversationHistory.take(maxMessages).toList();
  }

  /// Analyze user message to extract preferences and interests
  Future<void> _analyzeUserMessage(String messageText) async {
    final lowerText = messageText.toLowerCase();
    
    // Extract topics of interest - expanded for enhanced AI
    final allTopics = {
      // Health topics
      'period', 'menstruation', 'cycle', 'ovulation', 'fertility',
      'pms', 'mood', 'cramps', 'symptoms', 'pregnancy', 'contraception',
      'hormones', 'health', 'exercise', 'nutrition', 'stress', 'sleep',
      
      // Science topics
      'science', 'physics', 'chemistry', 'biology', 'dna', 'photosynthesis',
      'gravity', 'space', 'planets', 'evolution', 'atoms', 'molecules',
      
      // Technology topics  
      'technology', 'computer', 'ai', 'artificial intelligence', 'machine learning',
      'smartphone', 'internet', 'cloud', 'software', 'hardware', 'programming',
      
      // Lifestyle topics
      'lifestyle', 'wellness', 'meditation', 'yoga', 'fitness', 'diet',
      'mental health', 'self care', 'habits', 'productivity',
      
      // General knowledge
      'history', 'geography', 'culture', 'language', 'education', 'learning',
      'mathematics', 'math', 'statistics', 'economy', 'environment'
    };

    for (final topic in allTopics) {
      if (lowerText.contains(topic)) {
        _topicsOfInterest.add(topic);
      }
    }

    // Track frequent questions
    if (lowerText.contains('?')) {
      final question = _normalizeQuestion(lowerText);
      _frequentQuestions[question] = (_frequentQuestions[question] ?? 0) + 1;
    }

    // Extract preferences
    _extractPreferences(lowerText);

    // Save updated data
    await _saveUserPreferences();
    await _saveTopicsOfInterest();
    await _saveFrequentQuestions();
    
    // Sync to cloud for cross-device persistence
    await _cloudSync.syncToCloud();
  }

  /// Normalize question text for pattern matching
  String _normalizeQuestion(String question) {
    // Remove specific dates, names, numbers to create patterns
    return question
        .replaceAll(RegExp(r'\b\d+\b'), '[number]')
        .replaceAll(RegExp(r'\b(my|i|me|mine)\b'), '[user]')
        .trim();
  }

  /// Extract user preferences from message - enhanced for multi-topic conversations
  void _extractPreferences(String messageText) {
    // Exercise preferences
    if (messageText.contains('yoga')) _userPreferences['prefers_yoga'] = true;
    if (messageText.contains('running')) _userPreferences['prefers_running'] = true;
    if (messageText.contains('walking')) _userPreferences['prefers_walking'] = true;
    if (messageText.contains('swimming')) _userPreferences['prefers_swimming'] = true;
    
    // Learning preferences
    if (messageText.contains('simple') || messageText.contains('easy')) {
      _userPreferences['learning_style'] = 'simple';
    } else if (messageText.contains('technical') || messageText.contains('advanced')) {
      _userPreferences['learning_style'] = 'technical';
    }
    
    // Communication style
    if (messageText.contains('quick') || messageText.contains('brief')) {
      _userPreferences['communication_style'] = 'brief';
    } else if (messageText.contains('detail') || messageText.contains('explain')) {
      _userPreferences['communication_style'] = 'detailed';
    }
    
    // Interest in examples
    if (messageText.contains('example') || messageText.contains('show me')) {
      _userPreferences['likes_examples'] = true;
    }
    
    // Fun facts interest
    if (messageText.contains('fun fact') || messageText.contains('interesting')) {
      _userPreferences['likes_fun_facts'] = true;
    }

    // Concerns level
    if (messageText.contains('worried') || messageText.contains('concern')) {
      _userPreferences['needs_reassurance'] = true;
    }
    
    // Curiosity level
    if (messageText.contains('why') || messageText.contains('how') || messageText.contains('what')) {
      _userPreferences['curious_learner'] = true;
    }
  }

  /// Get personalized response suggestions based on memory
  List<String> getPersonalizedSuggestions() {
    final suggestions = <String>[];

    // Add suggestions based on topics of interest - enhanced for multi-topic AI
    if (_topicsOfInterest.contains('mood')) {
      suggestions.add('How can I manage mood swings during PMS?');
    }
    if (_topicsOfInterest.contains('exercise')) {
      suggestions.add('What exercises are best during my period?');
    }
    if (_topicsOfInterest.contains('fertility')) {
      suggestions.add('How can I track ovulation more accurately?');
    }
    if (_topicsOfInterest.contains('science')) {
      suggestions.add('Explain photosynthesis in simple terms');
    }
    if (_topicsOfInterest.contains('technology')) {
      suggestions.add('How does machine learning work?');
    }
    if (_topicsOfInterest.contains('ai') || _topicsOfInterest.contains('artificial intelligence')) {
      suggestions.add('What can AI do for healthcare?');
    }
    if (_topicsOfInterest.contains('nutrition') || _topicsOfInterest.contains('diet')) {
      suggestions.add('Best foods for menstrual health');
    }
    if (_topicsOfInterest.contains('stress')) {
      suggestions.add('How to manage stress naturally?');
    }
    if (_topicsOfInterest.contains('sleep')) {
      suggestions.add('How much sleep do I need?');
    }

    // Add suggestions based on frequent questions
    final topQuestions = _frequentQuestions.entries
        .where((entry) => entry.value >= 2)
        .map((entry) => entry.key)
        .take(2)
        .toList();

    for (final question in topQuestions) {
      if (!suggestions.contains(question)) {
        suggestions.add(question);
      }
    }

    // Enhanced default suggestions if no patterns found
    if (suggestions.isEmpty) {
      suggestions.addAll([
        'When will my next period start?',
        'How do I track symptoms?',
        'Fun science facts',
        'How does GPS work?',
        'Healthy lifestyle tips',
        'Understanding my cycle phases',
      ]);
    }

    return suggestions.take(4).toList();
  }

  /// Get contextual AI response based on memory - enhanced for better context
  String getContextualPrompt(String userMessage) {
    final context = StringBuffer();
    
    // Add user preferences context - enhanced
    if (_userPreferences.isNotEmpty) {
      context.write('User preferences: ');
      if (_userPreferences['communication_style'] == 'brief') {
        context.write('prefers brief responses; ');
      } else if (_userPreferences['communication_style'] == 'detailed') {
        context.write('enjoys detailed explanations; ');
      }
      
      if (_userPreferences['learning_style'] == 'simple') {
        context.write('prefers simple explanations; ');
      } else if (_userPreferences['learning_style'] == 'technical') {
        context.write('can handle technical details; ');
      }
      
      if (_userPreferences['likes_examples'] == true) {
        context.write('appreciates examples; ');
      }
      
      if (_userPreferences['likes_fun_facts'] == true) {
        context.write('enjoys interesting facts; ');
      }
      
      if (_userPreferences['curious_learner'] == true) {
        context.write('is a curious learner; ');
      }
      
      if (_userPreferences['needs_reassurance'] == true) {
        context.write('may need reassurance; ');
      }
    }

    // Add topics of interest
    if (_topicsOfInterest.isNotEmpty) {
      context.write('Interested in: ${_topicsOfInterest.join(', ')}; ');
    }

    // Add recent conversation context
    final recentMessages = getRelevantContext(maxMessages: 3);
    if (recentMessages.length > 1) {
      context.write('Recent conversation context: ');
      for (final msg in recentMessages.reversed) {
        if (msg is types.TextMessage) {
          context.write('${msg.author.id == 'ai_flowai' ? 'AI' : 'User'}: ${msg.text}; ');
        }
      }
    }

    return context.toString();
  }

  /// Store personalized insight
  Future<void> storePersonalizedInsight(String key, String insight) async {
    _personalizedInsights[key] = insight;
    await _savePersonalizedInsights();
  }

  /// Get stored personalized insight
  String? getPersonalizedInsight(String key) {
    return _personalizedInsights[key];
  }
  
  /// Get all personalized insights for FlowAI context
  Map<String, String> getPersonalizedInsights() {
    return Map<String, String>.from(_personalizedInsights);
  }

  /// Clear all conversation memory (for privacy/reset)
  Future<void> clearMemory() async {
    _conversationHistory.clear();
    _userPreferences.clear();
    _topicsOfInterest.clear();
    _frequentQuestions.clear();
    _personalizedInsights.clear();

    // Clear user-specific data from storage
    await _prefs.remove(_getUserSpecificKey(_conversationHistoryKey));
    await _prefs.remove(_getUserSpecificKey(_userPreferencesKey));
    await _prefs.remove(_getUserSpecificKey(_topicsOfInterestKey));
    await _prefs.remove(_getUserSpecificKey(_frequentQuestionsKey));
    await _prefs.remove(_getUserSpecificKey(_personalizedInsightsKey));
    
    // Clear cloud backup as well
    await _cloudSync.clearCloudBackup();
  }
  
  /// Clear memory for a specific user (for user data isolation)
  Future<void> clearMemoryForUser(String userId) async {
    await _prefs.remove('${_conversationHistoryKey}_$userId');
    await _prefs.remove('${_userPreferencesKey}_$userId');
    await _prefs.remove('${_topicsOfInterestKey}_$userId');
    await _prefs.remove('${_frequentQuestionsKey}_$userId');
    await _prefs.remove('${_personalizedInsightsKey}_$userId');
  }

  /// Get memory statistics for debugging
  Future<Map<String, dynamic>> getMemoryStats() async {
    final syncStatus = await _cloudSync.getSyncStatus();
    
    return {
      'total_messages': _conversationHistory.length,
      'topics_of_interest': _topicsOfInterest.length,
      'frequent_questions': _frequentQuestions.length,
      'user_preferences': _userPreferences.length,
      'personalized_insights': _personalizedInsights.length,
      'cloud_sync_enabled': syncStatus['sync_enabled'],
      'last_cloud_sync': syncStatus['last_sync'],
      'pending_cloud_sync': syncStatus['pending_sync'],
    };
  }

  // Private methods for data persistence
  Future<void> _loadMemoryData() async {
    await _loadConversationHistory();
    await _loadUserPreferences();
    await _loadTopicsOfInterest();
    await _loadFrequentQuestions();
    await _loadPersonalizedInsights();
  }

  /// Get user-specific key for data isolation
  String _getUserSpecificKey(String baseKey) {
    return _currentUserId != null ? '${baseKey}_$_currentUserId' : baseKey;
  }

  Future<void> _loadConversationHistory() async {
    final historyJson = _prefs.getString(_getUserSpecificKey(_conversationHistoryKey));
    if (historyJson != null) {
      final List<dynamic> messages = json.decode(historyJson);
      _conversationHistory = messages.map((msgJson) {
        // Convert JSON back to Message objects
        return types.TextMessage(
          author: types.User(
            id: msgJson['author']['id'],
            firstName: msgJson['author']['firstName'],
            lastName: msgJson['author']['lastName'],
            imageUrl: msgJson['author']['imageUrl'],
          ),
          createdAt: msgJson['createdAt'],
          id: msgJson['id'],
          text: msgJson['text'],
        );
      }).toList();
    }
  }

  Future<void> _saveConversationHistory() async {
    final messagesJson = _conversationHistory.map((message) {
      if (message is types.TextMessage) {
        return {
          'author': {
            'id': message.author.id,
            'firstName': message.author.firstName,
            'lastName': message.author.lastName,
            'imageUrl': message.author.imageUrl,
          },
          'createdAt': message.createdAt,
          'id': message.id,
          'text': message.text,
        };
      }
      return null;
    }).where((msg) => msg != null).toList();

    await _prefs.setString(_getUserSpecificKey(_conversationHistoryKey), json.encode(messagesJson));
  }

  Future<void> _loadUserPreferences() async {
    final prefsJson = _prefs.getString(_getUserSpecificKey(_userPreferencesKey));
    if (prefsJson != null) {
      _userPreferences = Map<String, dynamic>.from(json.decode(prefsJson));
    }
  }

  Future<void> _saveUserPreferences() async {
    await _prefs.setString(_getUserSpecificKey(_userPreferencesKey), json.encode(_userPreferences));
  }

  Future<void> _loadTopicsOfInterest() async {
    final topicsJson = _prefs.getString(_getUserSpecificKey(_topicsOfInterestKey));
    if (topicsJson != null) {
      _topicsOfInterest = Set<String>.from(json.decode(topicsJson));
    }
  }

  Future<void> _saveTopicsOfInterest() async {
    await _prefs.setString(_getUserSpecificKey(_topicsOfInterestKey), json.encode(_topicsOfInterest.toList()));
  }

  Future<void> _loadFrequentQuestions() async {
    final questionsJson = _prefs.getString(_getUserSpecificKey(_frequentQuestionsKey));
    if (questionsJson != null) {
      _frequentQuestions = Map<String, int>.from(json.decode(questionsJson));
    }
  }

  Future<void> _saveFrequentQuestions() async {
    await _prefs.setString(_getUserSpecificKey(_frequentQuestionsKey), json.encode(_frequentQuestions));
  }

  Future<void> _loadPersonalizedInsights() async {
    final insightsJson = _prefs.getString(_getUserSpecificKey(_personalizedInsightsKey));
    if (insightsJson != null) {
      _personalizedInsights = Map<String, String>.from(json.decode(insightsJson));
    }
  }

  Future<void> _savePersonalizedInsights() async {
    await _prefs.setString(_getUserSpecificKey(_personalizedInsightsKey), json.encode(_personalizedInsights));
  }
}
