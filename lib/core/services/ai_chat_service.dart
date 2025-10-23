import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import 'dart:async';

import 'ai_conversation_memory.dart';
import 'flowai_service.dart';
import '../config/flowiq_config.dart';
import '../../generated/app_localizations.dart';
import '../../generated/app_localizations_extensions.dart';

/// AI Chat Service for real-time health conversations
class AIChatService {
  static final AIChatService _instance = AIChatService._internal();
  factory AIChatService() => _instance;
  AIChatService._internal();

  final List<types.Message> _messages = [];
  final StreamController<List<types.Message>> _messagesController = StreamController<List<types.Message>>.broadcast();
  final Uuid _uuid = const Uuid();
  
  // AI User representation
  types.User? _aiUser;
  types.User? _currentUser;
  AIConversationMemory? _conversationMemory;
  bool _isInitialized = false;
  AppLocalizations? _localizations;
  
  // FlowAI Integration
  final FlowAIService _flowAIService = FlowAIService();
  bool _useFlowAI = false;

  Stream<List<types.Message>> get messagesStream => _messagesController.stream;
  List<types.Message> get messages => List.unmodifiable(_messages);

  Future<void> initialize({required String userId, required String userName, AppLocalizations? localizations, String? flowAIApiKey}) async {
    if (_isInitialized) return;
    
    _localizations = localizations;
    
    _currentUser = types.User(
      id: userId,
      firstName: userName,
    );

    _aiUser = types.User(
      id: 'ai_flowai',
      firstName: 'Mira',
      lastName: 'AI',
      imageUrl: 'https://i.pravatar.cc/300?img=47', // AI avatar
    );
    
    // Initialize FlowAI if API key is provided
    if (flowAIApiKey != null && flowAIApiKey.isNotEmpty) {
      try {
        await _initializeFlowAI(flowAIApiKey);
      } catch (e) {
        debugPrint('FlowAI initialization failed, using fallback responses: $e');
      }
    } else if (FlowIQConfig.isConfigured) {
      try {
        await _initializeFlowAI(FlowIQConfig.apiKey!);
      } catch (e) {
        debugPrint('FlowAI initialization failed, using fallback responses: $e');
      }
    }
    
    // Initialize conversation memory with user ID for data isolation
    _conversationMemory = AIConversationMemory();
    await _conversationMemory?.initialize(userId: userId);
    
    // Clear any existing conversation history to ensure clean state
    await _conversationMemory?.clearMemory();
    _messages.clear();
    
    // Always add fresh welcome message with updated name
    _addAIMessage(
      "Hi $userName! 👋 I'm Mira, your AI assistant. I'm here to help you understand your cycle, provide personalized health insights, and answer any questions about reproductive wellness. How can I help you today?"
    );
    
    _isInitialized = true;
  }

  /// Send user message and get AI response
  Future<void> sendMessage(types.TextMessage message) async {
    // Add user message
    _messages.insert(0, message);
    _notifyListeners();
    
    // Store in conversation memory
    await _conversationMemory?.storeMessage(message);

    // Simulate typing delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Generate AI response with context
    final contextPrompt = _conversationMemory?.getContextualPrompt(message.text);
    final response = await _generateAIResponse(message.text, contextPrompt: contextPrompt);
    _addAIMessage(response);
  }

  /// Add AI message to conversation
  Future<void> _addAIMessage(String text) async {
    if (_aiUser == null) return;
    
    final aiMessage = types.TextMessage(
      author: _aiUser!,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: _uuid.v4(),
      text: text,
    );

    _messages.insert(0, aiMessage);
    _notifyListeners();
    
    // Store in conversation memory
    await _conversationMemory?.storeMessage(aiMessage);
  }

  /// Generate contextual AI response based on user input
  Future<String> _generateAIResponse(String userMessage, {String? contextPrompt}) async {
    // Try FlowAI first if available
    if (_useFlowAI && _currentUser != null) {
      try {
        final flowAIResponse = await _getFlowAIResponse(userMessage, contextPrompt);
        if (flowAIResponse != null && flowAIResponse.isNotEmpty) {
          return flowAIResponse;
        }
      } catch (e) {
        debugPrint('FlowAI request failed, falling back to local responses: $e');
      }
    }
    
    // Fallback to local responses
    return _getLocalAIResponse(userMessage, contextPrompt: contextPrompt);
  }
  
