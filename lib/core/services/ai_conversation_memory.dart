import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

/// AI Conversation Memory service to maintain context and user preferences
class AIConversationMemory {
  static final AIConversationMemory _instance = AIConversationMemory._internal();
  factory AIConversationMemory() => _instance;
  AIConversationMemory._internal();

  late SharedPreferences _prefs;
  
  // Memory keys
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

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadMemoryData();
  }

  /// Store a conversation message in memory
  Future<void> storeMessage(types.Message message) async {
    _conversationHistory.insert(0, message);
    
    // Keep only last 100 messages to manage memory
    if (_conversationHistory.length > 100) {
      _conversationHistory = _conversationHistory.take(100).toList();
    }

    // Extract insights from user messages
    if (message.author.id != 'ai_flowsense' && message is types.TextMessage) {
      await _analyzeUserMessage(message.text);
    }

    await _saveConversationHistory();
  }

  /// Get relevant conversation context for AI response generation
  List<types.Message> getRelevantContext({int maxMessages = 10}) {
    return _conversationHistory.take(maxMessages).toList();
  }

  /// Analyze user message to extract preferences and interests
  Future<void> _analyzeUserMessage(String messageText) async {
    final lowerText = messageText.toLowerCase();
    
    // Extract topics of interest
    final healthTopics = [
      'period', 'menstruation', 'cycle', 'ovulation', 'fertility',
      'pms', 'mood', 'cramps', 'symptoms', 'pregnancy', 'contraception',
      'hormones', 'health', 'exercise', 'nutrition', 'stress', 'sleep'
    ];

    for (final topic in healthTopics) {
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
  }

  /// Normalize question text for pattern matching
  String _normalizeQuestion(String question) {
    // Remove specific dates, names, numbers to create patterns
    return question
        .replaceAll(RegExp(r'\b\d+\b'), '[number]')
        .replaceAll(RegExp(r'\b(my|i|me|mine)\b'), '[user]')
        .trim();
  }

  /// Extract user preferences from message
  void _extractPreferences(String messageText) {
    // Exercise preferences
    if (messageText.contains('yoga')) _userPreferences['prefers_yoga'] = true;
    if (messageText.contains('running')) _userPreferences['prefers_running'] = true;
    if (messageText.contains('walking')) _userPreferences['prefers_walking'] = true;
    
    // Communication style
    if (messageText.contains('quick') || messageText.contains('brief')) {
      _userPreferences['communication_style'] = 'brief';
    } else if (messageText.contains('detail') || messageText.contains('explain')) {
      _userPreferences['communication_style'] = 'detailed';
    }

    // Concerns level
    if (messageText.contains('worried') || messageText.contains('concern')) {
      _userPreferences['needs_reassurance'] = true;
    }
  }

  /// Get personalized response suggestions based on memory
  List<String> getPersonalizedSuggestions() {
    final suggestions = <String>[];

    // Add suggestions based on topics of interest
    if (_topicsOfInterest.contains('mood')) {
      suggestions.add('How can I manage mood swings during PMS?');
    }
    if (_topicsOfInterest.contains('exercise')) {
      suggestions.add('What exercises are best during my period?');
    }
    if (_topicsOfInterest.contains('fertility')) {
      suggestions.add('How can I track ovulation more accurately?');
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

    // Default suggestions if no patterns found
    if (suggestions.isEmpty) {
      suggestions.addAll([
        'When will my next period start?',
        'How do I track symptoms?',
        'Understanding my cycle phases',
      ]);
    }

    return suggestions.take(4).toList();
  }

  /// Get contextual AI response based on memory
  String getContextualPrompt(String userMessage) {
    final context = StringBuffer();
    
    // Add user preferences context
    if (_userPreferences.isNotEmpty) {
      context.write('User preferences: ');
      if (_userPreferences['communication_style'] == 'brief') {
        context.write('prefers brief responses; ');
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
          context.write('${msg.author.id == 'ai_flowsense' ? 'AI' : 'User'}: ${msg.text}; ');
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

  /// Clear all conversation memory (for privacy/reset)
  Future<void> clearMemory() async {
    _conversationHistory.clear();
    _userPreferences.clear();
    _topicsOfInterest.clear();
    _frequentQuestions.clear();
    _personalizedInsights.clear();

    await _prefs.remove(_conversationHistoryKey);
    await _prefs.remove(_userPreferencesKey);
    await _prefs.remove(_topicsOfInterestKey);
    await _prefs.remove(_frequentQuestionsKey);
    await _prefs.remove(_personalizedInsightsKey);
  }

  /// Get memory statistics for debugging
  Map<String, dynamic> getMemoryStats() {
    return {
      'total_messages': _conversationHistory.length,
      'topics_of_interest': _topicsOfInterest.length,
      'frequent_questions': _frequentQuestions.length,
      'user_preferences': _userPreferences.length,
      'personalized_insights': _personalizedInsights.length,
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

  Future<void> _loadConversationHistory() async {
    final historyJson = _prefs.getString(_conversationHistoryKey);
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

    await _prefs.setString(_conversationHistoryKey, json.encode(messagesJson));
  }

  Future<void> _loadUserPreferences() async {
    final prefsJson = _prefs.getString(_userPreferencesKey);
    if (prefsJson != null) {
      _userPreferences = Map<String, dynamic>.from(json.decode(prefsJson));
    }
  }

  Future<void> _saveUserPreferences() async {
    await _prefs.setString(_userPreferencesKey, json.encode(_userPreferences));
  }

  Future<void> _loadTopicsOfInterest() async {
    final topicsJson = _prefs.getString(_topicsOfInterestKey);
    if (topicsJson != null) {
      _topicsOfInterest = Set<String>.from(json.decode(topicsJson));
    }
  }

  Future<void> _saveTopicsOfInterest() async {
    await _prefs.setString(_topicsOfInterestKey, json.encode(_topicsOfInterest.toList()));
  }

  Future<void> _loadFrequentQuestions() async {
    final questionsJson = _prefs.getString(_frequentQuestionsKey);
    if (questionsJson != null) {
      _frequentQuestions = Map<String, int>.from(json.decode(questionsJson));
    }
  }

  Future<void> _saveFrequentQuestions() async {
    await _prefs.setString(_frequentQuestionsKey, json.encode(_frequentQuestions));
  }

  Future<void> _loadPersonalizedInsights() async {
    final insightsJson = _prefs.getString(_personalizedInsightsKey);
    if (insightsJson != null) {
      _personalizedInsights = Map<String, String>.from(json.decode(insightsJson));
    }
  }

  Future<void> _savePersonalizedInsights() async {
    await _prefs.setString(_personalizedInsightsKey, json.encode(_personalizedInsights));
  }
}
