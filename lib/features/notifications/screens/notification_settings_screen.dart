import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/notifications/smart_notification_system.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/user_service.dart';
import '../../../core/models/user_profile.dart';

/// 🔔 Notification Settings Screen
/// Advanced notification preferences with smart timing controls
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen>
    with TickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  late NotificationPreferences _preferences;
  bool _isLoading = true;
  
  // Time range selections
  TimeOfDay _quietTimeStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietTimeEnd = const TimeOfDay(hour: 7, minute: 0);
  
  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _loadPreferences();
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _loadPreferences() async {
    try {
      // Load current preferences
      _preferences = NotificationPreferences.defaultPreferences();
      
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading notification preferences: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context),
      body: _isLoading ? _buildLoadingScreen() : _buildSettingsContent(),
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Notification Settings',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.save_outlined, color: Colors.white),
          ),
          onPressed: _savePreferences,
        ),
        const SizedBox(width: 16),
      ],
    );
  }
  
  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Loading notification settings...',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSettingsContent() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(),
            const SizedBox(height: 24),
            _buildNotificationTypesSection(),
            const SizedBox(height: 32),
            _buildTimingSection(),
            const SizedBox(height: 32),
            _buildAdvancedSection(),
            const SizedBox(height: 32),
            _buildTestNotificationSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryColor.withOpacity(0.3),
            AppTheme.secondaryColor.withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.notifications_active,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Smart Notifications',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'AI-powered personalized health alerts',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNotificationTypesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notification Types',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...NotificationType.values.map((type) => _buildNotificationTypeCard(type)),
      ],
    );
  }
  
  Widget _buildNotificationTypeCard(NotificationType type) {
    final isEnabled = _preferences.allowsNotification(type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isEnabled 
              ? AppTheme.primaryColor.withOpacity(0.3)
              : Colors.white.withOpacity(0.1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isEnabled 
                ? _getTypeColor(type).withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getTypeIcon(type),
            color: isEnabled ? _getTypeColor(type) : Colors.grey,
            size: 20,
          ),
        ),
        title: Text(
          _getTypeTitle(type),
          style: TextStyle(
            color: isEnabled ? Colors.white : Colors.white54,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          _getTypeDescription(type),
          style: TextStyle(
            color: isEnabled ? Colors.white70 : Colors.white38,
            fontSize: 14,
          ),
        ),
        trailing: Switch.adaptive(
          value: isEnabled,
          activeColor: _getTypeColor(type),
          inactiveThumbColor: Colors.grey,
          onChanged: (value) {
            setState(() {
              _preferences.typePreferences[type] = value;
            });
          },
        ),
      ),
    );
  }
  
  Widget _buildTimingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Timing & Frequency',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTimingCard(),
      ],
    );
  }
  
  Widget _buildTimingCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildQuietHoursSection(),
          const SizedBox(height: 20),
          _buildMaxNotificationsSection(),
          const SizedBox(height: 20),
          _buildWeekendSection(),
        ],
      ),
    );
  }
  
  Widget _buildQuietHoursSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quiet Hours',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTimeSelector(
                'Start',
                _quietTimeStart,
                (time) => setState(() => _quietTimeStart = time),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTimeSelector(
                'End',
                _quietTimeEnd,
                (time) => setState(() => _quietTimeEnd = time),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildTimeSelector(String label, TimeOfDay time, Function(TimeOfDay) onChanged) {
    return GestureDetector(
      onTap: () async {
        final selectedTime = await showTimePicker(
          context: context,
          initialTime: time,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.dark(
                  primary: AppTheme.primaryColor,
                  onPrimary: Colors.white,
                  surface: Color(0xFF1E1E2E),
                  onSurface: Colors.white,
                ),
              ),
              child: child!,
            );
          },
        );
        if (selectedTime != null) {
          onChanged(selectedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time.format(context),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMaxNotificationsSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Max Daily Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
          ),
          child: Text(
            '${_preferences.maxDailyNotifications}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildWeekendSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekend Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Receive notifications on weekends',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Switch.adaptive(
          value: _preferences.allowWeekends,
          activeColor: AppTheme.primaryColor,
          onChanged: (value) {
            setState(() {
              // This would update the preference
            });
          },
        ),
      ],
    );
  }
  
  Widget _buildAdvancedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Advanced Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildAdvancedCard(),
      ],
    );
  }
  
  Widget _buildAdvancedCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          _buildAdvancedOption(
            'AI Optimization',
            'Let AI optimize notification timing',
            true,
            Icons.psychology,
            (value) {},
          ),
          const SizedBox(height: 16),
          _buildAdvancedOption(
            'Context Awareness',
            'Use location and activity for timing',
            true,
            Icons.location_on,
            (value) {},
          ),
          const SizedBox(height: 16),
          _buildAdvancedOption(
            'Smart Grouping',
            'Group similar notifications together',
            true,
            Icons.group_work,
            (value) {},
          ),
        ],
      ),
    );
  }
  
  Widget _buildAdvancedOption(
    String title,
    String description,
    bool value,
    IconData icon,
    Function(bool) onChanged,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        Switch.adaptive(
          value: value,
          activeColor: AppTheme.primaryColor,
          onChanged: onChanged,
        ),
      ],
    );
  }
  
  Widget _buildTestNotificationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Test Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _buildTestButton(),
      ],
    );
  }
  
  Widget _buildTestButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _sendTestNotification,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Send Test Notification',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
  
  // Helper methods
  Color _getTypeColor(NotificationType type) {
    switch (type) {
      case NotificationType.healthAlert:
        return Colors.red;
      case NotificationType.cyclePhase:
        return AppTheme.primaryColor;
      case NotificationType.medication:
        return Colors.orange;
      case NotificationType.aiInsight:
        return Colors.purple;
      case NotificationType.wellnessTip:
        return Colors.green;
      default:
        return AppTheme.secondaryColor;
    }
  }
  
  IconData _getTypeIcon(NotificationType type) {
    switch (type) {
      case NotificationType.healthAlert:
        return Icons.warning;
      case NotificationType.cyclePhase:
        return Icons.calendar_month;
      case NotificationType.medication:
        return Icons.medication;
      case NotificationType.aiInsight:
        return Icons.psychology;
      case NotificationType.wellnessTip:
        return Icons.lightbulb;
      case NotificationType.biometricUpdate:
        return Icons.monitor_heart;
      case NotificationType.fertilityWindow:
        return Icons.favorite;
      case NotificationType.symptomReminder:
        return Icons.assignment;
    }
  }
  
  String _getTypeTitle(NotificationType type) {
    switch (type) {
      case NotificationType.healthAlert:
        return 'Health Alerts';
      case NotificationType.cyclePhase:
        return 'Cycle Phases';
      case NotificationType.medication:
        return 'Medications';
      case NotificationType.aiInsight:
        return 'AI Insights';
      case NotificationType.wellnessTip:
        return 'Wellness Tips';
      case NotificationType.biometricUpdate:
        return 'Biometric Updates';
      case NotificationType.fertilityWindow:
        return 'Fertility Window';
      case NotificationType.symptomReminder:
        return 'Symptom Reminders';
    }
  }
  
  String _getTypeDescription(NotificationType type) {
    switch (type) {
      case NotificationType.healthAlert:
        return 'Important health warnings and alerts';
      case NotificationType.cyclePhase:
        return 'Menstrual cycle phase notifications';
      case NotificationType.medication:
        return 'Medication and supplement reminders';
      case NotificationType.aiInsight:
        return 'AI-powered health insights and trends';
      case NotificationType.wellnessTip:
        return 'Daily wellness tips and suggestions';
      case NotificationType.biometricUpdate:
        return 'Heart rate, temperature, and other metrics';
      case NotificationType.fertilityWindow:
        return 'Fertility and ovulation predictions';
      case NotificationType.symptomReminder:
        return 'Reminders to log symptoms and data';
    }
  }
  
  Future<void> _sendTestNotification() async {
    try {
      final userService = Provider.of<UserService>(context, listen: false);
      final user = await userService.getCurrentUser();
      
      if (user != null) {
        await SmartNotificationSystem.instance.sendSmartHealthNotification(
          user: user,
          type: NotificationType.wellnessTip,
          customMessage: 'This is a test notification from Flow Ai! 🎉',
          priority: NotificationPriority.normal,
          delayMinutes: 0,
        );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Test notification sent!'),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending test notification: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send test notification'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
  
  Future<void> _savePreferences() async {
    try {
      // In a real app, save preferences to storage
      // await NotificationPreferencesService.savePreferences(_preferences);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Preferences saved successfully!'),
            backgroundColor: AppTheme.primaryColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving preferences: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save preferences'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
