import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Model for a single citation entry
class Citation {
  final String title;
  final String description;

  const Citation({
    required this.title,
    required this.description,
  });
}

/// Reusable widget to display "View Sources" link and citation dialog
class CitationWidget extends StatelessWidget {
  final String dialogTitle;
  final String dialogDescription;
  final List<Citation> citations;
  final Color? linkColor;
  final Color? iconColor;

  const CitationWidget({
    super.key,
    required this.dialogTitle,
    required this.dialogDescription,
    required this.citations,
    this.linkColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCitationDialog(context),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 14,
            color: linkColor ?? AppTheme.primaryPurple,
          ),
          const SizedBox(width: 6),
          Text(
            'View Sources',
            style: TextStyle(
              color: linkColor ?? AppTheme.primaryPurple,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showCitationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.menu_book,
              color: iconColor ?? AppTheme.primaryPurple,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                dialogTitle,
                style: TextStyle(
                  color: iconColor ?? AppTheme.primaryPurple,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dialogDescription,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
              const SizedBox(height: 12),
              ...citations.map((citation) => _buildCitationItem(citation)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(color: iconColor ?? AppTheme.primaryPurple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCitationItem(Citation citation) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 16,
            color: AppTheme.accentMint,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  citation.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: AppTheme.darkGrey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  citation.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.mediumGrey,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pre-defined citation sets for common use cases

class CitationSets {
  static const List<Citation> cycleRegularity = [
    Citation(
      title: '1. Cycle Length Analysis',
      description: 'Statistical analysis of your recorded cycle lengths over time.',
    ),
    Citation(
      title: '2. Variation Tracking',
      description: 'Standard deviation calculation to measure cycle consistency.',
    ),
    Citation(
      title: '3. Pattern Recognition',
      description: 'Machine learning models trained on clinical cycle data and research.',
    ),
    Citation(
      title: '4. Medical Guidelines',
      description: 'Based on ACOG and WHO standards for menstrual health assessment.',
    ),
  ];

  static const List<Citation> predictionAccuracy = [
    Citation(
      title: '1. Historical Comparison',
      description: 'Comparing AI predictions against actual cycle start dates you recorded.',
    ),
    Citation(
      title: '2. Machine Learning Models',
      description: 'Ensemble of SVM, Random Forest, Neural Networks, and LSTM models.',
    ),
    Citation(
      title: '3. Confidence Scoring',
      description: 'Statistical analysis of prediction reliability and uncertainty ranges.',
    ),
    Citation(
      title: '4. Continuous Learning',
      description: 'Algorithms improve accuracy over time using your feedback and data.',
    ),
    Citation(
      title: '5. Biometric Integration',
      description: 'Heart rate, temperature, and health data correlation for enhanced accuracy.',
    ),
  ];

  static const List<Citation> symptomPrediction = [
    Citation(
      title: '1. Pattern Analysis',
      description: 'ML-based recognition of symptom patterns across your cycle history.',
    ),
    Citation(
      title: '2. Temporal Correlation',
      description: 'Time-series analysis linking symptoms to cycle phases.',
    ),
    Citation(
      title: '3. Severity Modeling',
      description: 'Predictive algorithms for symptom intensity based on historical data.',
    ),
    Citation(
      title: '4. Ensemble Forecasting',
      description: 'Combined predictions from multiple ML models for higher accuracy.',
    ),
  ];

  static const List<Citation> fertilityWindow = [
    Citation(
      title: '1. LSTM Neural Networks',
      description: 'Sequential pattern learning with 12-cycle memory for ovulation prediction.',
    ),
    Citation(
      title: '2. Gaussian Process Models',
      description: 'Uncertainty quantification for fertility window predictions.',
    ),
    Citation(
      title: '3. Bayesian Inference',
      description: 'Prior belief updates based on individual cycle history.',
    ),
    Citation(
      title: '4. Biometric Correlation',
      description: 'Temperature and heart rate pattern analysis for ovulation detection.',
    ),
    Citation(
      title: '5. Medical Research',
      description: 'Based on WHO and ASRM fertility awareness guidelines.',
    ),
  ];

  static const List<Citation> healthConditions = [
    Citation(
      title: '1. PCOS Detection',
      description: 'Pattern recognition based on Rotterdam criteria and cycle irregularities.',
    ),
    Citation(
      title: '2. Endometriosis Markers',
      description: 'Symptom correlation and pain pattern analysis.',
    ),
    Citation(
      title: '3. Risk Scoring',
      description: 'Statistical algorithms for condition probability assessment.',
    ),
    Citation(
      title: '4. Medical Guidelines',
      description: 'ACOG diagnostic criteria and clinical research integration.',
    ),
  ];

  static const List<Citation> moodEnergy = [
    Citation(
      title: '1. Hormonal Correlation',
      description: 'Analysis of mood patterns linked to cycle phase and hormonal changes.',
    ),
    Citation(
      title: '2. Temporal Patterns',
      description: 'ML-based identification of recurring mood and energy cycles.',
    ),
    Citation(
      title: '3. PMS Prediction',
      description: 'Statistical models for premenstrual syndrome symptom forecasting.',
    ),
    Citation(
      title: '4. Biometric Integration',
      description: 'Sleep, activity, and heart rate correlation with emotional wellbeing.',
    ),
  ];
}
