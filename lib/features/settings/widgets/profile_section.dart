import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../models/user_preferences.dart';

class ProfileSection extends StatelessWidget {
  const ProfileSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final preferences = settings.preferences;
        
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).brightness == Brightness.dark
                    ? AppTheme.primaryRose.withValues(alpha: 0.8)
                    : Colors.white,
                AppTheme.primaryRose,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryRose.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar
              GestureDetector(
                onTap: () => _editAvatar(context, settings),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.accentMint, AppTheme.secondaryBlue],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: preferences.avatarUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 40,
                        )
                      : ClipOval(
                          child: Image.network(
                            preferences.avatarUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 40,
                              );
                            },
                          ),
                        ),
                ),
              ),

              const SizedBox(width: 20),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    GestureDetector(
                      onTap: () => _editDisplayName(context, settings),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              preferences.displayName.isEmpty 
                                  ? 'Tap to add your name'
                                  : preferences.displayName,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: preferences.displayName.isEmpty
                                    ? Colors.white.withValues(alpha: 0.7)
                                    : Colors.white,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.edit,
                            color: Colors.white.withValues(alpha: 0.7),
                            size: 18,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    // User ID or Email
                    Text(
                      'User ID: ${preferences.userId}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Quick Stats
                    Row(
                      children: [
                        _buildStatChip(
                          icon: Icons.language,
                          label: preferences.language.code.toUpperCase(),
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(width: 8),
                        _buildStatChip(
                          icon: preferences.notificationsEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          label: preferences.notificationsEnabled ? 'ON' : 'OFF',
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                        const SizedBox(width: 8),
                        if (preferences.syncWithCycleSync)
                          _buildStatChip(
                            icon: Icons.sync,
                            label: 'SYNC',
                            color: AppTheme.successGreen.withValues(alpha: 0.3),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _editDisplayName(BuildContext context, SettingsProvider settings) {
    final controller = TextEditingController(text: settings.preferences.displayName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter your display name',
            border: OutlineInputBorder(),
          ),
          maxLength: 50,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                HapticFeedback.lightImpact();
                await settings.updateDisplayName(name);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Display name updated!'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                  Navigator.pop(context);
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryRose,
            ),
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editAvatar(BuildContext context, SettingsProvider settings) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
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
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Change Avatar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAvatarOption(
                  context,
                  settings,
                  Icons.photo_camera,
                  'Camera',
                  () => _selectFromCamera(context, settings),
                ),
                _buildAvatarOption(
                  context,
                  settings,
                  Icons.photo_library,
                  'Gallery',
                  () => _selectFromGallery(context, settings),
                ),
                _buildAvatarOption(
                  context,
                  settings,
                  Icons.delete,
                  'Remove',
                  () => _removeAvatar(context, settings),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(
    BuildContext context,
    SettingsProvider settings,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  void _selectFromCamera(BuildContext context, SettingsProvider settings) {
    // TODO: Implement camera selection
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Camera selection coming soon!'),
        backgroundColor: AppTheme.secondaryBlue,
      ),
    );
  }

  void _selectFromGallery(BuildContext context, SettingsProvider settings) {
    // TODO: Implement gallery selection
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Gallery selection coming soon!'),
        backgroundColor: AppTheme.secondaryBlue,
      ),
    );
  }

  void _removeAvatar(BuildContext context, SettingsProvider settings) async {
    HapticFeedback.lightImpact();
    await settings.updateAvatar('');
    
    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Avatar removed!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }
}
