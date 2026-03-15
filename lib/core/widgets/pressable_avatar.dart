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

class _PressableAvatarState extends State<PressableAvatar> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.94);
  void _onTapUp(TapUpDetails details) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final photoUrl = widget.photoUrl;
    final displayName = widget.displayName;

    Widget avatarContent;

    if (photoUrl != null && photoUrl.isNotEmpty) {
      avatarContent = ClipOval(
        child: Image.network(
          photoUrl,
          width: 34,
          height: 34,
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

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: Container(
          width: 42,
          height: 42,
          padding: const EdgeInsets.all(2.4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6FA5),
                Color(0xFFC850F2),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFC850F2).withOpacity(0.28),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.scaffoldBackgroundColor,
            ),
            child: Center(child: avatarContent),
          ),
        ),
      ),
    );
  }

  Widget _fallbackIcon(ThemeData theme) {
    return Icon(Icons.person_rounded, size: 19, color: theme.colorScheme.primary);
  }
}
