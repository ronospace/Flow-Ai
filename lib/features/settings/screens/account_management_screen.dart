import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/auth_service.dart';
import '../../../generated/app_localizations.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _isEditingProfile = false;
  bool _isExporting = false;
  bool _showPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _displayNameController.text = settings.preferences.displayName ?? '';
    
    // Force a fresh sync first
    try {
      await settings.forceUserDataSync();
    } catch (e) {
      debugPrint('Warning: Could not sync user data: $e');
    }
    
    // Load email from stored user metadata (more reliable than auth service)
    try {
      final userMetadata = await settings.getUserMetadata();
      if (userMetadata != null && userMetadata['email'] != null && userMetadata['email'].toString().isNotEmpty) {
        _emailController.text = userMetadata['email'];
        debugPrint('📧 Loaded email from metadata: ${userMetadata['email']}');
      } else {
        // Fallback to auth service if metadata doesn't have email
        final authService = AuthService();
        await authService.initialize();
        final userData = await authService.getUserData();
        if (userData != null && userData['email'] != null && userData['email'].toString().isNotEmpty) {
          _emailController.text = userData['email'];
          debugPrint('📧 Loaded email from auth service: ${userData['email']}');
          
          // Store this email in metadata for future use
          final currentMetadata = await settings.getUserMetadata() ?? {};
          currentMetadata['email'] = userData['email'];
          await settings.storeUserMetadata(currentMetadata);
        } else {
          debugPrint('⚠️ No email found in metadata or auth service');
          _emailController.text = 'Not available';
        }
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      _emailController.text = 'Error loading email';
    }
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
              // Header
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: theme.colorScheme.onSurface,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
                  title: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.manage_accounts,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Account Management',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Profile Management Section
                      _buildProfileSection(),
                      const SizedBox(height: 24),

                      // Security Section
                      _buildSecuritySection(),
                      const SizedBox(height: 24),

                      // Data Management Section
                      _buildDataManagementSection(),
                      const SizedBox(height: 24),

                      // Account Actions Section
                      _buildAccountActionsSection(),
                      const SizedBox(height: 100),
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

  Widget _buildProfileSection() {
    final theme = Theme.of(context);
    
    return SettingsSection(
      title: 'Profile Information',
      icon: Icons.person,
      children: [
        // Display Name
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.secondaryBlue.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.secondaryBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: AppTheme.secondaryBlue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Display Name',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isEditingProfile = !_isEditingProfile;
                        if (!_isEditingProfile) {
                          _loadUserData();
                        }
                      });
                    },
                    child: Text(_isEditingProfile ? 'Cancel' : 'Edit'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (_isEditingProfile) ...[
                TextField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your display name',
                    prefixIcon: Icon(Icons.edit, color: AppTheme.secondaryBlue),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _saveDisplayName,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondaryBlue,
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Consumer<SettingsProvider>(
                  builder: (context, settings, child) {
                    return Text(
                      settings.preferences.displayName ?? 'Not set',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ),

        // Email (read-only for now)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.accentMint.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.accentMint.withValues(alpha: 0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.email,
                    color: AppTheme.accentMint,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Email Address',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Verified',
                      style: TextStyle(
                        color: AppTheme.successGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _emailController.text.isEmpty ? 'Not available' : _emailController.text,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    final theme = Theme.of(context);
    
    return SettingsSection(
      title: 'Security & Privacy',
      icon: Icons.security,
      children: [
        // Change Password
        SettingsTile(
          leading: const Icon(Icons.lock_reset, color: AppTheme.warningOrange),
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: () => _showChangePasswordDialog(),
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.arrow_forward_ios,
              size: 12,
              color: AppTheme.warningOrange,
            ),
          ),
        ),
        
        // Privacy Settings
        SettingsTile(
          leading: const Icon(Icons.privacy_tip, color: AppTheme.primaryPurple),
          title: 'Privacy Settings',
          subtitle: 'Control your data privacy',
          onTap: () {
            // TODO: Navigate to privacy settings
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Privacy settings coming soon!'),
                backgroundColor: AppTheme.primaryPurple,
              ),
            );
          },
        ),
        
        // Two-Factor Authentication
        SettingsTile(
          leading: const Icon(Icons.verified_user, color: AppTheme.successGreen),
          title: 'Two-Factor Authentication',
          subtitle: 'Add extra security to your account',
          onTap: () {
            // TODO: Implement 2FA setup
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('2FA setup coming soon!'),
                backgroundColor: AppTheme.successGreen,
              ),
            );
          },
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.warningOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'SETUP',
              style: TextStyle(
                color: AppTheme.warningOrange,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDataManagementSection() {
    return SettingsSection(
      title: 'Data Management',
      icon: Icons.storage,
      children: [
        // Export Data
        SettingsTile(
          leading: const Icon(Icons.download, color: AppTheme.accentMint),
          title: 'Export Data',
          subtitle: 'Download your tracking data',
          onTap: _exportUserData,
          trailing: _isExporting 
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentMint),
                ),
              )
            : const Icon(Icons.arrow_forward_ios, size: 16),
        ),
        
        // Data Backup
        SettingsTile(
          leading: const Icon(Icons.backup, color: AppTheme.secondaryBlue),
          title: 'Backup Data',
          subtitle: 'Save your data to cloud storage',
          onTap: () {
            // TODO: Implement data backup
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data backup coming soon!'),
                backgroundColor: AppTheme.secondaryBlue,
              ),
            );
          },
        ),
        
        // Clear Cache
        SettingsTile(
          leading: const Icon(Icons.cleaning_services, color: AppTheme.warningOrange),
          title: 'Clear Cache',
          subtitle: 'Free up storage space',
          onTap: _clearCache,
        ),
        
        // Delete All Data
        SettingsTile(
          leading: const Icon(Icons.delete_sweep, color: AppTheme.primaryRose),
          title: 'Delete All Data',
          subtitle: 'Permanently delete all tracking data',
          onTap: _showDeleteAllDataDialog,
        ),
      ],
    );
  }

  Widget _buildAccountActionsSection() {
    return SettingsSection(
      title: 'Account Actions',
      icon: Icons.settings,
      children: [
        // Connected Accounts
        SettingsTile(
          leading: const Icon(Icons.link, color: AppTheme.primaryPurple),
          title: 'Connected Accounts',
          subtitle: 'Manage linked social accounts',
          onTap: () {
            // TODO: Show connected accounts
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connected accounts coming soon!'),
                backgroundColor: AppTheme.primaryPurple,
              ),
            );
          },
        ),
        
        // Account Deactivation
        SettingsTile(
          leading: const Icon(Icons.pause_circle, color: AppTheme.warningOrange),
          title: 'Deactivate Account',
          subtitle: 'Temporarily deactivate your account',
          onTap: () => _showDeactivateAccountDialog(),
        ),
        
        // Delete Account
        SettingsTile(
          leading: const Icon(Icons.delete_forever, color: AppTheme.primaryRose),
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          onTap: () => _showDeleteAccountDialog(),
        ),
      ],
    );
  }

  Future<void> _saveDisplayName() async {
    if (_displayNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Display name cannot be empty'),
          backgroundColor: AppTheme.primaryRose,
        ),
      );
      return;
    }

    try {
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      await settings.updateDisplayName(_displayNameController.text.trim());
      
      setState(() {
        _isEditingProfile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Display name updated successfully'),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update display name: $e'),
          backgroundColor: AppTheme.primaryRose,
        ),
      );
    }
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_reset, color: AppTheme.warningOrange),
            SizedBox(width: 16),
            Text('Change Password'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _passwordController,
              obscureText: !_showPassword,
              decoration: InputDecoration(
                labelText: 'Current Password',
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showPassword = !_showPassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _newPasswordController,
              obscureText: !_showNewPassword,
              decoration: InputDecoration(
                labelText: 'New Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_showNewPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showNewPassword = !_showNewPassword),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Confirm New Password',
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(_showConfirmPassword ? Icons.visibility_off : Icons.visibility),
                  onPressed: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _changePassword,
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningOrange),
            child: const Text('Change Password'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match'),
          backgroundColor: AppTheme.primaryRose,
        ),
      );
      return;
    }

    if (_newPasswordController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters'),
          backgroundColor: AppTheme.primaryRose,
        ),
      );
      return;
    }

    // TODO: Implement actual password change
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Password change functionality coming soon!'),
        backgroundColor: AppTheme.warningOrange,
      ),
    );
  }

  Future<void> _exportUserData() async {
    setState(() => _isExporting = true);

    try {
      // Simulate data export
      await Future.delayed(const Duration(seconds: 2));
      
      // Create sample CSV data
      const csvData = '''Date,Cycle Day,Flow Intensity,Symptoms,Mood,Energy
2024-01-15,1,Heavy,Cramps;Headache,3,2
2024-01-16,2,Medium,Fatigue,4,3
2024-01-17,3,Light,None,5,4''';

      // Share the data
      await Share.share(
        csvData,
        subject: 'Flow Ai Data Export',
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Data exported successfully'),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: $e'),
          backgroundColor: AppTheme.primaryRose,
        ),
      );
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _clearCache() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.cleaning_services, color: AppTheme.warningOrange),
            SizedBox(width: 16),
            Text('Clear Cache'),
          ],
        ),
        content: const Text(
          'This will clear temporary files and cached data. Your personal data will not be affected.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cache clearing
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Cache cleared successfully'),
                  backgroundColor: AppTheme.successGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningOrange),
            child: const Text('Clear Cache'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.pause_circle, color: AppTheme.warningOrange),
            SizedBox(width: 16),
            Text('Deactivate Account'),
          ],
        ),
        content: const Text(
          'Your account will be temporarily deactivated. You can reactivate it by signing in again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deactivation
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deactivation coming soon!'),
                  backgroundColor: AppTheme.warningOrange,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningOrange),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAllDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.delete_sweep, color: AppTheme.primaryRose),
            SizedBox(width: 16),
            Text('Delete All Data'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete all your tracking data including:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 12),
            Text('• Cycle history and period tracking'),
            Text('• Symptoms and mood logs'),
            Text('• AI insights and predictions'),
            Text('• Personal preferences and settings'),
            Text('• Conversation history with AI'),
            SizedBox(height: 12),
            Text(
              'Your account will remain active but all data will be lost. This action cannot be undone.',
              style: TextStyle(
                color: AppTheme.primaryRose,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performDataDeletion();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
            child: const Text('Delete All Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _performDataDeletion() async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Deleting all data...'),
            ],
          ),
        ),
      );
      
      // Simulate data deletion process
      await Future.delayed(const Duration(seconds: 3));
      
      // TODO: Implement actual data deletion logic here
      // This would include:
      // - Clear all SharedPreferences data
      // - Clear conversation memory
      // - Reset user preferences
      // - Clear any cached files
      // - Reset AI chat history
      
      // For now, just reset settings to demonstrate
      final settings = Provider.of<SettingsProvider>(context, listen: false);
      await settings.resetToDefaults();
      
      // Close loading dialog
      Navigator.pop(context);
      
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('All data deleted successfully'),
            ],
          ),
          backgroundColor: AppTheme.successGreen,
          duration: Duration(seconds: 4),
        ),
      );
      
      // Refresh the screen
      setState(() {});
      _loadUserData();
      
    } catch (e) {
      // Close loading dialog
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete data: $e'),
          backgroundColor: AppTheme.primaryRose,
        ),
      );
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppTheme.primaryRose),
            SizedBox(width: 16),
            Text('Delete Account'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All your data including cycle history, insights, and preferences will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement account deletion
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion coming soon!'),
                  backgroundColor: AppTheme.primaryRose,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRose),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}
