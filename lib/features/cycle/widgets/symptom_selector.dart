import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';

class SymptomSelector extends StatefulWidget {
  final Set<String> selectedSymptoms;
  final Map<String, double> symptomSeverity;
  final Function(Set<String>) onSymptomsChanged;
  final Function(String, double) onSeverityChanged;

  const SymptomSelector({
    super.key,
    required this.selectedSymptoms,
    required this.symptomSeverity,
    required this.onSymptomsChanged,
    required this.onSeverityChanged,
  });

  @override
  State<SymptomSelector> createState() => _SymptomSelectorState();
}

class _SymptomSelectorState extends State<SymptomSelector> {
  Map<String, List<SymptomOption>> _getSymptomCategories(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    return {
      localizations.physical: [
        SymptomOption(localizations.cramps, '🔥', AppTheme.primaryRose),
        SymptomOption(localizations.headache, '🤕', AppTheme.secondaryBlue),
        SymptomOption(localizations.breastTenderness, '💙', AppTheme.primaryPurple),
        SymptomOption(localizations.backPain, '💢', AppTheme.accentMint),
        SymptomOption(localizations.bloating, '🎈', Color(0xFFFF7043)),
        SymptomOption(localizations.nausea, '🤢', Color(0xFF66BB6A)),
        SymptomOption(localizations.fatigue, '😴', Color(0xFF9575CD)),
        SymptomOption(localizations.hotFlashes, '🔥', Color(0xFFEF5350)),
      ],
      localizations.emotional: [
        SymptomOption(localizations.moodSwingsSymptom, '🎭', AppTheme.primaryRose),
        SymptomOption(localizations.irritability, '😤', Color(0xFFFF7043)),
        SymptomOption(localizations.anxiety, '😰', AppTheme.secondaryBlue),
        SymptomOption(localizations.depression, '😢', Color(0xFF9575CD)),
        SymptomOption(localizations.emotionalSensitivity, '💝', AppTheme.primaryPurple),
        SymptomOption(localizations.stress, '😫', Color(0xFFEF5350)),
      ],
      localizations.skinAndHair: [
        SymptomOption(localizations.acne, '🦠', Color(0xFFFF7043)),
        SymptomOption(localizations.oilySkin, '✨', AppTheme.accentMint),
        SymptomOption(localizations.drySkin, '🏜️', Color(0xFFBCAAA4)),
        SymptomOption(localizations.hairChanges, '💇', AppTheme.primaryPurple),
      ],
      localizations.digestive: [
        SymptomOption(localizations.constipation, '🚫', Color(0xFFBCAAA4)),
        SymptomOption(localizations.diarrhea, '💧', AppTheme.secondaryBlue),
        SymptomOption(localizations.foodCravings, '🍫', Color(0xFFFF7043)),
        SymptomOption(localizations.lossOfAppetite, '🚫', AppTheme.mediumGrey),
      ],
    };
  }

