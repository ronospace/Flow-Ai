import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../models/user_preferences.dart';
import '../providers/settings_provider.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.palette,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  AppLocalizations.of(context).chooseTheme,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                ),
              ],
            ),
          ).animate().slideY(begin: -0.3, end: 0).fadeIn(),

          // Theme Options
          Expanded(
            child: Consumer<SettingsProvider>(
              builder: (context, settings, child) {
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    _buildThemeOption(
                      context,
                      settings,
                      AppThemeMode.light,
                      AppLocalizations.of(context).lightTheme,
                      AppLocalizations.of(context).lightThemeDescription,
                      Icons.light_mode,
                      Colors.orange,
                    ).animate().slideX(begin: 0.3, end: 0).fadeIn(),
                    
                    const SizedBox(height: 12),
                    
                    _buildThemeOption(
                      context,
                      settings,
                      AppThemeMode.dark,
                      AppLocalizations.of(context).darkTheme,
                      AppLocalizations.of(context).darkThemeDescription,
                      Icons.dark_mode,
                      Colors.indigo,
                    ).animate().slideX(begin: 0.3, end: 0).fadeIn(delay: 100.ms),
                    
                    const SizedBox(height: 12),
                    
                    _buildThemeOption(
                      context,
                      settings,
                      AppThemeMode.system,
                      AppLocalizations.of(context).systemTheme,
                      AppLocalizations.of(context).systemThemeDescription,
                      Icons.settings_brightness,
                      Colors.purple,
                    ).animate().slideX(begin: 0.3, end: 0).fadeIn(delay: 200.ms),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    SettingsProvider settings,
    AppThemeMode themeMode,
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
  ) {
    final theme = Theme.of(context);
    final isSelected = settings.preferences.themeMode == themeMode;
    
    return Container(
      decoration: BoxDecoration(
        color: isSelected 
            ? AppTheme.primaryRose.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        border: isSelected 
            ? Border.all(color: AppTheme.primaryRose, width: 2)
            : Border.all(color: theme.colorScheme.outline),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isSelected 
                ? iconColor.withValues(alpha: 0.2)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isSelected ? iconColor : theme.colorScheme.onSurfaceVariant,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppTheme.primaryRose : theme.textTheme.bodyLarge?.color,
            fontSize: 16,
          ),
        ),
          subtitle: Text(
          subtitle,
          style: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        trailing: isSelected 
            ? const Icon(
                Icons.check_circle,
                color: AppTheme.primaryRose,
              )
            : Icon(
                Icons.circle_outlined,
                color: theme.colorScheme.outline,
              ),
        onTap: () async {
          if (!isSelected) {
            HapticFeedback.mediumImpact();
            await settings.updateThemeMode(themeMode);
            
            if (context.mounted) {
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${AppLocalizations.of(context).themeChangedTo} $title'),
                  backgroundColor: AppTheme.sweetPeach,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
              
              Navigator.pop(context);
            }
          }
        },
      ),
    );
  }
}
