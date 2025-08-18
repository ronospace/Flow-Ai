import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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
                                  value: settings.preferences.biometricEnabled,
                                  onChanged: settings.updateBiometricEnabled,
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
      applicationName: 'FlowSense',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2024 FlowSense. All rights reserved.',
      children: [
        const Text('AI-powered menstrual cycle tracking for better reproductive health.'),
      ],
    );
  }

  Future<void> _launchWhatsApp() async {
    final phoneNumber = '+4917627702411';
    final message = 'Hi! I need help with FlowSense app.';
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
          duration: Duration(seconds: 2),
        ),
      );
      
      // Perform sign out logic here
      // await AuthService().signOut();
      
      // Navigate to auth screen
      await Future.delayed(const Duration(milliseconds: 1000));
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/auth',
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sign out failed. Please try again.'),
            backgroundColor: AppTheme.primaryRose,
          ),
        );
      }
    }
  }

  void _showAccountManagement(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12),
                decoration: BoxDecoration(
                  color: AppTheme.lightGrey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Icon(
                        Icons.manage_accounts,
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
                            'Account Management',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.darkGrey,
                            ),
                          ),
                          Text(
                            'Manage your account and preferences',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppTheme.mediumGrey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Account Options
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  children: [
                    _buildAccountOption(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      subtitle: 'Update your personal information',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildAccountOption(
                      icon: Icons.lock_reset,
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildAccountOption(
                      icon: Icons.email,
                      title: 'Change Email',
                      subtitle: 'Update your email address',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildAccountOption(
                      icon: Icons.download,
                      title: 'Export Data',
                      subtitle: 'Download your tracking data',
                      onTap: () => Navigator.pop(context),
                    ),
                    _buildAccountOption(
                      icon: Icons.delete_forever,
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account',
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteAccountDialog(context);
                      },
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAccountOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive ? AppTheme.primaryRose : AppTheme.secondaryBlue;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppTheme.mediumGrey,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
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
                  Icons.warning,
                  color: AppTheme.primaryRose,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              const Text('Delete Account'),
            ],
          ),
          content: const Text(
            'This action cannot be undone. All your data including cycle history, insights, and preferences will be permanently deleted.',
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
                // Handle account deletion
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryRose,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