  /// Generate local AI response (fallback when FlowAI is unavailable)
  Future<String> _getLocalAIResponse(String userMessage, {String? contextPrompt}) async {
    final lowerMessage = userMessage.toLowerCase();
    
    // Use conversation context for more personalized responses
    if (contextPrompt != null && contextPrompt.isNotEmpty) {
      debugPrint('Using context for response: $contextPrompt');
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

    // Name-related questions
    if (lowerMessage.contains('name') || lowerMessage.contains('call you') || lowerMessage.contains('who are you')) {
      return _getNameResponse(lowerMessage);
    }
    
    // Date and time questions
    if (lowerMessage.contains('date') || lowerMessage.contains('today') || lowerMessage.contains('time') || lowerMessage.contains('what day')) {
      return _getDateTimeResponse(lowerMessage);
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
      _localizations?.aiPeriodResponse1 ?? "I can help you track your menstrual cycle! 🩸 When did your last period start? You can log this in the Period Tracker section, and I'll help predict your next cycle.",
      _localizations?.aiPeriodResponse2 ?? "Understanding your period patterns is key to reproductive health. The average cycle is 21-35 days. Have you noticed any changes in your cycle lately?",
      _localizations?.aiPeriodResponse3 ?? "Period tracking helps identify patterns in flow intensity, duration, and symptoms. Would you like me to guide you through logging your current period?",
      _localizations?.aiPeriodResponse4 ?? "Irregular periods can be influenced by stress, diet, exercise, or hormonal changes. If you're concerned about irregularities, consider consulting with a healthcare provider.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getMoodPMSResponse(String message) {
    final responses = [
      _localizations?.aiMoodResponse1 ?? "PMS affects up to 85% of menstruating people. 💭 Tracking mood changes can help identify patterns. Are you experiencing mood swings, irritability, or anxiety?",
      _localizations?.aiMoodResponse2 ?? "Mood fluctuations during your cycle are completely normal due to hormonal changes. Try logging your daily mood to see patterns emerge over time.",
      _localizations?.aiMoodResponse3 ?? "For PMS symptoms, consider: gentle exercise, adequate sleep, reducing caffeine, and stress management techniques. What symptoms are you experiencing?",
      _localizations?.aiMoodResponse4 ?? "Cramps and mood changes often peak 1-2 days before your period. Heat therapy, gentle stretching, and staying hydrated can help manage discomfort.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getFertilityResponse(String message) {
    final responses = [
      _localizations?.aiFertilityResponse1 ?? "Ovulation typically occurs 14 days before your next period. 🥚 Are you tracking fertility to conceive or for natural family planning?",
      _localizations?.aiFertilityResponse2 ?? "Your fertile window is usually 5 days before ovulation and the day of ovulation. Tracking basal body temperature and cervical mucus can help identify this window.",
      _localizations?.aiFertilityResponse3 ?? "Fertility awareness involves understanding your body's natural signs. Would you like me to explain the different fertility tracking methods?",
      _localizations?.aiFertilityResponse4 ?? "If you're trying to conceive, focus on the fertile window. If preventing pregnancy, remember that natural methods require consistency and education.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getSymptomsResponse(String message) {
    final responses = [
      _localizations?.aiSymptomsResponse1 ?? "Tracking symptoms helps identify patterns and potential triggers. 📊 What symptoms are you experiencing? I can help you log them properly.",
      _localizations?.aiSymptomsResponse2 ?? "Common cycle-related symptoms include bloating, breast tenderness, headaches, and fatigue. Are these new symptoms or part of your regular pattern?",
      _localizations?.aiSymptomsResponse3 ?? "Severe or unusual symptoms should be discussed with a healthcare provider. I can help you prepare questions and track symptoms to share with them.",
      _localizations?.aiSymptomsResponse4 ?? "Pain management techniques include heat therapy, gentle exercise, anti-inflammatory medications, and relaxation techniques. What type of pain are you experiencing?",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getHealthWellnessResponse(String message) {
    final responses = [
      _localizations?.aiHealthResponse1 ?? "A balanced lifestyle supports menstrual health! 🌟 Regular exercise, adequate sleep, stress management, and proper nutrition all play important roles.",
      _localizations?.aiHealthResponse2 ?? "Exercise can help reduce PMS symptoms and regulate cycles. Low-impact activities like walking, yoga, and swimming are excellent choices during your cycle.",
      _localizations?.aiHealthResponse3 ?? "Nutrition during your cycle: focus on iron-rich foods, complex carbohydrates, and staying hydrated. Limit caffeine and alcohol if they worsen symptoms.",
      _localizations?.aiHealthResponse4 ?? "Stress significantly impacts menstrual health. Consider meditation, deep breathing exercises, or other stress-reduction techniques that work for you.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getAppUsageResponse(String message) {
    final responses = [
      _localizations?.aiAppUsageResponse1 ?? "Great question! 📱 To track your period: go to Period Tracker → tap the calendar → select start date → log flow intensity and symptoms daily.",
      _localizations?.aiAppUsageResponse2 ?? "The AI Insights section provides personalized analysis based on your tracking data. The more you log, the more accurate your insights become!",
      _localizations?.aiAppUsageResponse3 ?? "You can log symptoms in the Symptoms section, track mood and energy levels, and even add notes about your daily experiences.",
      _localizations?.aiAppUsageResponse4 ?? "For predictions: ensure you've logged at least 2-3 complete cycles for accurate forecasting. The AI learns from your patterns to make better predictions.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getPredictionResponse(String message) {
    final responses = [
      _localizations?.aiPredictionResponse1 ?? "Cycle predictions become more accurate with consistent tracking! 🔮 Based on your historical data, I can predict your next period with 85-95% accuracy.",
      _localizations?.aiPredictionResponse2 ?? "Your next period prediction is based on your average cycle length and recent patterns. Have you noticed any factors that might affect your cycle timing?",
      _localizations?.aiPredictionResponse3 ?? "Predictions consider cycle length, symptoms, and hormonal patterns. Factors like stress, travel, illness, or lifestyle changes can affect timing.",
      _localizations?.aiPredictionResponse4 ?? "For the most accurate predictions, log your period start and end dates consistently. I'll analyze patterns and provide increasingly accurate forecasts.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getGeneralResponse(String message) {
    if (message.contains('hi') || message.contains('hello')) {
      final greetings = [
        _localizations?.aiGreetingHello1 ?? "Hello! 😊 How can I help you with your reproductive health today?",
        _localizations?.aiGreetingHello2 ?? "Hi there! I'm here to support your menstrual health journey. What would you like to know?",
        _localizations?.aiGreetingHello3 ?? "Welcome back! Ready to dive into some health insights or track your cycle?",
      ];
      return greetings[math.Random().nextInt(greetings.length)];
    } else {
      final thanks = [
        _localizations?.aiGreetingThanks1 ?? "You're very welcome! 💕 I'm always here to help with your health questions and cycle tracking needs.",
        _localizations?.aiGreetingThanks2 ?? "Happy to help! Feel free to ask me anything about reproductive health, cycle tracking, or using the app.",
        _localizations?.aiGreetingThanks3 ?? "Anytime! Remember, consistent tracking leads to better insights and predictions. Keep up the great work!",
      ];
      return thanks[math.Random().nextInt(thanks.length)];
    }
  }

  String _getNameResponse(String message) {
    final responses = [
      "Hi! I'm Mira ✨ Your personal AI assistant. I'm here to help you with all things related to your reproductive health and cycle tracking!",
      "You can call me Mira! 🌟 I'm your dedicated AI health companion, ready to support you on your wellness journey.",
      "I'm Mira, your AI assistant! 💫 Think of me as your personal health guide - I'm always here to help answer your questions about cycles, symptoms, and reproductive wellness.",
      "Nice to meet you! I'm Mira ⭐ I'm specifically designed to help you understand and track your menstrual health. What would you like to know?",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }
  
  String _getDateTimeResponse(String message) {
    final now = DateTime.now();
    final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final months = ['January', 'February', 'March', 'April', 'May', 'June', 
                   'July', 'August', 'September', 'October', 'November', 'December'];
    
    final dayName = weekdays[now.weekday - 1];
    final monthName = months[now.month - 1];
    final day = now.day;
    final year = now.year;
    
    final responses = [
      "📅 Today is $dayName, $monthName $day, $year! Perfect day for tracking your health data. How are you feeling today?",
      "Today's date is $monthName $day, $year ($dayName). 🗓️ This is great timing to log any symptoms or cycle updates!",
      "It's $dayName, $monthName $day, $year today! ✨ A good day to check in with your body and track how you're feeling.",
      "Today is $monthName $day, $year - that's a $dayName! 🌟 Want to log any cycle data or symptoms for today?",
    ];
    
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getContextualResponse(String message) {
    final responses = [
      _localizations?.aiContextualResponse1 ?? "That's an interesting question! 🤔 Can you provide more details? I'd love to help you understand your reproductive health better.",
      _localizations?.aiContextualResponse2 ?? "I want to make sure I give you the most helpful response. Could you elaborate on what specific aspect you're curious about?",
      _localizations?.aiContextualResponse3 ?? "Great question! Reproductive health is complex and individual. What specific information would be most helpful for your situation?",
      _localizations?.aiContextualResponse4 ?? "I'm here to help with all aspects of menstrual and reproductive health. Feel free to ask about periods, symptoms, predictions, or general wellness!",
      _localizations?.aiContextualResponse5 ?? "Every person's experience is unique! 🌸 The more specific you can be about your question, the better I can tailor my advice to your needs.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  /// Get suggested quick replies based on conversation context
  List<String> getSuggestedReplies() {
    // Get personalized suggestions based on conversation history
    final personalizedSuggestions = _conversationMemory?.getPersonalizedSuggestions() ?? [];
    
    // If we have personalized suggestions, use them
    if (personalizedSuggestions.isNotEmpty) {
      return personalizedSuggestions;
    }
    
    // Enhanced suggestion categories for better user experience
    final timeBasedSuggestions = _getTimeBasedSuggestions();
    final contextualSuggestions = _getContextualSuggestions();
    final educationalSuggestions = _getEducationalSuggestions();
    final healthSuggestions = _getHealthSuggestions();
    
    // Combine suggestions from different categories
    final allSuggestions = [
      ...timeBasedSuggestions,
      ...contextualSuggestions,
      ...educationalSuggestions,
      ...healthSuggestions,
    ];
    
    // Return 6-8 diverse suggestions
    final shuffled = List<String>.from(allSuggestions)..shuffle();
    return shuffled.take(8).toList();
  }
  
  /// Get time-based contextual suggestions
  List<String> _getTimeBasedSuggestions() {
    final hour = DateTime.now().hour;
    
    if (hour >= 6 && hour < 12) {
      // Morning suggestions
      return [
        "How am I feeling this morning?",
        "Should I exercise during my period?",
        "What's my cycle status today?",
        "Best breakfast for my cycle phase?",
      ];
    } else if (hour >= 12 && hour < 17) {
      // Afternoon suggestions
      return [
        "Managing afternoon fatigue during cycle",
        "Healthy snacks for PMS cravings",
        "When should I expect my next period?",
        "Tracking my energy levels",
      ];
    } else {
      // Evening suggestions
      return [
        "How to improve sleep during my cycle?",
        "Evening self-care for PMS",
        "Reflecting on today's symptoms",
        "Relaxation techniques for cramps",
      ];
    }
  }
  
  /// Get contextual suggestions based on app usage patterns
  List<String> _getContextualSuggestions() {
    return [
      "When will my next period start?",
      "How do I track symptoms effectively?",
      "What causes irregular periods?",
      "Help with fertility tracking",
      "Understanding my cycle patterns",
      "Managing PMS symptoms naturally",
      "Why am I having mood swings?",
      "Is my cycle length normal?",
      "How to predict ovulation?",
      "Dealing with period pain",
      "What affects cycle regularity?",
      "Signs of hormonal imbalance",
    ];
  }
  
  /// Get educational suggestions for learning
  List<String> _getEducationalSuggestions() {
    return [
      "Explain the menstrual cycle phases",
      "What happens during ovulation?",
      "Understanding fertility windows",
      "How hormones affect my mood",
      "Why do I get cramps?",
      "What is a normal flow?",
      "Difference between PMS and PMDD",
      "How stress affects my cycle",
      "Nutrition for menstrual health",
      "Exercise recommendations by cycle phase",
      "Natural remedies for period symptoms",
      "When to see a healthcare provider",
      "Birth control effects on cycles",
      "Perimenopause and cycle changes",
    ];
  }
  
  /// Get health and wellness suggestions
  List<String> _getHealthSuggestions() {
    return [
      "Best foods for iron deficiency",
      "Yoga poses for menstrual cramps",
      "How to track basal body temperature",
      "Managing heavy periods naturally",
      "Supplements for menstrual health",
      "Hydration during menstruation",
      "Sleep tips for better cycles",
      "Stress reduction techniques",
      "Essential oils for PMS relief",
      "Heat therapy vs cold therapy",
      "Mindfulness for cycle awareness",
      "Building healthy cycle habits",
      "Environmental factors affecting cycles",
      "Travel and menstrual cycle changes",
    ];
  }

  /// Clear conversation history
  Future<void> clearMessages() async {
    _messages.clear();
    _notifyListeners();
    
    // Clear conversation memory
    await _conversationMemory?.clearMemory();
    
    // Re-add welcome message
    await _addAIMessage(
      _localizations?.aiWelcomeBack ?? "Hello again! 👋 I'm ready to help you with any questions about your reproductive health and cycle tracking. What can I assist you with today?"
    );
  }

  void _notifyListeners() {
    _messagesController.add(List.from(_messages));
  }

  void dispose() {
    _messagesController.close();
  }

  /// Get current user for message composition
  types.User? get currentUser => _currentUser;
  
  /// Get memory statistics for debugging
  Map<String, dynamic> getMemoryStats() {
    return _conversationMemory?.getMemoryStats() ?? {};
  }
  
  /// Store a personalized insight about the user
  Future<void> storePersonalizedInsight(String key, String insight) async {
    await _conversationMemory?.storePersonalizedInsight(key, insight);
  }
  
  /// Get a personalized insight about the user
  String? getPersonalizedInsight(String key) {
    return _conversationMemory?.getPersonalizedInsight(key);
  }
  
  // FlowAI Integration Methods
  
  /// Initialize FlowAI service
  Future<void> _initializeFlowAI(String apiKey) async {
    try {
      await _flowAIService.initialize(apiKey: apiKey);
      _useFlowAI = _flowAIService.isInitialized;
      debugPrint('🤖 FlowAI integration ${_useFlowAI ? "enabled" : "failed"}');
    } catch (e) {
      debugPrint('FlowAI initialization error: $e');
      _useFlowAI = false;
    }
  }
  
  /// Get response from FlowAI service
  Future<String?> _getFlowAIResponse(String userMessage, String? contextPrompt) async {
    if (!_useFlowAI || _currentUser == null) return null;
    
    try {
      // Build context from conversation memory and cycle data
      final healthContext = _buildHealthContext(contextPrompt);
      
      final response = await _flowAIService.sendHealthChatMessage(
        message: userMessage,
        userId: _currentUser!.id,
        cycleData: _getCycleContextData(),
        recentSymptoms: _getRecentSymptoms(),
        currentPhase: _getCurrentCyclePhase(),
      );
      
      return response.content;
    } on FlowAIException catch (e) {
      debugPrint('FlowAI service error: $e');
      return null;
    } catch (e) {
      debugPrint('Unexpected FlowAI error: $e');
      return null;
    }
  }
  
  /// Build health context for FlowAI
  String? _buildHealthContext(String? conversationContext) {
    final contextParts = <String>[];
    
    if (conversationContext != null && conversationContext.isNotEmpty) {
      contextParts.add('Previous conversation: $conversationContext');
    }
    
    // Add personalized insights from memory
    final personalizedInsights = _conversationMemory?.getPersonalizedInsights() ?? {};
    if (personalizedInsights.isNotEmpty) {
      final insightsText = personalizedInsights.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      contextParts.add('User insights: $insightsText');
    }
    
    return contextParts.isNotEmpty ? contextParts.join('; ') : null;
  }
  
  /// Get cycle context data for FlowAI
  Map<String, dynamic>? _getCycleContextData() {
    // This would be populated with actual cycle data from the app
    // For now, return null as we don't have access to cycle data here
    return null;
  }
  
  /// Get recent symptoms for FlowAI context
  List<String>? _getRecentSymptoms() {
    // This would be populated with recent symptom data
    // For now, return null as we don't have access to symptom data here
    return null;
  }
  
  /// Get current cycle phase for FlowAI context
  String? _getCurrentCyclePhase() {
    // This would be calculated based on current cycle data
    // For now, return null as we don't have access to cycle data here
    return null;
  }
  
  /// Generate AI insights using FlowAI
  Future<String?> generateFlowAIInsights({
    required Map<String, dynamic> cycleAnalysis,
    List<String>? patterns,
  }) async {
    if (!_useFlowAI || _currentUser == null) return null;
    
    try {
      final response = await _flowAIService.generateInsights(
        userId: _currentUser!.id,
        cycleAnalysis: cycleAnalysis,
        patterns: patterns,
      );
      
      return response.content;
    } catch (e) {
      debugPrint('FlowAI insights generation failed: $e');
      return null;
    }
  }
  
  /// Check if FlowAI is available and working
  bool get isFlowAIEnabled => _useFlowAI && _flowAIService.isInitialized;
  
  /// Get FlowAI service status
  String get aiServiceStatus {
    if (!_isInitialized) return 'Not initialized';
    if (_useFlowAI && _flowAIService.isInitialized) return 'FlowAI enabled';
    return 'Local responses only';
  }
}
