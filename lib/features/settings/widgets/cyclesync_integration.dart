import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';

class FlowIQIntegration extends StatefulWidget {
  const FlowIQIntegration({super.key});

  @override
  State<FlowIQIntegration> createState() => _FlowIQIntegrationState();
}

class _FlowIQIntegrationState extends State<FlowIQIntegration> {
  bool _isConnecting = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isConnected = settings.preferences.syncWithCycleSync;
        
        return SettingsSection(
          title: 'Flow iQ Integration',
          icon: Icons.local_hospital_outlined,
          children: [
            // Connection Status
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    isConnected 
                        ? AppTheme.successGreen.withValues(alpha: 0.1)
                        : AppTheme.warningOrange.withValues(alpha: 0.1),
                    isConnected 
                        ? AppTheme.accentMint.withValues(alpha: 0.05)
                        : AppTheme.primaryRose.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isConnected 
                      ? AppTheme.successGreen.withValues(alpha: 0.3)
                      : AppTheme.warningOrange.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isConnected 
                                ? [AppTheme.successGreen, AppTheme.accentMint]
                                : [AppTheme.warningOrange, AppTheme.primaryRose],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          isConnected ? Icons.sync : Icons.sync_disabled,
                          color: Colors.white,
                          size: 24,
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
                                  isConnected ? 'Connected' : 'Not Connected',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: isConnected 
                                        ? AppTheme.successGreen
                                        : AppTheme.warningOrange,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: isConnected 
                                        ? AppTheme.successGreen
                                        : AppTheme.warningOrange,
                                    shape: BoxShape.circle,
                                  ),
                                ).animate(onPlay: (controller) => controller.repeat())
                                  .fadeIn(duration: 1000.ms)
                                  .then(delay: 500.ms)
                                  .fadeOut(duration: 1000.ms),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isConnected
                                  ? 'Your data syncs with Flow iQ Clinical'
                                  : 'Connect to sync your cycle data with clinical app',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  if (isConnected) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.account_circle,
                            color: AppTheme.successGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Synced Account',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  settings.preferences.cycleSyncUserId ?? 'Unknown',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.successGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Connection Toggle
            SettingsTile(
              leading: Icon(
                isConnected ? Icons.sync : Icons.sync_disabled,
                color: isConnected ? AppTheme.successGreen : AppTheme.warningOrange,
              ),
              title: isConnected ? 'Disconnect Flow iQ' : 'Connect to Flow iQ',
              subtitle: isConnected 
                  ? 'Stop syncing with Flow iQ Clinical'
                  : 'Sync your cycle data with Flow iQ Clinical',
              trailing: _isConnecting
                  ? const SizedBox(width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryRose),
                      ),
                    )
                  : Switch.adaptive(
                      value: isConnected,
                      onChanged: (value) => _toggleConnection(context, settings, value),
                      activeColor: AppTheme.successGreen,
                    ),
            ),

            if (isConnected) ...[
              SettingsTile(
                leading: const Icon(Icons.cloud_sync, color: AppTheme.secondaryBlue),
                title: 'Sync Now',
                subtitle: 'Manually sync your latest data',
                onTap: () => _syncNow(context, settings),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 16,
                ),
              ),
              
              SettingsTile(
                leading: const Icon(Icons.history, color: AppTheme.accentMint),
                title: 'Sync History',
                subtitle: 'View sync activity and conflicts',
                onTap: () => _showSyncHistory(context),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  size: 16,
                ),
              ),
            ],

            // CycleSync Info
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: AppTheme.secondaryBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'About CycleSync Integration',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Connect FlowSense with CycleSync Enterprise to sync your menstrual cycle data across platforms. Your data remains secure and encrypted during transfer.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => _learnMore(context),
                    child: const Row(
                      children: [
                        Text(
                          'Learn More',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.secondaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward,
                          color: AppTheme.secondaryBlue,
                          size: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleConnection(BuildContext context, SettingsProvider settings, bool value) async {
    setState(() {
      _isConnecting = true;
    });

    try {
      HapticFeedback.mediumImpact();
      
      if (value) {
        // Connect to CycleSync
        await _connectToCycleSync(context, settings);
      } else {
        // Disconnect from CycleSync
        await settings.updateCycleSyncIntegration(false, null);
        
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: const Text('Disconnected from CycleSync'),
              backgroundColor: AppTheme.warningOrange,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConnecting = false;
        });
      }
    }
  }

  Future<void> _connectToCycleSync(BuildContext context, SettingsProvider settings) async {
    // Show consent dialog first
    final consent = await _showConsentDialog(context);
    
    if (!consent) {
      return; // User declined consent
    }
    
    // Proceed with connection if user consented
    await Future.delayed(const Duration(seconds: 2));
    
    // Generate a mock user ID for CycleSync
    final cycleSyncUserId = 'cyclesync_${DateTime.now().millisecondsSinceEpoch}';
    
    await settings.updateCycleSyncIntegration(true, cycleSyncUserId);
    
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Successfully connected to CycleSync!'),
          backgroundColor: AppTheme.successGreen,
          action: SnackBarAction(
            label: 'Sync Now',
            textColor: Colors.white,
            onPressed: () => _syncNow(context, settings),
          ),
        ),
      );
    }
  }

  void _syncNow(BuildContext context, SettingsProvider settings) {
    HapticFeedback.lightImpact();
    
    // Show sync in progress
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.successGreen),
            ),
            const SizedBox(height: 16),
            const Text('Syncing with CycleSync...'),
          ],
        ),
      ),
    );
    
    // Simulate sync process
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Sync completed successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    });
  }

  void _showSyncHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.only(
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
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Sync History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 20),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.history,
                      size: 64,
                      color: AppTheme.lightGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Sync history will appear here',
                      style: TextStyle(
                        color: AppTheme.mediumGrey,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showConsentDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryRose, AppTheme.secondaryBlue],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.sync,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Connect to CycleSync',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'By connecting to CycleSync Enterprise, you agree to:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              const Text('• Share your menstrual cycle data with CycleSync'),
              const Text('• Allow data synchronization across platforms'),
              const Text('• Enable enhanced AI-powered health insights'),
              const Text('• Receive personalized recommendations'),
              const SizedBox(height: 16),
              Text(
                'Your data privacy:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.successGreen,
                ),
              ),
              const SizedBox(height: 8),
              const Text('✓ Data is encrypted during transfer'),
              const Text('✓ You can disconnect at any time'),
              const Text('✓ Your data remains under your control'),
              const Text('✓ Complies with healthcare privacy standards'),
              const SizedBox(height: 16),
              Text(
                'Do you consent to connect your FlowSense data with CycleSync Enterprise?',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.darkGrey,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(false),
            child: const Text(
              'Decline',
              style: TextStyle(
                color: AppTheme.warningOrange,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Accept & Connect',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    ) ?? false; // Return false if dialog is dismissed
  }

  void _learnMore(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CycleSync Integration'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'What is CycleSync?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'CycleSync Enterprise is our comprehensive menstrual health platform that provides advanced analytics, AI-powered insights, and seamless data synchronization across multiple devices and applications.',
              ),
              const SizedBox(height: 16),
              Text(
                'Benefits of Integration:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              const Text('• Sync data across all your devices'),
              const Text('• Advanced AI health predictions'),
              const Text('• Comprehensive health reports'),
              const Text('• Healthcare provider integration'),
              const Text('• Enhanced data backup and security'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
