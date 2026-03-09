import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../services/partner_service.dart';

class PartnerPrivacySettingsScreen extends StatefulWidget {
  const PartnerPrivacySettingsScreen({super.key});

  @override
  State<PartnerPrivacySettingsScreen> createState() =>
      _PartnerPrivacySettingsScreenState();
}

class _PartnerPrivacySettingsScreenState
    extends State<PartnerPrivacySettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  PartnerSharingSettings? _currentSettings;
  PartnerSharingSettings? _tempSettings;
  bool _hasChanges = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();
    _loadCurrentSettings();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _loadCurrentSettings() {
    final partnerService = context.read<PartnerService>();
    if (partnerService.currentPartnership != null) {
      setState(() {
        _currentSettings = partnerService.currentPartnership!.sharingSettings;
        _tempSettings = _currentSettings;
      });
    }
  }

  void _updateSetting(
    PartnerSharingSettings Function(PartnerSharingSettings) update,
  ) {
    if (_tempSettings != null) {
      setState(() {
        _tempSettings = update(_tempSettings!);
        _hasChanges = _tempSettings != _currentSettings;
      });
    }
  }

  Future<void> _saveSettings() async {
    if (_tempSettings == null || !_hasChanges) return;

    setState(() => _isLoading = true);

    try {
      await context.read<PartnerService>().updateSharingSettings(
        _tempSettings!,
      );

      setState(() {
        _currentSettings = _tempSettings;
        _hasChanges = false;
      });

      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: const Text('Privacy settings updated successfully!'),
          backgroundColor: AppTheme.successGreen,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(
          content: Text('Failed to update settings: $e'),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetToDefaults() {
    setState(() {
      _tempSettings = const PartnerSharingSettings();
      _hasChanges = _tempSettings != _currentSettings;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_tempSettings == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Settings'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy & Sharing'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveSettings,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPrivacyOverview(theme),
                  const SizedBox(height: 24),

                  _buildSection(
                    'Cycle Data Sharing',
                    'Control what cycle information is shared with your partner',
                    Icons.favorite,
                    AppTheme.primaryRose,
                    [
                      _buildSwitchTile(
                        'Period Dates',
                        'Share when your period starts and ends',
                        _tempSettings!.sharePredictions,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sharePredictions: value),
                        ),
                        Icons.calendar_today,
                      ),
                      _buildSwitchTile(
                        'Cycle Predictions',
                        'Share AI predictions for future cycles',
                        _tempSettings!.sharePredictions,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sharePredictions: value),
                        ),
                        Icons.auto_graph,
                      ),
                      _buildSwitchTile(
                        'Ovulation Dates',
                        'Share fertile window and ovulation predictions',
                        _tempSettings!.sharePredictions,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sharePredictions: value),
                        ),
                        Icons.favorite_border,
                      ),
                      _buildSwitchTile(
                        'Flow Intensity',
                        'Share detailed flow intensity information',
                        _tempSettings!.sharePhysicalSymptoms,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sharePhysicalSymptoms: value),
                        ),
                        Icons.water_drop,
                        isAdvanced: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    'Symptoms & Health',
                    'Choose what health information to share',
                    Icons.healing,
                    AppTheme.secondaryBlue,
                    [
                      _buildSwitchTile(
                        'Basic Symptoms',
                        'Share common symptoms like cramps, headaches',
                        _tempSettings!.shareSymptoms,
                        (value) => _updateSetting(
                          (settings) => settings.copyWith(shareSymptoms: value),
                        ),
                        Icons.local_hospital,
                      ),
                      _buildSwitchTile(
                        'Detailed Symptoms',
                        'Share all symptoms and severity levels',
                        _tempSettings!.sharePhysicalSymptoms,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sharePhysicalSymptoms: value),
                        ),
                        Icons.assignment,
                        isAdvanced: true,
                      ),
                      _buildSwitchTile(
                        'Mood Data',
                        'Share mood tracking and emotional insights',
                        _tempSettings!.shareMoodData,
                        (value) => _updateSetting(
                          (settings) => settings.copyWith(shareMoodData: value),
                        ),
                        Icons.psychology,
                      ),
                      _buildSwitchTile(
                        'Pain Levels',
                        'Share pain intensity and location details',
                        _tempSettings!.sharePhysicalSymptoms,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sharePhysicalSymptoms: value),
                        ),
                        Icons.sentiment_very_dissatisfied,
                        isAdvanced: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    'AI Insights & Trends',
                    'Control sharing of AI-generated insights',
                    Icons.auto_awesome,
                    AppTheme.accentMint,
                    [
                      _buildSwitchTile(
                        'AI Health Insights',
                        'Share personalized AI health recommendations',
                        _tempSettings!.allowInsights,
                        (value) => _updateSetting(
                          (settings) => settings.copyWith(allowInsights: value),
                        ),
                        Icons.psychology,
                      ),
                      _buildSwitchTile(
                        'Health Trends',
                        'Share long-term health pattern analysis',
                        _tempSettings!.allowInsights,
                        (value) => _updateSetting(
                          (settings) => settings.copyWith(allowInsights: value),
                        ),
                        Icons.trending_up,
                      ),
                      _buildSwitchTile(
                        'Personal Notes',
                        'Share your private journal entries and notes',
                        _tempSettings!.shareSymptoms,
                        (value) => _updateSetting(
                          (settings) => settings.copyWith(shareSymptoms: value),
                        ),
                        Icons.note,
                        isAdvanced: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    'Communication & Notifications',
                    'Manage how your partner can communicate with you',
                    Icons.notifications,
                    AppTheme.warningOrange,
                    [
                      _buildSwitchTile(
                        'Partner Messages',
                        'Allow your partner to send you messages',
                        _tempSettings!.sendNotifications,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sendNotifications: value),
                        ),
                        Icons.chat,
                      ),
                      _buildSwitchTile(
                        'Care Reminders',
                        'Receive care suggestions from your partner',
                        _tempSettings!.sendNotifications,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sendNotifications: value),
                        ),
                        Icons.favorite,
                      ),
                      _buildSwitchTile(
                        'Mood Check-ins',
                        'Allow partner to check on your mood',
                        _tempSettings!.sendNotifications,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sendNotifications: value),
                        ),
                        Icons.sentiment_satisfied,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    'Notification Preferences',
                    'Choose what notifications your partner receives',
                    Icons.notification_important,
                    AppTheme.primaryPurple,
                    [
                      _buildSwitchTile(
                        'Period Start/End',
                        'Notify partner when period starts or ends',
                        _tempSettings!.sendNotifications &&
                            _tempSettings!.sendNotifications,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sendNotifications: value),
                        ),
                        Icons.event,
                      ),
                      _buildSwitchTile(
                        'Ovulation Notifications',
                        'Notify partner about ovulation timing',
                        _tempSettings!.sendNotifications,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sendNotifications: value),
                        ),
                        Icons.favorite_border,
                      ),
                      _buildSwitchTile(
                        'Mood Changes',
                        'Notify partner about significant mood changes',
                        _tempSettings!.sendNotifications,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sendNotifications: value),
                        ),
                        Icons.psychology,
                      ),
                      _buildSwitchTile(
                        'Symptom Alerts',
                        'Notify partner about new or severe symptoms',
                        _tempSettings!.sendNotifications,
                        (value) => _updateSetting(
                          (settings) =>
                              settings.copyWith(sendNotifications: value),
                        ),
                        Icons.warning,
                        isAdvanced: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  _buildSection(
                    'Advanced Privacy',
                    'Additional privacy and visibility controls',
                    Icons.security,
                    AppTheme.darkGrey,
                    [
                      _buildSwitchTile(
                        'Hide During Period',
                        'Reduce visibility to partner during menstruation',
                        _tempSettings!.allowInsights,
                        (value) => _updateSetting(
                          (settings) => settings.copyWith(allowInsights: value),
                        ),
                        Icons.visibility_off,
                        isAdvanced: true,
                      ),
                      _buildSwitchTile(
                        'Hide Detailed Health Data',
                        'Hide sensitive health metrics and details',
                        _tempSettings!.allowInsights,
                        (value) => _updateSetting(
                          (settings) => settings.copyWith(allowInsights: value),
                        ),
                        Icons.shield,
                        isAdvanced: true,
                      ),
                      _buildSwitchTile(
                        'Allow History Access',
                        'Let partner view historical cycle data',
                        _tempSettings!.allowInsights,
                        (value) => _updateSetting(
                          (settings) => settings.copyWith(allowInsights: value),
                        ),
                        Icons.history,
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  _buildActionButtons(theme),

                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrivacyOverview(ThemeData theme) {
    return Container(
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryRose.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.shield, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Privacy Matters',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    Text(
                      'You have complete control over what you share',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildPrivacyMetric(
                'Shared',
                _getSharedCount(),
                AppTheme.successGreen,
              ),
              const SizedBox(width: 16),
              _buildPrivacyMetric(
                'Private',
                _getPrivateCount(),
                AppTheme.warningOrange,
              ),
              const SizedBox(width: 16),
              _buildPrivacyMetric(
                'Advanced',
                _getAdvancedCount(),
                AppTheme.secondaryBlue,
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildPrivacyMetric(String label, int count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.1),
                  color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
    IconData icon, {
    bool isAdvanced = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.lightGrey.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (value ? AppTheme.successGreen : AppTheme.lightGrey)
                  .withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? AppTheme.successGreen : AppTheme.mediumGrey,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    if (isAdvanced) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.warningOrange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'ADVANCED',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.warningOrange,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: AppTheme.mediumGrey),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            thumbColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppTheme.primaryRose
                  : null,
            ),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppTheme.primaryRose.withValues(alpha: 0.5)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Column(
      children: [
        if (_hasChanges) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.warningOrange.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: AppTheme.warningOrange, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You have unsaved changes. Don\'t forget to save!',
                    style: TextStyle(
                      color: AppTheme.warningOrange,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().shake(delay: 100.ms),
          const SizedBox(height: 16),
        ],

        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _resetToDefaults,
                icon: const Icon(Icons.refresh),
                label: const Text('Reset to Defaults'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.mediumGrey,
                  side: BorderSide(color: AppTheme.mediumGrey),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            if (_hasChanges) ...[
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _saveSettings,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryRose,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  int _getSharedCount() {
    if (_tempSettings == null) return 0;
    int count = 0;
    if (_tempSettings!.sharePredictions) count++;
    if (_tempSettings!.sharePredictions) count++;
    if (_tempSettings!.sharePredictions) count++;
    if (_tempSettings!.shareSymptoms) count++;
    if (_tempSettings!.shareMoodData) count++;
    if (_tempSettings!.allowInsights) count++;
    if (_tempSettings!.allowInsights) count++;
    if (_tempSettings!.sendNotifications) count++;
    if (_tempSettings!.sendNotifications) count++;
    if (_tempSettings!.sendNotifications) count++;
    if (_tempSettings!.sendNotifications) count++;
    if (_tempSettings!.sendNotifications) count++;
    if (_tempSettings!.sendNotifications) count++;
    if (_tempSettings!.allowInsights) count++;
    return count;
  }

  int _getPrivateCount() {
    return 14 - _getSharedCount() - _getAdvancedCount();
  }

  int _getAdvancedCount() {
    if (_tempSettings == null) return 0;
    int count = 0;
    if (_tempSettings!.sharePhysicalSymptoms) count++;
    if (_tempSettings!.sharePhysicalSymptoms) count++;
    if (_tempSettings!.sharePhysicalSymptoms) count++;
    if (_tempSettings!.shareSymptoms) count++;
    if (_tempSettings!.sendNotifications) count++;
    if (_tempSettings!.allowInsights) count++;
    if (_tempSettings!.allowInsights) count++;
    return count;
  }
}
