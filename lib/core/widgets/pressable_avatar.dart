import 'package:flutter/material.dart';

class PressableAvatar extends StatefulWidget {
  final VoidCallback onTap;

  // identity (optional)
  final String? displayName;
  final String? photoUrl;

  const PressableAvatar({
    super.key,
    required this.onTap,
    this.displayName,
    this.photoUrl,
  });

  @override
  State<PressableAvatar> createState() => _PressableAvatarState();
}

class _PressableAvatarState extends State<PressableAvatar> with SingleTickerProviderStateMixin {
  double _scale = 1.0;
  late final AnimationController _glowController;


  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.85);
  void _onTapUp(TapUpDetails details) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final photoUrl = widget.photoUrl;
    final displayName = widget.displayName;

    Widget avatarContent;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      avatarContent = ClipOval(
        child: Image.network(
          photoUrl,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackIcon(theme),
        ),
      );
    } else if (displayName != null && displayName.trim().isNotEmpty) {
      final parts = displayName.trim().split(RegExp(r"\s+"));
      final initials =
          (parts.first[0] + (parts.length > 1 ? parts.last[0] : ""))
              .toUpperCase();

      avatarContent = Center(
        child: Text(
          initials,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      );
    } else {
      avatarContent = _fallbackIcon(theme);
    }

    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _glowController,
        builder: (context, child) {
          final glow = 0.10 + (_glowController.value * 0.12);
          return AnimatedScale(
            scale: _scale,
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [
                          theme.colorScheme.primary.withOpacity(0.20),
                          theme.colorScheme.surface.withOpacity(0.88),
                        ]
                      : [
                          Colors.white.withOpacity(0.92),
                          theme.colorScheme.primary.withOpacity(0.10),
                        ],
                ),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.22 + (_glowController.value * 0.12)),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(glow),
                    blurRadius: 16 + (_glowController.value * 8),
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: child,
            ),
          );
        },
        child: avatarContent,
      ),
    );
  }

  Widget _fallbackIcon(ThemeData theme) {
    return Icon(Icons.person, size: 20, color: theme.colorScheme.primary);
  }
}
