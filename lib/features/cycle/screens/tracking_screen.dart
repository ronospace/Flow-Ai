import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/cycle_data.dart';
import '../../../core/database/database_service.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/widgets/modern_button.dart';
import '../widgets/flow_intensity_picker.dart';
import '../widgets/symptom_selector.dart';
import '../widgets/mood_energy_slider.dart';
import '../widgets/pain_body_map.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  late PageController _pageController;
  
  // Tracking data
  DateTime _selectedDate = DateTime.now();
  FlowIntensity _flowIntensity = FlowIntensity.none;
  final Set<String> _symptoms = {};
  final Map<String, double> _symptomSeverity = {};
  double _mood = 3.0;
  double _energy = 3.0;
  double _pain = 1.0;
  final Map<String, double> _painAreas = {};
  String _notes = '';
  
  final TextEditingController _notesController = TextEditingController();
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;
  bool _recentlySaved = false;
  Timer? _savedStateTimer;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _pageController = PageController();
    
    // Load existing data for selected date
    _loadExistingData();
    
    // Listen for changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _pageController.animateToPage(
          _tabController.index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }
  
  @override
  void dispose() {
    _savedStateTimer?.cancel();
    _tabController.dispose();
    _pageController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  void _loadExistingData() async {
    try {
      // Load existing tracking data for the selected date from database
      final databaseService = DatabaseService();
      final existingData = await databaseService.getDailyTracking(_selectedDate);
      
      if (existingData != null) {
        setState(() {
          _flowIntensity = existingData['flow_intensity'] ?? FlowIntensity.none;
          
          // Load symptoms
          _symptoms.clear();
          if (existingData['symptoms'] != null) {
            _symptoms.addAll(List<String>.from(existingData['symptoms']));
          }
          
          // Load symptom severity
          _symptomSeverity.clear();
          if (existingData['symptom_severity'] != null) {
            _symptomSeverity.addAll(Map<String, double>.from(existingData['symptom_severity']));
          }
          
          // Load mood, energy, pain
          _mood = existingData['mood']?.toDouble() ?? 3.0;
          _energy = existingData['energy']?.toDouble() ?? 3.0;
          _pain = existingData['pain']?.toDouble() ?? 1.0;
          
          // Load pain areas
          _painAreas.clear();
          if (existingData['pain_areas'] != null) {
            _painAreas.addAll(Map<String, double>.from(existingData['pain_areas']));
          }
          
          // Load notes
          _notes = existingData['notes'] ?? '';
          _notesController.text = _notes;
          
          // Reset unsaved changes since we just loaded
          _hasUnsavedChanges = false;
        });
      } else {
        // Reset to defaults if no data exists for this date
        setState(() {
          _flowIntensity = FlowIntensity.none;
          _symptoms.clear();
          _symptomSeverity.clear();
          _mood = 3.0;
          _energy = 3.0;
          _pain = 1.0;
          _painAreas.clear();
          _notes = '';
          _notesController.text = '';
          _hasUnsavedChanges = false;
        });
      }
    } catch (e) {
      // Handle database errors gracefully
      debugPrint('Error loading tracking data: $e');
    }
  }
  
  
  void _markUnsavedChanges() {
    if (!_hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = true;
        _recentlySaved = false; // Clear recent saved state when new changes are made
      });
    }
    // Cancel the saved state timer if it's running
    _savedStateTimer?.cancel();
  }
  
  Future<void> _saveTrackingData() async {
    // Prevent multiple simultaneous saves
    if (_isSaving) return;
    
    HapticFeedback.lightImpact();
    
    // Set loading state
    setState(() {
      _isSaving = true;
    });
    
    try {
      final databaseService = DatabaseService();
      final localizations = AppLocalizations.of(context);
      
      // Save daily tracking data to database
      await databaseService.saveDailyTracking(
        date: _selectedDate,
        flowIntensity: _flowIntensity != FlowIntensity.none ? _flowIntensity : null,
        symptoms: _symptoms.isNotEmpty ? _symptoms.toList() : null,
        symptomSeverity: _symptomSeverity.isNotEmpty ? _symptomSeverity : null,
        mood: _mood,
        energy: _energy,
        pain: _pain,
        painAreas: _painAreas.isNotEmpty ? _painAreas : null,
        notes: _notes.isNotEmpty ? _notes : null,
      );
      
      // Success haptic feedback
      HapticFeedback.heavyImpact();
      
      if (mounted) {
        setState(() {
          _hasUnsavedChanges = false;
          _isSaving = false;
          _recentlySaved = true;
        });
        
        // Set timer to clear the "recently saved" state after 1 second (faster feedback)
        _savedStateTimer?.cancel();
        _savedStateTimer = Timer(const Duration(milliseconds: 1000), () {
          if (mounted) {
            setState(() {
              _recentlySaved = false;
            });
          }
        });
        
        // Show enhanced success feedback with animation and improved styling
        final theme = Theme.of(context);
        
        // Use a try-catch to handle ScaffoldMessenger context issues
        try {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: theme.shadowColor.withValues(alpha: 0.15),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.celebration,
                      color: AppTheme.primaryRose,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                '🎉 Data Successfully Saved!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: theme.colorScheme.onPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tracking for ${DateFormat('MMMM d, yyyy').format(_selectedDate)} securely stored',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '✓',
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: AppTheme.primaryRose,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(milliseconds: 1500), // Fast display for better UX
            elevation: 12,
            action: _shouldShowSmartNavigation() ? SnackBarAction(
              label: 'View Insights',
              textColor: theme.colorScheme.onPrimary,
              backgroundColor: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
              onPressed: () => _navigateToInsights(),
            ) : null,
          ),
        );
        } catch (e) {
          // Fallback: show simple success indicator if ScaffoldMessenger fails
          debugPrint('✅ Data saved successfully for ${DateFormat('MMMM d, yyyy').format(_selectedDate)}');
        }
        
        // Auto-navigate to next tab after save (unless on last tab)
        _autoNavigateToNextTab();
        
        // Smart post-save navigation after delay
        _scheduleSmartNavigation();
        
        // Always show a quick action suggestion after 2 seconds for user engagement
        _scheduleQuickActionSuggestion();
      }
    } catch (e) {
      // Handle save errors
      debugPrint('Error saving tracking data: $e');
      
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        
        // Error haptic feedback
        HapticFeedback.heavyImpact();
        
        final theme = Theme.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onError.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onError,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Save Failed',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                        Text(
                        'Please check your connection and try again',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onError.withValues(alpha: 0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 4),
            elevation: 8,
            action: SnackBarAction(
              label: 'Retry',
              textColor: theme.colorScheme.onError,
              onPressed: _saveTrackingData,
            ),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient(theme.brightness == Brightness.dark),
        ),
        child: SafeArea(
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
              
              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildCustomAppBar() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Date Selector
          Expanded(
            child: GestureDetector(
              onTap: () => _showDatePicker(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.cardColor.withValues(alpha: 0.9),
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
                      color: AppTheme.primaryRose,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat('EEEE').format(_selectedDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                          ),
                        ),
                        Text(
                          DateFormat('MMMM d, y').format(_selectedDate),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: _hasUnsavedChanges 
                ? AppTheme.warningOrange.withValues(alpha: 0.1)
                : AppTheme.accentMint.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _hasUnsavedChanges ? 'Unsaved' : 'Synced',
              style: TextStyle(
                color: _hasUnsavedChanges ? AppTheme.warningOrange : AppTheme.accentMint,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }
  
  Widget _buildTabBar() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        tabAlignment: TabAlignment.center,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        dividerColor: Colors.transparent,
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
        tabs: [
          Tab(
            child: _buildTabContent(Icons.water_drop, AppLocalizations.of(context).flowTab),
          ),
          Tab(
            child: _buildTabContent(Icons.health_and_safety, AppLocalizations.of(context).symptomsTab),
          ),
          Tab(
            child: _buildTabContent(Icons.mood, AppLocalizations.of(context).moodTab),
          ),
          Tab(
            child: _buildTabContent(Icons.healing, AppLocalizations.of(context).painTab),
          ),
          Tab(
            child: _buildTabContent(Icons.note_alt, AppLocalizations.of(context).notesTab),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: -0.2, end: 0);
  }
  
  Widget _buildTabContent(IconData icon, String label) {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 3),
          Text(label),
        ],
      ),
    );
  }
  
  Widget _buildFlowTab() {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flow',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ).animate().fadeIn().slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 24),
          
          // Modern flow intensity selector
          FlowIntensityPicker(
            selectedIntensity: _flowIntensity,
            onIntensitySelected: (intensity) {
              setState(() {
                _flowIntensity = intensity;
              });
              _markUnsavedChanges();
              HapticFeedback.selectionClick();
            },
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2, end: 0),
          
          const SizedBox(height: 24),
          
          // Simplified AI insight
          if (_flowIntensity != FlowIntensity.none)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentMint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentMint.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.accentMint,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _getFlowInsight(_flowIntensity),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0),
        ],
      ),
    );
  }
  
  Widget _buildSymptomsTab() {
    final localizations = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.all(20),
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
          child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localizations.moodAndEnergy,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.howAreYouFeelingToday,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 30),
          MoodEnergySlider(
            label: localizations.mood,
            value: _mood,
            onChanged: (value) {
              setState(() {
                _mood = value;
              });
              _markUnsavedChanges();
            },
            emoji: _getMoodEmoji(_mood),
            color: AppTheme.primaryRose,
          ),
          const SizedBox(height: 40),
          MoodEnergySlider(
            label: 'Energy',
            value: _energy,
            onChanged: (value) {
              setState(() {
                _energy = value;
              });
              _markUnsavedChanges();
            },
            emoji: _getEnergyEmoji(_energy),
            color: AppTheme.accentMint,
          ),
          const SizedBox(height: 100), // Extra bottom padding
        ],
      ),
    );
  }
  
  Widget _buildPainTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pain Level',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rate your overall pain level',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 30),
          MoodEnergySlider(
            label: 'Pain Level',
            value: _pain,
            onChanged: (value) {
              setState(() {
                _pain = value;
              });
              _markUnsavedChanges();
            },
            emoji: _getPainEmoji(_pain),
            color: AppTheme.primaryRose,
            min: 1,
            max: 5,
          ),
          const SizedBox(height: 40),
          SizedBox(height: 400, // Fixed height for PainBodyMap
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
          const SizedBox(height: 20), // Bottom padding
        ],
      ),
    );
  }
  
  Widget _buildNotesTab() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Notes',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ).animate().fadeIn().slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'Capture your thoughts, feelings, and observations about your cycle',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 30),
          
          // Notes Input Section
          Container(
            constraints: const BoxConstraints(minHeight: 200),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _notesController.text.isNotEmpty 
                    ? AppTheme.primaryRose.withValues(alpha: 0.1)
                    : theme.dividerColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                // Header with icon
                Container(
                  padding: const EdgeInsets.all(20),
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
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
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
                              DateFormat('EEEE, MMMM d').format(_selectedDate),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_notesController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentMint.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${_notesController.text.length} chars',
                            style: const TextStyle(
                              fontSize: 10,
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
                  constraints: const BoxConstraints(minHeight: 180),
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: _notesController,
                    maxLines: null,
                    minLines: 8,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: 'How are you feeling today? Any symptoms, mood changes, or observations you\'d like to remember?\n\nTip: Recording your thoughts helps identify patterns over time.',
                      hintStyle: TextStyle(
                        color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.1),
                        fontSize: 14,
                        height: 1.5,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                    ),
                    textInputAction: TextInputAction.newline,
                    onChanged: (value) {
                      setState(() {
                        _notes = value;
                      });
                      _markUnsavedChanges();
                    },
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
          
          const SizedBox(height: 30),
          
          // Quick Notes Suggestions
          if (_notesController.text.isEmpty) ...[
            Text(
              'Quick Notes',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildQuickNote('🌙', 'Sleep quality'),
                _buildQuickNote('🍎', 'Food cravings'),
                _buildQuickNote('💧', 'Hydration'),
                _buildQuickNote('🏃‍♀️', 'Exercise'),
                _buildQuickNote('😴', 'Energy levels'),
                _buildQuickNote('🧘‍♀️', 'Stress management'),
              ],
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
  
  Widget _buildQuickNote(String emoji, String label) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () {
        final currentText = _notesController.text;
        final newText = currentText.isEmpty 
            ? '$label: '
            : '$currentText\n$label: ';
        
        _notesController.text = newText;
        _notesController.selection = TextSelection.fromPosition(
          TextPosition(offset: newText.length),
        );
        
        setState(() {
          _notes = newText;
        });
        _markUnsavedChanges();
        HapticFeedback.selectionClick();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: theme.dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.add_circle_outline,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSaveButton() {
    String buttonText;
    IconData buttonIcon;
    List<Color>? gradientColors;
    bool isEnabled;
    bool isLoading = false;
    
    if (_isSaving) {
      buttonText = '⏳ Saving...';
      buttonIcon = Icons.hourglass_empty_rounded;
      gradientColors = [AppTheme.mediumGrey, AppTheme.mediumGrey];
      isEnabled = false;
      isLoading = true;
    } else if (_recentlySaved) {
      buttonText = 'Saved ✓';
      buttonIcon = Icons.check_rounded;
      gradientColors = [AppTheme.successGreen, AppTheme.successGreen.withValues(alpha: 0.8)];
      isEnabled = false;
    } else if (_hasUnsavedChanges) {
      buttonText = 'Save Changes';
      buttonIcon = Icons.save_rounded;
      gradientColors = [AppTheme.primaryRose, AppTheme.primaryPurple]; // Elegant gradient
      isEnabled = true;
    } else {
      buttonText = 'Up to date';
      buttonIcon = Icons.done_rounded;
      gradientColors = [AppTheme.accentMint.withValues(alpha: 0.6), AppTheme.accentMint.withValues(alpha: 0.4)];
      isEnabled = false;
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ModernButton(
          text: buttonText,
          onPressed: isEnabled ? _saveTrackingData : null,
          icon: buttonIcon,
          type: _hasUnsavedChanges ? ModernButtonType.primary : ModernButtonType.success,
          size: ModernButtonSize.medium,
          isExpanded: true,
          isLoading: isLoading,
          gradientColors: gradientColors,
        ),
      ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0),
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
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _loadExistingData();
    }
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
  
  String _getFlowInsight(FlowIntensity intensity) {
    switch (intensity) {
      case FlowIntensity.none:
        return 'Start tracking to get personalized insights';
      case FlowIntensity.spotting:
        return 'Light spotting is normal at the beginning or end of your cycle.';
      case FlowIntensity.light:
        return 'Light flow - stay hydrated and rest as needed.';
      case FlowIntensity.medium:
        return 'Normal flow pattern - you\'re doing great!';
      case FlowIntensity.heavy:
        return 'Heavy flow - monitor iron intake and rest.';
      case FlowIntensity.veryHeavy:
        return 'Very heavy flow - consider tracking for your doctor.';
      default:
        return 'Keep tracking for better insights';
    }
  }
  
  // Auto-navigate to next tab after save
  void _autoNavigateToNextTab() {
    // Get current tab index
    final currentTabIndex = _tabController.index;
    final totalTabs = _tabController.length;
    
    // Only navigate if not on last tab
    if (currentTabIndex < totalTabs - 1) {
      // Schedule navigation with small delay for better UX
      Timer(const Duration(milliseconds: 800), () {
        if (mounted) {
          // Animate to next tab
          _tabController.animateTo(currentTabIndex + 1);
          
          // Provide haptic feedback
          HapticFeedback.selectionClick();
        }
      });
    }
  }
  
  // Smart navigation helper methods
  bool _shouldShowSmartNavigation() {
    // Only show navigation suggestion for critical situations
    final hasCriticalData = (_flowIntensity == FlowIntensity.heavy || _flowIntensity == FlowIntensity.veryHeavy) ||
        (_symptoms.length >= 3) || // Multiple symptoms
        (_pain >= 4.0) || // High pain
        (_painAreas.length >= 2); // Multiple pain areas
    
    return hasCriticalData;
  }
  
  void _navigateToInsights() {
    // Navigate to insights/analytics page
    context.go('/insights');
  }
  
  void _scheduleSmartNavigation() {
    // Only schedule auto-navigation if user has entered substantial tracking data
    if (!_shouldShowSmartNavigation()) return;
    
    // Wait 6 seconds after save confirmation, then show navigation options
    Timer(const Duration(seconds: 6), () {
      if (!mounted) return;
      
      // Determine best next screen based on tracked data
      String nextScreen = _determineNextScreen();
      String screenTitle = _getScreenTitle(nextScreen);
      
      // Show bottom sheet with navigation options
      _showSmartNavigationSheet(nextScreen, screenTitle);
    });
  }
  
  void _scheduleQuickActionSuggestion() {
    // Show a quick action suggestion for all users after 2 seconds
    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      // Don't show if critical navigation is already scheduled
      if (_shouldShowSmartNavigation()) return;
      
      // Show a brief, helpful next action
      _showQuickActionSnackBar();
    });
  }
  
  void _showQuickActionSnackBar() {
    final theme = Theme.of(context);
    
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.accentMint,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Great job tracking! View your progress or add more entries.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View Progress',
            textColor: AppTheme.primaryRose,
            onPressed: () => context.go('/insights'),
          ),
        ),
      );
    } catch (e) {
      // Fallback: log success message if ScaffoldMessenger fails
      debugPrint('💡 Quick action suggestion: View your progress or add more entries');
    }
  }
  
  String _determineNextScreen() {
    // Smart logic to suggest next screen based on what was tracked
    if (_symptoms.isNotEmpty || _pain > 2.0) {
      return '/insights'; // Show health insights if symptoms or pain
    } else if (_flowIntensity != FlowIntensity.none) {
      return '/cycle'; // Show cycle overview for flow tracking
    } else if (_notes.isNotEmpty && _notes.length > 50) {
      return '/journal'; // Show journal/notes history for detailed entries
    } else {
      return '/home'; // Default to home screen
    }
  }
  
  String _getScreenTitle(String route) {
    switch (route) {
      case '/insights':
        return 'Health Insights';
      case '/cycle':
        return 'Cycle Overview';
      case '/journal':
        return 'Personal Journal';
      case '/home':
      default:
        return 'Home Dashboard';
    }
  }
  
  void _showSmartNavigationSheet(String nextScreen, String screenTitle) {
    final theme = Theme.of(context);
    
    try {
      // Show a more subtle snackbar instead of full modal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'AI Insights Available',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      'View personalized health recommendations',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: theme.colorScheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 4),
          elevation: 8,
          action: SnackBarAction(
            label: 'View Insights',
            textColor: AppTheme.primaryRose,
            onPressed: () => context.go(nextScreen),
          ),
        ),
      );
    } catch (e) {
      // Fallback: log smart navigation suggestion if ScaffoldMessenger fails
      debugPrint('🤖 AI Insights Available: View personalized health recommendations at $screenTitle');
    }
  }
}
