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

  void _onTapDown(TapDownDetails details) => setState(() => _scale = 0.85);
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
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackIcon(theme),
        ),
      );
    } else if (displayName != null && displayName.trim().isNotEmpty) {
      final parts = displayName.trim().split(RegExp(r"\s+"));
      final initials = (parts.first[0] + (parts.length > 1 ? parts.last[0] : ""))
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
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.25),
                Colors.white.withOpacity(0.08),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.primary.withOpacity(0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: avatarContent,
        ),
      ),
    );
  }

  Widget _fallbackIcon(ThemeData theme) {
    return Icon(
      Icons.person,
      size: 20,
      color: theme.colorScheme.primary,
    );
  }
}
