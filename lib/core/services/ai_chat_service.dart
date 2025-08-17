import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import 'dart:async';

import 'ai_conversation_memory.dart';

/// AI Chat Service for real-time health conversations
class AIChatService {
  static final AIChatService _instance = AIChatService._internal();
  factory AIChatService() => _instance;
  AIChatService._internal();

  final List<types.Message> _messages = [];
  final StreamController<List<types.Message>> _messagesController = StreamController<List<types.Message>>.broadcast();
  final Uuid _uuid = const Uuid();
  
  // AI User representation
  late final types.User _aiUser;
  late final types.User _currentUser;
  late final AIConversationMemory _conversationMemory;

  Stream<List<types.Message>> get messagesStream => _messagesController.stream;
  List<types.Message> get messages => List.unmodifiable(_messages);

  Future<void> initialize({required String userId, required String userName}) async {
    _currentUser = types.User(
      id: userId,
      firstName: userName,
    );

    _aiUser = types.User(
      id: 'ai_flowsense',
      firstName: 'FlowSense',
      lastName: 'AI',
      imageUrl: 'https://i.pravatar.cc/300?img=47', // AI avatar
    );
    
    // Initialize conversation memory
    _conversationMemory = AIConversationMemory();
    await _conversationMemory.initialize();
    
    // Load existing messages or add welcome message
    final existingMessages = _conversationMemory.getRelevantContext();
    if (existingMessages.isNotEmpty) {
      _messages.addAll(existingMessages);
      _notifyListeners();
    } else {
      // Add welcome message
      _addAIMessage(
        "Hi ${userName}! 👋 I'm your FlowSense AI assistant. I'm here to help you understand your cycle, provide personalized health insights, and answer any questions about reproductive wellness. How can I help you today?"
      );
    }
  }

  /// Send user message and get AI response
  Future<void> sendMessage(types.TextMessage message) async {
    // Add user message
    _messages.insert(0, message);
    _notifyListeners();
    
    // Store in conversation memory
    await _conversationMemory.storeMessage(message);

    // Simulate typing delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate AI response with context
    final contextPrompt = _conversationMemory.getContextualPrompt(message.text);
    final response = await _generateAIResponse(message.text, contextPrompt: contextPrompt);
    _addAIMessage(response);
  }

  /// Add AI message to conversation
  Future<void> _addAIMessage(String text) async {
    final aiMessage = types.TextMessage(
      author: _aiUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: text,
    );

    _messages.insert(0, aiMessage);
    _notifyListeners();
    
    // Store in conversation memory
    await _conversationMemory.storeMessage(aiMessage);
  }

  /// Generate contextual AI response based on user input
  Future<String> _generateAIResponse(String userMessage, {String? contextPrompt}) async {
    final lowerMessage = userMessage.toLowerCase();
    
    // Use conversation context for more personalized responses
    if (contextPrompt != null && contextPrompt.isNotEmpty) {
      debugPrint('Using context for response: $contextPrompt');
      // In a real implementation, we would pass the context to an LLM
    }

    // Cycle tracking responses
    if (lowerMessage.contains('period') || lowerMessage.contains('menstruation')) {
      return _getPeriodRelatedResponse(lowerMessage);
    }

    // Mood and PMS responses
    if (lowerMessage.contains('mood') || lowerMessage.contains('pms') || lowerMessage.contains('cramps')) {
      return _getMoodPMSResponse(lowerMessage);
    }

    // Fertility and ovulation
    if (lowerMessage.contains('fertile') || lowerMessage.contains('ovulation') || lowerMessage.contains('pregnancy')) {
      return _getFertilityResponse(lowerMessage);
    }

    // Symptoms tracking
    if (lowerMessage.contains('symptom') || lowerMessage.contains('pain') || lowerMessage.contains('bloating')) {
      return _getSymptomsResponse(lowerMessage);
    }

    // Health and wellness
    if (lowerMessage.contains('health') || lowerMessage.contains('exercise') || lowerMessage.contains('diet')) {
      return _getHealthWellnessResponse(lowerMessage);
    }

    // App usage
    if (lowerMessage.contains('how to') || lowerMessage.contains('track') || lowerMessage.contains('use app')) {
      return _getAppUsageResponse(lowerMessage);
    }

    // Predictions and insights
    if (lowerMessage.contains('predict') || lowerMessage.contains('next period') || lowerMessage.contains('when')) {
      return _getPredictionResponse(lowerMessage);
    }

    // General greeting or thanks
    if (lowerMessage.contains('hi') || lowerMessage.contains('hello') || lowerMessage.contains('thank')) {
      return _getGeneralResponse(lowerMessage);
    }

    // Default contextual response
    return _getContextualResponse(lowerMessage);
  }

