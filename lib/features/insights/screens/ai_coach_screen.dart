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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('AI Health Coach'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.primaryPurple,
      ),
      body: ComingSoonWidgets.aiCoach(
        context,
        footerWidgets: [
          const SizedBox(height: 8),
          MedicalDisclaimerBanner(),
          const SizedBox(height: 16),
          MedicalCitationsFooter(),
        ],
      ),
    );
  }
}
