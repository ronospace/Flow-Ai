import '../../../core/ui/app_segmented_selector.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_layout.dart';
import '../../../core/ui/app_scroll_physics.dart';
import '../../../core/models/cycle_data.dart';
import '../../../core/database/database_service.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/ui/adaptive_messages.dart';
import '../widgets/flow_intensity_picker.dart';
import '../widgets/symptom_selector.dart';
import '../services/tracking_pattern_insight_service.dart';
import '../widgets/mood_energy_slider.dart';
import '../widgets/pain_body_map.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late PageController _pageController;
  final GlobalKey _flowAiInsightsKey = GlobalKey();

  // Tracking data
  DateTime _selectedDate = DateTime.now();
  FlowIntensity _flowIntensity = FlowIntensity.none;
  final Set<String> _symptoms = {};
  final Map<String, double> _symptomSeverity = {};
  double _mood = 3.0;
  double _energy = 3.0;
  double _pain = 1.0;
  bool _moodObserved = false;
  bool _energyObserved = false;
  bool _painObserved = false;
  final TrackingPatternInsightService _trackingInsightService =
      TrackingPatternInsightService();
  List<Map<String, dynamic>> _trackingInsightHistory =
      const <Map<String, dynamic>>[];
  final Map<String, double> _painAreas = {};
  String _notes = '';
  static const Map<String, String> _quickNotes = <String, String>{
    'Sleep quality': '🌙',
    'Food cravings': '🍎',
    'Hydration': '💧',
    'Exercise': '🏃‍♀️',
    'Energy levels': '😴',
    'Stress management': '🧘‍♀️',
  };
  static const String _quickTagsMarker = '🏷️ Quick Tags:';

  final Set<String> _selectedQuickNotes = {};
  String _committedNotes = '';
  bool _notesDraftDirty = false;

  final TextEditingController _notesController = TextEditingController();
  final FocusNode _notesFocusNode = FocusNode();
  bool _notesEditorActive = false;
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;
  bool _recentlySaved = false;
  Timer? _savedStateTimer;
  Timer? _autosaveTimer;
  Future<void> _saveChain = Future<void>.value();
  int _editRevision = 0;
  int _savedRevision = 0;
  int _loadGeneration = 0;

  static const Duration _autosaveDelay = Duration(milliseconds: 300);

  static const EdgeInsets _trackTabScrollPadding = EdgeInsets.fromLTRB(
    AppTheme.spaceLg,
    AppTheme.spaceXl,
    AppTheme.spaceLg,
    AppLayout.bottomNavigationContentGap,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notesFocusNode.addListener(_handleNotesFocusChanged);
    _tabController = TabController(length: 5, vsync: this);
    _pageController = PageController();

    // Load existing data for selected date
    _loadExistingData();

    // Listen for changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: AppTheme.motionBase,
          curve: AppTheme.motionCurve,
        );
      }
    });
  }

  @override
  void dispose() {
    _autosaveTimer?.cancel();
    _commitNotesDraftForPersistence();

    if (_hasUnsavedChanges) {
      _queueAutosave();
    }

    _loadGeneration++;
    WidgetsBinding.instance.removeObserver(this);
    _savedStateTimer?.cancel();
    _tabController.dispose();
    _pageController.dispose();
    _notesFocusNode.removeListener(_handleNotesFocusChanged);
    _notesFocusNode.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        unawaited(_flushPendingAutosave());
        return;

      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        return;
    }
  }

  Future<void> _loadExistingData() async {
    final requestedDate = _selectedDate;
    final generation = ++_loadGeneration;

    try {
      final databaseService = DatabaseService();
      final existingData = await databaseService.getDailyTracking(
        requestedDate,
      );

      final insightHistory = await _trackingInsightService.loadPriorHistory(
        requestedDate,
      );

      if (!mounted ||
          generation != _loadGeneration ||
          !_isSameTrackingDate(requestedDate, _selectedDate)) {
        return;
      }

      setState(() {
        _trackingInsightHistory = insightHistory;

        if (existingData != null) {
          _flowIntensity = existingData['flow_intensity'] ?? FlowIntensity.none;

          _symptoms
            ..clear()
            ..addAll(
              existingData['symptoms'] == null
                  ? const <String>[]
                  : List<String>.from(existingData['symptoms']),
            );

          _symptomSeverity.clear();
          if (existingData['symptom_severity'] != null) {
            _symptomSeverity.addAll(
              Map<String, double>.from(existingData['symptom_severity']),
            );
          }

          _mood = existingData['mood']?.toDouble() ?? 3.0;
          _energy = existingData['energy']?.toDouble() ?? 3.0;
          _pain = existingData['pain']?.toDouble() ?? 1.0;
          _moodObserved = existingData['mood_observed'] == 1;
          _energyObserved = existingData['energy_observed'] == 1;
          _painObserved = existingData['pain_observed'] == 1;

          _painAreas.clear();
          if (existingData['pain_areas'] != null) {
            _painAreas.addAll(
              Map<String, double>.from(existingData['pain_areas']),
            );
          }

          final storedNotes = existingData['notes'] as String? ?? '';
          final decodedNotes = _decodeStoredNotes(storedNotes);
          _notes = decodedNotes.notes;
          _committedNotes = decodedNotes.notes;
          _notesDraftDirty = false;
          _notesController.text = decodedNotes.notes;

          _selectedQuickNotes
            ..clear()
            ..addAll(decodedNotes.quickNotes);
        } else {
          _flowIntensity = FlowIntensity.none;
          _symptoms.clear();
          _symptomSeverity.clear();
          _mood = 3.0;
          _energy = 3.0;
          _pain = 1.0;
          _moodObserved = false;
          _energyObserved = false;
          _painObserved = false;
          _painAreas.clear();
          _notes = '';
          _committedNotes = '';
          _notesDraftDirty = false;
          _notesController.text = '';
          _selectedQuickNotes.clear();
        }

        _hasUnsavedChanges = false;
        _recentlySaved = false;
      });
    } catch (_) {
      // Preserve the current screen state when a database read fails.
    }
  }

  bool _isSameTrackingDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  ({String notes, Set<String> quickNotes}) _decodeStoredNotes(
    String storedNotes,
  ) {
    final marker = '\n\n$_quickTagsMarker ';
    final markerIndex = storedNotes.lastIndexOf(marker);

    if (markerIndex < 0) {
      final standalonePrefix = '$_quickTagsMarker ';
      if (!storedNotes.startsWith(standalonePrefix)) {
        return (notes: storedNotes, quickNotes: <String>{});
      }

      final tags = storedNotes
          .substring(standalonePrefix.length)
          .split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toSet();

      if (tags.isEmpty || !tags.every(_quickNotes.containsKey)) {
        return (notes: storedNotes, quickNotes: <String>{});
      }

      return (notes: '', quickNotes: tags);
    }

    final tags = storedNotes
        .substring(markerIndex + marker.length)
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet();

    if (tags.isEmpty || !tags.every(_quickNotes.containsKey)) {
      return (notes: storedNotes, quickNotes: <String>{});
    }

    return (notes: storedNotes.substring(0, markerIndex), quickNotes: tags);
  }

  void _handleNotesFocusChanged() {
    final isActive = _notesFocusNode.hasFocus;

    if (!mounted || _notesEditorActive == isActive) {
      return;
    }

    setState(() {
      _notesEditorActive = isActive;
    });
  }

  void _beginNotesEditing() {
    if (!mounted || _notesEditorActive) {
      return;
    }

    setState(() {
      _notesEditorActive = true;
    });
  }

  bool _commitNotesDraftForPersistence() {
    if (!_notesDraftDirty) {
      return false;
    }

    if (_committedNotes == _notes) {
      _notesDraftDirty = false;
      return false;
    }

    _committedNotes = _notes;
    _notesDraftDirty = false;
    _editRevision++;
    _hasUnsavedChanges = true;
    _recentlySaved = false;
    _savedStateTimer?.cancel();

    return true;
  }

  void _finishNotesEditing() {
    final notesChanged = _commitNotesDraftForPersistence();

    if (mounted && (_notesEditorActive || notesChanged)) {
      setState(() {
        _notesEditorActive = false;
      });
    }

    _notesFocusNode.unfocus();

    unawaited(_flushPendingAutosave(showFailureFeedback: true));
  }

  void _markUnsavedChanges() {
    _editRevision++;

    if (!_hasUnsavedChanges || _recentlySaved) {
      setState(() {
        _hasUnsavedChanges = true;
        _recentlySaved = false;
      });
    }

    _savedStateTimer?.cancel();
    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    _autosaveTimer?.cancel();
    _autosaveTimer = Timer(_autosaveDelay, () {
      _queueAutosave();
    });
  }

  _TrackingSaveSnapshot _captureTrackingSnapshot() {
    return _TrackingSaveSnapshot(
      date: _selectedDate,
      flowIntensity: _flowIntensity,
      symptoms: List<String>.from(_symptoms),
      symptomSeverity: Map<String, double>.from(_symptomSeverity),
      mood: _mood,
      energy: _energy,
      pain: _pain,
      moodObserved: _moodObserved,
      energyObserved: _energyObserved,
      painObserved: _painObserved,
      painAreas: Map<String, double>.from(_painAreas),
      notes: _committedNotes,
      selectedQuickNotes: Set<String>.from(_selectedQuickNotes),
    );
  }

  void _queueAutosave() {
    if (!_hasUnsavedChanges) return;

    final revision = _editRevision;
    final snapshot = _captureTrackingSnapshot();

    _saveChain = _saveChain.then(
      (_) => _persistTrackingSnapshot(snapshot, revision, showFeedback: false),
    );
  }

  Future<bool> _flushPendingAutosave({bool showFailureFeedback = false}) async {
    _autosaveTimer?.cancel();
    _commitNotesDraftForPersistence();

    final targetRevision = _editRevision;

    if (_hasUnsavedChanges) {
      _queueAutosave();
    }

    await _saveChain;

    final saved = _savedRevision >= targetRevision;

    if (!saved && showFailureFeedback && mounted) {
      await AdaptiveMessages.showError(
        context,
        'Could not save tracking. Please try again.',
      );
    }

    return saved;
  }

  Future<void> _persistTrackingSnapshot(
    _TrackingSaveSnapshot snapshot,
    int revision, {
    required bool showFeedback,
  }) async {
    if (mounted) {
      setState(() {
        _isSaving = true;
      });
    }

    try {
      final databaseService = DatabaseService();

      final quickNotesText = snapshot.selectedQuickNotes.isEmpty
          ? ''
          : '\n\n$_quickTagsMarker '
                '${snapshot.selectedQuickNotes.join(', ')}';

      final fullNotes =
          snapshot.notes.isNotEmpty || snapshot.selectedQuickNotes.isNotEmpty
          ? (snapshot.notes + quickNotesText).trim()
          : null;

      await databaseService.saveDailyTracking(
        date: snapshot.date,
        flowIntensity: snapshot.flowIntensity,
        symptoms: snapshot.symptoms,
        symptomSeverity: snapshot.symptomSeverity,
        mood: snapshot.moodObserved ? snapshot.mood : null,
        energy: snapshot.energyObserved ? snapshot.energy : null,
        pain: snapshot.painObserved ? snapshot.pain : null,
        moodObserved: snapshot.moodObserved,
        energyObserved: snapshot.energyObserved,
        painObserved: snapshot.painObserved,
        painAreas: snapshot.painAreas,
        notes: fullNotes ?? '',
      );

      if (revision > _savedRevision) {
        _savedRevision = revision;
      }

      if (mounted) {
        final isCurrentRevision = revision == _editRevision;

        setState(() {
          _isSaving = false;
          _hasUnsavedChanges = !isCurrentRevision || _notesDraftDirty;
          _recentlySaved = isCurrentRevision && showFeedback;
        });

        if (isCurrentRevision && showFeedback) {
          _savedStateTimer?.cancel();
          _savedStateTimer = Timer(const Duration(milliseconds: 1000), () {
            if (mounted) {
              setState(() {
                _recentlySaved = false;
              });
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _hasUnsavedChanges = true;
        });

        if (showFeedback) {
          HapticFeedback.heavyImpact();
          await AdaptiveMessages.showError(
            context,
            'Could not save tracking. Please try again.',
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient(
            theme.brightness == Brightness.dark,
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom App Bar with Date Selector
              _buildCustomAppBar(),

              // Tab Bar
              _buildTabBar(),

              // Tab Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) {
                    _tabController.animateTo(index);
                  },
                  children: [
                    _buildFlowTab(),
                    _buildSymptomsTab(),
                    _buildMoodEnergyTab(),
                    _buildPainTab(),
                    _buildNotesTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceLg,
        vertical: AppTheme.spaceXl,
      ),
      child: Row(
        children: [
          // Date Selector
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.cardColor.withValues(alpha: 0.72),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 18,
                      offset:
                          (_hasUnsavedChanges || _isSaving || _recentlySaved)
                          ? Offset.zero
                          : const Offset(0, 1.6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: AppTheme.primaryRose,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('EEEE').format(_selectedDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            DateFormat('MMMM d, y').format(_selectedDate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: AppTheme.fwSemi,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.expand_more,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
          ),

          const SizedBox(width: 12),

          // Status indicator (simplified)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
            decoration: BoxDecoration(
              color:
                  (_hasUnsavedChanges
                          ? AppTheme.warningOrange
                          : AppTheme.accentMint)
                      .withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    (_hasUnsavedChanges
                            ? AppTheme.warningOrange
                            : AppTheme.accentMint)
                        .withValues(alpha: 0.32),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _hasUnsavedChanges
                      ? Icons.edit_rounded
                      : Icons.check_circle_rounded,
                  size: 12,
                  color: _hasUnsavedChanges
                      ? AppTheme.warningOrange
                      : AppTheme.accentMint,
                ),
                const SizedBox(width: 5),
                Text(
                  _hasUnsavedChanges ? 'Unsaved' : 'Saved',
                  style: TextStyle(
                    color: _hasUnsavedChanges
                        ? AppTheme.warningOrange
                        : AppTheme.accentMint,
                    fontWeight: AppTheme.fwBold,
                    fontSize: 9.0,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [...AppTheme.shadowLg(Colors.black)],
      ),
      child: AnimatedBuilder(
        animation: _tabController,
        builder: (context, child) {
          return AppSegmentedSelector(
            labels: [
              localizations.flowTab,
              localizations.symptomsTab,
              localizations.moodTab,
              localizations.painTab,
              localizations.notesTab,
            ],
            icons: const [
              Icons.water_drop,
              Icons.health_and_safety,
              Icons.mood,
              Icons.healing,
              Icons.note_alt,
            ],
            selectedIndex: _tabController.index,
            onSelected: (index) {
              if (index != _tabController.index) {
                _tabController.animateTo(index);
              }
            },
          );
        },
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2, end: 0);
  }

  Widget _buildFlowTab() {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, viewportConstraints) {
        final flowTitleStyle = theme.textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        );

        final titlePainter =
            TextPainter(
              text: TextSpan(text: 'Flow', style: flowTitleStyle),
              textDirection: Directionality.of(context),
              textScaler: MediaQuery.textScalerOf(context),
              maxLines: 1,
            )..layout(
              maxWidth: viewportConstraints.maxWidth - (AppTheme.spaceLg * 2),
            );

        // Only space ABOVE the grid is deducted.
        // Insights and contextual feedback remain below the grid and scroll.
        final gridBudget = viewportConstraints.hasBoundedHeight
            ? (viewportConstraints.maxHeight -
                      AppTheme.spaceXl -
                      titlePainter.height -
                      24)
                  .clamp(0.0, double.infinity)
                  .toDouble()
            : null;

        return SingleChildScrollView(
          physics: AppScrollPhysics.spring,
          padding: _trackTabScrollPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Flow',
                style: flowTitleStyle,
              ).animate().fadeIn().slideX(begin: -0.2, end: 0),

              const SizedBox(height: 24),

              // Modern flow intensity selector
              FlowIntensityPicker(
                selectedIntensity: _flowIntensity,
                maxGridHeight: Theme.of(context).platform == TargetPlatform.iOS
                    ? legacyIosGridBudget
                    : null,
                selectedViewportHeight:
                    Theme.of(context).platform == TargetPlatform.android &&
                        _flowIntensity != FlowIntensity.none
                    ? selectedFlowViewportBudget
                    : null,
                aiInsightsKey:
                    Theme.of(context).platform == TargetPlatform.android
                    ? _flowAiInsightsKey
                    : null,
                onIntensitySelected: (intensity) {
                  setState(() {
                    _flowIntensity = intensity;
                  });
                  _markUnsavedChanges();
                  HapticFeedback.selectionClick();

                  if (Theme.of(context).platform == TargetPlatform.android &&
                      intensity != FlowIntensity.none) {
                    // Frame 1 lays out the AI section and measures it.
                    // Frame 2 applies the derived whole-grid scale.
                    // Reveal only after both layouts have settled.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (!mounted) return;

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!mounted) return;

                        final insightContext =
                            _flowAiInsightsKey.currentContext;
                        if (insightContext == null) return;

                        Scrollable.ensureVisible(
                          insightContext,
                          duration: AppTheme.motionBase,
                          curve: AppTheme.motionCurve,
                          alignment: 1.0,
                          alignmentPolicy:
                              ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
                        );
                      });
                    });
                  }
                },
              ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSymptomsTab() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spaceLg,
            vertical: AppTheme.spaceXl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.symptoms,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.selectAllSymptoms,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SymptomSelector(
              selectedSymptoms: _symptoms,
              symptomSeverity: _symptomSeverity,
              onSymptomsChanged: (symptoms) {
                setState(() {
                  _symptoms.clear();
                  _symptoms.addAll(symptoms);
                });
                _markUnsavedChanges();
              },
              onSeverityChanged: (symptom, severity) {
                setState(() {
                  _symptomSeverity[symptom] = severity;
                });
                _markUnsavedChanges();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodEnergyTab() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SingleChildScrollView(
      physics: AppScrollPhysics.spring,
      padding: _trackTabScrollPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: '${localizations.moodAndEnergy}:',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' ${localizations.howAreYouFeelingToday}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MoodEnergySlider(
              label: localizations.mood,
              value: _mood,
              onChanged: (value) {
                setState(() {
                  _mood = value;
                  _moodObserved = true;
                });
                _markUnsavedChanges();
              },
              emoji: _getMoodEmoji(_mood),
              color: AppTheme.primaryRose,
              insight: TrackingPatternInsightService.analyze(
                metric: TrackingInsightMetric.mood,
                currentValue: _mood,
                currentObserved: _moodObserved,
                history: _trackingInsightHistory,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MoodEnergySlider(
              label: 'Energy',
              value: _energy,
              onChanged: (value) {
                setState(() {
                  _energy = value;
                  _energyObserved = true;
                });
                _markUnsavedChanges();
              },
              emoji: _getEnergyEmoji(_energy),
              color: AppTheme.accentMint,
              insight: TrackingPatternInsightService.analyze(
                metric: TrackingInsightMetric.energy,
                currentValue: _energy,
                currentObserved: _energyObserved,
                history: _trackingInsightHistory,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPainTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      physics: AppScrollPhysics.spring,
      padding: _trackTabScrollPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Pain Level:',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' Rate your pain',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: MoodEnergySlider(
              label: 'Pain Level',
              value: _pain,
              onChanged: (value) {
                setState(() {
                  _pain = value;
                  _painObserved = true;
                });
                _markUnsavedChanges();
              },
              emoji: _getPainEmoji(_pain),
              color: AppTheme.primaryRose,
              min: 1,
              max: 5,
              insight: TrackingPatternInsightService.analyze(
                metric: TrackingInsightMetric.pain,
                currentValue: _pain,
                currentObserved: _painObserved,
                history: _trackingInsightHistory,
              ),
            ),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PainBodyMap(
              painAreas: _painAreas,
              onPainAreaChanged: (area, intensity) {
                setState(() {
                  if (intensity > 0) {
                    _painAreas[area] = intensity;
                  } else {
                    _painAreas.remove(area);
                  }
                });
                _markUnsavedChanges();
              },
            ),
          ),
          const SizedBox(height: AppTheme.spaceXl),
        ],
      ),
    );
  }

  Widget _buildNotesTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      key: const ValueKey('track-notes-scroll-view'),
      physics: AppScrollPhysics.spring,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: _trackTabScrollPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Personal Notes:',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                  text: ' Add a quick cycle note',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideX(begin: -0.2, end: 0),

          const SizedBox(height: 24),

          // Notes Input Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              key: const ValueKey('track-notes-editor'),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _notesController.text.isNotEmpty
                      ? AppTheme.primaryRose.withValues(alpha: 0.1)
                      : theme.dividerColor,
                  width: 2,
                ),
                boxShadow: AppTheme.shadowLg(theme.shadowColor),
              ),
              child: Column(
                children: [
                  // Header with icon
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primaryRose.withValues(alpha: 0.1),
                          AppTheme.primaryPurple.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppTheme.primaryRose,
                                AppTheme.primaryPurple,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.edit_note_rounded,
                            color: theme.colorScheme.onPrimary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today\'s Journal Entry',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                DateFormat(
                                  'EEEE, MMMM d',
                                ).format(_selectedDate),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (_notesController.text.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentMint.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color:
                                    (_hasUnsavedChanges
                                            ? AppTheme.warningOrange
                                            : AppTheme.accentMint)
                                        .withValues(alpha: 0.42),
                              ),
                            ),
                            child: Text(
                              '${_notesController.text.length} chars',
                              style: const TextStyle(
                                fontSize: AppTheme.fsXs,
                                color: AppTheme.accentMint,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Text Input Area
                  Container(
                    key: const ValueKey('track-notes-input-area'),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                    child: Semantics(
                      container: true,
                      textField: true,
                      label: AppLocalizations.of(context).notesTab,
                      child: TextField(
                        key: const ValueKey('track-notes-field'),
                        controller: _notesController,
                        focusNode: _notesFocusNode,
                        onTap: _beginNotesEditing,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.done,
                        textCapitalization: TextCapitalization.sentences,
                        onEditingComplete: _finishNotesEditing,
                        maxLines: null,
                        minLines: 5,
                        scrollPadding: const EdgeInsets.all(AppTheme.spaceXl),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.5,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Anything worth remembering?',
                          hintStyle: TextStyle(
                            color: theme.textTheme.bodyMedium?.color
                                ?.withValues(alpha: 0.1),
                            fontSize: AppTheme.fsMd,
                            height: 1.5,
                          ),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                        ),
                        onChanged: (value) {
                          if (_notes == value) {
                            return;
                          }

                          setState(() {
                            _notes = value;
                            _notesDraftDirty = _notes != _committedNotes;
                            _hasUnsavedChanges =
                                _hasUnsavedChanges || _notesDraftDirty;
                            if (_notesDraftDirty) {
                              _recentlySaved = false;
                            }
                          });

                          _savedStateTimer?.cancel();
                        },
                        onTapOutside: (_) {
                          FocusScope.of(context).unfocus();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),

          const SizedBox(height: 30),

          // Quick Notes - Always Visible Multi-Select
          Text(
            'Quick Tags',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap to select multiple tags for quick tracking',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _quickNotes.entries
                  .map((entry) => _buildQuickNote(entry.value, entry.key))
                  .toList(growable: false),
            ),
          ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  Widget _buildQuickNote(String emoji, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedQuickNotes.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedQuickNotes.remove(label);
          } else {
            _selectedQuickNotes.add(label);
          }
        });
        _markUnsavedChanges();
        HapticFeedback.selectionClick();
      },
      child: AnimatedContainer(
        duration: AppTheme.motionFast,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryRose.withValues(alpha: 0.15)
              : theme.cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.primaryRose : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primaryRose.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ]
              : [
                  BoxShadow(
                    color: theme.shadowColor.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Semantics(
          button: true,
          selected: isSelected,
          label: label,
          excludeSemantics: true,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                emoji,
                style: TextStyle(
                  fontSize: 15,
                  shadows: isSelected
                      ? [
                          Shadow(
                            color: AppTheme.primaryRose.withValues(alpha: 0.3),
                            blurRadius: 4,
                          ),
                        ]
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSelected
                        ? AppTheme.primaryRose
                        : theme.colorScheme.onSurface.withValues(alpha: 0.8),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isSelected ? Icons.check_circle : Icons.add_circle_outline,
                size: 14,
                color: isSelected
                    ? AppTheme.primaryRose
                    : theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final theme = Theme.of(context);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: AppTheme.primaryRose,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || _isSameTrackingDate(picked, _selectedDate)) {
      return;
    }

    final saved = await _flushPendingAutosave(showFailureFeedback: true);

    if (!mounted || !saved) {
      return;
    }

    setState(() {
      _selectedDate = picked;
    });

    await _loadExistingData();
  }

  String _getMoodEmoji(double mood) {
    if (mood <= 1) return '😢';
    if (mood <= 2) return '😔';
    if (mood <= 3) return '😐';
    if (mood <= 4) return '😊';
    return '😄';
  }

  String _getEnergyEmoji(double energy) {
    if (energy <= 1) return '😴';
    if (energy <= 2) return '😪';
    if (energy <= 3) return '🙂';
    if (energy <= 4) return '⚡';
    return '🔥';
  }

  String _getPainEmoji(double pain) {
    if (pain <= 1) return '😌';
    if (pain <= 2) return '😕';
    if (pain <= 3) return '😣';
    if (pain <= 4) return '😖';
    return '😫';
  }
}

class _TrackingSaveSnapshot {
  const _TrackingSaveSnapshot({
    required this.date,
    required this.flowIntensity,
    required this.symptoms,
    required this.symptomSeverity,
    required this.mood,
    required this.energy,
    required this.pain,
    required this.moodObserved,
    required this.energyObserved,
    required this.painObserved,
    required this.painAreas,
    required this.notes,
    required this.selectedQuickNotes,
  });

  final DateTime date;
  final FlowIntensity flowIntensity;
  final List<String> symptoms;
  final Map<String, double> symptomSeverity;
  final double mood;
  final double energy;
  final double pain;
  final bool moodObserved;
  final bool energyObserved;
  final bool painObserved;
  final Map<String, double> painAreas;
  final String notes;
  final Set<String> selectedQuickNotes;
}
