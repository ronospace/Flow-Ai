import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../services/partner_service.dart';
import 'partner_invitation_actions.dart';

class PartnerInvitationQrTab extends StatelessWidget {
  final ThemeData theme;
  final PartnerInvitation? generatedInvitation;
  final bool isSent;
  final VoidCallback onGenerateCode;
  final VoidCallback onSaveQr;

  const PartnerInvitationQrTab({
    super.key,
    required this.theme,
    required this.generatedInvitation,
    required this.isSent,
    required this.onGenerateCode,
    required this.onSaveQr,
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
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryRose.withValues(alpha: 0.28),
                        blurRadius: 26,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (generatedInvitation != null)
                        QrImageView(
                          data: PartnerInvitationActions.generateInvitationLink(
                            generatedInvitation!,
                          ),
                          version: QrVersions.auto,
                          size: 176,
                          foregroundColor: AppTheme.darkGrey,
                        )
                      else
                        Container(
                          width: 176,
                          height: 176,
                          decoration: BoxDecoration(
                            color: AppTheme.lightGrey.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.qr_code,
                                size: 52,
                                color: AppTheme.mediumGrey,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Generate QR Code',
                                style: TextStyle(
                                  color: AppTheme.mediumGrey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 8),
                      Text(
                        'Scan to connect',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ).animate().scale(
                  begin: const Offset(0.92, 0.92),
                  curve: Curves.easeOutBack,
                ).fadeIn(delay: 120.ms),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onGenerateCode,
                        icon: const Icon(Icons.refresh, size: 20),
                        label: const Text('Generate Code'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryRose,
                          side: const BorderSide(width: 1.5, color: AppTheme.primaryRose),
                          minimumSize: const Size(double.infinity, 56),
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
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: generatedInvitation != null ? onSaveQr : null,
                        icon: const Icon(Icons.save, size: 20),
                        label: const Text('Save QR'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSent
                              ? AppTheme.primaryRose.withOpacity(0.35)
                              : AppTheme.primaryRose,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 56),
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
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
