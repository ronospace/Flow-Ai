import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../models/onboarding_data.dart';

class CycleHistoryStepScreen extends StatefulWidget {
  final OnboardingData data;
  final Function(OnboardingData) onSave;

  const CycleHistoryStepScreen({
    super.key,
    required this.data,
    required this.onSave,
  });

  @override
  State<CycleHistoryStepScreen> createState() => _CycleHistoryStepScreenState();
}

class _CycleHistoryStepScreenState extends State<CycleHistoryStepScreen> {
  DateTime? _lastPeriodDate;
  int _cycleLength = 28;
  int _periodLength = 5;
  bool _isFirstTimeTracking = true;
  String? _previousTrackingMethod;
  final Set<String> _selectedSymptoms = {};
  final Set<String> _selectedIrregularities = {};

  final List<String> _trackingMethods = [
    'Paper calendar',
    'Phone app',
    'No formal tracking',
    'Other method',
  ];

  @override
  void initState() {
    super.initState();
    _lastPeriodDate = widget.data.lastPeriodDate;
    _cycleLength = widget.data.averageCycleLength ?? 28;
    _periodLength = widget.data.averagePeriodLength ?? 5;
    _isFirstTimeTracking = widget.data.isFirstTimeTracking;
    _previousTrackingMethod = widget.data.previousTrackingMethod;
    _selectedSymptoms.addAll(widget.data.symptoms);
    _selectedIrregularities.addAll(widget.data.cycleIrregularities);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient(theme.brightness == Brightness.dark),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
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
                        'Cycle History',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Help us understand your cycle patterns',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ).animate().fadeIn().slideY(begin: -0.3, end: 0),

            const SizedBox(height: 32),

            // Tracking Experience
            _buildTrackingExperienceSection(theme)
                .animate(delay: 200.ms).fadeIn().slideX(begin: 0.3, end: 0),

            const SizedBox(height: 24),

            // Last Period Date
            if (!_isFirstTimeTracking)
              _buildLastPeriodSection(theme)
                  .animate(delay: 300.ms).fadeIn().slideX(begin: 0.3, end: 0),

            if (!_isFirstTimeTracking) const SizedBox(height: 24),

            // Cycle Length
            _buildCycleLengthSection(theme)
                .animate(delay: 400.ms).fadeIn().slideX(begin: 0.3, end: 0),

            const SizedBox(height: 24),

            // Period Length
            _buildPeriodLengthSection(theme)
                .animate(delay: 500.ms).fadeIn().slideX(begin: 0.3, end: 0),

            const SizedBox(height: 24),

            // Common Symptoms
            _buildSymptomsSection(theme)
                .animate(delay: 600.ms).fadeIn().slideY(begin: 0.3, end: 0),

            const SizedBox(height: 24),

            // Irregularities
            _buildIrregularitiesSection(theme)
                .animate(delay: 700.ms).fadeIn().slideY(begin: 0.3, end: 0),

            const SizedBox(height: 40),

            // Continue Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRose,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 8,
                ),
                child: Text(
                  'Continue',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.3, end: 0),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingExperienceSection(ThemeData theme) {
    return _buildSection(
      title: 'Tracking Experience',
      subtitle: 'Have you tracked your cycle before?',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildChoiceCard(
                  title: 'First Time',
                  subtitle: 'New to tracking',
                  icon: Icons.star_outline,
                  isSelected: _isFirstTimeTracking,
                  onTap: () => setState(() => _isFirstTimeTracking = true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildChoiceCard(
                  title: 'Experienced',
                  subtitle: 'Tracked before',
                  icon: Icons.trending_up,
                  isSelected: !_isFirstTimeTracking,
                  onTap: () => setState(() => _isFirstTimeTracking = false),
                ),
              ),
            ],
          ),
          if (!_isFirstTimeTracking) ...[
            const SizedBox(height: 16),
            _buildPreviousMethodSection(theme),
          ],
        ],
      ),
    );
  }

  Widget _buildPreviousMethodSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryRose.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryRose.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How did you track before?',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryRose,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _trackingMethods.map((method) {
              final isSelected = _previousTrackingMethod == method;
              return FilterChip(
                label: Text(method),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _previousTrackingMethod = selected ? method : null;
                  });
                },
                backgroundColor: theme.cardColor,
                selectedColor: AppTheme.primaryRose.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryRose : AppTheme.mediumGrey,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLastPeriodSection(ThemeData theme) {
    return _buildSection(
      title: 'Last Period',
      subtitle: 'When did your last period start?',
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _selectLastPeriodDate,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryRose.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.event,
                      color: AppTheme.primaryRose,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Last period start date',
                          style: TextStyle(
                            color: AppTheme.primaryRose,
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _lastPeriodDate != null
                              ? '${_lastPeriodDate!.day}/${_lastPeriodDate!.month}/${_lastPeriodDate!.year}'
                              : 'Select date',
                          style: TextStyle(
                            color: _lastPeriodDate != null
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 16,
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
      ),
    );
  }

  Widget _buildCycleLengthSection(ThemeData theme) {
    return _buildSection(
      title: 'Average Cycle Length',
      subtitle: 'How many days from period start to next period start?',
      child: Container(
        padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_cycleLength days',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryPurple,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCycleLengthColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getCycleLengthLabel(),
                    style: TextStyle(
                      color: _getCycleLengthColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: _cycleLength.toDouble(),
              min: 21,
              max: 40,
              divisions: 19,
              activeTrackColor: Colors.blue,
        activeThumbColor: Colors.blue,
              onChanged: (value) {
                setState(() {
                  _cycleLength = value.round();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('21 days', style: theme.textTheme.bodySmall),
                Text('40 days', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodLengthSection(ThemeData theme) {
    return _buildSection(
      title: 'Average Period Length',
      subtitle: 'How many days does your period typically last?',
      child: Container(
        padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_periodLength days',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryRose,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getPeriodLengthColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getPeriodLengthLabel(),
                    style: TextStyle(
                      color: _getPeriodLengthColor(),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Slider(
              value: _periodLength.toDouble(),
              min: 2,
              max: 10,
              divisions: 8,
              activeTrackColor: Colors.blue,
        activeThumbColor: Colors.blue,
              onChanged: (value) {
                setState(() {
                  _periodLength = value.round();
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('2 days', style: theme.textTheme.bodySmall),
                Text('10 days', style: theme.textTheme.bodySmall),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomsSection(ThemeData theme) {
    return _buildSection(
      title: 'Common Symptoms',
      subtitle: 'Which symptoms do you typically experience?',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: CommonSymptoms.all.map((symptom) {
          final isSelected = _selectedSymptoms.contains(symptom);
          return FilterChip(
            label: Text(symptom),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedSymptoms.add(symptom);
                } else {
                  _selectedSymptoms.remove(symptom);
                }
              });
            },
            backgroundColor: theme.cardColor,
            selectedColor: AppTheme.accentMint.withValues(alpha: 0.1),
            labelStyle: TextStyle(
              color: isSelected ? AppTheme.accentMint : AppTheme.mediumGrey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildIrregularitiesSection(ThemeData theme) {
    return _buildSection(
      title: 'Cycle Irregularities',
      subtitle: 'Do you experience any of these? (Optional)',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: CycleIrregularities.types.map((irregularity) {
          final isSelected = _selectedIrregularities.contains(irregularity);
          return FilterChip(
            label: Text(irregularity),
            selected: isSelected,
            onSelected: (selected) {
              setState(() {
                if (selected) {
                  _selectedIrregularities.add(irregularity);
                } else {
                  _selectedIrregularities.remove(irregularity);
                }
              });
            },
            backgroundColor: theme.cardColor,
            selectedColor: AppTheme.warningOrange.withValues(alpha: 0.1),
            labelStyle: TextStyle(
              color: isSelected ? AppTheme.warningOrange : AppTheme.mediumGrey,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildChoiceCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryPurple.withValues(alpha: 0.1)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? AppTheme.primaryPurple
              : AppTheme.mediumGrey.withValues(alpha: 0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: isSelected ? AppTheme.primaryPurple : AppTheme.mediumGrey,
                  size: 32,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.primaryPurple : AppTheme.darkGrey,
                  ),
                ),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getCycleLengthColor() {
    if (_cycleLength >= 25 && _cycleLength <= 32) {
      return AppTheme.sweetPeach;
    } else if (_cycleLength >= 23 && _cycleLength <= 35) {
      return AppTheme.warningOrange;
    } else {
      return AppTheme.errorRed;
    }
  }

  String _getCycleLengthLabel() {
    if (_cycleLength >= 25 && _cycleLength <= 32) {
      return 'Normal';
    } else if (_cycleLength >= 23 && _cycleLength <= 35) {
      return 'Variable';
    } else {
      return 'Irregular';
    }
  }

  Color _getPeriodLengthColor() {
    if (_periodLength >= 3 && _periodLength <= 7) {
      return AppTheme.sweetPeach;
    } else if (_periodLength >= 2 && _periodLength <= 8) {
      return AppTheme.warningOrange;
    } else {
      return AppTheme.errorRed;
    }
  }

  String _getPeriodLengthLabel() {
    if (_periodLength >= 3 && _periodLength <= 7) {
      return 'Normal';
    } else if (_periodLength >= 2 && _periodLength <= 8) {
      return 'Variable';
    } else {
      return 'Irregular';
    }
  }

  Future<void> _selectLastPeriodDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now().subtract(const Duration(days: 14)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryRose,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _lastPeriodDate) {
      setState(() {
        _lastPeriodDate = picked;
      });
    }
  }

  void _saveData() {
    HapticFeedback.lightImpact();

    final updatedData = widget.data.copyWith(
      lastPeriodDate: _lastPeriodDate,
      averageCycleLength: _cycleLength,
      averagePeriodLength: _periodLength,
      isFirstTimeTracking: _isFirstTimeTracking,
      previousTrackingMethod: _previousTrackingMethod,
      symptoms: _selectedSymptoms.toList(),
      cycleIrregularities: _selectedIrregularities.toList(),
    );

    widget.onSave(updatedData);
  }
}
