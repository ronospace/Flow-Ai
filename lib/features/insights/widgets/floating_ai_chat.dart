import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:provider/provider.dart';

import '../../../core/services/enhanced_ai_chat_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../../settings/providers/settings_provider.dart';
import 'package:uuid/uuid.dart';

class FloatingAIChat extends StatefulWidget {
  const FloatingAIChat({super.key});

  @override
  State<FloatingAIChat> createState() => _FloatingAIChatState();
}

class _FloatingAIChatState extends State<FloatingAIChat> {
  final EnhancedAIChatService _chatService = EnhancedAIChatService();
  final TextEditingController _textController = TextEditingController();

  bool _isExpanded = false;
  bool _isTyping = false;
  bool _showQuickReplies = true;

  List<types.Message> _messages = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localizations = AppLocalizations.of(context);
      final settingsProvider = context.read<SettingsProvider>();
      final userPreferences = settingsProvider.preferences;

      final userName =
          userPreferences.displayName ??
          userPreferences.userId.split('_').last;

      _chatService.initialize(
        userId: userPreferences.userId,
        userName: userName,
        localizations: localizations,
      );
    });

    _chatService.messagesStream.listen((messages) {
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _isTyping = false;
      });
    });

    _messages = _chatService.messages;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _toggleChat() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _handleSendPressed(types.PartialText message) {
    final currentUser = _chatService.currentUser;
    final text = message.text.trim();

    if (currentUser == null || text.isEmpty) return;

    final textMessage = types.TextMessage(
      author: currentUser,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: const Uuid().v4(),
      text: text,
    );

    setState(() {
      _isTyping = true;
      _showQuickReplies = false;
    });

    _chatService.sendMessage(textMessage);
  }

  void _sendFromInput() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _handleSendPressed(types.PartialText(text: text));
    _textController.clear();
  }

  void _sendQuickReply(String text) {
    _handleSendPressed(types.PartialText(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        if (_isExpanded)
          Positioned(
            left: 12,
            right: 12,
            bottom: keyboardInset > 0 ? keyboardInset + 12 : 92,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: screenSize.height * 0.50,
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildHeader(context),
                  Expanded(child: _buildChatArea(context)),
                  if (_showQuickReplies && keyboardInset == 0)
                    _buildQuickReplies(context),
                  _buildInput(context),
                ],
              ),
            ),
          )
        else
          Positioned(
            right: 18,
            bottom: 104,
            child: GestureDetector(
              onTap: _toggleChat,
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryRose.withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryPurple, AppTheme.primaryRose],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.22),
              ),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.auto_awesome_rounded,
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
                  'Mira AI Assistant',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _isTyping ? 'Thinking...' : 'Ready to help',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.88),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleChat,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatArea(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Theme(
        data: theme.copyWith(primaryColor: AppTheme.primaryRose),
        child: Chat(
          messages: _messages,
          onSendPressed: _handleSendPressed,
          user: _chatService.currentUser ?? const types.User(id: 'fallback_user'),
          showUserAvatars: true,
          showUserNames: false,
          customBottomWidget: const SizedBox.shrink(),
          theme: DefaultChatTheme(
            primaryColor: AppTheme.primaryRose,
            secondaryColor: AppTheme.secondaryBlue.withValues(alpha: 0.10),
            backgroundColor: Colors.transparent,
            inputBackgroundColor: Colors.transparent,
            messageBorderRadius: 18,
            messageInsetsHorizontal: 18,
            messageInsetsVertical: 12,
            receivedMessageBodyTextStyle:
                theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  height: 1.45,
                ) ??
                const TextStyle(fontSize: 15, height: 1.45),
            sentMessageBodyTextStyle:
                theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.45,
                ) ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.45,
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickReplies(BuildContext context) {
    final theme = Theme.of(context);
    final suggestions = [
      'Next period?',
      'Am I fertile?',
      'Why late?',
      'Track symptoms',
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(10, 0, 10, 4),
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppTheme.primaryPurple.withValues(alpha: 0.14),
        ),
      ),
      child: SizedBox(
        height: 34,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: suggestions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final text = suggestions[index];
            return InkWell(
              onTap: () => _sendQuickReply(text),
              borderRadius: BorderRadius.circular(18),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryRose.withValues(alpha: 0.12),
                      AppTheme.primaryPurple.withValues(alpha: 0.12),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppTheme.primaryRose.withValues(alpha: 0.24),
                  ),
                ),
                child: Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.primaryRose,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              constraints: const BoxConstraints(maxHeight: 110),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: AppTheme.primaryRose.withValues(alpha: 0.18),
                  width: 1.2,
                ),
              ),
              child: TextField(
                controller: _textController,
                maxLines: null,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                textCapitalization: TextCapitalization.sentences,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 15,
                  height: 1.35,
                ),
                decoration: InputDecoration(
                  hintText: 'Ask about cycle, fertility, symptoms...',
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor.withValues(alpha: 0.72),
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _sendFromInput(),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withValues(alpha: 0.28),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _sendFromInput,
                borderRadius: BorderRadius.circular(22),
                child: const SizedBox(
                  width: 46,
                  height: 46,
                  child: Icon(
                    Icons.send_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
