import 'package:flutter/material.dart';
import '../../../core/ui/adaptive_messages.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';
import '../services/feelings_database_service.dart';
import '../services/feelings_analytics_service.dart';

/// Enhanced daily feelings tracker with advanced analytics and insights
class EnhancedDailyFeelingsTracker extends StatefulWidget {
  final DateTime? selectedDate;

  const EnhancedDailyFeelingsTracker({super.key, this.selectedDate});

  @override
  State<EnhancedDailyFeelingsTracker> createState() =>
      _EnhancedDailyFeelingsTrackerState();
}

class _EnhancedDailyFeelingsTrackerState
    extends State<EnhancedDailyFeelingsTracker>
    with TickerProviderStateMixin {
  final FeelingsDatabaseService _databaseService =
      FeelingsDatabaseService.instance;
  final FeelingsAnalyticsService _analyticsService =
      FeelingsAnalyticsService.instance;

  late AnimationController _animationController;
  late AnimationController _saveController;
  late TabController _tabController;

  DateTime _selectedDate = DateTime.now();
  DailyFeelingsEntry? _currentEntry;

  // Tracking state
  Map<MoodCategory, double> _moodScores = {};
  Map<EnergyType, double> _energyLevels = {};
  Map<String, int> _symptoms = {};
  Map<String, String> _customTags = {};
  String _notes = '';
  double? _overallWellbeing;

  // UI state
  bool _isLoading = true;
  bool _isSaving = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();

    _selectedDate = widget.selectedDate ?? DateTime.now();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _saveController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _tabController = TabController(length: 4, vsync: this);

    _initializeTracker();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _saveController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Initialize the feelings tracker
  Future<void> _initializeTracker() async {
    setState(() => _isLoading = true);

    try {
      await _databaseService.initialize();
      await _loadExistingEntry();
      _animationController.forward();
    } catch (e) {
      debugPrint('Failed to initialize feelings tracker: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Load existing entry for selected date
  Future<void> _loadExistingEntry() async {
    final entry = await _databaseService.getEntryForDate(_selectedDate);

    if (entry != null) {
      setState(() {
        _currentEntry = entry;
        _moodScores = Map.from(entry.moodScores);
        _energyLevels = Map.from(entry.energyLevels);
        _symptoms = Map.from(entry.symptoms);
        _customTags = Map.from(entry.customTags);
        _notes = entry.notes;
        _overallWellbeing = entry.overallWellbeing;
      });
    } else {
      _initializeEmptyEntry();
    }
  }

  /// Initialize an empty entry without fabricating user measurements.
  void _initializeEmptyEntry() {
    setState(() {
      _moodScores = {};
      _energyLevels = {};
      _symptoms = {};
      _customTags = {};
      _notes = '';

      _overallWellbeing = null;
    });
  }

  /// Save current entry
  Future<void> _saveEntry() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    _saveController.forward();

    try {
      final entry = DailyFeelingsEntry(
        id:
            _currentEntry?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        date: _selectedDate,
        moodScores: Map.from(_moodScores),
        energyLevels: Map.from(_energyLevels),
        symptoms: Map.from(_symptoms),
        customTags: Map.from(_customTags),
        notes: _notes,
        overallWellbeing: _overallWellbeing,
        timestamp: DateTime.now(),
      );

      await _databaseService.saveEntry(entry);

      // Trigger analytics processing
      await _analyticsService.processNewEntry(entry);

      setState(() {
        _currentEntry = entry;
        _hasUnsavedChanges = false;
      });

      if (mounted) {
        AdaptiveMessages.showSuccess(context, 'Feelings saved successfully');
      }
    } catch (e) {
      debugPrint('Failed to save entry: $e');
      if (mounted) {
        AdaptiveMessages.showError(context, 'Failed to save feelings');
      }
    } finally {
      setState(() => _isSaving = false);
      _saveController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Enhanced App Bar
          _buildAppBar(context, theme),

          if (_isLoading)
            SliverFillRemaining(child: _buildLoadingState())
          else ...[
            // Date Selector
            _buildDateSelector(theme),

            // Overall Wellbeing
            _buildOverallWellbeingSection(theme),

            // Feelings Categories Tabs
            _buildCategoriesTabs(theme),

            // Feelings Content
            _buildFeelingsContent(theme),

            // Quick Insights
            _buildQuickInsights(theme),

            // Notes Section
            _buildNotesSection(theme),

            // Historical Trends
            _buildHistoricalTrends(theme),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ],
      ),

      // Floating save button
      floatingActionButton: _buildSaveButton(),
    );
  }

  /// Build app bar
  Widget _buildAppBar(BuildContext context, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 160,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.secondaryBlue,
                AppTheme.primaryPurple,
                AppTheme.primaryRose,
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Icon(
                          Icons.sentiment_very_satisfied,
                          color: Colors.white,
                          size: 28,
                        ),
                      ).animate().scale(delay: 200.ms),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                  'Daily Feelings',
                                  style: theme.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                )
                                .animate()
                                .fadeIn(delay: 400.ms)
                                .slideX(begin: 0.3),
                            Text(
                              'Track your emotional wellbeing',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.white.withValues(alpha: 0.82),
                              ),
                            ).animate().fadeIn(delay: 600.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
          ),
          SizedBox(height: 24),
          Text(
            'Loading your feelings data...',
            style: TextStyle(color: AppTheme.mediumGrey, fontSize: 16),
          ),
        ],
      ),
    );
  }

  /// Build date selector
  Widget _buildDateSelector(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: AppTheme.primaryPurple,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatSelectedDate(_selectedDate),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    Text(
                      _getDateRelativeString(_selectedDate),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppTheme.mediumGrey,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _selectDate(context),
                icon: Icon(Icons.edit_calendar, color: AppTheme.primaryPurple),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
      ),
    );
  }

  /// Build overall wellbeing section
  Widget _buildOverallWellbeingSection(ThemeData theme) {
    final scheme = theme.colorScheme;
    final recordedValue = _overallWellbeing;
    final sliderValue = recordedValue ?? 5.0;
    final wellbeingColor = recordedValue == null
        ? scheme.onSurfaceVariant
        : _getWellbeingColor(recordedValue);

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: recordedValue == null
                ? scheme.surfaceContainerHighest
                : null,
            gradient: recordedValue == null
                ? null
                : LinearGradient(
                    colors: [
                      wellbeingColor.withValues(alpha: 0.16),
                      wellbeingColor.withValues(alpha: 0.08),
                    ],
                  ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: recordedValue == null
                  ? scheme.outline.withValues(alpha: 0.35)
                  : wellbeingColor.withValues(alpha: 0.4),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    recordedValue == null
                        ? Icons.favorite_border
                        : _getWellbeingIcon(recordedValue),
                    color: wellbeingColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Overall Wellbeing',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: scheme.onSurface,
                      ),
                    ),
                  ),
                  Text(
                    recordedValue == null
                        ? 'Not recorded'
                        : '${recordedValue.toInt()}/10',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: wellbeingColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: recordedValue == null
                      ? scheme.outline.withValues(alpha: 0.25)
                      : wellbeingColor,
                  inactiveTrackColor: scheme.outline.withValues(alpha: 0.25),
                  thumbColor: wellbeingColor,
                  overlayColor: wellbeingColor.withValues(alpha: 0.12),
                  trackHeight: 6,
                  thumbShape: recordedValue == null
                      ? SliderComponentShape.noThumb
                      : const RoundSliderThumbShape(enabledThumbRadius: 12),
                ),
                child: Slider(
                  value: sliderValue,
                  min: 1,
                  max: 10,
                  divisions: 9,
                  onChanged: (value) {
                    setState(() {
                      _overallWellbeing = value;
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Poor',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      recordedValue == null
                          ? 'Tap or drag to record'
                          : _getWellbeingDescription(recordedValue),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: wellbeingColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Excellent',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
      ),
    );
  }

  /// Build categories tabs
  Widget _buildCategoriesTabs(ThemeData theme) {
    final scheme = theme.colorScheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          decoration: BoxDecoration(
            color: scheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.outline.withValues(alpha: 0.35)),
          ),
          child: TabBar(
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            indicator: BoxDecoration(
              color: AppTheme.primaryPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: scheme.onPrimary,
            unselectedLabelColor: scheme.onSurfaceVariant,
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Mood'),
              Tab(text: 'Energy'),
              Tab(text: 'Symptoms'),
              Tab(text: 'Tags'),
            ],
          ),
        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
      ),
    );
  }

  /// Build feelings content
  Widget _buildFeelingsContent(ThemeData theme) {
    return SliverToBoxAdapter(
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, _) {
          final index = _tabController.index;

          final Widget activeSection = switch (index) {
            0 => _buildMoodSection(theme),
            1 => _buildEnergySection(theme),
            2 => _buildSymptomsSection(theme),
            3 => _buildTagsSection(theme),
            _ => _buildMoodSection(theme),
          };

          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: KeyedSubtree(
              key: ValueKey<int>(index),
              child: activeSection,
            ),
          );
        },
      ).animate().fadeIn(delay: 800.ms),
    );
  }

  /// Build mood section
  Widget _buildMoodSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...MoodCategory.values.map(
            (category) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildMoodSlider(category),
            ),
          ),
        ],
      ),
    );
  }

  /// Build mood slider
  Widget _buildMoodSlider(MoodCategory category) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final recordedValue = _moodScores[category];
    final sliderValue = recordedValue ?? 5.0;
    final color = _getMoodCategoryColor(category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: recordedValue == null
              ? scheme.outline.withValues(alpha: 0.35)
              : color.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getMoodCategoryIcon(category), color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  category.displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Text(
                recordedValue == null
                    ? 'Not recorded'
                    : '${recordedValue.toInt()}/10',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: recordedValue == null
                      ? scheme.onSurfaceVariant
                      : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: recordedValue == null
                  ? scheme.outline.withValues(alpha: 0.25)
                  : color,
              inactiveTrackColor: scheme.outline.withValues(alpha: 0.25),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.12),
              trackHeight: 4,
              thumbShape: recordedValue == null
                  ? SliderComponentShape.noThumb
                  : const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: sliderValue,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (newValue) {
                setState(() {
                  _moodScores[category] = newValue;
                  _hasUnsavedChanges = true;
                });
              },
            ),
          ),
          if (recordedValue == null)
            Text(
              'Tap or drag to record',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  /// Build energy section
  Widget _buildEnergySection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          ...EnergyType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildEnergySlider(type),
            ),
          ),
        ],
      ),
    );
  }

  /// Build energy slider
  Widget _buildEnergySlider(EnergyType type) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final recordedValue = _energyLevels[type];
    final sliderValue = recordedValue ?? 5.0;
    final color = _getEnergyTypeColor(type);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: recordedValue == null
              ? scheme.outline.withValues(alpha: 0.35)
              : color.withValues(alpha: 0.45),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_getEnergyTypeIcon(type), color: color, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  type.displayName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface,
                  ),
                ),
              ),
              Text(
                recordedValue == null
                    ? 'Not recorded'
                    : '${recordedValue.toInt()}/10',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: recordedValue == null
                      ? scheme.onSurfaceVariant
                      : color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: recordedValue == null
                  ? scheme.outline.withValues(alpha: 0.25)
                  : color,
              inactiveTrackColor: scheme.outline.withValues(alpha: 0.25),
              thumbColor: color,
              overlayColor: color.withValues(alpha: 0.12),
              trackHeight: 4,
              thumbShape: recordedValue == null
                  ? SliderComponentShape.noThumb
                  : const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: sliderValue,
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (newValue) {
                setState(() {
                  _energyLevels[type] = newValue;
                  _hasUnsavedChanges = true;
                });
              },
            ),
          ),
          if (recordedValue == null)
            Text(
              'Tap or drag to record',
              style: theme.textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
    );
  }

  /// Build symptoms section
  Widget _buildSymptomsSection(ThemeData theme) {
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _commonSymptoms.length,
        itemBuilder: (context, index) {
          final symptom = _commonSymptoms[index];
          final isSelected = _symptoms.containsKey(symptom);
          final intensity = _symptoms[symptom] ?? 0;

          return GestureDetector(
            onTap: () => _toggleSymptom(symptom),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primaryRose.withValues(alpha: 0.16)
                    : theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryRose
                      : scheme.outline.withValues(alpha: 0.4),
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    symptom,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? AppTheme.primaryRose
                          : scheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        3,
                        (i) => Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: i < intensity
                                ? AppTheme.primaryRose
                                : scheme.outline.withValues(alpha: 0.35),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Build tags section
  Widget _buildTagsSection(ThemeData theme) {
    final scheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Tags',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: scheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ..._customTags.entries.map(
                (entry) => Chip(
                  label: Text(entry.key),
                  backgroundColor: AppTheme.accentMint.withValues(alpha: 0.16),
                  labelStyle: TextStyle(
                    color: scheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  deleteIcon: Icon(
                    Icons.close,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                  side: BorderSide(
                    color: AppTheme.accentMint.withValues(alpha: 0.45),
                  ),
                  onDeleted: () {
                    setState(() {
                      _customTags.remove(entry.key);
                      _hasUnsavedChanges = true;
                    });
                  },
                ),
              ),
              ActionChip(
                label: const Text('Add Tag'),
                avatar: const Icon(
                  Icons.add,
                  size: 16,
                  color: AppTheme.primaryPurple,
                ),
                backgroundColor: AppTheme.primaryPurple.withValues(alpha: 0.14),
                labelStyle: const TextStyle(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
                side: BorderSide(
                  color: AppTheme.primaryPurple.withValues(alpha: 0.4),
                ),
                onPressed: _addCustomTag,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Suggested Tags',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedTags
                .map(
                  (tag) => ActionChip(
                    label: Text(tag),
                    backgroundColor: theme.cardColor,
                    labelStyle: TextStyle(
                      color: scheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    side: BorderSide(
                      color: scheme.outline.withValues(alpha: 0.4),
                    ),
                    onPressed: () {
                      setState(() {
                        _customTags[tag] = 'suggested';
                        _hasUnsavedChanges = true;
                      });
                    },
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  /// Build quick insights
  Widget _buildQuickInsights(ThemeData theme) {
    final insights = _generateQuickInsights();

    if (insights.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Insights',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
              ),
            ),
            const SizedBox(height: 12),
            ...insights.map(
              (insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.accentMint.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.accentMint.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        color: AppTheme.accentMint,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          insight,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppTheme.darkGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.2),
    );
  }

  /// Build notes section
  Widget _buildNotesSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.edit_note,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: TextEditingController(text: _notes),
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'How are you feeling today? Any specific thoughts or events you\'d like to remember?',
                  hintStyle: TextStyle(
                    color: AppTheme.mediumGrey.withValues(alpha: 0.1),
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.mediumGrey.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primaryPurple),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                ),
                onChanged: (value) {
                  setState(() {
                    _notes = value;
                    _hasUnsavedChanges = true;
                  });
                },
              ),
            ],
          ),
        ).animate().fadeIn(delay: 1200.ms).slideY(begin: 0.2),
      ),
    );
  }

  /// Build historical trends
  Widget _buildHistoricalTrends(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.trending_up,
                    color: AppTheme.primaryPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recent Trends',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkGrey,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _viewDetailedAnalytics(context),
                    child: Text(
                      'View All',
                      style: TextStyle(
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              FutureBuilder<List<TrendInsight>>(
                future: _analyticsService.getRecentTrends(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text(
                      'Track your feelings for a few more days to see trends',
                      style: TextStyle(
                        color: AppTheme.mediumGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    );
                  }

                  return Column(
                    children: snapshot.data!
                        .take(3)
                        .map(
                          (trend) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Icon(
                                  _getTrendIcon(trend.direction),
                                  color: _getTrendColor(trend.direction),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    trend.description,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppTheme.darkGrey,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ).animate().fadeIn(delay: 1400.ms).slideY(begin: 0.2),
      ),
    );
  }

  /// Build save button
  Widget _buildSaveButton() {
    return AnimatedScale(
      scale: _hasUnsavedChanges ? 1.0 : 0.8,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton.extended(
        onPressed: _hasUnsavedChanges ? _saveEntry : null,
        backgroundColor: _hasUnsavedChanges
            ? AppTheme.primaryPurple
            : AppTheme.mediumGrey,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Icon(Icons.save, color: Colors.white),
        ),
        label: Text(
          _isSaving ? 'Saving...' : 'Save',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ).animate().scale(delay: 1600.ms),
    );
  }

  // === HELPER METHODS ===

  String _formatSelectedDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Today';
    } else if (selectedDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}, ${date.year}';
    }
  }

  String _getDateRelativeString(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Track your feelings today';
    } else if (difference == 1) {
      return 'How did you feel yesterday?';
    } else {
      return '$difference days ago';
    }
  }

  Color _getWellbeingColor(double value) {
    if (value >= 8) return AppTheme.successGreen;
    if (value >= 6) return AppTheme.accentMint;
    if (value >= 4) return AppTheme.warningOrange;
    return AppTheme.primaryRose;
  }

  IconData _getWellbeingIcon(double value) {
    if (value >= 8) return Icons.sentiment_very_satisfied;
    if (value >= 6) return Icons.sentiment_satisfied;
    if (value >= 4) return Icons.sentiment_neutral;
    return Icons.sentiment_dissatisfied;
  }

  String _getWellbeingDescription(double value) {
    if (value >= 8) return 'Excellent';
    if (value >= 6) return 'Good';
    if (value >= 4) return 'Okay';
    return 'Poor';
  }

  Color _getMoodCategoryColor(MoodCategory category) {
    switch (category) {
      case MoodCategory.happiness:
        return AppTheme.successGreen;
      case MoodCategory.anxiety:
        return AppTheme.warningOrange;
      case MoodCategory.sadness:
        return AppTheme.secondaryBlue;
      case MoodCategory.anger:
        return AppTheme.primaryRose;
      case MoodCategory.excitement:
        return AppTheme.accentMint;
      case MoodCategory.calmness:
        return AppTheme.primaryPurple;
    }
  }

  IconData _getMoodCategoryIcon(MoodCategory category) {
    switch (category) {
      case MoodCategory.happiness:
        return Icons.sentiment_very_satisfied;
      case MoodCategory.anxiety:
        return Icons.psychology;
      case MoodCategory.sadness:
        return Icons.sentiment_dissatisfied;
      case MoodCategory.anger:
        return Icons.warning;
      case MoodCategory.excitement:
        return Icons.celebration;
      case MoodCategory.calmness:
        return Icons.self_improvement;
    }
  }

  Color _getEnergyTypeColor(EnergyType type) {
    switch (type) {
      case EnergyType.physical:
        return AppTheme.primaryRose;
      case EnergyType.mental:
        return AppTheme.primaryPurple;
      case EnergyType.emotional:
        return AppTheme.secondaryBlue;
      case EnergyType.social:
        return AppTheme.accentMint;
    }
  }

  IconData _getEnergyTypeIcon(EnergyType type) {
    switch (type) {
      case EnergyType.physical:
        return Icons.fitness_center;
      case EnergyType.mental:
        return Icons.psychology;
      case EnergyType.emotional:
        return Icons.favorite;
      case EnergyType.social:
        return Icons.people;
    }
  }

  List<String> _generateQuickInsights() {
    final insights = <String>[];

    if (_moodScores.isNotEmpty) {
      final moodAverage =
          _moodScores.values.reduce((a, b) => a + b) / _moodScores.length;

      if (moodAverage >= 7) {
        insights.add(
          'Your mood is looking great today! Keep up the positive energy.',
        );
      } else if (moodAverage <= 4) {
        insights.add(
          'Consider some self-care activities to support your mood.',
        );
      }
    }

    if (_energyLevels.isNotEmpty) {
      final energyAverage =
          _energyLevels.values.reduce((a, b) => a + b) / _energyLevels.length;

      if (energyAverage <= 4) {
        insights.add(
          'You recorded lower energy today. Consider rest if you need it.',
        );
      }
    }

    if (_symptoms.isNotEmpty) {
      insights.add(
        'You logged ${_symptoms.length} symptoms today. '
        'Tracking them over time may help reveal patterns.',
      );
    }

    return insights;
  }

  void _toggleSymptom(String symptom) {
    setState(() {
      if (_symptoms.containsKey(symptom)) {
        final currentIntensity = _symptoms[symptom]!;
        if (currentIntensity < 3) {
          _symptoms[symptom] = currentIntensity + 1;
        } else {
          _symptoms.remove(symptom);
        }
      } else {
        _symptoms[symptom] = 1;
      }
      _hasUnsavedChanges = true;
    });
  }

  void _addCustomTag() {
    showDialog(
      context: context,
      builder: (context) {
        String newTag = '';
        return AlertDialog(
          title: const Text('Add Custom Tag'),
          content: TextField(
            onChanged: (value) => newTag = value,
            decoration: const InputDecoration(hintText: 'Enter tag name'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (newTag.isNotEmpty) {
                  setState(() {
                    _customTags[newTag] = 'custom';
                    _hasUnsavedChanges = true;
                  });
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      await _loadExistingEntry();
    }
  }

  IconData _getTrendIcon(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.up:
        return Icons.trending_up;
      case TrendDirection.down:
        return Icons.trending_down;
      case TrendDirection.stable:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(TrendDirection direction) {
    switch (direction) {
      case TrendDirection.up:
        return AppTheme.successGreen;
      case TrendDirection.down:
        return AppTheme.primaryRose;
      case TrendDirection.stable:
        return AppTheme.mediumGrey;
    }
  }

  void _viewDetailedAnalytics(BuildContext context) {
    Navigator.pushNamed(context, '/feelings/analytics');
  }

  // === CONSTANTS ===

  static const List<String> _commonSymptoms = [
    'Headache',
    'Fatigue',
    'Nausea',
    'Back Pain',
    'Bloating',
    'Cramps',
    'Mood Swings',
    'Anxiety',
    'Insomnia',
    'Appetite Changes',
    'Breast Tenderness',
    'Joint Pain',
  ];

  static const List<String> _suggestedTags = [
    'Work Stress',
    'Good Sleep',
    'Exercise',
    'Social Time',
    'Meditation',
    'Period',
    'Travel',
    'Family Time',
    'Date Night',
    'Self Care',
    'Busy Day',
    'Relaxing',
  ];
}

// === DATA MODELS ===

class DailyFeelingsEntry {
  final String id;
  final DateTime date;
  final Map<MoodCategory, double> moodScores;
  final Map<EnergyType, double> energyLevels;
  final Map<String, int> symptoms;
  final Map<String, String> customTags;
  final String notes;
  final double? overallWellbeing;
  final DateTime timestamp;

  DailyFeelingsEntry({
    required this.id,
    required this.date,
    required this.moodScores,
    required this.energyLevels,
    required this.symptoms,
    required this.customTags,
    required this.notes,
    required this.overallWellbeing,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'moodScores': moodScores.map((k, v) => MapEntry(k.name, v)),
      'energyLevels': energyLevels.map((k, v) => MapEntry(k.name, v)),
      'symptoms': symptoms,
      'customTags': customTags,
      'notes': notes,
      'overallWellbeing': overallWellbeing,
      'overallWellbeingRecorded': overallWellbeing != null,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory DailyFeelingsEntry.fromJson(Map<String, dynamic> json) {
    final rawWellbeing = json['overallWellbeing'];
    final wellbeingWasRecorded = json['overallWellbeingRecorded'] == true;

    return DailyFeelingsEntry(
      id: json['id'],
      date: DateTime.parse(json['date']),
      moodScores: (json['moodScores'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          MoodCategory.values.firstWhere((category) => category.name == key),
          (value as num).toDouble(),
        ),
      ),
      energyLevels: (json['energyLevels'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          EnergyType.values.firstWhere((type) => type.name == key),
          (value as num).toDouble(),
        ),
      ),
      symptoms: Map<String, int>.from(json['symptoms'] ?? const {}),
      customTags: Map<String, String>.from(json['customTags'] ?? const {}),
      notes: json['notes'] ?? '',
      overallWellbeing: wellbeingWasRecorded && rawWellbeing is num
          ? rawWellbeing.toDouble()
          : null,
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class TrendInsight {
  final String description;
  final TrendDirection direction;
  final double confidence;
  final String category;

  TrendInsight({
    required this.description,
    required this.direction,
    required this.confidence,
    required this.category,
  });
}

// === ENUMS ===

enum MoodCategory { happiness, anxiety, sadness, anger, excitement, calmness }

extension MoodCategoryExtension on MoodCategory {
  String get displayName {
    switch (this) {
      case MoodCategory.happiness:
        return 'Happiness';
      case MoodCategory.anxiety:
        return 'Anxiety';
      case MoodCategory.sadness:
        return 'Sadness';
      case MoodCategory.anger:
        return 'Anger';
      case MoodCategory.excitement:
        return 'Excitement';
      case MoodCategory.calmness:
        return 'Calmness';
    }
  }
}

enum EnergyType { physical, mental, emotional, social }

extension EnergyTypeExtension on EnergyType {
  String get displayName {
    switch (this) {
      case EnergyType.physical:
        return 'Physical Energy';
      case EnergyType.mental:
        return 'Mental Clarity';
      case EnergyType.emotional:
        return 'Emotional Stability';
      case EnergyType.social:
        return 'Social Energy';
    }
  }
}

enum TrendDirection { up, down, stable }
