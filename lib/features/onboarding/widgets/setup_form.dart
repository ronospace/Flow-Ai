import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../generated/app_localizations.dart';

class SetupForm extends StatefulWidget {
  final Function(Map<String, dynamic>) onSave;

  const SetupForm({
    super.key,
    required this.onSave,
  });

  @override
  State<SetupForm> createState() => _SetupFormState();
}

class _SetupFormState extends State<SetupForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Form data
  int _cycleLength = 28;
  int _periodLength = 5;
  final Set<String> _selectedGoals = {};
  final Map<String, bool> _reminderSettings = {
    'period': true,
    'ovulation': true,
    'medication': false,
    'symptoms': false,
  };

  // Available tracking goals
  final List<Map<String, dynamic>> _trackingGoals = [
    {'id': 'fertility', 'title': 'Fertility Tracking', 'icon': Icons.favorite},
    {'id': 'symptoms', 'title': 'Symptom Monitoring', 'icon': Icons.healing},
    {'id': 'mood', 'title': 'Mood Tracking', 'icon': Icons.mood},
    {'id': 'exercise', 'title': 'Exercise & Wellness', 'icon': Icons.fitness_center},
    {'id': 'medication', 'title': 'Medication Reminders', 'icon': Icons.medication},
    {'id': 'health', 'title': 'General Health', 'icon': Icons.local_hospital},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
    
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              'Setup Your Profile',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help us personalize your experience',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 32),

            // Cycle Length
            _buildCycleLengthSection(theme),
            const SizedBox(height: 24),

            // Period Length
            _buildPeriodLengthSection(theme),
            const SizedBox(height: 24),

            // Tracking Goals
            _buildTrackingGoalsSection(theme),
            const SizedBox(height: 24),

            // Reminder Settings
            _buildReminderSettingsSection(theme),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Save Preferences',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleLengthSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Cycle Length',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How many days is your typical cycle? (First day of period to first day of next period)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: _cycleLength.toDouble(),
                  min: 21,
                  max: 35,
                  divisions: 14,
                  label: '$_cycleLength days',
                  onChanged: (value) {
                    setState(() {
                      _cycleLength = value.round();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_cycleLength days',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPeriodLengthSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Period Length',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'How many days does your period typically last?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Slider(
                  value: _periodLength.toDouble(),
                  min: 2,
                  max: 8,
                  divisions: 6,
                  label: '$_periodLength days',
                  onChanged: (value) {
                    setState(() {
                      _periodLength = value.round();
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_periodLength days',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackingGoalsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What would you like to track?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select all that apply (you can change this later)',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _trackingGoals.map((goal) {
            final isSelected = _selectedGoals.contains(goal['id']);
            return FilterChip(
              label: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    goal['icon'],
                    size: 16,
                    color: isSelected 
                        ? theme.colorScheme.onPrimary 
                        : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(goal['title']),
                ],
              ),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedGoals.add(goal['id']);
                  } else {
                    _selectedGoals.remove(goal['id']);
                  }
                });
              },
              backgroundColor: theme.colorScheme.surface,
              selectedColor: theme.colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected 
                    ? theme.colorScheme.onPrimary 
                    : theme.colorScheme.onSurface,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReminderSettingsSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reminder Preferences',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose which reminders you\'d like to receive',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        ..._reminderSettings.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: SwitchListTile(
              title: Text(_getReminderTitle(entry.key)),
              subtitle: Text(_getReminderDescription(entry.key)),
              value: entry.value,
              onChanged: (value) {
                setState(() {
                  _reminderSettings[entry.key] = value;
                });
              },
              activeTrackColor: Colors.blue,
        activeThumbColor: Colors.blue,
            ),
          );
        }),
      ],
    );
  }

  String _getReminderTitle(String key) {
    switch (key) {
      case 'period':
        return 'Period Reminders';
      case 'ovulation':
        return 'Ovulation Reminders';
      case 'medication':
        return 'Medication Reminders';
      case 'symptoms':
        return 'Symptom Tracking Reminders';
      default:
        return key;
    }
  }

  String _getReminderDescription(String key) {
    switch (key) {
      case 'period':
        return 'Get notified when your period is expected';
      case 'ovulation':
        return 'Get notified during your fertile window';
      case 'medication':
        return 'Daily medication and supplement reminders';
      case 'symptoms':
        return 'Gentle reminders to log symptoms';
      default:
        return '';
    }
  }

  void _saveSetup() {
    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.lightImpact();
      
      final data = {
        'cycleLength': _cycleLength,
        'periodLength': _periodLength,
        'goals': _selectedGoals.toList(),
        'reminders': _reminderSettings,
      };
      
      widget.onSave(data);
    }
  }
}
