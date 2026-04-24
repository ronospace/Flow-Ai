import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class PartnerEmptyState extends StatelessWidget {
  final ThemeData theme;
  final VoidCallback onInvite;
  final VoidCallback onJoin;

  const PartnerEmptyState({
    super.key,
    required this.theme,
    required this.onInvite,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        
        children: [
          const SizedBox(height: 18),
          Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryRose.withValues(alpha: 0.1),
                      AppTheme.primaryPurple.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                ),
                child: Icon(
                  Icons.favorite_border,
                  size: 60,
                  color: AppTheme.primaryRose,
                ),
              )
              .animate()
              .scale(begin: const Offset(0.5, 0.5))
              .fadeIn(duration: 800.ms),
          const SizedBox(height: 16),
          Text(
            'Connect with Your Partner',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryRose,
            ),
          ).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 12),
          Text(
            'Share your cycle journey together\nGet support, insights, and stay connected',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.5,
            ),
          ).animate().fadeIn(delay: 400.ms),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: defaultTargetPlatform == TargetPlatform.iOS
                    ? 164
                    : 156,
                child: ElevatedButton.icon(
                  onPressed: onInvite,
                  icon: const Icon(Icons.send, size: 20),
                  label: const Text('Invite Partner'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRose,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: defaultTargetPlatform == TargetPlatform.iOS
                    ? 164
                    : 156,
                child: OutlinedButton.icon(
                  onPressed: onJoin,
                  icon: const Icon(Icons.link, size: 20),
                  label: const Text('Join Partner'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryRose,
                    side: const BorderSide(width: 1.8, color: AppTheme.primaryRose),
                    minimumSize: const Size(double.infinity, 54),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    visualDensity: VisualDensity.compact,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0),
          
        ],
      ),
    );
  }
}
