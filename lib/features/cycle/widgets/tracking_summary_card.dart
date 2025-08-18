import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/cycle_data.dart';
import 'package:intl/intl.dart';
import '../../../generated/app_localizations.dart';

class TrackingSummaryCard extends StatelessWidget {
  final CycleData cycleData;
  final VoidCallback? onEdit;

  const TrackingSummaryCard({
    super.key,
    required this.cycleData,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and edit button
          _buildHeader(context),
          
          const SizedBox(height: 20),
          
          // Flow intensity
          _buildFlowSection(),
          
          if (cycleData.symptoms.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSymptomsSection(),
          ],
          
          // Mood and Energy
          _buildMoodEnergySection(context),
          
          if (cycleData.pain != null && cycleData.pain! > 1) ...[
            const SizedBox(height: 16),
            _buildPainSection(),
          ],
          
          if (cycleData.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 16),
            _buildNotesSection(context),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3, end: 0);
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.day(_getCycleDay()),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
              Text(
                DateFormat.yMMMd(l10n.localeName).format(cycleData.createdAt),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mediumGrey,
                ),
              ),
            ],
          ),
        ),
        if (onEdit != null)
          IconButton(
            onPressed: onEdit,
            icon: const Icon(
              Icons.edit_rounded,
              color: AppTheme.mediumGrey,
            ),
          ),
      ],
    );
  }

  Widget _buildFlowSection() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _getFlowColor().withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              cycleData.flowIntensity.emoji,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Flow',
              style: const TextStyle(
                color: AppTheme.mediumGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              _getFlowText(context),
              style: TextStyle(
                color: _getFlowColor(),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSymptomsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Symptoms',
          style: const TextStyle(
            color: AppTheme.mediumGrey,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: cycleData.symptoms.take(4).map((symptom) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                symptom,
                style: const TextStyle(
                  color: AppTheme.secondaryBlue,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
        if (cycleData.symptoms.length > 4)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '+${cycleData.symptoms.length - 4} more',
              style: const TextStyle(
                color: AppTheme.mediumGrey,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMoodEnergySection(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Row(
      children: [
        if (cycleData.mood != null)
          Expanded(
            child: _buildStatItem(
              l10n.moodLabel,
              _getMoodEmoji(cycleData.mood!),
              _getMoodText(context, cycleData.mood!),
              AppTheme.primaryRose,
            ),
          ),
        if (cycleData.mood != null && cycleData.energy != null)
          const SizedBox(width: 16),
        if (cycleData.energy != null)
          Expanded(
            child: _buildStatItem(
              'Energy',
              _getEnergyEmoji(cycleData.energy!),
              _getEnergyText(context, cycleData.energy!),
              AppTheme.accentMint,
            ),
          ),
      ],
    );
  }

  Widget _buildPainSection() {
    return _buildStatItem(
      'Pain Level',
      _getPainEmoji(cycleData.pain!),
      _getPainText(context, cycleData.pain!),
      _getPainColor(cycleData.pain!),
    );
  }

  Widget _buildStatItem(String label, String emoji, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: AppTheme.mediumGrey,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.note_alt_rounded,
              size: 16,
              color: AppTheme.mediumGrey,
            ),
            SizedBox(width: 6),
            Text(
              'Notes',
              style: const TextStyle(
                color: AppTheme.mediumGrey,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.lightGrey.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            cycleData.notes!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.darkGrey,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Helper methods
  int _getCycleDay() {
    return DateTime.now().difference(cycleData.startDate).inDays + 1;
  }

  String _formatDateLocal(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context);
    return DateFormat.yMMMd(l10n.localeName).format(date);
  }

  Color _getFlowColor() {
    switch (cycleData.flowIntensity) {
      case FlowIntensity.none:
        return AppTheme.lightGrey;
      case FlowIntensity.spotting:
        return AppTheme.accentMint;
      case FlowIntensity.light:
        return AppTheme.secondaryBlue;
      case FlowIntensity.medium:
        return AppTheme.primaryPurple;
      case FlowIntensity.heavy:
        return AppTheme.primaryRose;
      case FlowIntensity.veryHeavy:
        return const Color(0xFFD32F2F);
    }
  }

  String _getFlowText(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (cycleData.flowIntensity) {
      case FlowIntensity.none:
        return l10n.flowIntensityNone;
      case FlowIntensity.spotting:
        return l10n.spotting;
      case FlowIntensity.light:
        return l10n.lightFlow;
      case FlowIntensity.medium:
        return l10n.normalFlow;
      case FlowIntensity.heavy:
        return l10n.heavyFlow;
      case FlowIntensity.veryHeavy:
        return l10n.veryHeavy;
    }
  }

  String _getMoodEmoji(double mood) {
    if (mood <= 1) return '😢';
    if (mood <= 2) return '😔';
    if (mood <= 3) return '😐';
    if (mood <= 4) return '😊';
    return '😄';
  }

  String _getMoodText(BuildContext context, double mood) {
    final l10n = AppLocalizations.of(context);
    if (mood <= 1) return 'Sad';
    if (mood <= 2) return 'Low';
    if (mood <= 3) return 'Neutral';
    if (mood <= 4) return 'Happy';
    return 'Great';
  }

  String _getEnergyEmoji(double energy) {
    if (energy <= 1) return '😴';
    if (energy <= 2) return '😪';
    if (energy <= 3) return '🙂';
    if (energy <= 4) return '⚡';
    return '🔥';
  }

  String _getEnergyText(BuildContext context, double energy) {
    // Map energy to generic localized labels
    final l10n = AppLocalizations.of(context);
    if (energy <= 1) return 'Low';
    if (energy <= 2) return 'Medium';
    if (energy <= 3) return 'Medium';
    if (energy <= 4) return 'High';
    return 'High';
  }

  String _getPainEmoji(double pain) {
    if (pain <= 1) return '😌';
    if (pain <= 2) return '😕';
    if (pain <= 3) return '😣';
    if (pain <= 4) return '😖';
    return '😫';
  }

  String _getPainText(BuildContext context, double pain) {
    final l10n = AppLocalizations.of(context);
    if (pain <= 1) return 'None';
    if (pain <= 2) return 'Mild';
    if (pain <= 3) return 'Moderate';
    if (pain <= 4) return 'Severe';
    return 'Severe';
  }

  Color _getPainColor(double pain) {
    if (pain <= 1) return AppTheme.accentMint;
    if (pain <= 2) return const Color(0xFFFFC107);
    if (pain <= 3) return const Color(0xFFFF9800);
    if (pain <= 4) return const Color(0xFFFF5722);
    return AppTheme.primaryRose;
  }
}
