import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

class ZyraFlowAIChatV2 extends StatefulWidget {
  final VoidCallback onClose;

  const ZyraFlowAIChatV2({super.key, required this.onClose});

  @override
  State<ZyraFlowAIChatV2> createState() => _ZyraFlowAIChatV2State();
}

class _ZyraFlowAIChatV2State extends State<ZyraFlowAIChatV2> {
  final List<types.Message> _messages = [];
  final types.User _user = const types.User(id: "user");
  final types.User _bot = const types.User(id: "bot");

  final TextEditingController _controller = TextEditingController();
  bool _showQuickReplies = true;
  @override
  void initState() {
    super.initState();

    _messages.add(
      types.TextMessage(
        author: _bot,
        id: "welcome",
        text: "Hi, I’m Mira. I can help with your cycle, fertility, symptoms, and timing. What would you like to explore?",
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }


  void _handleSendPressed(types.PartialText message) {
    final text = message.text.trim();
    if (text.isEmpty) return;

    final userMessage = types.TextMessage(
      author: _user,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    setState(() {
      _messages.insert(0, userMessage);
      _showQuickReplies = false;
    });

    _controller.clear();

    Future.delayed(const Duration(milliseconds: 400), () {
      if (!mounted) return;

      final reply = types.TextMessage(
        author: _bot,
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "I'm here for you 💛",
        createdAt: DateTime.now().millisecondsSinceEpoch,
      );

      setState(() {
        _messages.insert(0, reply);
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          children: [
            _buildHeader(theme),

            Expanded(child: _buildChat()),

            if (_showQuickReplies && keyboard == 0)
              _buildQuickReplies(theme),

            _buildInput(theme, keyboard),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF56CAB), Color(0xFFB06AE3)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Mira AI Assistant",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Cycle • Fertility • Symptoms",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: widget.onClose,
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChat() {
    return Chat(
      onSendPressed: _handleSendPressed,
      messages: _messages,
      user: _user,
      showUserAvatars: false,
      customBottomWidget: const SizedBox.shrink(), // no internal input
    );
  }

  
  Widget _buildQuickReplies(ThemeData theme) {
    final items = [
      "Am I fertile?",
      "Why is my period late?",
      "Track my symptoms",
      "Cycle advice",
    ];

    return SizedBox(
      height: 60,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () {
            _handleSendPressed(types.PartialText(text: items[i]));
          },
          child: Chip(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),

            labelPadding: const EdgeInsets.symmetric(horizontal: 6),
            label: Text(
              items[i],
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }


Widget _buildInput(ThemeData theme, double keyboard) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.only(
        bottom: keyboard > 0 ? keyboard : 8,
        left: 12,
        right: 12,
        top: 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Ask about your cycle, fertility, symptoms...",
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: theme.colorScheme.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFFF56CAB),
              foregroundColor: Colors.white,
              minimumSize: const Size(52, 52),
            ),
            icon: const Icon(Icons.arrow_forward_rounded),
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                _handleSendPressed(types.PartialText(text: text));
              }
            },
          ),
        ],
      ),
    );
  }
}
