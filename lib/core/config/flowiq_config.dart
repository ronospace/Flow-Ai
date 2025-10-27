import 'package:flutter/foundation.dart';

/// Configuration class for Flow Ai integration
class FlowIQConfig {
  // Flow Ai API Configuration
  static const String baseUrl = 'https://api.flowai.io/v1';
  static const String chatEndpoint = '/chat/completions';
  static const String healthEndpoint = '/health';
  static const String insightsEndpoint = '/insights/generate';
  
  // Model Configuration
  static const String defaultModel = 'flowai-chat-v1';
  static const String insightsModel = 'flowai-insights-v1';
  static const String healthModel = 'flowai-health-v1';
  
  // Request Settings
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration healthCheckTimeout = Duration(seconds: 10);
  static const Duration minRequestInterval = Duration(milliseconds: 500);
  
  // Token Limits
  static const int maxTokens = 500;
  static const int maxContextTokens = 1000;
  
  // Model Parameters
  static const double temperature = 0.7;
  static const double topP = 0.9;
  static const double presencePenalty = 0.1;
  static const double frequencyPenalty = 0.1;
  
  // Rate Limiting
  static const int maxRequestsPerMinute = 20;
  static const int maxRequestsPerHour = 500;
  
  // Feature Flags
  static const bool enableHealthContext = true;
  static const bool enableInsightGeneration = true;
  static const bool enableMemoryIntegration = true;
  static const bool enableFallbackResponses = true;
  
  // API Key Configuration
  static String? _apiKey;
  static String? _organizationId;
  
  /// Initialize Flow Ai configuration with API credentials
  static void initialize({
    required String apiKey,
    String? organizationId,
  }) {
    _apiKey = apiKey;
    _organizationId = organizationId;
    debugPrint('🔑 Flow Ai configuration initialized');
  }
  
  /// Get API key (should be set from secure storage or environment)
  static String? get apiKey {
    if (_apiKey != null) return _apiKey;
    
    // In production, this should come from secure storage or environment variables
    if (kDebugMode) {
      // For development, you can set a debug API key here
      return const String.fromEnvironment('FLOWAI_API_KEY');
    }
    
    return null;
  }
  
  /// Get organization ID
  static String? get organizationId => _organizationId;
  
  /// Check if Flow Ai is configured
  static bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;
  
  /// Get environment-specific configuration
  static Map<String, dynamic> getEnvironmentConfig() {
    if (kDebugMode) {
      return {
        'base_url': baseUrl,
        'timeout': defaultTimeout.inSeconds,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'enable_logging': true,
        'enable_debug_mode': true,
      };
    } else {
      return {
        'base_url': baseUrl,
        'timeout': defaultTimeout.inSeconds,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'enable_logging': false,
        'enable_debug_mode': false,
      };
    }
  }
  
  /// Get headers for API requests
  static Map<String, String> getRequestHeaders() {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'User-Agent': 'FlowiQ/1.0',
      'X-App-Version': '1.0.0',
      'X-Platform': kIsWeb ? 'web' : 'mobile',
    };
    
    if (apiKey != null) {
      headers['Authorization'] = 'Bearer $apiKey';
    }
    
    if (organizationId != null) {
      headers['X-Organization-ID'] = organizationId!;
    }
    
    return headers;
  }
  
  /// Get model configuration for specific use cases
  static Map<String, dynamic> getModelConfig(FlowAIUseCase useCase) {
    switch (useCase) {
      case FlowAIUseCase.chat:
        return {
          'model': defaultModel,
          'max_tokens': maxTokens,
          'temperature': temperature,
          'top_p': topP,
          'presence_penalty': presencePenalty,
          'frequency_penalty': frequencyPenalty,
        };
      
      case FlowAIUseCase.insights:
        return {
          'model': insightsModel,
          'max_tokens': maxTokens * 2,
          'temperature': 0.3, // Lower temperature for more focused insights
          'top_p': 0.8,
          'presence_penalty': 0.0,
          'frequency_penalty': 0.0,
        };
      
      case FlowAIUseCase.health:
        return {
          'model': healthModel,
          'max_tokens': maxTokens,
          'temperature': 0.5, // Balanced for health advice
          'top_p': 0.9,
          'presence_penalty': 0.1,
          'frequency_penalty': 0.1,
        };
    }
  }
  
  /// Get retry configuration
  static Map<String, dynamic> getRetryConfig() {
    return {
      'max_retries': 3,
      'initial_delay_ms': 1000,
      'max_delay_ms': 10000,
      'backoff_multiplier': 2.0,
      'retry_on_timeout': true,
      'retry_on_rate_limit': true,
    };
  }
  
  /// Get fallback configuration
  static Map<String, dynamic> getFallbackConfig() {
    return {
      'enable_fallback': enableFallbackResponses,
      'fallback_responses': [
        "I'm having trouble connecting right now, but I'm here to help! Could you try asking your question again?",
        "Let me think about that for a moment. Could you provide a bit more detail about what you're experiencing?",
        "I want to give you the best answer possible. Can you tell me more about your specific situation?",
      ],
      'fallback_suggestions': [
        "When will my next period start?",
        "How do I track symptoms?",
        "Understanding my cycle patterns",
        "Managing period symptoms",
      ],
    };
  }
  
  /// Validate configuration
  static List<String> validateConfig() {
    final errors = <String>[];
    
    if (!isConfigured) {
      errors.add('API key is required for FlowAI integration');
    }
    
    if (baseUrl.isEmpty) {
      errors.add('Base URL cannot be empty');
    }
    
    if (defaultTimeout.inSeconds < 5) {
      errors.add('Timeout should be at least 5 seconds');
    }
    
    if (maxTokens <= 0) {
      errors.add('Max tokens must be positive');
    }
    
    if (temperature < 0 || temperature > 2) {
      errors.add('Temperature must be between 0 and 2');
    }
    
    return errors;
  }
}

/// Use cases for FlowAI integration
enum FlowAIUseCase {
  chat,
  insights,
  health,
}

/// FlowAI service status
enum FlowAIStatus {
  uninitialized,
  initializing,
  ready,
  error,
  maintenance,
}
