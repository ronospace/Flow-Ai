import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service class for Flow Ai integration
/// Handles communication with Flow Ai API endpoints
class FlowAIService {
  static final FlowAIService _instance = FlowAIService._internal();
  factory FlowAIService() => _instance;
  FlowAIService._internal();

  // Flow Ai Configuration
  static const String _baseUrl = 'https://api.flowai.io/v1';
  static const String _chatEndpoint = '/chat/completions';
  static const String _healthEndpoint = '/health';
  
  String? _apiKey;
  String? _modelId;
  bool _isInitialized = false;
  Duration _timeout = const Duration(seconds: 30);
  
  // Rate limiting
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(milliseconds: 500);
  
  /// Initialize Flow Ai service with API credentials
  Future<void> initialize({
    required String apiKey,
    String modelId = 'flowai-chat-v1',
    Duration? timeout,
  }) async {
    _apiKey = apiKey;
    _modelId = modelId;
    if (timeout != null) _timeout = timeout;
    
    // Test connection
    try {
      final isHealthy = await _checkHealth();
      if (!isHealthy) {
        throw FlowAIException('Flow Ai service is not available');
      }
      
      _isInitialized = true;
      debugPrint('✅ Flow Ai service initialized successfully');
    } catch (e) {
      debugPrint('❌ Flow Ai initialization failed: $e');
      throw FlowAIException('Failed to initialize Flow Ai service: $e');
    }
  }

  /// Send a chat message to Flow Ai and get response
  Future<FlowAIResponse> sendChatMessage({
    required String message,
    required String userId,
    String? conversationContext,
    Map<String, dynamic>? userMetadata,
  }) async {
    if (!_isInitialized) {
      throw FlowAIException('Flow Ai service not initialized');
    }

    if (_apiKey == null) {
      throw FlowAIException('API key not provided');
    }

    // Rate limiting
    await _enforceRateLimit();

    try {
      final requestBody = _buildChatRequest(
        message: message,
        userId: userId,
        conversationContext: conversationContext,
        userMetadata: userMetadata,
      );

      final response = await http
          .post(
            Uri.parse('$_baseUrl$_chatEndpoint'),
            headers: _buildHeaders(),
            body: json.encode(requestBody),
          )
          .timeout(_timeout);

      return _handleChatResponse(response);
    } on TimeoutException {
      throw FlowAIException('Request timed out');
    } on http.ClientException catch (e) {
      throw FlowAIException('Network error: $e');
    } catch (e) {
      throw FlowAIException('Unexpected error: $e');
    }
  }

  /// Send a message with cycle context for personalized health responses
  Future<FlowAIResponse> sendHealthChatMessage({
    required String message,
    required String userId,
    Map<String, dynamic>? cycleData,
    List<String>? recentSymptoms,
    String? currentPhase,
  }) async {
    // Build health-specific context
    final healthContext = _buildHealthContext(
      cycleData: cycleData,
      recentSymptoms: recentSymptoms,
      currentPhase: currentPhase,
    );

    return sendChatMessage(
      message: message,
      userId: userId,
      conversationContext: healthContext,
      userMetadata: {
        'type': 'health_chat',
        'app': 'flowai',
        'domain': 'reproductive_health',
      },
    );
  }

  /// Get AI insights based on cycle data
  Future<FlowAIResponse> generateInsights({
    required String userId,
    required Map<String, dynamic> cycleAnalysis,
    List<String>? patterns,
  }) async {
    final insightPrompt = _buildInsightPrompt(cycleAnalysis, patterns);
    
    return sendChatMessage(
      message: insightPrompt,
      userId: userId,
      userMetadata: {
        'type': 'insight_generation',
        'app': 'flowai',
      },
    );
  }

