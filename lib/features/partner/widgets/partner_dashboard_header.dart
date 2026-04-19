import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/partner_avatar_badge.dart';
import '../widgets/partner_connection_stat.dart';

class PartnerDashboardHeader extends StatelessWidget {
  final Animation<double> animation;
  final String primaryUserName;
  final String partnerUserName;
  final DateTime createdAt;
  final int messageCount;
  final int careActionCount;

  const PartnerDashboardHeader({
    super.key,
    required this.animation,
    required this.primaryUserName,
    required this.partnerUserName,
    required this.createdAt,
    required this.messageCount,
    required this.careActionCount,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (animation.value * 0.2),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryRose.withValues(alpha: 0.1),
                  AppTheme.primaryPurple.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.primaryRose.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    PartnerAvatarBadge(name: primaryUserName, isPrimary: true),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        children: [
                          Container(
                                width: 60,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primaryRose,
                                      AppTheme.primaryPurple,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              )
                              .animate(onPlay: (c) => c.repeat())
                              .shimmer(duration: 2000.ms)
                              .then(delay: 1000.ms),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.warningOrange.withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppTheme.warningOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Partner sync disabled',
                                  style: TextStyle(
                                    color: AppTheme.warningOrange,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    PartnerAvatarBadge(name: partnerUserName, isPrimary: false),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    PartnerConnectionStat(
                      label: 'Days Connected',
                      value: '${DateTime.now().difference(createdAt).inDays}',
                      icon: Icons.favorite,
                      color: AppTheme.primaryRose,
                    ),
                    PartnerConnectionStat(
                      label: 'Messages',
                      value: '$messageCount',
                      icon: Icons.chat,
                      color: AppTheme.secondaryBlue,
                    ),
                    PartnerConnectionStat(
                      label: 'Care Actions',
                      value: '$careActionCount',
                      icon: Icons.healing,
                      color: AppTheme.accentMint,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
