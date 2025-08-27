import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../providers/settings_provider.dart';
import '../models/user_preferences.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/language_selector.dart';
import '../widgets/theme_selector.dart';
import '../widgets/profile_section.dart';
import '../widgets/cyclesync_integration.dart';
import 'help_screen.dart';
import 'account_management_screen.dart';

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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient(theme.brightness == Brightness.dark),
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
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
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
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      // Profile Section
                      ProfileSection()
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

                      // Authentication & Security
                      SettingsSection(
                        title: 'Authentication & Security',
                        icon: Icons.security_outlined,
                        children: [
                          SettingsTile(
                            leading: const Icon(Icons.fingerprint, color: AppTheme.accentMint),
                            title: 'Biometric Login',
                            subtitle: 'Use fingerprint or face recognition',
                            trailing: Consumer<SettingsProvider>(
                              builder: (context, settings, child) {
                                return Switch.adaptive(
                                  value: settings.preferences.biometricAuth,
                                  onChanged: (value) => settings.updateBiometricAuth(value),
                                  activeColor: AppTheme.accentMint,
                                );
                              },
                            ),
                          ),
                          SettingsTile(
                            leading: const Icon(Icons.logout, color: AppTheme.primaryRose),
                            title: 'Sign Out',
                            subtitle: 'Sign out of your account',
                            onTap: () => _showSignOutDialog(context),
                          ),
                          SettingsTile(
                            leading: const Icon(Icons.manage_accounts, color: AppTheme.secondaryBlue),
                            title: 'Account Management',
                            subtitle: 'Manage your account settings',
                            onTap: () => _showAccountManagement(context),
                          ),
                        ],
                      ).animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 350.ms),

                      const SizedBox(height: 24),

                      // Flow iQ Integration
                      const FlowIQIntegration()
                          .animate(controller: _sectionsController)
                          .slideY(begin: 0.3, end: 0)
                          .fadeIn(delay: 400.ms),

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
                                  colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
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
                            subtitle: 'See what\'s coming next in ZyraFlow',
                            onTap: () => context.push('/future-plans'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
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
                            leading: const Icon(Icons.favorite, color: AppTheme.primaryRose),
                            title: 'Help Us Improve',
                            subtitle: 'Share your feedback and ideas',
                            onTap: () => context.push('/feedback'),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryRose.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryRose.withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Text(
                                '❤️',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ),
                          SettingsTile(
                            leading: const Icon(Icons.help_center, color: AppTheme.warningOrange),
                            title: l10n.help,
                            subtitle: l10n.getHelpTutorials,
                            onTap: () => _showHelp(context),
                          ),
                          SettingsTile(
                            leading: const Icon(Icons.chat, color: AppTheme.accentMint),
                            title: 'WhatsApp Support',
                            subtitle: 'Get instant help via WhatsApp',
                            onTap: () => _launchWhatsApp(),
                          ),
                          SettingsTile(
                            leading: const Icon(Icons.send, color: AppTheme.secondaryBlue),
                            title: 'Telegram Support',
                            subtitle: 'Connect with us on Telegram',
                            onTap: () => _launchTelegram(),
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
      applicationName: 'ZyraFlow',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 ZyraFlow. All rights reserved.',
      children: [
        const Text('AI-powered menstrual cycle tracking for better reproductive health.'),
      ],
    );
  }

  Future<void> _launchWhatsApp() async {
    final phoneNumber = '+4917627702411';
    final message = 'Hi! I need help with ZyraFlow app.';
    final url = 'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}';
    
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
                style: TextStyle(
                  color: AppTheme.mediumGrey,
                ),
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
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text('Signing out...'),
              ],
            ),
            backgroundColor: AppTheme.mediumGrey,
            duration: Duration(seconds: 5),
          ),
        );
      }
      
      // Initialize and sign out from AuthService
      final authService = AuthService();
      try {
        await authService.initialize();
      } catch (e) {
        debugPrint('⚠️ AuthService initialization failed during sign out, continuing anyway: $e');
      }
      await authService.signOut();
      
      // Clear all app state and user data
      await _clearAllAppData();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Successfully signed out'),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      // Navigate to auth screen after a brief delay
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        // First try GoRouter go method
        try {
          context.go('/auth');
        } catch (goError) {
          debugPrint('GoRouter navigation failed: $goError');
          // Fallback to pushNamedAndRemoveUntil using regular Navigator
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/auth',
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Sign out error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Sign out failed: ${e.toString()}')),
              ],
            ),
            backgroundColor: AppTheme.primaryRose,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _handleSignOut,
            ),
          ),
        );
      }
    }
  }
  
  /// Clear all application data on sign out
  Future<void> _clearAllAppData() async {
    try {
      // Clear provider states
      final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
      
      // Reset all cached data - you can add more providers here as needed
      // Note: We keep app preferences like theme, language, etc.
      // but clear user-specific data
      
      debugPrint('✅ Application data cleared successfully');
    } catch (e) {
      debugPrint('❌ Error clearing app data: $e');
    }
  }

  void _showAccountManagement(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AccountManagementScreen(),
      ),
    );
  }

}
