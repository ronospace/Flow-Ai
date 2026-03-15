import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/services/app_state_service.dart';
import '../../../core/services/data_export_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/app_logger.dart';
import '../../../core/ui/adaptive_messages.dart';
import '../../../generated/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../../cycle/providers/cycle_provider.dart';
import '../../insights/providers/insights_provider.dart';
import '../../health/providers/health_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';
import '../models/user_preferences.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/language_selector.dart';
import '../widgets/profile_section.dart';
import '../widgets/cyclesync_integration.dart';
import '../widgets/theme_switcher_card.dart';
import 'help_screen.dart';
import 'account_management_screen.dart';
import '../widgets/medical_citations_section.dart';
import 'dart:io';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _sectionsController;

  String get _platformDisclosureLabel => Platform.isIOS
      ? 'App Store Guideline 2.5.1 - HealthKit Transparency'
      : 'Required Disclosure';

  String get _platformIntegrationText => Platform.isIOS
      ? 'Flow Ai integrates with Apple HealthKit to enhance your experience:'
      : 'Flow Ai integrates with Health Connect to enhance your experience:';

  String get _platformManagePath => Platform.isIOS
      ? 'Settings → Health → Data Access & Devices → Flow Ai'
      : 'Settings → Apps → Health Connect → App permissions → Flow Ai';

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _sectionsController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _headerController.forward();
    _sectionsController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _sectionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(
            theme.brightness == Brightness.dark,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Custom App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
                  title: Row(
                    children: [
                      Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryRose,
                                  AppTheme.primaryPurple,
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 18,
                            ),
                          )
                          .animate(controller: _headerController)
                          .scale(begin: const Offset(0, 0))
                          .fadeIn(),
                      const SizedBox(width: 12),
                      Text(
                            l10n.settings,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                          .animate(controller: _headerController)
                          .slideX(begin: -0.3, end: 0)
                          .fadeIn(delay: 200.ms),
                    ],
                  ),
                ),
              ),

              // Settings Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Profile Section
                      ProfileSection()
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(),

                      const SizedBox(height: 24),

                      // Prominent Theme Switcher Card
                      const ThemeSwitcherCard()
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 50.ms),

                      const SizedBox(height: 24),

                      // App Preferences
                      SettingsSection(
                            title: l10n.appPreferences,
                            icon: Icons.language_outlined,
                            children: [
                              SettingsTile(
                                leading: const Icon(
                                  Icons.language,
                                  color: AppTheme.accentMint,
                                ),
                                title: l10n.language,
                                subtitle: l10n.chooseYourLanguage,
                                onTap: () => _showLanguageSelector(context),
                                trailing: Consumer<SettingsProvider>(
                                  builder: (context, settings, child) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.accentMint.withValues(
                                          alpha: 0.1,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        settings
                                            .preferences
                                            .language
                                            .displayName,
                                        style: const TextStyle(
                                          color: AppTheme.accentMint,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          )
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 100.ms),

                      const SizedBox(height: 24),

                      // Health Data & Privacy (Guideline 2.5.1 & 1.4.1)
                      SettingsSection(
                            title: 'Health Data',
                            icon: Icons.health_and_safety,
                            children: [
                              SettingsTile(
                                leading: const Icon(
                                  Icons.favorite,
                                  color: AppTheme.primaryRose,
                                ),
                                title: Platform.isIOS
                                    ? 'HealthKit Integration'
                                    : 'Health Connect Integration',
                                subtitle: Platform.isIOS
                                    ? 'Manage Apple HealthKit data access'
                                    : 'Manage Health Connect data access',
                                onTap: () => _showHealthKitInfo(context),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.privacy_tip,
                                  color: AppTheme.secondaryBlue,
                                ),
                                title: 'Health Data Privacy',
                                subtitle: 'Learn how your data is protected',
                                onTap: () => _showHealthDataPrivacy(context),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.medical_information,
                                  color: AppTheme.secondaryBlue,
                                ),
                                title: 'Medical Sources & Citations',
                                subtitle:
                                    'View all medical sources and citations (App Store 1.4.1)',
                                onTap: () => _showMedicalCitations(context),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                            ],
                          )
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 150.ms),

                      const SizedBox(height: 24),

                      // Notifications & Reminders
                      SettingsSection(
                            title: l10n.notifications,
                            icon: Icons.notifications_outlined,
                            children: [
                              Consumer<SettingsProvider>(
                                builder: (context, settings, child) {
                                  return SettingsTile(
                                    leading: Icon(
                                      settings.preferences.notificationsEnabled
                                          ? Icons.notifications_active
                                          : Icons.notifications_off,
                                      color: AppTheme.secondaryBlue,
                                    ),
                                    title: l10n.enableNotifications,
                                    subtitle: l10n.receiveReminders,
                                    trailing: Switch.adaptive(
                                      value: settings
                                          .preferences
                                          .notificationsEnabled,
                                      onChanged:
                                          settings.updateNotificationsEnabled,
                                      thumbColor:
                                          WidgetStateProperty.resolveWith(
                                            (states) =>
                                                states.contains(
                                                  WidgetState.selected,
                                                )
                                                ? AppTheme.secondaryBlue
                                                : null,
                                          ),
                                      trackColor:
                                          WidgetStateProperty.resolveWith(
                                            (states) =>
                                                states.contains(
                                                  WidgetState.selected,
                                                )
                                                ? AppTheme.secondaryBlue
                                                      .withValues(alpha: 0.5)
                                                : null,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              Consumer<SettingsProvider>(
                                builder: (context, settings, child) {
                                  return SettingsTile(
                                    leading: const Icon(
                                      Icons.access_time,
                                      color: AppTheme.primaryRose,
                                    ),
                                    title: l10n.notificationTime,
                                    subtitle: l10n.dailyReminders,
                                    trailing: GestureDetector(
                                      onTap: () => _showTimePicker(context),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryRose
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: AppTheme.primaryRose
                                                .withValues(alpha: 0.3),
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.access_time,
                                              color: AppTheme.primaryRose,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              settings
                                                  .preferences
                                                  .notificationTime
                                                  .format(context),
                                              style: const TextStyle(
                                                color: AppTheme.primaryRose,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    enabled: settings
                                        .preferences
                                        .notificationsEnabled,
                                  );
                                },
                              ),
                            ],
                          )
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 200.ms),

                      const SizedBox(height: 24),

                      // AI & Features
                      SettingsSection(
                            title: l10n.aiSmartFeatures,
                            icon: Icons.psychology_outlined,
                            children: [
                              Consumer<SettingsProvider>(
                                builder: (context, settings, child) {
                                  return SettingsTile(
                                    leading: const Icon(
                                      Icons.auto_awesome,
                                      color: AppTheme.warningOrange,
                                    ),
                                    title: l10n.aiInsights,
                                    subtitle: l10n.personalizedAiInsights,
                                    trailing: Switch.adaptive(
                                      value: settings
                                          .preferences
                                          .aiInsightsEnabled,
                                      onChanged:
                                          settings.updateAiInsightsEnabled,
                                      thumbColor:
                                          WidgetStateProperty.resolveWith(
                                            (states) =>
                                                states.contains(
                                                  WidgetState.selected,
                                                )
                                                ? AppTheme.warningOrange
                                                : null,
                                          ),
                                      trackColor:
                                          WidgetStateProperty.resolveWith(
                                            (states) =>
                                                states.contains(
                                                  WidgetState.selected,
                                                )
                                                ? AppTheme.warningOrange
                                                      .withValues(alpha: 0.5)
                                                : null,
                                          ),
                                    ),
                                  );
                                },
                              ),
                              Consumer<SettingsProvider>(
                                builder: (context, settings, child) {
                                  return SettingsTile(
                                    leading: const Icon(
                                      Icons.vibration,
                                      color: AppTheme.secondaryBlue,
                                    ),
                                    title: l10n.hapticFeedback,
                                    subtitle: l10n.vibrationInteractions,
                                    trailing: Switch.adaptive(
                                      value: settings
                                          .preferences
                                          .hapticFeedbackEnabled,
                                      onChanged:
                                          settings.updateHapticFeedbackEnabled,
                                      thumbColor:
                                          WidgetStateProperty.resolveWith(
                                            (states) =>
                                                states.contains(
                                                  WidgetState.selected,
                                                )
                                                ? AppTheme.secondaryBlue
                                                : null,
                                          ),
                                      trackColor:
                                          WidgetStateProperty.resolveWith(
                                            (states) =>
                                                states.contains(
                                                  WidgetState.selected,
                                                )
                                                ? AppTheme.secondaryBlue
                                                      .withValues(alpha: 0.5)
                                                : null,
                                          ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          )
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 300.ms),

                      const SizedBox(height: 24),

                      // Data & Privacy
                      SettingsSection(
                            title: 'Data & Privacy',
                            icon: Icons.cloud_download_outlined,
                            children: [
                              SettingsTile(
                                leading: const Icon(
                                  Icons.picture_as_pdf,
                                  color: AppTheme.primaryRose,
                                ),
                                title: 'Export as PDF',
                                subtitle: 'Download health report as PDF',
                                onTap: () =>
                                    _exportData(context, ExportFormat.pdf),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.table_chart,
                                  color: AppTheme.accentMint,
                                ),
                                title: 'Export as CSV',
                                subtitle:
                                    'Download data for spreadsheet analysis',
                                onTap: () =>
                                    _exportData(context, ExportFormat.csv),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.code,
                                  color: AppTheme.secondaryBlue,
                                ),
                                title: 'Export as JSON',
                                subtitle: 'Complete data backup in JSON format',
                                onTap: () =>
                                    _exportData(context, ExportFormat.json),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                            ],
                          )
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 300.ms),

                      const SizedBox(height: 24),

                      // Account & Security
                      SettingsSection(
                            title: 'Authentication & Security',
                            icon: Icons.security_outlined,
                            children: [
                              SettingsTile(
                                leading: const Icon(
                                  Icons.fingerprint,
                                  color: AppTheme.accentMint,
                                ),
                                title: 'Biometric Login',
                                subtitle: 'Use fingerprint or face recognition',
                                trailing: Consumer<SettingsProvider>(
                                  builder: (context, settings, child) {
                                    return Switch.adaptive(
                                      value: settings.preferences.biometricAuth,
                                      onChanged: (value) =>
                                          settings.updateBiometricAuth(value),
                                      thumbColor:
                                          WidgetStateProperty.resolveWith(
                                            (states) =>
                                                states.contains(
                                                  WidgetState.selected,
                                                )
                                                ? AppTheme.accentMint
                                                : null,
                                          ),
                                      trackColor:
                                          WidgetStateProperty.resolveWith(
                                            (states) =>
                                                states.contains(
                                                  WidgetState.selected,
                                                )
                                                ? AppTheme.accentMint
                                                      .withValues(alpha: 0.5)
                                                : null,
                                          ),
                                    );
                                  },
                                ),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.logout,
                                  color: AppTheme.primaryRose,
                                ),
                                title: 'Sign Out',
                                subtitle: 'Sign out of your account',
                                onTap: () => _showSignOutDialog(context),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.manage_accounts,
                                  color: AppTheme.secondaryBlue,
                                ),
                                title: 'Account Management',
                                subtitle: 'Manage your account settings',
                                onTap: () => _showAccountManagement(context),
                              ),
                            ],
                          )
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 350.ms),

                      const SizedBox(height: 24),

                      // Flow Ai Integration
                      const FlowIQIntegration()
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 400.ms),

                      const SizedBox(height: 24),

                      // Help & Tutorials
                      SettingsSection(
                            title: 'Help & Tutorials',
                            icon: Icons.school_outlined,
                            children: [
                              SettingsTile(
                                leading: const Icon(
                                  Icons.play_circle_outline,
                                  color: AppTheme.secondaryBlue,
                                ),
                                title: 'Interactive Tutorials',
                                subtitle: 'Learn how to use Flow Ai features',
                                onTap: () => _showTutorialsDialog(context),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.refresh,
                                  color: AppTheme.warningOrange,
                                ),
                                title: 'Reset Tutorials',
                                subtitle: 'See all tutorials again',
                                onTap: () => _resetAllTutorials(context),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.lock_open,
                                  color: AppTheme.accentMint,
                                ),
                                title: 'Feature Progress',
                                subtitle: 'View unlocked features and progress',
                                onTap: () => _showFeatureProgress(context),
                                trailing: const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                              ),
                            ],
                          )
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 450.ms),

                      const SizedBox(height: 24),

                      // Support & About
                      SettingsSection(
                            title: l10n.supportAbout,
                            icon: Icons.help_outline,
                            children: [
                              // Future Features Section
                              SettingsTile(
                                leading: Container(
                                  width: 24,
                                  height: 24,
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFF6C63FF),
                                        Color(0xFF9C27B0),
                                      ],
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.rocket_launch,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                ),
                                title: '🚀 Future Plans',
                                subtitle: 'See what\'s coming next in Flow Ai',
                                onTap: () => context.push('/future-plans'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6C63FF),
                                        Color(0xFF9C27B0),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.favorite,
                                  color: AppTheme.primaryRose,
                                ),
                                title: 'Help Us Improve',
                                subtitle: 'Share your feedback and ideas',
                                onTap: () => context.push('/feedback'),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryRose.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AppTheme.primaryRose.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    '❤️',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                ),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.help_center,
                                  color: AppTheme.warningOrange,
                                ),
                                title: l10n.help,
                                subtitle: l10n.getHelpTutorials,
                                onTap: () => _showHelp(context),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.chat,
                                  color: AppTheme.accentMint,
                                ),
                                title: 'WhatsApp Support',
                                subtitle: 'Get instant help via WhatsApp',
                                onTap: () => _launchWhatsApp(),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.send,
                                  color: AppTheme.secondaryBlue,
                                ),
                                title: 'Telegram Support',
                                subtitle: 'Connect with us on Telegram',
                                onTap: () => _launchTelegram(),
                              ),
                              SettingsTile(
                                leading: const Icon(
                                  Icons.info,
                                  color: AppTheme.mediumGrey,
                                ),
                                title: l10n.about,
                                subtitle: l10n.versionInfoLegal,
                                onTap: () => _showAbout(context),
                              ),
                            ],
                          )
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 500.ms),

                      const SizedBox(height: 100), // Bottom spacing
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const LanguageSelector(),
    );
  }

  void _showTimePicker(BuildContext context) async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final time = await showTimePicker(
      context: context,
      initialTime: settings.preferences.notificationTime,
    );

    if (time != null) {
      HapticFeedback.lightImpact();
      settings.updateNotificationTime(time);
    }
  }

  void _showHelp(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HelpScreen()),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Flow Ai',
      applicationVersion: '2.0.0',
      applicationLegalese: '© 2026 Flow Ai. All rights reserved.',
      children: [
        const Text(
          'AI-powered menstrual cycle tracking for better reproductive health.',
        ),
      ],
    );
  }

  void _showHealthKitFullDisclosure(BuildContext context) {
    final platformName = Platform.isIOS ? 'Apple HealthKit' : 'Health Connect';
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.health_and_safety, color: AppTheme.secondaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${platformName} Integration',
                style: TextStyle(color: AppTheme.secondaryBlue),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.warningOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: AppTheme.warningOrange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _platformDisclosureLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.warningOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                Platform.isIOS
                    ? 'Flow Ai uses Apple HealthKit to access your health data for enhanced cycle predictions and personalized insights.'
                    : 'Flow Ai uses Health Connect to access your health data for enhanced cycle predictions and personalized insights.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'We may access the following health data:',
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDisclosureItem(
                Icons.favorite,
                'Heart rate & HRV for cycle correlation',
              ),
              _buildDisclosureItem(
                Icons.thermostat,
                'Body temperature for ovulation tracking',
              ),
              _buildDisclosureItem(
                Icons.bedtime,
                'Sleep data for pattern analysis',
              ),
              _buildDisclosureItem(
                Icons.directions_walk,
                'Activity & steps for wellness insights',
              ),
              _buildDisclosureItem(
                Icons.water_drop,
                'Menstrual flow data (if tracked in HealthKit)',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 18,
                      color: AppTheme.successGreen,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This data is used exclusively to provide personalized cycle predictions, health insights, and pattern detection. We never sell or share your health data.',
                        style: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                Platform.isIOS
                    ? 'You can manage HealthKit access at any time in iOS Settings → Health → Data Access & Devices.'
                    : 'You can manage Health Connect access at any time in Android Settings → Apps → Health Connect → App permissions.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Could open iOS Settings here if needed
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryBlue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Manage in Settings'),
          ),
        ],
      ),
    );
  }

  Widget _buildDisclosureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.secondaryBlue.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  void _showHealthKitInfo(BuildContext context) {
    // Show the full disclosure dialog
    _showHealthKitFullDisclosure(context);
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.health_and_safety, color: AppTheme.primaryRose),
            const SizedBox(width: 12),
            Text(
              Platform.isIOS
                  ? 'HealthKit Integration'
                  : 'Health Connect Integration',
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _platformIntegrationText,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              _buildHealthDataItem(Icons.favorite, 'Heart rate & HRV'),
              _buildHealthDataItem(Icons.thermostat, 'Body temperature'),
              _buildHealthDataItem(Icons.bedtime, 'Sleep data'),
              _buildHealthDataItem(Icons.directions_walk, 'Activity & steps'),
              _buildHealthDataItem(Icons.water_drop, 'Menstrual flow'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.secondaryBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16,
                          color: AppTheme.secondaryBlue,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Manage Permissions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.secondaryBlue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _platformManagePath,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: TextStyle(color: AppTheme.primaryRose),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthDataItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.secondaryBlue.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  void _showMedicalCitations(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 600),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: const Text('Medical Sources & Citations'),
                automaticallyImplyLeading: false,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Expanded(child: MedicalCitationsSection()),
            ],
          ),
        ),
      ),
    );
  }

  void _showHealthDataPrivacy(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.privacy_tip, color: AppTheme.secondaryBlue),
            const SizedBox(width: 12),
            const Text('Health Data Privacy'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.successGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield, color: AppTheme.successGreen, size: 32),
                    const SizedBox(height: 12),
                    Text(
                      'Your Privacy is Protected',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.successGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '✓ Data encrypted on your device\n'
                      '✓ No data sold to third parties\n'
                      '✓ HIPAA compliant security\n'
                      '✓ Full control over permissions\n'
                      '✓ Delete data anytime',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () => _launchPrivacyPolicy(),
                icon: Icon(Icons.open_in_new, size: 16),
                label: const Text('Read Full Privacy Policy'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.secondaryBlue,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.secondaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchPrivacyPolicy() async {
    final url = Uri.parse('https://flowiq.app/privacy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchWhatsApp() async {
    final phoneNumber = '+4917627702411';
    final message = 'Hi! I need help with Flow Ai app.';
    final url =
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        HapticFeedback.lightImpact();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('WhatsApp is not installed on this device'),
              backgroundColor: AppTheme.primaryRose,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open WhatsApp'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchTelegram() async {
    const username = 'ronospace';
    const url = 'https://t.me/$username';

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
        HapticFeedback.lightImpact();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Telegram is not installed on this device'),
              backgroundColor: AppTheme.secondaryBlue,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error launching Telegram: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Telegram'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRose.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.logout,
                  color: AppTheme.primaryRose,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Text('Sign Out'),
            ],
          ),
          content: const Text(
            'Are you sure you want to sign out of your account? You can always sign back in later.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.mediumGrey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _handleSignOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRose,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleSignOut() async {
    try {
      // Show loading message using adaptive messaging
      if (mounted) {
        await AdaptiveMessages.showInfo(context, 'Signing out...');
      }

      AppLogger.auth('🔐 Starting comprehensive sign out process...');

      // Clear all app state and user data first
      await _clearAllAppData();

      // Reset app state using the centralized service
      final appStateService = AppStateService();
      await appStateService.resetAppState();

      AppLogger.auth('✅ Complete sign out successful - all user data cleared');

      // Show success message
      if (mounted) {
        await AdaptiveMessages.showSuccess(context, 'Signed out');
      }

      // Navigate to auth screen immediately
      if (mounted) {
        try {
          context.go('/auth');
          AppLogger.navigation('📱 Navigated to auth screen after sign out');
        } catch (goError) {
          AppLogger.error('GoRouter navigation failed: $goError');
          // Fallback to pushNamedAndRemoveUntil using regular Navigator
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/auth', (route) => false);
        }
      }
    } catch (e) {
      AppLogger.error('❌ Sign out error: $e');
      if (mounted) {
        await AdaptiveMessages.showError(
          context,
          'Sign out failed: ${e.toString()}',
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  /// Clear all application data on sign out
  Future<void> _clearAllAppData() async {
    try {
      AppLogger.auth('🧹 Clearing all application data...');

      // Clear all provider states but preserve app preferences (theme, language, etc.)
      try {
        // Clear cycle-related data
        final cycleProvider = Provider.of<CycleProvider>(
          context,
          listen: false,
        );
        cycleProvider.clearUserData();
        AppLogger.auth('✅ Cycle data cleared');
      } catch (e) {
        AppLogger.warning('⚠️ Failed to clear cycle data: $e');
      }

      try {
        // Clear insights and AI data
        final insightsProvider = Provider.of<InsightsProvider>(
          context,
          listen: false,
        );
        insightsProvider.clearUserData();
        AppLogger.auth('✅ Insights data cleared');
      } catch (e) {
        AppLogger.warning('⚠️ Failed to clear insights data: $e');
      }

      try {
        // Clear health data
        final healthProvider = Provider.of<HealthProvider>(
          context,
          listen: false,
        );
        healthProvider.clearUserData();
        AppLogger.auth('✅ Health data cleared');
      } catch (e) {
        AppLogger.warning('⚠️ Failed to clear health data: $e');
      }

      try {
        // Preserve onboarding state to avoid forcing onboarding again
        AppLogger.auth('ℹ️ Onboarding state preserved');
      } catch (e) {
        AppLogger.warning('⚠️ Failed to clear onboarding data: $e');
      }

      // Note: We intentionally preserve SettingsProvider data (theme, language, etc.)
      // as these are app preferences, not user-specific data

      AppLogger.auth(
        '✅ All user-specific application data cleared successfully',
      );
    } catch (e) {
      AppLogger.error('❌ Error clearing app data: $e');
      rethrow; // Re-throw to handle in the calling method
    }
  }

  void _showAccountManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountManagementScreen()),
    );
  }

  Future<void> _exportData(BuildContext context, ExportFormat format) async {
    // Show date range selector
    final dateRange = await _showDateRangeSelector(context);
    if (dateRange == null || !context.mounted) return;
    // Capture before async gap
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Show loading
    // Show loading
    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Exporting data...'),
              ],
            ),
          ),
        ),
      ),
    );
    try {
      final exportService = DataExportService();
      final filePath = await exportService.exportData(
        format: format,
        dateRange: dateRange,
      );

      if (!mounted) return;
      navigator.pop(); // Close loading

      if (filePath != null) {
        // Show success with share option
        _showExportSuccessAfterExport(messenger, navigator, filePath, format);
      } else {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Export failed. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      navigator.pop(); // Close loading
      messenger.showSnackBar(
        SnackBar(
          content: Text('Export error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<ExportDateRange?> _showDateRangeSelector(BuildContext context) async {
    return await showDialog<ExportDateRange>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Date Range'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Last 30 Days'),
              onTap: () => Navigator.pop(context, ExportDateRange.last30Days()),
            ),
            ListTile(
              title: const Text('Last 3 Months'),
              onTap: () =>
                  Navigator.pop(context, ExportDateRange.last3Months()),
            ),
            ListTile(
              title: const Text('Last 6 Months'),
              onTap: () =>
                  Navigator.pop(context, ExportDateRange.last6Months()),
            ),
            ListTile(
              title: const Text('Last 12 Months'),
              onTap: () =>
                  Navigator.pop(context, ExportDateRange.last12Months()),
            ),
            ListTile(
              title: const Text('All Time'),
              onTap: () => Navigator.pop(context, ExportDateRange.allTime()),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportSuccessAfterExport(
    ScaffoldMessengerState messenger,
    NavigatorState navigator,
    String filePath,
    ExportFormat format,
  ) {
    _showExportSuccess(navigator.context, filePath, format);
  }

  void _showExportSuccess(
    BuildContext context,
    String filePath,
    ExportFormat format,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successGreen),
            const SizedBox(width: 12),
            const Text('Export Successful'),
          ],
        ),
        content: Text(
          'Your data has been exported as ${format.name.toUpperCase()}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await DataExportService().shareExportedFile(filePath);
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showTutorialsDialog(BuildContext context) {
    final tutorials = [
      {'id': 'home', 'title': 'Home Dashboard', 'icon': Icons.home},
      {
        'id': 'calendar',
        'title': 'Cycle Calendar',
        'icon': Icons.calendar_month,
      },
      {
        'id': 'tracking',
        'title': 'Daily Tracking',
        'icon': Icons.track_changes,
      },
      {'id': 'insights', 'title': 'AI Insights', 'icon': Icons.insights},
      {'id': 'health', 'title': 'Health Dashboard', 'icon': Icons.favorite},
      {'id': 'settings', 'title': 'Settings', 'icon': Icons.settings},
      {'id': 'ai_coach', 'title': 'AI Coach', 'icon': Icons.smart_toy},
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Interactive Tutorials'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: tutorials.length,
            itemBuilder: (context, index) {
              final tutorial = tutorials[index];
              return ListTile(
                leading: Icon(
                  tutorial['icon'] as IconData,
                  color: AppTheme.primaryRose,
                ),
                title: Text(tutorial['title'] as String),
                subtitle: const Text('Tap to start tutorial'),
                trailing: const Icon(Icons.play_arrow),
                onTap: () {
                  Navigator.pop(context);
                  _startTutorial(context, tutorial['id'] as String);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _startTutorial(BuildContext context, String tutorialId) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final onboardingProvider = Provider.of<OnboardingProvider>(
        context,
        listen: false,
      );
      await onboardingProvider.startTutorial(tutorialId);

      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Tutorial "$tutorialId" will start shortly'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text('Failed to start tutorial: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _resetAllTutorials(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.refresh, color: AppTheme.warningOrange),
            const SizedBox(width: 12),
            const Text('Reset Tutorials'),
          ],
        ),
        content: const Text(
          'This will reset all tutorials so you can view them again. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningOrange,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      if (!context.mounted) return;
      // Capture before async gap
      final messenger = ScaffoldMessenger.of(context);
      try {
        final onboardingProvider = Provider.of<OnboardingProvider>(
          context,
          listen: false,
        );
        await onboardingProvider.resetAllTutorials();

        if (!mounted) return;
        HapticFeedback.mediumImpact();
        messenger.showSnackBar(
          const SnackBar(
            content: Text('All tutorials have been reset'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        messenger.showSnackBar(
          SnackBar(
            content: Text('Failed to reset tutorials: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

void _showFeatureProgress(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.lock_open, color: AppTheme.accentMint),
          const SizedBox(width: 12),
          const Text('Feature Progress'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Progressive feature unlocking helps you learn the app gradually. Track your progress below:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            _buildFeatureProgressItem('Basic Tracking', 1.0, 'Unlocked'),
            _buildFeatureProgressItem('Cycle Calendar', 0.8, '4/5 actions'),
            _buildFeatureProgressItem('AI Insights', 0.3, '3/10 entries'),
            _buildFeatureProgressItem('Health Dashboard', 0.0, 'Locked'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Widget _buildFeatureProgressItem(
  String title,
  double progress,
  String subtitle,
) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text(
              subtitle,
              style: TextStyle(
                color: progress == 1.0
                    ? AppTheme.successGreen
                    : AppTheme.mediumGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppTheme.lightGrey,
          valueColor: AlwaysStoppedAnimation<Color>(
            progress == 1.0 ? AppTheme.successGreen : AppTheme.primaryPurple,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    ),
  );
}