  String _expandedCategory = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final symptomCategories = _getSymptomCategories(context);
    if (_expandedCategory.isEmpty) {
      _expandedCategory = symptomCategories.keys.first;
    }
    return SingleChildScrollView(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          children: [
            // Selected symptoms summary
            if (widget.selectedSymptoms.isNotEmpty) ...[
              _buildSelectedSymptomsSummary(),
              const SizedBox(height: 20),
            ],
            
            // Category selector
            _buildCategorySelector(),
            
            const SizedBox(height: 20),
            
            // Symptoms list
            Expanded(
              child: _buildSymptomsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedSymptomsSummary() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                color: AppTheme.primaryRose,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context).selectedSymptoms(widget.selectedSymptoms.length),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.selectedSymptoms.map((symptom) {
              final severity = widget.symptomSeverity[symptom] ?? 3.0;
              return _buildSelectedSymptomChip(symptom, severity);
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2, end: 0);
  }

  Widget _buildSelectedSymptomChip(String symptom, double severity) {
    final color = _getSymptomColor(symptom);
    final severityText = _getSeverityText(severity);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _getSymptomEmoji(symptom),
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            symptom,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              severityText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 8,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () {
              final updatedSymptoms = Set<String>.from(widget.selectedSymptoms);
              updatedSymptoms.remove(symptom);
              widget.onSymptomsChanged(updatedSymptoms);
              HapticFeedback.lightImpact();
            },
            child: Icon(
              Icons.close,
              size: 14,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    final theme = Theme.of(context);
    final symptomCategories = _getSymptomCategories(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: symptomCategories.keys.map((category) {
          final isSelected = category == _expandedCategory;
          return Padding(padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _expandedCategory = category;
                });
                HapticFeedback.selectionClick();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected 
                      ? const LinearGradient(
                          colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                        )
                      : null,
                  color: isSelected ? null : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppTheme.lightGrey,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppTheme.primaryRose.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppTheme.mediumGrey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSymptomsList() {
    final symptomCategories = _getSymptomCategories(context);
    final symptoms = symptomCategories[_expandedCategory] ?? [];
    
    return ListView.builder(
      itemCount: symptoms.length,
      itemBuilder: (context, index) {
        final symptom = symptoms[index];
        final isSelected = widget.selectedSymptoms.contains(symptom.name);
        final severity = widget.symptomSeverity[symptom.name] ?? 3.0;
        
        return Padding(padding: const EdgeInsets.only(bottom: 12),
          child: _buildSymptomTile(symptom, isSelected, severity, index),
        );
      },
    );
  }

  Widget _buildSymptomTile(SymptomOption symptom, bool isSelected, double severity, int index) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        final updatedSymptoms = Set<String>.from(widget.selectedSymptoms);
        if (isSelected) {
          updatedSymptoms.remove(symptom.name);
        } else {
          updatedSymptoms.add(symptom.name);
        }
        widget.onSymptomsChanged(updatedSymptoms);
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? symptom.color : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? symptom.color.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 6 : 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                // Emoji and name
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: symptom.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      symptom.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    symptom.name,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? symptom.color : AppTheme.darkGrey,
                    ),
                  ),
                ),
                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? symptom.color : Colors.transparent,
                    border: Border.all(
                      color: isSelected ? symptom.color : AppTheme.lightGrey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
                ),
              ],
            ),
            
            // Severity slider (shown when selected)
            if (isSelected) ...[
              const SizedBox(height: 16),
              _buildSeveritySlider(symptom.name, severity, symptom.color),
            ],
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: index * 50))
      .fadeIn()
      .slideX(begin: 0.2, end: 0);
  }

  Widget _buildSeveritySlider(String symptom, double severity, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Severity:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.mediumGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              _getSeverityText(severity),
              style: theme.textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            trackHeight: 4,
          ),
          child: Slider(
            value: severity,
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: (value) {
              widget.onSeverityChanged(symptom, value);
              HapticFeedback.selectionClick();
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0);
  }

  String _getSeverityText(double severity) {
    switch (severity.round()) {
      case 1: return 'Mild';
      case 2: return 'Light';
      case 3: return 'Moderate';
      case 4: return 'Strong';
      case 5: return 'Severe';
      default: return 'Moderate';
    }
  }

  Color _getSymptomColor(String symptom) {
    final symptomCategories = _getSymptomCategories(context);
    for (final category in symptomCategories.values) {
      for (final option in category) {
        if (option.name == symptom) {
          return option.color;
        }
      }
    }
    return AppTheme.primaryRose;
  }

  String _getSymptomEmoji(String symptom) {
    final symptomCategories = _getSymptomCategories(context);
    for (final category in symptomCategories.values) {
      for (final option in category) {
        if (option.name == symptom) {
          return option.emoji;
        }
      }
    }
    return '📝';
  }
}

class SymptomOption {
  final String name;
  final String emoji;
  final Color color;

  const SymptomOption(this.name, this.emoji, this.color);
}
