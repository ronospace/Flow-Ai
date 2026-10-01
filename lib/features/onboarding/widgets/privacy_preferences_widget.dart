import 'dart:io';

import 'package:flutter/material.dart';

/// Onboarding privacy disclosure.
///
/// This screen intentionally contains no decorative consent switches.
/// Privacy controls must only appear where they govern real production
/// behavior.
class PrivacyPreferencesWidget extends StatelessWidget {
  const PrivacyPreferencesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shield_outlined,
                color: theme.colorScheme.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Privacy & Data',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Flow Ai shows privacy controls only where they are connected '
            'to real app behavior.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 28),
          _PrivacyFactCard(
            icon: Icons.health_and_safety_outlined,
            title: Platform.isIOS
                ? 'Apple Health access'
                : 'Android Health access',
            description: Platform.isIOS
                ? 'If you connect Apple Health, Flow Ai requests read access '
                      'only to the health categories you choose to share. '
                      'You can manage or revoke access from the Health screen '
                      'and iOS Health settings.'
                : 'If you connect Health Connect, Flow Ai requests read '
                      'access only to supported health categories you approve. '
                      'You can manage or revoke access from the Health screen '
                      'and Android Health Connect settings.',
          ),
          const SizedBox(height: 14),
          const _PrivacyFactCard(
            icon: Icons.auto_awesome_outlined,
            title: 'Online AI requests',
            description:
                'When you use Flow Ai online AI chat, your message and '
                'account identifier are sent over HTTPS to the configured '
                'AI service to generate a response. Do not include '
                'information you do not want processed by that service.',
          ),
          const SizedBox(height: 14),
          const _PrivacyFactCard(
            icon: Icons.save_outlined,
            title: 'Backup status',
            description:
                'Current backup support is local-only. Flow Ai does not '
                'currently provide cloud backup or cross-device cloud sync '
                'through the backup service.',
          ),
          const SizedBox(height: 14),
          const _PrivacyFactCard(
            icon: Icons.tune_outlined,
            title: 'Feature controls',
            description:
                'Health access is managed from the Health screen. '
                'Account and data-management actions are available from '
                'Account Management. Flow Ai does not present research, '
                'partner-sharing, marketing, cloud-backup, or AI-consent '
                'switches unless those controls are backed by production '
                'behavior.',
          ),
          const SizedBox(height: 28),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Flow Ai does not claim that all processing is '
                    'device-only. Network-backed features disclose when '
                    'information is sent off-device.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyFactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _PrivacyFactCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