  /// Check if Flow Ai service is healthy
  Future<bool> _checkHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$_baseUrl$_healthEndpoint'),
            headers: _buildHeaders(),
          )
          .timeout(const Duration(seconds: 10));
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Health check failed: $e');
      return false;
    }
  }

  /// Build request headers
  Map<String, String> _buildHeaders() {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_apiKey',
      'User-Agent': 'FlowAi/1.0',
      'X-Model-Id': _modelId ?? 'flowai-chat-v1',
    };
  }

  /// Build chat request payload
  Map<String, dynamic> _buildChatRequest({
    required String message,
    required String userId,
    String? conversationContext,
    Map<String, dynamic>? userMetadata,
  }) {
    final request = {
      'model': _modelId,
      'messages': [
        {
          'role': 'system',
          'content': _getSystemPrompt(),
        },
        if (conversationContext != null) {
          'role': 'system',
          'content': 'Context: $conversationContext',
        },
        {
          'role': 'user',
          'content': message,
        },
      ],
      'user_id': userId,
      'max_tokens': 500,
      'temperature': 0.7,
      'top_p': 0.9,
      'presence_penalty': 0.1,
      'frequency_penalty': 0.1,
    };

    if (userMetadata != null) {
      request['metadata'] = userMetadata;
    }

    return request;
  }

  /// Get system prompt for Mira AI
  String _getSystemPrompt() {
    return '''
You are Mira, the AI assistant for Flow Ai, a menstrual cycle tracking app. You are knowledgeable, empathetic, and supportive when discussing reproductive health topics.

Key characteristics:
- Warm, friendly, and professional tone
- Use emojis appropriately to make conversations more engaging
- Provide evidence-based health information
- Always encourage users to consult healthcare providers for medical concerns
- Respect privacy and be non-judgmental
- Focus on education, support, and empowerment
- Keep responses concise but informative (max 3-4 sentences)

Areas of expertise:
- Menstrual cycle tracking and patterns
- Period-related symptoms and management
- Fertility awareness and ovulation
- Reproductive health education
- App usage guidance
- General wellness tips related to menstrual health

Always remind users that you provide educational information and not medical advice.
''';
  }

  /// Build health-specific context
  String _buildHealthContext({
    Map<String, dynamic>? cycleData,
    List<String>? recentSymptoms,
    String? currentPhase,
  }) {
    final contextParts = <String>[];
    
    if (currentPhase != null) {
      contextParts.add('Current cycle phase: $currentPhase');
    }
    
    if (recentSymptoms != null && recentSymptoms.isNotEmpty) {
      contextParts.add('Recent symptoms: ${recentSymptoms.join(', ')}');
    }
    
    if (cycleData != null && cycleData.isNotEmpty) {
      contextParts.add('Cycle data: ${json.encode(cycleData)}');
    }
    
    return contextParts.join('; ');
  }

  /// Build insight generation prompt
  String _buildInsightPrompt(Map<String, dynamic> cycleAnalysis, List<String>? patterns) {
    final prompt = StringBuffer();
    prompt.write('Generate personalized health insights based on this cycle analysis: ');
    prompt.write(json.encode(cycleAnalysis));
    
    if (patterns != null && patterns.isNotEmpty) {
      prompt.write('. Detected patterns: ${patterns.join(', ')}');
    }
    
    prompt.write('. Please provide 2-3 actionable insights with recommendations.');
    
    return prompt.toString();
  }

  /// Handle chat API response
  FlowAIResponse _handleChatResponse(http.Response response) {
    if (response.statusCode == 200) {
      try {
        final data = json.decode(response.body) as Map<String, dynamic>;
        
        final choices = data['choices'] as List?;
        if (choices == null || choices.isEmpty) {
          throw FlowAIException('No response choices received');
        }
        
        final message = choices[0]['message'] as Map<String, dynamic>?;
        final content = message?['content'] as String?;
        
        if (content == null || content.isEmpty) {
          throw FlowAIException('Empty response content');
        }
        
        return FlowAIResponse(
          content: content,
          messageId: data['id'] as String?,
          model: data['model'] as String?,
          usage: _parseUsage(data['usage'] as Map<String, dynamic>?),
          metadata: data['metadata'] as Map<String, dynamic>?,
        );
      } catch (e) {
        throw FlowAIException('Failed to parse response: $e');
      }
    } else if (response.statusCode == 401) {
      throw FlowAIException('Unauthorized - check API key');
    } else if (response.statusCode == 429) {
      throw FlowAIException('Rate limit exceeded - please try again later');
    } else if (response.statusCode >= 500) {
      throw FlowAIException('Server error - please try again later');
    } else {
      throw FlowAIException('Request failed with status ${response.statusCode}');
    }
  }

  /// Parse usage information from response
  FlowAIUsage? _parseUsage(Map<String, dynamic>? usageData) {
    if (usageData == null) return null;
    
    return FlowAIUsage(
      promptTokens: usageData['prompt_tokens'] as int? ?? 0,
      completionTokens: usageData['completion_tokens'] as int? ?? 0,
      totalTokens: usageData['total_tokens'] as int? ?? 0,
    );
  }

  /// Enforce rate limiting between requests
  Future<void> _enforceRateLimit() async {
    if (_lastRequestTime != null) {
      final timeSinceLastRequest = DateTime.now().difference(_lastRequestTime!);
      if (timeSinceLastRequest < _minRequestInterval) {
        final waitTime = _minRequestInterval - timeSinceLastRequest;
        await Future.delayed(waitTime);
      }
    }
    _lastRequestTime = DateTime.now();
  }

  /// Get service status
  bool get isInitialized => _isInitialized;
  
  /// Get configured model ID
  String? get modelId => _modelId;
}

/// FlowAI response model
class FlowAIResponse {
  final String content;
  final String? messageId;
  final String? model;
  final FlowAIUsage? usage;
  final Map<String, dynamic>? metadata;

  FlowAIResponse({
    required this.content,
    this.messageId,
    this.model,
    this.usage,
    this.metadata,
  });

  @override
  String toString() {
    return 'FlowAIResponse(content: ${content.length} chars, model: $model, messageId: $messageId)';
  }
}

/// FlowAI usage statistics
class FlowAIUsage {
  final int promptTokens;
  final int completionTokens;
  final int totalTokens;

  FlowAIUsage({
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
  });

  @override
  String toString() {
    return 'FlowAIUsage(prompt: $promptTokens, completion: $completionTokens, total: $totalTokens)';
  }
}

/// FlowAI service exceptions
class FlowAIException implements Exception {
  final String message;
  FlowAIException(this.message);

  @override
  String toString() => 'FlowAIException: $message';
}
