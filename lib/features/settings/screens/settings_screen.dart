import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../models/user_preferences.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/language_selector.dart';
import '../widgets/theme_selector.dart';
import '../widgets/profile_section.dart';
import '../widgets/cyclesync_integration.dart';
import 'help_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _sectionsController;

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
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient(Theme.of(context).brightness == Brightness.dark),
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
                            colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          size: 18,
                        ),
                      ).animate(controller: _headerController)
                        .scale(begin: const Offset(0, 0))
                        .fadeIn(),
                      const SizedBox(width: 12),
                      Text(
                        l10n.settings,
                        style: const TextStyle(
                          color: AppTheme.darkGrey,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ).animate(controller: _headerController)
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
                      const ProfileSection()
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(),
                      
                      const SizedBox(height: 24),

                      // App Preferences
                      SettingsSection(
                        title: l10n.appPreferences,
                        icon: Icons.palette_outlined,
                        children: [
                          SettingsTile(
                            leading: const Icon(Icons.palette, color: AppTheme.primaryRose),
                            title: l10n.theme,
                            subtitle: l10n.customizeAppearance,
                            onTap: () => _showThemeSelector(context),
                            trailing: Consumer<SettingsProvider>(
                              builder: (context, settings, child) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryRose.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    _getThemeName(settings.preferences.themeMode),
                                    style: const TextStyle(
                                      color: AppTheme.primaryRose,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SettingsTile(
                            leading: const Icon(Icons.language, color: AppTheme.accentMint),
                            title: l10n.language,
                            subtitle: l10n.chooseYourLanguage,
                            onTap: () => _showLanguageSelector(context),
                            trailing: Consumer<SettingsProvider>(
                              builder: (context, settings, child) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppTheme.accentMint.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    settings.preferences.language.displayName,
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
                      ).animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 100.ms),

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
                                  value: settings.preferences.notificationsEnabled,
                                  onChanged: settings.updateNotificationsEnabled,
                                  activeColor: AppTheme.secondaryBlue,
                                ),
                              );
                            },
                          ),
                          Consumer<SettingsProvider>(
                            builder: (context, settings, child) {
                              return SettingsTile(
                                leading: const Icon(Icons.access_time, color: AppTheme.primaryRose),
                                title: l10n.notificationTime,
                                subtitle: l10n.dailyReminders,
                                trailing: GestureDetector(
                                  onTap: () => _showTimePicker(context),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryRose.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: AppTheme.primaryRose.withValues(alpha: 0.3),
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
                                          settings.preferences.notificationTime.format(context),
                                          style: const TextStyle(
                                            color: AppTheme.primaryRose,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                enabled: settings.preferences.notificationsEnabled,
                              );
                            },
                          ),
                        ],
                      ).animate(controller: _sectionsController)
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
                                leading: const Icon(Icons.auto_awesome, color: AppTheme.warningOrange),
                                title: l10n.aiInsights,
                                subtitle: l10n.personalizedAiInsights,
                                trailing: Switch.adaptive(
                                  value: settings.preferences.aiInsightsEnabled,
                                  onChanged: settings.updateAiInsightsEnabled,
                                  activeColor: AppTheme.warningOrange,
                                ),
                              );
                            },
                          ),
                          Consumer<SettingsProvider>(
                            builder: (context, settings, child) {
                              return SettingsTile(
                                leading: const Icon(Icons.vibration, color: AppTheme.secondaryBlue),
                                title: l10n.hapticFeedback,
                                subtitle: l10n.vibrationInteractions,
                                trailing: Switch.adaptive(
                                  value: settings.preferences.hapticFeedbackEnabled,
                                  onChanged: settings.updateHapticFeedbackEnabled,
                                  activeColor: AppTheme.secondaryBlue,
                                ),
                              );
                            },
                          ),
                        ],
                      ).animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 300.ms),

                      const SizedBox(height: 24),

                      // CycleSync Integration
                      const CycleSyncIntegration()
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 400.ms),

                      const SizedBox(height: 24),

                      // Support & About
                      SettingsSection(
                        title: l10n.supportAbout,
                        icon: Icons.help_outline,
                        children: [
                          SettingsTile(
                            leading: const Icon(Icons.help_center, color: AppTheme.warningOrange),
                            title: l10n.help,
                            subtitle: l10n.getHelpTutorials,
                            onTap: () => _showHelp(context),
                          ),
                          SettingsTile(
                            leading: const Icon(Icons.info, color: AppTheme.mediumGrey),
                            title: l10n.about,
                            subtitle: l10n.versionInfoLegal,
                            onTap: () => _showAbout(context),
                          ),
                        ],
                      ).animate(controller: _sectionsController)
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

  String _getThemeName(AppThemeMode themeMode) {
    final l10n = AppLocalizations.of(context)!;
    switch (themeMode) {
      case AppThemeMode.light:
        return l10n.light;
      case AppThemeMode.dark:
        return l10n.dark;
      case AppThemeMode.system:
        return l10n.system;
    }
  }

  void _showThemeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const ThemeSelector(),
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
      MaterialPageRoute(
        builder: (context) => const HelpScreen(),
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'FlowSense',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 FlowSense. All rights reserved.',
      children: [
        const Text('AI-powered menstrual cycle tracking for better reproductive health.'),
      ],
    );
  }
}
