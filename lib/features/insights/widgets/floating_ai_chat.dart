import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flow_ai/core/ui/app_geometry.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:provider/provider.dart';
import '../../../core/services/enhanced_ai_chat_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../../settings/providers/settings_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:flow_ai/core/layout/app_layout_metrics.dart';
import 'zyra/controllers/zyra_shell_controller.dart';

/// Floating AI Chat Widget for insights screen
class FloatingAIChat extends StatefulWidget {
  final GlobalKey tabsKey;
  final GlobalKey periodSelectorKey;
  final ValueChanged<bool>? onExpandedChanged;
  const FloatingAIChat({
    super.key,
    required this.tabsKey,
    required this.periodSelectorKey,
    this.onExpandedChanged,
  });

  @override
  State<FloatingAIChat> createState() => _FloatingAIChatState();
}

class _FloatingAIChatState extends State<FloatingAIChat>
    with TickerProviderStateMixin {
  static const double _floatingChatGap = 8;
  static const _thinkingDelay = Duration(milliseconds: 900);
  late AnimationController _fabController;
  late AnimationController _chatController;
  late AnimationController _expandController;
  late AnimationController _pulseController;
  late Animation<double> _fabAnimation;
  late Animation<double> _chatAnimation;
  late StreamSubscription _messagesSub;

  final EnhancedAIChatService _chatService = EnhancedAIChatService();
  late final ZyraShellController _shellController;
  List<types.Message> _messages = [];
  // removed unused _showQuickReplies
  // ignore: unused_field
  bool _isSuggestionsExpanded = true;
  // ignore: unused_field
  final List<String> _suggestedQuestions = [
    "When will my next period start?",
    "Is my cycle regular?",
    "Can I get pregnant today?",
    "What are my fertile days?",
    "Why is my period late?",
    "What do my symptoms mean?",
    "How long is a normal cycle?",
    "When am I ovulating?",
    "Is spotting normal?",
    "How can I reduce cramps?",
  ];

  late TextEditingController _textController;
  late FocusNode _inputFocusNode;

  // For resize gesture
  // ignore: unused_field
  double _initialHeight = 0;

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

    _pulseController =
        AnimationController(
            duration: const Duration(milliseconds: 950),
            vsync: this,
          )
          ..addListener(() {
            if (mounted) setState(() {});
          })
          ..repeat(reverse: true);

    _fabAnimation = CurvedAnimation(
      parent: _fabController,
      curve: Curves.easeInOutCubic,
    );

    _chatAnimation = CurvedAnimation(
      parent: _chatController,
      curve: Curves.easeOutCubic,
    );

    // Initialize text controller
    _textController = TextEditingController();
    _shellController = ZyraShellController()
      ..addListener(() {
        if (mounted) setState(() {});
      });

    _inputFocusNode = FocusNode()
      ..addListener(() {
        _shellController.setKeyboardVisibility(
          _inputFocusNode.hasFocus,
        );

        if (mounted) setState(() {});
      });

    // Initialize chat service after first build to get localizations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localizations = AppLocalizations.of(context);
      final settingsProvider = context.read<SettingsProvider>();
      final userPreferences = settingsProvider.preferences;

      final userName = userPreferences.displayName;

      _chatService.initialize(
        userId: userPreferences.userId,
        userName: userName,
        localizations: localizations,
      );
    });

    // Listen to messages
    _messagesSub = _chatService.messagesStream.listen((messages) {
      if (!mounted) return;

      setState(() {
        _messages = List<types.Message>.from(messages);
      });

      if (messages.isNotEmpty &&
          messages.last.author.id == 'ai_flowai_enhanced') {
        Future.delayed(_thinkingDelay, () {
          if (!mounted) return;

          final keyboardOpen = _inputFocusNode.hasFocus;

          _shellController.setTyping(false);

          if (!keyboardOpen) {
            _shellController.setQuickRepliesCollapsed(false);
            _isSuggestionsExpanded = true;
          }

          setState(() {});
        });
      }
    });

    _messages = List<types.Message>.from(_chatService.messages);

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
    _pulseController.dispose();
    _textController.dispose();
    _messagesSub.cancel();
    _inputFocusNode.dispose();
    _shellController.dispose();
    super.dispose();
  }

  void _startPulsingAnimation() {
    if (!_shellController.isExpanded) {
      _fabController.repeat(reverse: true);
    }
  }

  void _stopPulsingAnimation() {
    _fabController.stop();
    _fabController.reset();
  }

  void _toggleChat() {
    setState(() {
      _shellController.toggleExpanded();
      widget.onExpandedChanged?.call(_shellController.isExpanded);
      if (!_shellController.isExpanded) {
      }
    });

    if (_shellController.isExpanded) {
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
      _shellController.toggleFullScreen();
    });

    if (_shellController.isFullScreen) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
  }

  void _adjustChatHeight(double delta) {
    _shellController.adjustChatHeight(
      delta,
      MediaQuery.of(context).size.height,
    );
  }

  /// Determine if Quick Questions should be shown
  /// Show when there's only the welcome message (no user messages yet)

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
      _shellController.setTyping(true);
    });

    _chatService.sendMessage(textMessage);
  }



  double _getTabsBottom() {
    final ctx = widget.tabsKey.currentContext;
    if (ctx == null) return 200;
    final box = ctx.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    return pos.dy + box.size.height + 8;
  }

  double _getPeriodSelectorTop() {
    final ctx = widget.periodSelectorKey.currentContext;
    if (ctx == null) return MediaQuery.of(context).padding.top + 80;
    final box = ctx.findRenderObject() as RenderBox;
    final pos = box.localToGlobal(Offset.zero);
    return pos.dy;
  }

  @override
  Widget build(BuildContext context) {
    // // // // debugPrint("SCREEN HEIGHT: ");
    // // debugPrint("SAFE TOP: ");
    // // debugPrint("SAFE BOTTOM: ");
    // // // // debugPrint("VIEW INSETS (keyboard): ");

    final theme = Theme.of(context);
    final keyboardOpen = _inputFocusNode.hasFocus;
    final forceMaxMode =
        keyboardOpen || _shellController.isFullScreen;

    return Stack(
      children: [
        // Enhanced Chat Interface - NO OVERLAY
        if (_shellController.isExpanded)
          AnimatedPositioned(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            right: forceMaxMode ? 16 : AppLayoutMetrics.sideMargin,
            left: forceMaxMode ? 16 : AppLayoutMetrics.sideMargin,
            top: forceMaxMode
                ? _getPeriodSelectorTop()
                : _getTabsBottom(),
            bottom:
                MediaQuery.of(context).padding.bottom +
                MediaQuery.of(context).viewInsets.bottom +
                (forceMaxMode ? 0 : AppLayoutMetrics.gap),
            child: AnimatedBuilder(
              animation: _chatAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: AppGeometry.dialogRadius,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: AppGeometry.dialogRadius,
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.14),
                          blurRadius: 18,
                          spreadRadius: 0,
                          offset: const Offset(0, 8),
                        ),
                      ],
                      border: Border.all(
                        color: AppTheme.primaryRose.withValues(alpha: 0.16),
                        width: 1.2,
                      ),
                    ),
                    child: GestureDetector(
                      behavior: HitTestBehavior.deferToChild,
                      onTap: () {
                        FocusScope.of(context).unfocus();

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (!mounted) return;

                          _shellController.restoreDialogState();
                        });
                      },
                      child: Column(
                        children: [
                        // Enhanced Draggable Header with Controls
                        _buildEnhancedHeader(theme, compact: keyboardOpen),


                        // Main content area - improved spacing
                        Expanded(
                          child: _buildChatArea(theme),
                        ),

                        // Suggested Questions (above input)
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          child: keyboardOpen
                              ? const SizedBox.shrink()
                              : Container(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    2,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: _buildEnhancedQuickReplies(theme),
                                  ),
                                ),
                        ),

                        // Input Area (last = primary)
                        SizedBox(
                          height: MediaQuery.of(context).size.width > 900
                              ? 0
                              : 8,
                        ),
                        _buildEnhancedInput(theme, keyboardOpen),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

        // Enhanced Floating Action Button
        if (!_shellController.isExpanded)
          Positioned(
            right: 16,
            bottom: _shellController.isFullScreen
                ? (MediaQuery.of(context).padding.bottom +
                      MediaQuery.of(context).viewInsets.bottom)
                : (MediaQuery.of(context).padding.bottom +
                      MediaQuery.of(context).viewInsets.bottom +
                      16),
            child: AnimatedBuilder(
              animation: _fabAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _shellController.isExpanded ? 1.0 : (1.0 + _fabAnimation.value * 0.1),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: AppGeometry.capsuleRadius, // ZYRA_COMPACT_RADIUS_CENTRALIZATION
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryRose.withValues(alpha: 0.2),
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
                        child: _shellController.isExpanded
                            ? Icon(
                                Icons.close_rounded,
                                color: Theme.of(context).colorScheme.surface,
                                key: const ValueKey('close'),
                                size: 28,
                              )
                            : Stack(
                                key: const ValueKey('chat'),
                                children: [
                                  Icon(
                                    Icons.psychology_rounded,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.surface,
                                    size: 28,
                                  ),
                                  if (!_shellController.isExpanded)
                                    Positioned(
                                      top: -2,
                                      right: -2,
                                      child:
                                          Container(
                                                width: 16,
                                                height: 16,
                                                decoration: BoxDecoration(
                                                  gradient:
                                                      const LinearGradient(
                                                        colors: [
                                                          AppTheme.successGreen,
                                                          AppTheme.accentMint,
                                                        ],
                                                      ),
                                                  borderRadius:
                                                      AppGeometry.dialogRadius,
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: AppTheme
                                                          .successGreen
                                                          .withValues(
                                                            alpha: 0.5,
                                                          ),
                                                      blurRadius: 8,
                                                      spreadRadius: 4,
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.auto_awesome,
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.surface,
                                                  size: 10,
                                                ),
                                              )
                                              .animate(onPlay: null)
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

  // Enhanced Header with Controls
  Widget _buildEnhancedHeader(ThemeData theme, {bool compact = false}) {
    return Container(
      padding: EdgeInsets.all(compact ? 14 : 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppGeometry.dialogRadius, // ZYRA_HEADER_INPUT_LAYER_PATCH
      ),
      child: Column(
        children: [
          // Resize Handle - Only draggable area
          if (!_shellController.isFullScreen && !compact)
            Center(
              child: GestureDetector(
                onPanStart: (details) {
                  _initialHeight = _shellController.chatHeight;
                  _shellController.setResizing(true);
                },
                onPanUpdate: (details) {
                  if (!_shellController.isFullScreen && _shellController.isResizing) {
                    _adjustChatHeight(details.delta.dy);
                  }
                },
                onPanEnd: (details) {
                  _shellController.setResizing(false);
                },
                child: Container(
                  width: 16, // Larger hit area for better UX
                  height: 30, // Larger hit area
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: AppGeometry.capsuleRadius,
                    ),
                  ),
                ),
              ),
            ),
          if (!_shellController.isFullScreen && !compact) const SizedBox(height: 4),

          // Header Content
          Row(
            children: [
              // AI Avatar with Animation
              Container(
                    width: compact ? 42 : 48,
                    height: compact ? 42 : 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: AppGeometry.capsuleRadius,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Transform.scale(
                      scale: 0.965 + (_pulseController.value * 0.08),
                      child: Icon(
                        Icons.psychology_rounded,
                        color: Theme.of(context).colorScheme.surface,
                        size: 24,
                      ),
                    ),
                  )
                  .animate(onPlay: null)
                  .shimmer(
                    duration: 3000.ms,
                    color: Colors.white.withValues(alpha: 0.3),
                  )
                  .then(delay: 2000.ms),

              SizedBox(width: compact ? 12 : 16),

              // Title and Status
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Zyra AI',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Theme.of(context).colorScheme.surface,
                            fontWeight: FontWeight.w700,
                            fontSize: compact ? 17 : 18,
                            height: 1.0,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 950),
                          curve: Curves.easeInOutCubic,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: AppGeometry.capsuleRadius,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(
                                  alpha: 0.26 + (0.48 * _pulseController.value),
                                ),
                                blurRadius: 16 + (18 * _pulseController.value),
                                spreadRadius: 0.4,
                              ),
                            ],
                          ),
                          child: FadeTransition(
                            opacity: Tween(begin: 0.55, end: 1.0).animate(
                              CurvedAnimation(
                                parent: _pulseController,
                                curve: Curves.easeOut,
                              ),
                            ),
                            child: ScaleTransition(
                              scale: Tween(begin: 0.90, end: 1.03).animate(
                                CurvedAnimation(
                                  parent: _pulseController,
                                  curve: Curves.easeInOut,
                                ),
                              ),
                              child: Text(
                                'LIVE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: Theme.of(context).colorScheme.surface,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLiveStatusIndicator(),
                        const SizedBox(width: 6),
                        const SizedBox(width: 4),
                        Flexible(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: Colors.white.withValues(
                                alpha: _shellController.isTyping ? 0.9 : 0.78,
                              ),
                              fontSize: compact ? 12.5 : 13,
                              fontWeight: FontWeight.w400,
                              height: 1.05,
                              letterSpacing: _shellController.isTyping ? 0.08 : 0.0,
                            ),
                            child: Text(
                              _shellController.isTyping ? 'Thinking...' : 'Ready to assist',
                            ),
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
                      width: compact ? 42 : 48,
                      height: compact ? 42 : 48,
                      decoration: BoxDecoration(
                        borderRadius: AppGeometry.capsuleRadius,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        _shellController.isFullScreen
                            ? Icons.fullscreen_exit_rounded
                            : Icons.fullscreen_rounded,
                        color: Theme.of(context).colorScheme.surface,
                        size: 24,
                      ),
                    ),
                  ),

                  const SizedBox(width: 4),

                  // Close Button - Enhanced with better tap handling
                  GestureDetector(
                    onTap: _toggleChat,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: compact ? 42 : 48,
                      height: compact ? 42 : 48,
                      decoration: BoxDecoration(
                        borderRadius: AppGeometry.capsuleRadius,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Theme.of(context).colorScheme.surface,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          if (!compact) ...[
            // Medical Disclaimer (Guideline 1.4.1)
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: AppGeometry.capsuleRadius,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _getInsightsBannerText(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getInsightsBannerText() {
    if (_shellController.isTyping) {
      return 'Analyzing your patterns ✨' +
          '.' * ((_pulseController.value * 3).floor() + 1);
    }

    if (_messages.length > 1) {
      return 'Personalized insights based on your cycle data ⓘ';
    }

    return '✦ Personalized AI insights ⓘ Not medical advice';
  }

  // Stable Chat Area - replaces flutter_chat_ui AnimatedList
  Widget _buildChatArea(ThemeData theme) {
    final currentUserId = _chatService.currentUser?.id ?? 'fallback_user';

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        FocusScope.of(context).unfocus();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _shellController.restoreDialogState();
        });
      },
      child: ListView.builder(
        reverse: true,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final isUser = message.author.id == currentUserId;
          final text = message is types.TextMessage ? message.text : '';

          return Align(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.76,
              ),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [
                          AppTheme.primaryRose,
                          AppTheme.primaryPurple,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.surfaceContainer,
                          Theme.of(context).colorScheme.surface,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: AppGeometry.bubbleRadius,
                border: Border.all(
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.10)
                      : AppTheme.primaryRose.withValues(alpha: 0.22),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? AppTheme.primaryRose.withValues(alpha: 0.18)
                        : AppTheme.primaryPurple.withValues(alpha: 0.08),
                    blurRadius: 12,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Text(
                text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUser
                      ? Theme.of(context).colorScheme.surface
                      : theme.textTheme.bodyMedium?.color,
                  fontSize: 14,
                  height: 1.45,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Enhanced Quick Replies - More visible and professional
  Widget _buildEnhancedQuickReplies(ThemeData theme) {
    final suggestions = _chatService.getSuggestedReplies().toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header - More prominent
        InkWell(
          borderRadius: AppGeometry.dialogRadius,
          onTap: () {
            setState(() {
              _shellController.setQuickRepliesCollapsed(
                !_shellController.quickRepliesCollapsed,
              );
            });
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                    ),
                    borderRadius: AppGeometry.capsuleRadius,
                  ),
                  child: Icon(
                    Icons.auto_awesome_outlined,
                    color: Theme.of(context).colorScheme.surface,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Suggested Questions',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryRose,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                Icon(
                  _shellController.quickRepliesCollapsed
                      ? Icons.keyboard_arrow_down
                      : Icons.keyboard_arrow_up,
                  color: AppTheme.primaryRose,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 4),
        // Suggestions - Horizontal scrollable for better visibility
        if (!_shellController.quickRepliesCollapsed)
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
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
              _shellController.setTyping(true);
              _isSuggestionsExpanded = false;
              _shellController.setQuickRepliesCollapsed(true);
            });

            _chatService.sendMessage(message);
          },
          borderRadius: AppGeometry.dialogRadius,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryRose.withValues(alpha: 0.08),
                  AppTheme.primaryPurple.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: AppGeometry.capsuleRadius,
              border: Border.all(
                color: AppTheme.primaryRose.withValues(alpha: 0.2),
                width: 1,
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
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms, delay: (index * 100).ms)
        .slideX(begin: 0.3, end: 0);
  }

  Widget _buildLiveStatusIndicator() {
    final isThinking = _shellController.isTyping;
    final coreColor = isThinking ? AppTheme.primaryPurple : AppTheme.accentMint;
    final haloColor = isThinking
        ? AppTheme.primaryRose
        : AppTheme.secondaryBlue;
    final pulseDuration = isThinking ? 1050.ms : 1600.ms;
    final haloBegin = isThinking ? 0.82 : 0.76;
    final haloEnd = isThinking ? 1.28 : 1.18;
    final dotBegin = isThinking ? 0.94 : 0.97;
    final dotEnd = isThinking ? 1.09 : 1.05;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: haloColor.withValues(alpha: isThinking ? 0.20 : 0.18),
              ),
            )
            .animate(onPlay: null)
            .scaleXY(
              begin: haloBegin,
              end: haloEnd,
              duration: pulseDuration,
              curve: Curves.easeInOutCubic,
            )
            .fadeIn(duration: 180.ms)
            .then(delay: 120.ms)
            .fadeOut(duration: isThinking ? 520.ms : 900.ms),

        Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isThinking
                    ? const LinearGradient(
                        colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : const LinearGradient(
                        colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                color: null,
                boxShadow: [
                  BoxShadow(
                    color: coreColor.withValues(
                      alpha: isThinking ? 0.46 : 0.44,
                    ),
                    blurRadius: isThinking ? 13 : 10,
                    spreadRadius: isThinking ? 1.8 : 1.4,
                  ),
                ],
              ),
            )
            .animate(onPlay: null)
            .scaleXY(
              begin: dotBegin,
              end: dotEnd,
              duration: pulseDuration,
              curve: Curves.easeInOutCubic,
            ),
      ],
    );
  }

  // Enhanced Input Area - Better spacing and visibility
  Widget _buildEnhancedInput(ThemeData theme, bool keyboardOpen) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: keyboardOpen ? 6 : 8),
      decoration: const BoxDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: AppGeometry.inputHeight, maxHeight: keyboardOpen ? 64 : 120),
              child: TextField(
                textAlignVertical: TextAlignVertical.center,
                enableInteractiveSelection: false,
                controller: _textController,
                focusNode: _inputFocusNode,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: keyboardOpen ? 10 : 14,
                  ),
                  hintText: keyboardOpen
                      ? 'Tap the screen to view suggestions ✨'
                      : 'Ask about your cycle, symptoms, wellness, or lifestyle...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor.withValues(alpha: 0.7),
                    fontSize: keyboardOpen ? 14 : 15,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      Icons.send_rounded,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () {
                      final text = _textController.text.trim();
                      if (text.isNotEmpty) {
                        _handleSendPressed(types.PartialText(text: text));
                        _textController.clear();
                      }
                    },
                  ),
                  filled: true, // ZYRA_INPUT_SINGLE_SHELL_PATCH
                  fillColor: Theme.of(context).colorScheme.surface,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: AppGeometry.capsuleRadius,
                    borderSide: BorderSide(
                      color: AppTheme.primaryRose.withValues(alpha: 0.52),
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: AppGeometry.capsuleRadius,
                    borderSide: BorderSide(
                      color: AppTheme.primaryRose.withValues(alpha: 0.52),
                      width: 1,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: AppGeometry.capsuleRadius,
                    borderSide: BorderSide(
                      color: AppTheme.primaryRose.withValues(alpha: 0.52),
                      width: 1,
                    ),
                  ),
                ),
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14,
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
        ],
      ),
    );
  }
}