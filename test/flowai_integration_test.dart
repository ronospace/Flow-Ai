import 'package:flutter_test/flutter_test.dart';
import 'package:flowai/core/services/flowai_service.dart';
import 'package:flowai/core/config/flowai_config.dart';
import 'package:flowai/core/services/ai_chat_service.dart';
import 'package:flowai/core/services/ai_engine.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test suite for Flow Ai integration
/// 
/// These tests verify that the Flow Ai integration is working correctly
/// including configuration, service initialization, and fallback behavior.
void main() {
  // Ensure Flutter bindings and mock preferences are initialized for tests
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  group('Flow Ai Configuration Tests', () {
    test('should validate configuration correctly', () {
      // Test empty API key
      FlowAIConfig.initialize(apiKey: '');
      expect(FlowAIConfig.isConfigured, false);
      
      // Test valid API key
      FlowAIConfig.initialize(apiKey: 'test-api-key-123');
      expect(FlowAIConfig.isConfigured, true);
    });
    
    test('should return correct model configurations', () {
      FlowAIConfig.initialize(apiKey: 'test-key');
      
      final chatConfig = FlowAIConfig.getModelConfig(FlowAIUseCase.chat);
      expect(chatConfig['model'], equals('flowai-chat-v1'));
      expect(chatConfig['temperature'], equals(0.7));
      
      final insightsConfig = FlowAIConfig.getModelConfig(FlowAIUseCase.insights);
      expect(insightsConfig['model'], equals('flowai-insights-v1'));
      expect(insightsConfig['temperature'], equals(0.3));
    });
    
test('should validate configuration parameters', () {
      // Reset/clear API key before validation to simulate unconfigured state
      FlowAIConfig.initialize(apiKey: '');
      final errors = FlowAIConfig.validateConfig();
      
      // Should have error for missing API key initially
      expect(errors.isNotEmpty, true);
      expect(errors.any((error) => error.contains('API key')), true);
    });
  });
  
  group('Flow Ai Service Tests', () {
    late FlowAIService service;
    
    setUp(() {
      service = FlowAIService();
    });
    
    test('should handle initialization gracefully', () async {
      // Test with invalid API key (should not throw)
      try {
        await service.initialize(apiKey: 'invalid-key-123');
        // If we reach here, initialization handled the error gracefully
        expect(service.isInitialized, false);
      } catch (e) {
        // Expected to fail with invalid API key
        expect(e, isA<FlowAIException>());
      }
    });
    
    test('should create proper request headers', () {
      FlowAIConfig.initialize(apiKey: 'test-key-123');
      final headers = FlowAIConfig.getRequestHeaders();
      
      expect(headers['Content-Type'], equals('application/json'));
      expect(headers['Authorization'], equals('Bearer test-key-123'));
      expect(headers['User-Agent'], equals('FlowAi/1.0'));
    });
    
    test('should handle FlowAI exceptions properly', () {
      final exception = FlowAIException('Test error message');
      expect(exception.toString(), contains('Test error message'));
      expect(exception, isA<Exception>());
    });
    
    test('should create proper usage statistics', () {
      final usage = FlowAIUsage(
        promptTokens: 100,
        completionTokens: 200,
        totalTokens: 300,
      );
      
      expect(usage.promptTokens, equals(100));
      expect(usage.completionTokens, equals(200));
      expect(usage.totalTokens, equals(300));
    });
    
    test('should create proper response objects', () {
      final response = FlowAIResponse(
        content: 'Test response content',
        messageId: 'msg-123',
        model: 'flowai-chat-v1',
      );
      
      expect(response.content, equals('Test response content'));
      expect(response.messageId, equals('msg-123'));
      expect(response.model, equals('flowai-chat-v1'));
    });
  });
  
  group('AI Chat Service FlowAI Integration Tests', () {
    late AIChatService chatService;
    
    setUp(() {
      chatService = AIChatService();
    });
    
    test('should initialize without FlowAI API key', () async {
      // Should work with local responses when no API key provided
      await chatService.initialize(
        userId: 'test-user-123',
        userName: 'Test User',
      );
      
      expect(chatService.isFlowAIEnabled, false);
      expect(chatService.aiServiceStatus, equals('Local responses only'));
    });
    
    test('should handle FlowAI initialization failure gracefully', () async {
      // Should fallback to local responses when FlowAI fails
      await chatService.initialize(
        userId: 'test-user-123',
        userName: 'Test User',
        flowAIApiKey: 'invalid-key',
      );
      
      // Should still be initialized even if FlowAI failed
      expect(chatService.currentUser?.id, equals('test-user-123'));
    });
    
    test('should provide service status information', () async {
      await chatService.initialize(
        userId: 'test-user-123',
        userName: 'Test User',
      );
      
      final status = chatService.aiServiceStatus;
      expect(status, isNotEmpty);
      expect(['Local responses only', 'FlowAI enabled'].contains(status), true);
    });
  });
  
  group('AI Engine FlowAI Integration Tests', () {
    late AIEngine aiEngine;
    
    setUp(() {
      aiEngine = AIEngine.instance;
    });
    
    test('should initialize AI engine without FlowAI', () async {
      await aiEngine.initialize();
      
      expect(aiEngine.isInitialized, true);
      expect(aiEngine.engineStatus, contains('processing'));
    });
    
    test('should provide engine status information', () async {
      await aiEngine.initialize();
      
      final status = aiEngine.engineStatus;
      expect(status, isNotEmpty);
      expect([
        'Not initialized',
        'Enhanced with FlowAI', 
        'Local processing only'
      ].contains(status), true);
    });
    
    test('should handle FlowAI availability check', () async {
      await aiEngine.initialize();
      
      // Should return boolean indicating FlowAI availability
      final isEnabled = aiEngine.isFlowAIEnabled;
      expect(isEnabled, isA<bool>());
    });
  });
  
  group('FlowAI Integration Fallback Tests', () {
    test('should handle network errors gracefully', () async {
      final service = FlowAIService();
      
      // Test with invalid URL/network error
      try {
        await service.initialize(apiKey: 'test-key');
      } catch (e) {
        // Should handle network errors without crashing
        expect(e, isA<FlowAIException>());
      }
    });
    
    test('should provide fallback responses', () {
      final config = FlowAIConfig.getFallbackConfig();
      
      expect(config['enable_fallback'], isA<bool>());
      expect(config['fallback_responses'], isA<List>());
      expect(config['fallback_suggestions'], isA<List>());
      
      final responses = config['fallback_responses'] as List;
      final suggestions = config['fallback_suggestions'] as List;
      
      expect(responses.isNotEmpty, true);
      expect(suggestions.isNotEmpty, true);
    });
    
    test('should provide retry configuration', () {
      final retryConfig = FlowAIConfig.getRetryConfig();
      
      expect(retryConfig['max_retries'], isA<int>());
      expect(retryConfig['initial_delay_ms'], isA<int>());
      expect(retryConfig['max_delay_ms'], isA<int>());
      expect(retryConfig['backoff_multiplier'], isA<double>());
    });
  });
  
  group('FlowAI Environment Configuration Tests', () {
    test('should provide different configs for debug/release', () {
      final envConfig = FlowAIConfig.getEnvironmentConfig();
      
      expect(envConfig['base_url'], isNotEmpty);
      expect(envConfig['timeout'], isA<int>());
      expect(envConfig['max_tokens'], isA<int>());
      expect(envConfig['temperature'], isA<double>());
    });
    
    test('should validate all configuration parameters', () {
      FlowAIConfig.initialize(apiKey: 'valid-key');
      final errors = FlowAIConfig.validateConfig();
      
      // With valid key, should have no errors
      expect(errors.isEmpty, true);
    });
  });
}
