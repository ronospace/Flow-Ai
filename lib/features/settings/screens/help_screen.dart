import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int _expandedIndex = -1;

  final List<HelpItem> _helpItems = [
    HelpItem(
      question: "How do I start tracking my cycle?",
      answer: "Navigate to the Track tab and log your period start date. FlowSense will automatically begin tracking your cycle and provide predictions based on your data.",
      icon: Icons.play_circle_outline,
      color: AppTheme.primaryRose,
    ),
    HelpItem(
      question: "How accurate are AI predictions?",
      answer: "Our AI predictions improve with more data. Initially, accuracy is around 70-80%, but after 3-6 months of consistent tracking, accuracy typically reaches 85-95%.",
      icon: Icons.psychology,
      color: AppTheme.warningOrange,
    ),
    HelpItem(
      question: "Can I sync with other health apps?",
      answer: "Yes! FlowSense integrates with Apple Health and can sync data with other compatible health tracking applications through the Settings > Health Data section.",
      icon: Icons.sync,
      color: AppTheme.secondaryBlue,
    ),
    HelpItem(
      question: "How do I set up notifications?",
      answer: "Go to Settings > Notifications to enable alerts for period predictions, ovulation reminders, and symptom tracking prompts. You can customize timing and frequency.",
      icon: Icons.notifications_active,
      color: AppTheme.accentMint,
    ),
    HelpItem(
      question: "What symptoms should I track?",
      answer: "Track any symptoms you experience: cramps, mood changes, energy levels, bloating, headaches, or sleep patterns. More data helps provide better insights.",
      icon: Icons.favorite,
      color: AppTheme.primaryPurple,
    ),
    HelpItem(
      question: "Is my data private and secure?",
      answer: "Absolutely. All your health data is encrypted and stored locally on your device. We never share personal health information with third parties.",
      icon: Icons.security,
      color: AppTheme.successGreen,
    ),
    HelpItem(
      question: "How do I export my data?",
      answer: "You can export your data from Settings > Export Data. This creates a CSV file with all your tracked information that you can share with your healthcare provider.",
      icon: Icons.download,
      color: AppTheme.mediumGrey,
    ),
    HelpItem(
      question: "What if my cycle is irregular?",
      answer: "FlowSense is designed to work with irregular cycles too. The AI learns your unique patterns and adjusts predictions accordingly. Track consistently for best results.",
      icon: Icons.timeline,
      color: AppTheme.errorRed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.warningOrange, AppTheme.primaryRose],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.help_center,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              l10n.help,
              style: TextStyle(
                color: Theme.of(context).textTheme.titleLarge?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.warningOrange, AppTheme.primaryRose],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.warningOrange.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How can we help you?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Find answers to common questions about FlowSense',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ).animate().slideY(begin: -0.3, end: 0).fadeIn(),
            
            const SizedBox(height: 32),
            
            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
            ).animate().slideX(begin: -0.3, end: 0).fadeIn(delay: 200.ms),
            
            const SizedBox(height: 16),
            
            // FAQ Items
            ...List.generate(_helpItems.length, (index) {
              final item = _helpItems[index];
              final isExpanded = _expandedIndex == index;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ExpansionTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: item.color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      item.icon,
                      color: item.color,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    item.question,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(72, 0, 16, 16),
                      child: Text(
                        item.answer,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                  onExpansionChanged: (expanded) {
                    HapticFeedback.lightImpact();
                    setState(() {
                      _expandedIndex = expanded ? index : -1;
                    });
                  },
                ),
              ).animate(delay: Duration(milliseconds: 300 + (index * 100)))
                .slideX(begin: 0.3, end: 0)
                .fadeIn();
            }),
            
            const SizedBox(height: 32),
            
            // Contact Support Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.accentMint.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.accentMint, AppTheme.secondaryBlue],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.support_agent,
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
                              'Still need help?',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                            Text(
                              'Contact our support team',
                              style: TextStyle(
                                fontSize: 14,
                                color: Theme.of(context).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Support Options
                  _buildSupportOption(
                    context,
                    Icons.email,
                    'Email Support',
                    'Get help via email',
                    AppTheme.primaryRose,
                    () => _launchEmail(),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSupportOption(
                    context,
                    Icons.chat_bubble_outline,
                    'Live Chat',
                    'Chat with our support team',
                    AppTheme.secondaryBlue,
                    () => _showLiveChat(context),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  _buildSupportOption(
                    context,
                    Icons.article,
                    'User Guide',
                    'Complete app documentation',
                    AppTheme.warningOrange,
                    () => _openUserGuide(),
                  ),
                ],
              ),
            ).animate().slideY(begin: 0.3, end: 0).fadeIn(delay: 1.seconds),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportOption(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  void _launchEmail() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@flowsense.app',
      query: 'subject=FlowSense Support Request',
    );

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
      } else {
        _showErrorSnackBar('Could not open email app');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening email: $e');
    }
  }

  void _showLiveChat(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Live Chat'),
        content: const Text(
          'Live chat feature will be available soon. For now, please use email support for immediate assistance.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _openUserGuide() async {
    const url = 'https://flowsense.app/guide';
    final Uri uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Could not open user guide');
      }
    } catch (e) {
      _showErrorSnackBar('Error opening guide: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class HelpItem {
  final String question;
  final String answer;
  final IconData icon;
  final Color color;

  const HelpItem({
    required this.question,
    required this.answer,
    required this.icon,
    required this.color,
  });
}
