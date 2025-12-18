import 'package:flutter/material.dart';
import '../../../core/widgets/coming_soon_widget.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/medical_citations_footer.dart';
import '../../../core/widgets/medical_disclaimer_banner.dart';

class AICoachScreen extends StatelessWidget {
  const AICoachScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Coach'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryPurple,
      ),
      body: Column(
        children: [
          Expanded(
            child: ComingSoonWidgets.aiCoach(
              context,
              onNotifyMe: () {
                _showNotificationDialog(context);
              },
            ),
          ),
          // Medical Disclaimer Banner (App Store 1.4.1)
          MedicalDisclaimerBanner(),
          // Medical Citations Footer (App Store 1.4.1)
          MedicalCitationsFooter(),
        ],
      ),
    );
  }

  void _showNotificationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.notifications_active,
              color: AppTheme.primaryPurple,
            ),
            const SizedBox(width: 8),
            const Text('Notification Set'),
          ],
        ),
        content: const Text(
          'We\'ll notify you as soon as the AI Health Coach feature is available! '
          'In the meantime, continue tracking your cycle to help our AI provide '
          'better personalized insights when it launches.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: TextStyle(color: AppTheme.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }
}
