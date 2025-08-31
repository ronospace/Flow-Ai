import 'package:flutter/material.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:uuid/uuid.dart';
import 'dart:math' as math;
import 'dart:async';

import 'ai_conversation_memory.dart';
import 'flowai_service.dart';
import '../config/flowai_config.dart';
import '../../generated/app_localizations.dart';

/// Enhanced AI Chat Service with comprehensive FAQ and general knowledge
class EnhancedAIChatService {
  static final EnhancedAIChatService _instance = EnhancedAIChatService._internal();
  factory EnhancedAIChatService() => _instance;
  EnhancedAIChatService._internal();

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

  // FAQ Knowledge Base
  final Map<String, List<FAQItem>> _faqDatabase = {
    'health': [
      FAQItem('What is a normal menstrual cycle?', 'A normal menstrual cycle is typically 21-35 days long, with menstrual flow lasting 2-7 days. The average cycle length is 28 days.'),
      FAQItem('What causes irregular periods?', 'Irregular periods can be caused by stress, significant weight changes, hormonal imbalances, certain medications, underlying health conditions, or lifestyle factors.'),
      FAQItem('How can I track my fertility?', 'You can track fertility by monitoring your menstrual cycle, basal body temperature, cervical mucus changes, and using ovulation prediction kits.'),
      FAQItem('What are common PMS symptoms?', 'Common PMS symptoms include mood swings, bloating, breast tenderness, headaches, fatigue, food cravings, and irritability.'),
      FAQItem('When should I see a doctor about my period?', 'See a doctor if you have severe pain, very heavy bleeding, periods lasting longer than 7 days, or if your cycle changes significantly.'),
    ],
    'general': [
      FAQItem('What is artificial intelligence?', 'Artificial Intelligence (AI) is the simulation of human intelligence in machines that are programmed to think and learn like humans.'),
      FAQItem('How does machine learning work?', 'Machine learning is a subset of AI where computers learn to make predictions or decisions by finding patterns in data without being explicitly programmed.'),
      FAQItem('What is the difference between weather and climate?', 'Weather refers to short-term atmospheric conditions, while climate is the long-term average of weather patterns in a region over many years.'),
      FAQItem('How do vaccines work?', 'Vaccines work by training your immune system to recognize and fight specific diseases by exposing it to a safe version of the virus or bacteria.'),
      FAQItem('What causes seasons?', 'Seasons are caused by the tilt of Earth\'s axis as it orbits the sun, creating different amounts of sunlight in different parts of the world throughout the year.'),
    ],
    'technology': [
      FAQItem('What is cloud computing?', 'Cloud computing is the delivery of computing services like servers, storage, databases, and software over the internet (the cloud).'),
      FAQItem('How does GPS work?', 'GPS works using a network of satellites that send signals to GPS receivers, which calculate location based on the time it takes to receive signals from multiple satellites.'),
      FAQItem('What is cryptocurrency?', 'Cryptocurrency is a digital currency that uses cryptography for security and operates independently of traditional banks and governments.'),
      FAQItem('How do smartphones work?', 'Smartphones combine cellular communication, computing capabilities, and internet connectivity to provide a portable communication and computing device.'),
      FAQItem('What is the internet of things?', 'The Internet of Things (IoT) refers to the network of physical devices connected to the internet that can collect and share data.'),
    ],
    'science': [
      FAQItem('What is DNA?', 'DNA (Deoxyribonucleic acid) is the molecule that carries genetic information in all living things, determining inherited traits.'),
      FAQItem('How does photosynthesis work?', 'Photosynthesis is the process plants use to convert sunlight, carbon dioxide, and water into glucose and oxygen.'),
      FAQItem('What is gravity?', 'Gravity is a fundamental force that attracts objects with mass toward each other, keeping us on Earth and planets in orbit around the sun.'),
      FAQItem('Why is the sky blue?', 'The sky appears blue because when sunlight enters Earth\'s atmosphere, blue light is scattered more than other colors due to its shorter wavelength.'),
      FAQItem('What are black holes?', 'Black holes are extremely dense regions in space where gravity is so strong that nothing, not even light, can escape once it crosses the event horizon.'),
    ],
    'lifestyle': [
      FAQItem('How much sleep do I need?', 'Most adults need 7-9 hours of sleep per night for optimal health and well-being.'),
      FAQItem('What is a balanced diet?', 'A balanced diet includes a variety of foods from all food groups: fruits, vegetables, whole grains, lean proteins, and healthy fats.'),
      FAQItem('How much water should I drink daily?', 'The general recommendation is about 8 cups (64 ounces) of water per day, but individual needs vary based on activity level and climate.'),
      FAQItem('What are the benefits of exercise?', 'Regular exercise improves cardiovascular health, strengthens muscles and bones, boosts mood, helps with weight management, and reduces disease risk.'),
      FAQItem('How can I manage stress?', 'Effective stress management techniques include regular exercise, adequate sleep, meditation, deep breathing, time management, and social support.'),
    ]
  };

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
      id: 'ai_flowai_enhanced',
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
    } else if (FlowAIConfig.isConfigured) {
      try {
        await _initializeFlowAI(FlowAIConfig.apiKey!);
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
    
    // Add enhanced welcome message
    _addAIMessage(
      "Hi ${userName}! 👋 I'm Mira, your enhanced AI assistant. I can help you with:\n\n🩸 Reproductive health & cycle tracking\n💡 General knowledge & science\n🔬 Technology & lifestyle questions\n❓ FAQs on various topics\n\nWhat would you like to explore today?"
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
    final response = await _generateEnhancedAIResponse(message.text, contextPrompt: contextPrompt);
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

  /// Generate enhanced AI response with comprehensive knowledge
  Future<String> _generateEnhancedAIResponse(String userMessage, {String? contextPrompt}) async {
    // Try FlowAI first if available
    if (_useFlowAI && _currentUser != null) {
      try {
        final flowAIResponse = await _getFlowAIResponse(userMessage, contextPrompt);
        if (flowAIResponse != null && flowAIResponse.isNotEmpty) {
          return flowAIResponse;
        }
      } catch (e) {
        debugPrint('FlowAI request failed, falling back to enhanced local responses: $e');
      }
    }
    
    // Enhanced fallback responses with comprehensive knowledge
    return _getEnhancedLocalResponse(userMessage, contextPrompt: contextPrompt);
  }
  
  /// Generate enhanced local AI response with comprehensive knowledge
  Future<String> _getEnhancedLocalResponse(String userMessage, {String? contextPrompt}) async {
    final lowerMessage = userMessage.toLowerCase();
    
    // Analyze context and user patterns for more personalized responses
    final conversationHistory = _conversationMemory?.getRelevantContext() ?? [];
    final personalizedInsights = _conversationMemory?.getPersonalizedInsights() ?? {};
    
    // Check FAQ database first with enhanced matching
    final faqResponse = _searchFAQDatabase(lowerMessage);
    if (faqResponse != null) {
      return _enhanceResponseWithContext(faqResponse, contextPrompt, personalizedInsights);
    }
    
    // Enhanced topic detection with context awareness
    String baseResponse;
    
    // Health and cycle related responses (priority for this app)
    if (_isHealthRelated(lowerMessage)) {
      baseResponse = _getHealthResponse(lowerMessage);
    }
    // Technology questions with contextual depth
    else if (_isTechnologyRelated(lowerMessage)) {
      baseResponse = _getTechnologyResponse(lowerMessage);
    }
    // Science questions with educational value
    else if (_isScienceRelated(lowerMessage)) {
      baseResponse = _getScienceResponse(lowerMessage);
    }
    // Lifestyle questions with practical advice
    else if (_isLifestyleRelated(lowerMessage)) {
      baseResponse = _getLifestyleResponse(lowerMessage);
    }
    // Math and calculations with examples
    else if (_isMathRelated(lowerMessage)) {
      baseResponse = _getMathResponse(lowerMessage);
    }
    // Current events and general knowledge
    else if (_isGeneralKnowledgeRelated(lowerMessage)) {
      baseResponse = _getGeneralKnowledgeResponse(lowerMessage);
    }
    // Entertainment and fun facts
    else if (_isEntertainmentRelated(lowerMessage)) {
      baseResponse = _getEntertainmentResponse(lowerMessage);
    }
    // Greetings and personal questions with memory
    else if (_isPersonalRelated(lowerMessage)) {
      baseResponse = _getPersonalResponseWithMemory(lowerMessage, conversationHistory);
    }
    // App usage and features
    else if (_isAppRelated(lowerMessage)) {
      baseResponse = _getAppResponse(lowerMessage);
    }
    // Enhanced default response with intelligent analysis
    else {
      baseResponse = _getIntelligentDefaultResponse(lowerMessage, conversationHistory);
    }
    
    // Apply contextual enhancement to all responses
    return _enhanceResponseWithContext(baseResponse, contextPrompt, personalizedInsights);
  }

  // FAQ Database search
  String? _searchFAQDatabase(String query) {
    final keywords = query.split(' ');
    
    for (final category in _faqDatabase.keys) {
      final faqs = _faqDatabase[category]!;
      
      for (final faq in faqs) {
        // Check if question matches closely
        if (_calculateSimilarity(query, faq.question.toLowerCase()) > 0.6) {
          return "${faq.answer}\n\n💡 This is from my ${category} knowledge base. Feel free to ask follow-up questions!";
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
    final healthKeywords = ['period', 'menstruation', 'cycle', 'ovulation', 'fertility', 'pms', 'cramps', 
                            'symptoms', 'pain', 'bloating', 'mood', 'hormone', 'pregnancy', 'contraception'];
    return healthKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isTechnologyRelated(String message) {
    final techKeywords = ['computer', 'smartphone', 'internet', 'wifi', 'bluetooth', 'app', 'software', 
                          'hardware', 'ai', 'artificial intelligence', 'machine learning', 'cloud', 'bitcoin'];
    return techKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isScienceRelated(String message) {
    final scienceKeywords = ['science', 'physics', 'chemistry', 'biology', 'dna', 'atoms', 'gravity', 
                            'photosynthesis', 'evolution', 'space', 'planets', 'solar system'];
    return scienceKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isLifestyleRelated(String message) {
    final lifestyleKeywords = ['diet', 'exercise', 'sleep', 'nutrition', 'fitness', 'meditation', 
                              'stress', 'wellness', 'health', 'lifestyle', 'habits'];
    return lifestyleKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isMathRelated(String message) {
    final mathKeywords = ['calculate', 'math', 'mathematics', 'equation', 'formula', 'percentage', 
                          'statistics', 'probability', 'geometry', 'algebra'];
    return mathKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isGeneralKnowledgeRelated(String message) {
    final generalKeywords = ['history', 'geography', 'culture', 'language', 'country', 'capital', 
                            'population', 'economy', 'politics', 'current events'];
    return generalKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isEntertainmentRelated(String message) {
    final entertainmentKeywords = ['movie', 'music', 'book', 'game', 'sport', 'celebrity', 
                                  'entertainment', 'fun fact', 'trivia', 'joke'];
    return entertainmentKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isPersonalRelated(String message) {
    final personalKeywords = ['who are you', 'your name', 'about you', 'hello', 'hi', 'thank', 
                             'how are you', 'what can you do', 'help me'];
    return personalKeywords.any((keyword) => message.contains(keyword));
  }

  bool _isAppRelated(String message) {
    final appKeywords = ['app', 'track', 'log', 'feature', 'how to use', 'navigation', 'settings'];
    return appKeywords.any((keyword) => message.contains(keyword));
  }

  // Response generators for different topics
  String _getHealthResponse(String message) {
    final responses = [
      "Great health question! 🏥 ${_getRandomHealthFact()} Would you like specific guidance on tracking this in the app?",
      "I'm here to help with your reproductive health! 💖 ${_getRandomHealthTip()} What specific aspect would you like to explore?",
      "Health is so important! 🌟 ${_getRandomHealthInsight()} Feel free to ask more detailed questions.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getTechnologyResponse(String message) {
    final responses = [
      "Technology is fascinating! 💻 ${_getRandomTechFact()} I can explain more about how this works if you're interested.",
      "Great tech question! 🚀 ${_getRandomTechInsight()} Would you like me to break this down further?",
      "I love discussing technology! ⚡ ${_getRandomTechTip()} What specific aspect interests you most?",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getScienceResponse(String message) {
    final responses = [
      "Science is amazing! 🔬 ${_getRandomScienceFact()} The natural world is full of incredible phenomena.",
      "Excellent scientific question! 🧪 ${_getRandomScienceInsight()} Science helps us understand our world better.",
      "I enjoy exploring scientific topics! 🌟 ${_getRandomScienceExplanation()} Would you like to dive deeper?",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getLifestyleResponse(String message) {
    final responses = [
      "Lifestyle choices matter so much! 🌱 ${_getRandomLifestyleTip()} Small changes can make big differences.",
      "Great wellness question! 💪 ${_getRandomWellnessFact()} Taking care of yourself is so important.",
      "I love discussing healthy living! ✨ ${_getRandomLifestyleInsight()} What area would you like to focus on?",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getMathResponse(String message) {
    final responses = [
      "Math is everywhere! 📊 ${_getRandomMathFact()} Numbers and patterns help us understand the world.",
      "Mathematical thinking is powerful! 🧮 ${_getRandomMathInsight()} I can help with calculations if needed.",
      "I enjoy mathematical questions! ➕ ${_getRandomMathTip()} Math makes many things possible.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getGeneralKnowledgeResponse(String message) {
    final responses = [
      "The world is full of interesting facts! 🌍 ${_getRandomWorldFact()} There's so much to learn about our planet.",
      "Great question about the world! 📚 ${_getRandomKnowledgeFact()} Learning never stops being exciting.",
      "I love sharing knowledge! 🎓 ${_getRandomEducationalFact()} What else would you like to explore?",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getEntertainmentResponse(String message) {
    final responses = [
      "Let's have some fun! 🎉 ${_getRandomFunFact()} Life should have moments of joy and wonder.",
      "Entertainment and fun are important! 🎭 ${_getRandomEntertainmentFact()} What brings you joy?",
      "I enjoy lighter topics too! 😊 ${_getRandomTrivia()} Sometimes we need a break from serious stuff.",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getPersonalResponse(String message) {
    if (message.contains('who are you') || message.contains('about you')) {
      return "I'm Mira, your enhanced AI assistant! ✨ I'm designed to help with reproductive health tracking, but I also love discussing science, technology, lifestyle, and general knowledge. I'm here to learn with you and provide helpful information on almost any topic. What would you like to explore together?";
    } else if (message.contains('hello') || message.contains('hi')) {
      return "Hello! 👋 I'm excited to chat with you today. I can help with cycle tracking, answer health questions, discuss science and technology, share interesting facts, or just have a friendly conversation. What's on your mind?";
    } else if (message.contains('thank')) {
      return "You're so welcome! 💕 I genuinely enjoy helping and learning together. Whether it's health questions, curious facts, or just chatting - I'm here for it all. Feel free to ask me anything!";
    } else {
      return "I'm here and ready to help! 😊 As your AI companion, I can discuss health topics, answer questions about science and technology, share interesting facts, or help you navigate the app. What would you like to explore?";
    }
  }

  String _getAppResponse(String message) {
    final responses = [
      "I'd love to help you with the app! 📱 You can track your cycle, log symptoms, view insights, and much more. What specific feature would you like to learn about?",
      "The app has so many helpful features! 🌟 From cycle predictions to symptom tracking to AI insights. Which area interests you most?",
      "Great question about app usage! 💡 I can guide you through tracking, explain features, or help you get the most out of your health data. What do you need help with?",
    ];
    return responses[math.Random().nextInt(responses.length)];
  }

  String _getIntelligentDefaultResponse(String message, [List<types.Message>? conversationHistory]) {
    // Attempt to provide an intelligent response even for unknown topics
    if (message.length < 3) {
      return "I'd love to help you! Could you tell me a bit more about what you're thinking about? 😊";
    }
    
    // Analyze the conversation history for more intelligent responses
    String contextualNote = "";
    if (conversationHistory != null && conversationHistory.isNotEmpty) {
      contextualNote = "\n\nI notice we've been chatting about various topics - I'm always happy to dive deeper into any subject that interests you! ";
    }
    
    final responses = [
      "That's an interesting topic! 🤔 While I might not have specific expertise in that area, I'd be happy to discuss what I know or help you think through it. Can you share more details?$contextualNote",
      "I appreciate you bringing this up! 💭 Though this might be outside my main areas of expertise, I'm always eager to learn and explore new topics with you. What specific aspect interests you most?$contextualNote",
      "You've got me curious! 🔍 Even if I don't have detailed knowledge about this particular topic, I can try to help you think about it or suggest related areas I do know about. What's your main question?$contextualNote",
      "Interesting question! 🌟 I might not be an expert on everything, but I enjoy exploring ideas together. Could you help me understand what specifically you'd like to know more about?$contextualNote",
    ];
    
    return responses[math.Random().nextInt(responses.length)];
  }

  /// Enhanced personal response with memory
  String _getPersonalResponseWithMemory(String message, List<types.Message> conversationHistory) {
    if (message.contains('who are you') || message.contains('about you')) {
      return "I'm Mira, your enhanced AI assistant! ✨ I'm designed to help with reproductive health tracking, but I also love discussing science, technology, lifestyle, and general knowledge. I remember our conversations to provide better, more personalized responses. What would you like to explore together?";
    } else if (message.contains('hello') || message.contains('hi')) {
      final greeting = conversationHistory.isEmpty 
          ? "Hello! 👋 I'm excited to meet you and chat today."
          : "Hello again! 👋 Great to continue our conversation.";
      return "$greeting I can help with cycle tracking, answer health questions, discuss science and technology, share interesting facts, or just have a friendly conversation. What's on your mind?";
    } else if (message.contains('thank')) {
      return "You're so welcome! 💕 I genuinely enjoy helping and learning together. Whether it's health questions, curious facts, or just chatting - I'm here for it all. Feel free to ask me anything!";
    } else {
      final personalNote = conversationHistory.isNotEmpty 
          ? "I remember our previous chats and I'm here to continue helping! "
          : "";
      return "${personalNote}I'm here and ready to help! 😊 As your AI companion, I can discuss health topics, answer questions about science and technology, share interesting facts, or help you navigate the app. What would you like to explore?";
    }
  }

  /// Enhance response with contextual information and personalized insights
  String _enhanceResponseWithContext(String baseResponse, String? contextPrompt, Map<String, dynamic> personalizedInsights) {
    var enhancedResponse = baseResponse;
    
    // Add contextual information if available
    if (contextPrompt != null && contextPrompt.isNotEmpty) {
      enhancedResponse += "\n\n💡 Based on our conversation, I wanted to add: This connects to what we discussed earlier about similar topics.";
    }
    
    // Add personalized insights if relevant
    if (personalizedInsights.isNotEmpty && personalizedInsights.containsKey('interests')) {
      final interests = personalizedInsights['interests'] as String? ?? '';
      if (interests.isNotEmpty) {
        enhancedResponse += "\n\n🎯 Since you're interested in $interests, you might also enjoy exploring related topics!";
      }
    }
    
    return enhancedResponse;
  }

  // Random fact generators
  String _getRandomHealthFact() {
    final facts = [
      "Did you know the average woman has about 400 menstrual cycles in her lifetime?",
      "Your basal body temperature slightly increases after ovulation due to progesterone.",
      "The menstrual cycle is controlled by a complex interaction of hormones in your body.",
      "Exercise can help reduce PMS symptoms and menstrual pain for many people.",
      "Tracking your cycle can help you understand your body's unique patterns and rhythms.",
    ];
    return facts[math.Random().nextInt(facts.length)];
  }

  String _getRandomHealthTip() {
    final tips = [
      "Staying hydrated can help reduce bloating during your cycle.",
      "Regular sleep patterns can help regulate your menstrual cycle.",
      "Magnesium supplements may help with menstrual cramps for some people.",
      "Gentle exercise like walking or yoga can ease period discomfort.",
      "Keeping a symptom diary helps identify personal patterns and triggers.",
    ];
    return tips[math.Random().nextInt(tips.length)];
  }

  String _getRandomHealthInsight() {
    final insights = [
      "Every person's cycle is unique - what's normal for you might be different from others.",
      "Hormonal changes throughout your cycle can affect mood, energy, and even food cravings.",
      "Your cycle can be influenced by stress, diet, exercise, and sleep patterns.",
      "Understanding your fertility signs can be empowering whether you're trying to conceive or avoid pregnancy.",
      "Many reproductive health concerns are common and treatable with proper medical guidance.",
    ];
    return insights[math.Random().nextInt(insights.length)];
  }

  String _getRandomTechFact() {
    final facts = [
      "The first computer bug was an actual bug - a moth found in a Harvard Mark II computer in 1947!",
      "Your smartphone has more computing power than the computers that sent humans to the moon.",
      "The internet processes over 5 billion searches on Google every single day.",
      "Artificial Intelligence can now recognize images, understand speech, and even create art.",
      "Bluetooth technology was named after a 10th-century Danish king, Harald Bluetooth.",
    ];
    return facts[math.Random().nextInt(facts.length)];
  }

  String _getRandomTechInsight() {
    final insights = [
      "Machine learning algorithms improve by analyzing patterns in large datasets.",
      "Cloud computing lets you access your data from anywhere with an internet connection.",
      "Encryption keeps your personal information safe when transmitted over the internet.",
      "Apps like this one use AI to find patterns in your health data and provide insights.",
      "The Internet of Things connects everyday objects to the internet for smarter functionality.",
    ];
    return insights[math.Random().nextInt(insights.length)];
  }

  String _getRandomTechTip() {
    final tips = [
      "Regular software updates help keep your devices secure and running smoothly.",
      "Using strong, unique passwords for each account significantly improves your digital security.",
      "Backing up your important data prevents loss if something happens to your device.",
      "Learning keyboard shortcuts can make you much more efficient with computers.",
      "Privacy settings in apps and social media give you control over your personal information.",
    ];
    return tips[math.Random().nextInt(tips.length)];
  }

  String _getRandomScienceFact() {
    final facts = [
      "Honey never spoils - archaeologists have found edible honey in ancient Egyptian tombs!",
      "A single cloud can weigh more than a million pounds, but it floats because it's less dense than dry air.",
      "Your body produces about 25 million new cells every second.",
      "Octopuses have three hearts and blue blood due to copper-based hemocyanin instead of iron.",
      "Light from the sun takes about 8 minutes and 20 seconds to reach Earth.",
    ];
    return facts[math.Random().nextInt(facts.length)];
  }

  String _getRandomScienceInsight() {
    final insights = [
      "Photosynthesis by plants and algae produces all the oxygen we breathe.",
      "DNA is found in every cell with a nucleus and contains instructions for life.",
      "Gravity is actually the weakest of the four fundamental forces in physics.",
      "The human brain has about 86 billion neurons forming trillions of connections.",
      "Evolution is driven by natural selection acting on genetic variations over time.",
    ];
    return insights[math.Random().nextInt(insights.length)];
  }

  String _getRandomScienceExplanation() {
    final explanations = [
      "The water cycle continuously moves water between oceans, atmosphere, and land.",
      "Atoms are made of protons, neutrons, and electrons, and they combine to form molecules.",
      "Vaccines work by training your immune system to recognize and fight specific diseases.",
      "Climate change occurs when greenhouse gases trap more heat in Earth's atmosphere.",
      "Antibiotics work against bacteria but not viruses, which is why they don't cure colds.",
    ];
    return explanations[math.Random().nextInt(explanations.length)];
  }

  String _getRandomLifestyleTip() {
    final tips = [
      "The 20-20-20 rule: Every 20 minutes, look at something 20 feet away for 20 seconds.",
      "Drinking water first thing in the morning helps kickstart your metabolism.",
      "Taking short breaks during work can actually improve productivity and focus.",
      "Gratitude journaling for just 5 minutes a day can improve mental well-being.",
      "Eating colorful foods ensures you get a variety of nutrients and antioxidants.",
    ];
    return tips[math.Random().nextInt(tips.length)];
  }

  String _getRandomWellnessFact() {
    final facts = [
      "Laughter really can be medicine - it boosts immune function and releases endorphins.",
      "Walking for just 30 minutes a day can significantly improve cardiovascular health.",
      "Deep breathing exercises can quickly activate your body's relaxation response.",
      "Social connections are as important for health as exercise and good nutrition.",
      "Getting sunlight in the morning helps regulate your natural sleep-wake cycle.",
    ];
    return facts[math.Random().nextInt(facts.length)];
  }

  String _getRandomLifestyleInsight() {
    final insights = [
      "Small consistent habits often lead to bigger changes than dramatic short-term efforts.",
      "Your environment significantly influences your behavior and decisions.",
      "Stress management is a skill that improves with practice and patience.",
      "Quality sleep is when your body repairs itself and consolidates memories.",
      "Mindful eating helps you tune into hunger and fullness cues.",
    ];
    return insights[math.Random().nextInt(insights.length)];
  }

  String _getRandomMathFact() {
    final facts = [
      "Zero was invented in India around the 5th century and revolutionized mathematics.",
      "Pi (π) is an infinite, non-repeating decimal that appears throughout nature.",
      "The Fibonacci sequence appears in flower petals, pinecones, and galaxy spirals.",
      "Probability theory was developed to analyze games of chance and gambling.",
      "Statistics help us understand patterns and make predictions from data.",
    ];
    return facts[math.Random().nextInt(facts.length)];
  }

  String _getRandomMathInsight() {
    final insights = [
      "Mathematics is the language of science and helps describe natural phenomena.",
      "Geometry helps us understand shapes, spaces, and relationships in the world around us.",
      "Algebra teaches us to work with unknown quantities and solve problems systematically.",
      "Percentages are everywhere - from discounts to data analysis to health statistics.",
      "Mathematical modeling helps predict everything from weather to population growth.",
    ];
    return insights[math.Random().nextInt(insights.length)];
  }

  String _getRandomMathTip() {
    final tips = [
      "Breaking complex problems into smaller steps makes them more manageable.",
      "Estimating before calculating helps you check if your answer makes sense.",
      "Visual representations like graphs can make numerical data easier to understand.",
      "Practice with real-world applications makes math more meaningful and memorable.",
      "Understanding concepts is often more valuable than memorizing formulas.",
    ];
    return tips[math.Random().nextInt(tips.length)];
  }

  String _getRandomWorldFact() {
    final facts = [
      "There are more possible games of chess than atoms in the observable universe.",
      "The Great Wall of China isn't visible from space without aid, contrary to popular belief.",
      "Antarctica is the largest desert in the world, despite being covered in ice.",
      "More people live in California than in all of Canada.",
      "The human heart beats about 100,000 times per day.",
    ];
    return facts[math.Random().nextInt(facts.length)];
  }

  String _getRandomKnowledgeFact() {
    final facts = [
      "Languages change over time - English today is very different from Old English.",
      "Cultural traditions often have practical origins that helped communities survive.",
      "Geography affects everything from climate to cuisine to cultural development.",
      "Historical events create ripple effects that influence the present day.",
      "Human migration patterns have shaped the diversity of our modern world.",
    ];
    return facts[math.Random().nextInt(facts.length)];
  }

  String _getRandomEducationalFact() {
    final facts = [
      "Reading increases empathy by helping you understand different perspectives.",
      "Learning a new skill creates new neural pathways in your brain.",
      "Teaching someone else is one of the best ways to solidify your own understanding.",
      "Curiosity and asking questions are the foundation of all learning.",
      "Mistakes are valuable learning opportunities that help build understanding.",
    ];
    return facts[math.Random().nextInt(facts.length)];
  }

  String _getRandomFunFact() {
    final facts = [
      "Bananas are berries, but strawberries aren't! Botanical classification can be surprising.",
      "A group of flamingos is called a 'flamboyance' - how perfect is that?",
      "Wombat poop is cube-shaped! It's one of nature's most unusual geometric achievements.",
      "The word 'serendipity' was coined by a writer in 1754 to describe pleasant surprises.",
      "Penguins can jump up to 6 feet out of water - they're surprisingly athletic!",
    ];
    return facts[math.Random().nextInt(facts.length)];
  }

  String _getRandomEntertainmentFact() {
    final facts = [
      "Music can trigger the release of dopamine, the same chemical involved in other pleasures.",
      "Reading fiction improves empathy and emotional intelligence.",
      "Games can improve problem-solving skills and hand-eye coordination.",
      "Humor and laughter have measurable positive effects on physical and mental health.",
      "Art and creativity can be therapeutic and help process emotions.",
    ];
    return facts[math.Random().nextInt(facts.length)];
  }

  String _getRandomTrivia() {
    final trivia = [
      "The shortest war in history lasted only 38-45 minutes (Anglo-Zanzibar War, 1896).",
      "A jiffy is an actual unit of time: 1/100th of a second.",
      "The plastic tips on shoelaces are called aglets.",
      "A group of crows is called a murder, while a group of owls is called a parliament.",
      "The dot over a lowercase 'i' or 'j' is called a tittle.",
    ];
    return trivia[math.Random().nextInt(trivia.length)];
  }

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
    // Get personalized suggestions based on conversation history
    final personalizedSuggestions = _conversationMemory?.getPersonalizedSuggestions() ?? [];
    
    // If we have personalized suggestions, use them
    if (personalizedSuggestions.isNotEmpty) {
      return personalizedSuggestions;
    }
    
    // Enhanced default suggestions covering multiple topics
    final suggestions = [
      // Health & cycle (15+ questions)
      "When will my next period start?",
      "How do I track symptoms?",
      "What causes PMS?",
      "Help with fertility tracking",
      "Normal cycle length range?",
      "How to deal with menstrual pain?",
      "Best foods during periods",
      "Exercise during menstruation",
      "Understanding ovulation signs",
      "Birth control options",
      "Irregular periods causes",
      "Pregnancy symptoms vs PMS",
      "Hormone changes explained",
      "PCOS information",
      "Endometriosis symptoms",
      "When to see a gynecologist?",
      "Menopause preparation",
      "Fertility diet tips",
      
      // Science & knowledge (20+ questions)
      "How does photosynthesis work?",
      "What is artificial intelligence?",
      "Explain climate change",
      "Fun science facts",
      "How do vaccines work?",
      "What is DNA?",
      "Explain gravity",
      "Why is the sky blue?",
      "How does the brain work?",
      "What are black holes?",
      "Evolution explained simply",
      "Chemistry in daily life",
      "Physics principles",
      "Ocean science facts",
      "Human anatomy basics",
      "Renewable energy types",
      "Space exploration facts",
      "Genetics for beginners",
      "Environmental science",
      "Weather patterns",
      "Animal behavior insights",
      "Plant biology basics",
      
      // Technology (15+ questions)
      "How does GPS work?",
      "What is cloud computing?",
      "Explain machine learning",
      "Technology tips",
      "Internet basics",
      "Smartphone technology",
      "Social media safety",
      "Cybersecurity tips",
      "Future of AI",
      "Virtual reality explained",
      "Blockchain basics",
      "Programming concepts",
      "Digital privacy",
      "Computer hardware",
      "Software development",
      "Tech career advice",
      "Gaming technology",
      "Smart home devices",
      
      // Lifestyle & wellness (20+ questions)
      "Healthy lifestyle tips",
      "How much sleep do I need?",
      "Stress management advice",
      "Exercise during period",
      "Meditation techniques",
      "Nutrition basics",
      "Hydration importance",
      "Mental health support",
      "Work-life balance",
      "Healthy meal planning",
      "Fitness for beginners",
      "Yoga benefits",
      "Mindfulness practices",
      "Self-care routines",
      "Sleep hygiene tips",
      "Anxiety management",
      "Building good habits",
      "Time management",
      "Relationship advice",
      "Confidence building",
      "Goal setting strategies",
      "Productivity hacks",
      
      // General knowledge (15+ questions)
      "Random interesting facts",
      "Math in daily life",
      "Space and astronomy",
      "World history highlights",
      "Geography fun facts",
      "Cultural differences",
      "Language learning tips",
      "Art appreciation",
      "Music theory basics",
      "Literature classics",
      "Philosophy for beginners",
      "Psychology insights",
      "Economics simplified",
      "Political systems",
      "Current events discussion",
      "Travel knowledge",
      
      // App features (10+ questions)
      "How to use the app",
      "App features overview",
      "Understanding predictions",
      "Data insights explanation",
      "Tracking accuracy",
      "Privacy settings",
      "Export data options",
      "Notification customization",
      "Sync across devices",
      "AI recommendations",
      "Troubleshooting help",
      
      // Personal development (10+ questions)
      "Career growth tips",
      "Leadership skills",
      "Communication improvement",
      "Creative thinking",
      "Problem-solving techniques",
      "Decision-making strategies",
      "Learning techniques",
      "Memory improvement",
      "Focus and concentration",
      "Overcoming procrastination",
      
      // Fun & entertainment (10+ questions)
      "Tell me a joke",
      "Fun trivia questions",
      "Movie recommendations",
      "Book suggestions",
      "Game ideas",
      "Interesting hobbies",
      "Creative activities",
      "Weekend plans",
      "Travel destinations",
      "Cultural experiences",
    ];
    
    // Return 8-12 random suggestions for better variety
    final shuffled = List<String>.from(suggestions)..shuffle();
    return shuffled.take(12).toList();
  }

  /// Search FAQ database with specific query
  List<FAQItem> searchFAQs(String query, {String? category}) {
    final results = <FAQItem>[];
    final lowerQuery = query.toLowerCase();
    
    final categoriesToSearch = category != null ? [category] : _faqDatabase.keys;
    
    for (final cat in categoriesToSearch) {
      final faqs = _faqDatabase[cat] ?? [];
      
      for (final faq in faqs) {
        final similarity = _calculateSimilarity(lowerQuery, faq.question.toLowerCase());
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
      "Hello again! 👋 I'm your enhanced AI assistant Mira. I can help with health questions, discuss science and technology, share fascinating facts, or just chat about whatever interests you. What's on your mind today?"
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
      debugPrint('🤖 FlowAI integration ${_useFlowAI ? "enabled" : "failed"}');
    } catch (e) {
      debugPrint('FlowAI initialization error: $e');
      _useFlowAI = false;
    }
  }
  
  Future<String?> _getFlowAIResponse(String userMessage, String? contextPrompt) async {
    if (!_useFlowAI || _currentUser == null) return null;
    
    try {
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
  
  String? _buildHealthContext(String? conversationContext) {
    final contextParts = <String>[];
    
    if (conversationContext != null && conversationContext.isNotEmpty) {
      contextParts.add('Previous conversation: $conversationContext');
    }
    
    final personalizedInsights = _conversationMemory?.getPersonalizedInsights() ?? {};
    if (personalizedInsights.isNotEmpty) {
      final insightsText = personalizedInsights.entries
          .map((e) => '${e.key}: ${e.value}')
          .join(', ');
      contextParts.add('User insights: $insightsText');
    }
    
    return contextParts.isNotEmpty ? contextParts.join('; ') : null;
  }
  
  Map<String, dynamic>? _getCycleContextData() => null;
  List<String>? _getRecentSymptoms() => null;
  String? _getCurrentCyclePhase() => null;

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
  
  /// Check if FlowAI is available and working
  bool get isFlowAIEnabled => _useFlowAI && _flowAIService.isInitialized;
  
  /// Get FlowAI service status
  String get aiServiceStatus {
    if (!_isInitialized) return 'Not initialized';
    if (_useFlowAI && _flowAIService.isInitialized) return 'FlowAI enabled';
    return 'Enhanced local responses';
  }
}

/// FAQ Item model
class FAQItem {
  final String question;
  final String answer;

  FAQItem(this.question, this.answer);

  @override
  String toString() => 'FAQItem(question: $question, answer: ${answer.substring(0, math.min(50, answer.length))}...)';
}
