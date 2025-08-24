import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SettingsTile extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;
  final EdgeInsetsGeometry? padding;

  const SettingsTile({
    super.key,
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.enabled = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? () {
          HapticFeedback.lightImpact();
          onTap?.call();
        } : null,
        child: Opacity(
          opacity: enabled ? 1.0 : 0.5,
          child: Padding(
            padding: effectivePadding,
            child: Row(
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: 16),
                ],
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                if (trailing != null) ...[
                  const SizedBox(width: 16),
                  trailing!,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