  String _getPeriodRelatedResponse(String message) {
    final responses = [
      "I can help you track your menstrual cycle! 🩸 When did your last period start? You can log this in the Period Tracker section, and I'll help predict your next cycle.",
      "Understanding your period patterns is key to reproductive health. The average cycle is 21-35 days. Have you noticed any changes in your cycle lately?",
      "Period tracking helps identify patterns in flow intensity, duration, and symptoms. Would you like me to guide you through logging your current period?",
      "Irregular periods can be influenced by stress, diet, exercise, or hormonal changes. If you're concerned about irregularities, consider consulting with a healthcare provider.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getMoodPMSResponse(String message) {
    final responses = [
      "PMS affects up to 85% of menstruating people. 💭 Tracking mood changes can help identify patterns. Are you experiencing mood swings, irritability, or anxiety?",
      "Mood fluctuations during your cycle are completely normal due to hormonal changes. Try logging your daily mood to see patterns emerge over time.",
      "For PMS symptoms, consider: gentle exercise, adequate sleep, reducing caffeine, and stress management techniques. What symptoms are you experiencing?",
      "Cramps and mood changes often peak 1-2 days before your period. Heat therapy, gentle stretching, and staying hydrated can help manage discomfort.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getFertilityResponse(String message) {
    final responses = [
      "Ovulation typically occurs 14 days before your next period. 🥚 Are you tracking fertility to conceive or for natural family planning?",
      "Your fertile window is usually 5 days before ovulation and the day of ovulation. Tracking basal body temperature and cervical mucus can help identify this window.",
      "Fertility awareness involves understanding your body's natural signs. Would you like me to explain the different fertility tracking methods?",
      "If you're trying to conceive, focus on the fertile window. If preventing pregnancy, remember that natural methods require consistency and education.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getSymptomsResponse(String message) {
    final responses = [
      "Tracking symptoms helps identify patterns and potential triggers. 📊 What symptoms are you experiencing? I can help you log them properly.",
      "Common cycle-related symptoms include bloating, breast tenderness, headaches, and fatigue. Are these new symptoms or part of your regular pattern?",
      "Severe or unusual symptoms should be discussed with a healthcare provider. I can help you prepare questions and track symptoms to share with them.",
      "Pain management techniques include heat therapy, gentle exercise, anti-inflammatory medications, and relaxation techniques. What type of pain are you experiencing?",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getHealthWellnessResponse(String message) {
    final responses = [
      "A balanced lifestyle supports menstrual health! 🌟 Regular exercise, adequate sleep, stress management, and proper nutrition all play important roles.",
      "Exercise can help reduce PMS symptoms and regulate cycles. Low-impact activities like walking, yoga, and swimming are excellent choices during your cycle.",
      "Nutrition during your cycle: focus on iron-rich foods, complex carbohydrates, and staying hydrated. Limit caffeine and alcohol if they worsen symptoms.",
      "Stress significantly impacts menstrual health. Consider meditation, deep breathing exercises, or other stress-reduction techniques that work for you.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getAppUsageResponse(String message) {
    final responses = [
      "Great question! 📱 To track your period: go to Period Tracker → tap the calendar → select start date → log flow intensity and symptoms daily.",
      "The AI Insights section provides personalized analysis based on your tracking data. The more you log, the more accurate your insights become!",
      "You can log symptoms in the Symptoms section, track mood and energy levels, and even add notes about your daily experiences.",
      "For predictions: ensure you've logged at least 2-3 complete cycles for accurate forecasting. The AI learns from your patterns to make better predictions.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getPredictionResponse(String message) {
    final responses = [
      "Cycle predictions become more accurate with consistent tracking! 🔮 Based on your historical data, I can predict your next period with 85-95% accuracy.",
      "Your next period prediction is based on your average cycle length and recent patterns. Have you noticed any factors that might affect your cycle timing?",
      "Predictions consider cycle length, symptoms, and hormonal patterns. Factors like stress, travel, illness, or lifestyle changes can affect timing.",
      "For the most accurate predictions, log your period start and end dates consistently. I'll analyze patterns and provide increasingly accurate forecasts.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getGeneralResponse(String message) {
    if (message.contains('hi') || message.contains('hello')) {
      final greetings = [
        "Hello! 😊 How can I help you with your reproductive health today?",
        "Hi there! I'm here to support your menstrual health journey. What would you like to know?",
        "Welcome back! Ready to dive into some health insights or track your cycle?",
      ];
      return greetings[math.Random().nextInt(greetings.length)];
    } else {
      final thanks = [
        "You're very welcome! 💕 I'm always here to help with your health questions and cycle tracking needs.",
        "Happy to help! Feel free to ask me anything about reproductive health, cycle tracking, or using the app.",
        "Anytime! Remember, consistent tracking leads to better insights and predictions. Keep up the great work!",
      ];
      return thanks[math.Random().nextInt(thanks.length)];
    }
  }

  String _getContextualResponse(String message) {
    final responses = [
      "That's an interesting question! 🤔 Can you provide more details? I'd love to help you understand your reproductive health better.",
      "I want to make sure I give you the most helpful response. Could you elaborate on what specific aspect you're curious about?",
      "Great question! Reproductive health is complex and individual. What specific information would be most helpful for your situation?",
      "I'm here to help with all aspects of menstrual and reproductive health. Feel free to ask about periods, symptoms, predictions, or general wellness!",
      "Every person's experience is unique! 🌸 The more specific you can be about your question, the better I can tailor my advice to your needs.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  /// Get suggested quick replies based on conversation context
  List<String> getSuggestedReplies() {
    // Get personalized suggestions based on conversation history
    final personalizedSuggestions = _conversationMemory.getPersonalizedSuggestions();
    
    // If we have personalized suggestions, use them
    if (personalizedSuggestions.isNotEmpty) {
      return personalizedSuggestions;
    }
    
    // Otherwise, fallback to default suggestions
    final suggestions = [
      "When will my next period start?",
      "How do I track symptoms?",
      "What causes PMS?",
      "Help with fertility tracking",
      "Exercise during period",
      "Understanding my cycle",
      "Irregular periods",
      "Managing cramps",
    ];
    
    // Return 3-4 random suggestions
    final shuffled = List<String>.from(suggestions)..shuffle();
    return shuffled.take(4).toList();
  }

  /// Clear conversation history
  Future<void> clearMessages() async {
    _messages.clear();
    _notifyListeners();
    
    // Clear conversation memory
    await _conversationMemory.clearMemory();
    
    // Re-add welcome message
    await _addAIMessage(
      "Hello again! 👋 I'm ready to help you with any questions about your reproductive health and cycle tracking. What can I assist you with today?"
    );
  }

  void _notifyListeners() {
    _messagesController.add(List.from(_messages));
  }

  void dispose() {
    _messagesController.close();
  }

  /// Get current user for message composition
  types.User get currentUser => _currentUser;
  
  /// Get memory statistics for debugging
  Map<String, dynamic> getMemoryStats() {
    return _conversationMemory.getMemoryStats();
  }
  
  /// Store a personalized insight about the user
  Future<void> storePersonalizedInsight(String key, String insight) async {
    await _conversationMemory.storePersonalizedInsight(key, insight);
  }
  
  /// Get a personalized insight about the user
  String? getPersonalizedInsight(String key) {
    return _conversationMemory.getPersonalizedInsight(key);
  }
}
