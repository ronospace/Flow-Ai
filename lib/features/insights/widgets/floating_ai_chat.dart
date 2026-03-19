import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:provider/provider.dart';
import '../../../core/services/enhanced_ai_chat_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../../settings/providers/settings_provider.dart';
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
  bool _isFullScreen = false;
  double _chatHeight = 0.4; // Percentage of screen height
  late AnimationController _fabController;
  late AnimationController _chatController;
  late AnimationController _expandController;
  late Animation<double> _fabAnimation;
  late Animation<double> _chatAnimation;
  late Animation<double> _expandAnimation;

  final EnhancedAIChatService _chatService = EnhancedAIChatService();
  List<types.Message> _messages = [];
  bool _isTyping = false;
  bool _showQuickReplies = true;
  late TextEditingController _textController;

  // For resize gesture
  double _initialHeight = 0.5;
  bool _isResizing = false;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _chatController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOut,
    );

    _chatAnimation = CurvedAnimation(
      parent: _chatController,
      curve: Curves.easeOutCubic,
    );

    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );

    // Initialize text controller
    _textController = TextEditingController();

    // Initialize chat service after first build to get localizations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localizations = AppLocalizations.of(context);
      final settingsProvider = context.read<SettingsProvider>();
      final userPreferences = settingsProvider.preferences;

      final userName =
          userPreferences.displayName ??
          userPreferences.userId.split('_').last ??
          'User';

      _chatService.initialize(
        userId: userPreferences.userId,
        userName: userName,
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
    // Ensure animations are stopped and controllers disposed properly
    _fabController.stop();
    _chatController.stop();
    _expandController.stop();
    _fabController.dispose();
    _chatController.dispose();
    _expandController.dispose();
    _textController.dispose();
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
      if (!_isExpanded) {
        _isFullScreen = false;
        _chatHeight = 0.5;
      }
    });

    if (_isExpanded) {
      _stopPulsingAnimation();
      _chatController.forward();
    } else {
      _chatController.reverse();
      _expandController.reverse();
      _startPulsingAnimation();
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _chatHeight = _isFullScreen ? 0.9 : 0.6;
    });

    if (_isFullScreen) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _adjustChatHeight(double delta) {
    setState(() {
      _chatHeight = (_chatHeight - delta / MediaQuery.of(context).size.height)
          .clamp(0.3, 0.9);
    });
  }

  /// Determine if Quick Questions should be shown
  /// Show when there's only the welcome message (no user messages yet)
  bool _shouldShowQuickQuestions() {
    // If no messages at all, show quick questions
    if (_messages.isEmpty) return true;

    // If only one message and it's from AI (welcome message), show quick questions
    if (_messages.length == 1) {
      final firstMessage = _messages.first;
      return firstMessage.author.id == 'ai_flowai_enhanced';
    }

    // Otherwise, don't show quick questions
    return false;
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
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        // Enhanced Chat Interface - NO OVERLAY
        if (_isExpanded)
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            right: 8,
            left: 8,
            top: _isFullScreen
                ? MediaQuery.of(context).padding.top + 8
                : screenSize.height * 0.12,
            bottom: _isFullScreen
                ? MediaQuery.of(context).padding.bottom + 8
                : 80,
            child: AnimatedBuilder(
              animation: _chatAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_chatAnimation.value * 0.2),
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(
                        _isFullScreen ? 16 : 24,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.2),
                          blurRadius: 20,
                          spreadRadius: 4,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.primaryRose.withValues(alpha: 0.15),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        // Enhanced Draggable Header with Controls
                        _buildEnhancedHeader(theme),

                        // Main content area - improved spacing
                        Expanded(
                          child: Column(
                            children: [
                              // Chat Messages Area - More space allocated
                              Expanded(
                                flex: _shouldShowQuickQuestions() ? 5 : 9,
                                child: _buildChatArea(theme),
                              ),

                              // Quick Replies Section - More prominent and visible
                              if (_shouldShowQuickQuestions())
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: _buildEnhancedQuickReplies(theme),
                                ),
                            ],
                          ),
                        ),

                        // Enhanced Input Area
                        _buildEnhancedInput(theme),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

        // Enhanced Floating Action Button
        Positioned(
          right: 16,
          bottom: 16,
          child: AnimatedBuilder(
            animation: _fabAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isExpanded ? 1.0 : (1.0 + _fabAnimation.value * 0.1),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRose.withValues(alpha: 0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: FloatingActionButton(
                    heroTag: "ai_chat_main_fab",
                    onPressed: _toggleChat,
                    backgroundColor: AppTheme.primaryRose,
                    elevation: 0,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        return RotationTransition(
                          turns: animation,
                          child: child,
                        );
                      },
                      child: _isExpanded
                          ? Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              key: const ValueKey('close'),
                              size: 28,
                            )
                          : Stack(
                              key: const ValueKey('chat'),
                              children: [
                                Icon(
                                  Icons.psychology_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                if (!_isExpanded)
                                  Positioned(
                                    top: -2,
                                    right: -2,
                                    child:
                                        Container(
                                              width: 16,
                                              height: 16,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    AppTheme.successGreen,
                                                    AppTheme.accentMint,
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: AppTheme.successGreen
                                                        .withValues(alpha: 0.5),
                                                    blurRadius: 8,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                Icons.auto_awesome,
                                                color: Colors.white,
                                                size: 10,
                                              ),
                                            )
                                            .animate(
                                              onPlay: (controller) =>
                                                  controller.repeat(),
                                            )
                                            .shimmer(
                                              duration: 2000.ms,
                                              color: Colors.white.withValues(
                                                alpha: 0.5,
                                              ),
                                            )
                                            .then(delay: 1000.ms)
                                            .fadeOut(duration: 500.ms)
                                            .then(delay: 1000.ms)
                                            .fadeIn(duration: 500.ms),
                                  ),
                              ],
                            ),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Ask about health, science, technology, lifestyle...',
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
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) {
                  _handleSendPressed(types.PartialText(text: text.trim()));
                  _textController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          FloatingActionButton.small(
            heroTag: "ai_chat_send_fab",
            onPressed: () {
              final text = _textController.text.trim();
              if (text.isNotEmpty) {
                _handleSendPressed(types.PartialText(text: text));
                _textController.clear();
              }
            },
            backgroundColor: AppTheme.primaryRose,
            child: Icon(
              Icons.send,
              color: theme.colorScheme.onPrimary,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced Header with Controls
  Widget _buildEnhancedHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(_isFullScreen ? 16 : 24),
          topRight: Radius.circular(_isFullScreen ? 16 : 24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRose.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Resize Handle - Only draggable area
          if (!_isFullScreen)
            Center(
              child: GestureDetector(
                onPanStart: (details) {
                  _initialHeight = _chatHeight;
                  _isResizing = true;
                },
                onPanUpdate: (details) {
                  if (!_isFullScreen && _isResizing) {
                    _adjustChatHeight(details.delta.dy);
                  }
                },
                onPanEnd: (details) {
                  _isResizing = false;
                },
                child: Container(
                  width: 80, // Larger hit area for better UX
                  height: 30, // Larger hit area
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          if (!_isFullScreen) const SizedBox(height: 16),

          // Header Content
          Row(
            children: [
              // AI Avatar with Animation
              Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.psychology_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  )
                  .animate(onPlay: (controller) => controller.repeat())
                  .shimmer(
                    duration: 3000.ms,
                    color: Colors.white.withValues(alpha: 0.3),
                  )
                  .then(delay: 2000.ms),

              const SizedBox(width: 16),

              // Title and Status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mira AI Assistant',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: AppTheme.successGreen,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            )
                            .animate(
                              onPlay: (controller) => controller.repeat(),
                            )
                            .fadeIn(duration: 1000.ms)
                            .then(delay: 500.ms)
                            .fadeOut(duration: 1000.ms),
                        const SizedBox(width: 8),
                        Text(
                          _isTyping ? 'Thinking...' : 'Ready to help',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.white.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Header Actions - With improved tap handling
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Fullscreen Toggle
                  GestureDetector(
                    onTap: _toggleFullScreen,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        _isFullScreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Close Button - Enhanced with better tap handling
                  GestureDetector(
                    onTap: _toggleChat,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Medical Disclaimer (Guideline 1.4.1)
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  // Enhanced Chat Area - Better spacing and padding
  Widget _buildChatArea(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Theme(
        data: theme.copyWith(primaryColor: AppTheme.primaryRose),
        child: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          onMessageTap: _handleMessageTap,
          onPreviewDataFetched: _handlePreviewDataFetched,
          user: _chatService.currentUser ?? types.User(id: 'fallback_user'),
          theme: DefaultChatTheme(
            primaryColor: AppTheme.primaryRose,
            secondaryColor: AppTheme.secondaryBlue.withValues(alpha: 0.1),
            backgroundColor: theme.scaffoldBackgroundColor,
            inputBackgroundColor: theme.cardColor,
            inputTextColor: theme.textTheme.bodyMedium?.color ?? Colors.black,
            messageBorderRadius: 18,
            messageInsetsHorizontal: 20,
            messageInsetsVertical: 14,
            receivedMessageBodyTextStyle:
                theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color,
                  fontSize: 16,
                  height: 1.5,
                ) ??
                const TextStyle(fontSize: 16, height: 1.5),
            sentMessageBodyTextStyle:
                theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 16,
                  height: 1.5,
                ) ??
                const TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
          showUserAvatars: true,
          showUserNames: false,
          customBottomWidget: Container(), // We'll use our enhanced input
        ),
      ),
    );
  }

  // Enhanced Quick Replies - More visible and professional
  Widget _buildEnhancedQuickReplies(ThemeData theme) {
    final suggestions = _chatService.getSuggestedReplies().take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header - More prominent
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Suggested Questions',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppTheme.primaryRose,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Suggestions - Horizontal scrollable for better visibility
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              return _buildSuggestionChip(suggestions[index], theme, index);
            },
          ),
        ),
      ],
    );
  }

  // Suggestion Chip - More prominent and professional
  Widget _buildSuggestionChip(String suggestion, ThemeData theme, int index) {
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
              _showQuickReplies = false;
            });

            _chatService.sendMessage(message);
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryRose.withValues(alpha: 0.15),
                  AppTheme.primaryPurple.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: AppTheme.primaryRose.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              suggestion,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.primaryRose,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 100).ms)
        .slideX(begin: 0.3, end: 0);
  }

  // Enhanced Input Area - Better spacing and visibility
  Widget _buildEnhancedInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(_isFullScreen ? 16 : 24),
          bottomRight: Radius.circular(_isFullScreen ? 16 : 24),
        ),
        border: Border(
          top: BorderSide(
            color: Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppTheme.primaryRose.withValues(alpha: 0.2),
                  width: 1.5,
                ),
              ),
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText:
                      'Ask about health, science, technology, lifestyle...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor.withValues(alpha: 0.7),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                ),
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 16,
                  height: 1.4,
                ),
                onSubmitted: (text) {
                  if (text.trim().isNotEmpty) {
                    _handleSendPressed(types.PartialText(text: text.trim()));
                    _textController.clear();
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Send Button - More prominent
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  final text = _textController.text.trim();
                  if (text.isNotEmpty) {
                    _handleSendPressed(types.PartialText(text: text));
                    _textController.clear();
                  }
                },
                borderRadius: BorderRadius.circular(28),
                child: Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.transparent,
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick questions:',
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
