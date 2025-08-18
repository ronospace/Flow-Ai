import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '../../../core/services/ai_chat_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import 'package:uuid/uuid.dart';

/// Floating AI Chat Widget for insights screen
class FloatingAIChat extends StatefulWidget {
  const FloatingAIChat({super.key});

  @override
  State<FloatingAIChat> createState() => _FloatingAIChatState();
}

class _FloatingAIChatState extends State<FloatingAIChat>
    with TickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _fabController;
  late AnimationController _chatController;
  late Animation<double> _fabAnimation;
  late Animation<double> _chatAnimation;
  
  final AIChatService _chatService = AIChatService();
  List<types.Message> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    
    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _chatController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );
    
    _chatAnimation = CurvedAnimation(
      parent: _chatController,
      curve: Curves.easeInOutBack,
    );

    // Initialize chat service after first build to get localizations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localizations = AppLocalizations.of(context);
      _chatService.initialize(
        userId: 'current_user_123',
        userName: 'User',
        localizations: localizations,
      );
    });

    // Listen to messages
    _chatService.messagesStream.listen((messages) {
      if (mounted) {
        setState(() {
          _messages = messages;
          _isTyping = false;
        });
      }
    });

    _messages = _chatService.messages;
    
    // Start pulsing animation
    _startPulsingAnimation();
  }

  @override
  void dispose() {
    _fabController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  void _startPulsingAnimation() {
    if (!_isExpanded) {
      _fabController.repeat(reverse: true);
    }
  }

  void _stopPulsingAnimation() {
    _fabController.stop();
    _fabController.reset();
  }

  void _toggleChat() {
    setState(() {
      _isExpanded = !_isExpanded;
    });

    if (_isExpanded) {
      _stopPulsingAnimation();
      _chatController.forward();
    } else {
      _chatController.reverse();
      _startPulsingAnimation();
    }
  }

  void _handleSendPressed(types.PartialText message) {
    final currentUser = _chatService.currentUser;
    if (currentUser == null) return;
    
    final textMessage = types.TextMessage(
      author: currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: message.text,
    );

    setState(() {
      _isTyping = true;
    });

    _chatService.sendMessage(textMessage);
  }

  void _handleMessageTap(BuildContext _, types.Message message) {
    // Handle message tap if needed
  }

  void _handlePreviewDataFetched(
    types.TextMessage message,
    types.PreviewData previewData,
  ) {
    // Handle preview data if needed
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!;
    
    return Stack(
      children: [
        // Chat Interface
        if (_isExpanded)
          Positioned(
            right: 16,
            bottom: 100,
            child: AnimatedBuilder(
              animation: _chatAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _chatAnimation.value,
                  child: Container(
                    width: MediaQuery.of(context).size.width - 32,
                    height: MediaQuery.of(context).size.height * 0.6,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Chat Header
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
                            ),
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.psychology,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'FlowSense AI Assistant',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Ask me anything about your health', // This could be localized in the future
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white.withValues(alpha: 0.8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: _toggleChat,
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Chat Messages
                        Expanded(
                          child: Theme(
                            data: theme.copyWith(
                              // Customize chat theme
                              primaryColor: AppTheme.primaryRose,
                            ),
                            child: Chat(
                              messages: _messages,
                              onSendPressed: _handleSendPressed,
                              onMessageTap: _handleMessageTap,
                              onPreviewDataFetched: _handlePreviewDataFetched,
                              user: _chatService.currentUser ?? types.User(id: 'fallback_user'),
                              theme: DarkChatTheme(
                                primaryColor: AppTheme.primaryRose,
                                secondaryColor: AppTheme.secondaryBlue,
                                backgroundColor: theme.scaffoldBackgroundColor,
                                inputBackgroundColor: theme.cardColor,
                                inputTextColor: theme.textTheme.bodyMedium?.color ?? Colors.black,
                                messageBorderRadius: 12,
                              ),
                              customBottomWidget: _buildCustomInput(),
                            ),
                          ),
                        ),
                        
                        // Quick Replies
                        if (_messages.isNotEmpty && !_isTyping)
                          _buildQuickReplies(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        
        // Floating Action Button
        Positioned(
          right: 16,
          bottom: 16,
          child: AnimatedBuilder(
            animation: _fabAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isExpanded ? 1.0 : (1.0 + _fabAnimation.value * 0.1),
                child: FloatingActionButton(
                  onPressed: _toggleChat,
                  backgroundColor: AppTheme.primaryRose,
                  elevation: 8,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _isExpanded
                        ? const Icon(
                            Icons.close,
                            color: Colors.white,
                            key: ValueKey('close'),
                          )
                        : Stack(
                            key: const ValueKey('chat'),
                            children: [
                              const Icon(
                                Icons.psychology,
                                color: Colors.white,
                              ),
                              if (!_isExpanded)
                                Positioned(
                                  top: -2,
                                  right: -2,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: AppTheme.successGreen,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ).animate(onPlay: (controller) => controller.repeat())
                                    .fadeIn(duration: 1000.ms)
                                    .then(delay: 500.ms)
                                    .fadeOut(duration: 1000.ms),
                                ),
                            ],
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCustomInput() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Ask about your cycle, symptoms, or health...', // This could be localized in the future
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: theme.scaffoldBackgroundColor,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            onPressed: () {
              // Handle send - this would be connected to the chat input
            },
            backgroundColor: AppTheme.primaryRose,
            child: const Icon(
              Icons.send,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickReplies() {
    final theme = Theme.of(context);
    final suggestions = _chatService.getSuggestedReplies();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.5),
        border: Border(
          top: BorderSide(
            color: theme.dividerColor,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick questions:', // This could be localized in the future
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGrey,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: suggestions.map((suggestion) {
              return InkWell(
                onTap: () {
                  final currentUser = _chatService.currentUser;
                  if (currentUser == null) return;
                  
                  final message = types.TextMessage(
                    author: currentUser,
                    createdAt: DateTime.now().millisecondsSinceEpoch,
                    id: const Uuid().v4(),
                    text: suggestion,
                  );
                  
                  setState(() {
                    _isTyping = true;
                  });
                  
                  _chatService.sendMessage(message);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRose.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryRose.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    suggestion,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryRose,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
