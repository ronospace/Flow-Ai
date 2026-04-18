import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../services/partner_service.dart';
import 'partner_invitation_actions.dart';

class PartnerInvitationLinkTab extends StatelessWidget {
  final PartnerInvitation? generatedInvitation;
  final bool isSent;
  final VoidCallback onGenerateLink;
  final VoidCallback onShareLink;

  const PartnerInvitationLinkTab({
    super.key,
    required this.generatedInvitation,
    required this.isSent,
    required this.onGenerateLink,
    required this.onShareLink,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.link,
                        size: 48,
                        color: AppTheme.primaryRose,
                      ),
                      const SizedBox(height: 16),
                      if (generatedInvitation != null) ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.45),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  PartnerInvitationActions.generateInvitationLink(
                                    generatedInvitation!,
                                  ),
                                  style: TextStyle(
                                    color: AppTheme.mediumGrey,
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              IconButton(
                                onPressed: () => PartnerInvitationActions.copyToClipboard(
                                  PartnerInvitationActions.generateInvitationLink(
                                    generatedInvitation!,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.copy,
                                  color: AppTheme.primaryRose,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        Text(
                          'Link will appear here after generation',
                          style: TextStyle(color: AppTheme.mediumGrey),
                        ),
                      ],
                    ],
                  ),
                ).animate()
                 .fadeIn(delay: 120.ms)
                 .scale(
                   begin: const Offset(0.96, 0.96),
                   curve: Curves.easeOutBack,
                 ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onGenerateLink,
                        icon: const Icon(Icons.link),
                        label: const Text('Generate Link'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryRose,
                          side: BorderSide(color: AppTheme.primaryRose),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: generatedInvitation != null ? onShareLink : null,
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSent
                              ? AppTheme.primaryRose.withOpacity(0.35)
                              : AppTheme.primaryRose,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
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
