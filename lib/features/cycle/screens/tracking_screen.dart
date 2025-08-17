import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/cycle_data.dart';
import '../../../core/database/database_service.dart';
import '../../../generated/app_localizations.dart';
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
      });
    }
  }
  
  Future<void> _saveTrackingData() async {
    HapticFeedback.lightImpact();
    
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
      
      setState(() {
        _hasUnsavedChanges = false;
      });
      
      // Show success feedback with localized message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(localizations.trackingDataSaved(DateFormat('MMM d').format(_selectedDate))),
              ],
            ),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      // Handle save errors
      debugPrint('Error saving tracking data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Failed to save tracking data. Please try again.'),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient(Theme.of(context).brightness == Brightness.dark),
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
                  color: Colors.white.withValues(alpha: 0.9),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.mediumGrey,
                          ),
                        ),
                        Text(
                          DateFormat('MMMM d, y').format(_selectedDate),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(
                      Icons.expand_more,
                      color: AppTheme.mediumGrey,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn().slideX(begin: -0.2, end: 0),
          ),
          
          const SizedBox(width: 12),
          
          // AI Insights Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.psychology,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  'AI',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms).scale(),
        ],
      ),
    );
  }
  
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
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
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.mediumGrey,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
  
  Widget _buildFlowTab() {
    final localizations = AppLocalizations.of(context);
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.flowIntensity,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn().slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            localizations.selectTodaysFlowIntensity,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
            ),
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 20),
          
          Expanded(
            child: FlowIntensityPicker(
              selectedIntensity: _flowIntensity,
              onIntensitySelected: (intensity) {
                setState(() {
                  _flowIntensity = intensity;
                });
                _markUnsavedChanges();
                HapticFeedback.selectionClick();
              },
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.3, end: 0),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSymptomsTab() {
    final localizations = AppLocalizations.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                localizations.symptoms,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                localizations.selectAllSymptoms,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mediumGrey,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
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
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            localizations.moodAndEnergy,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            localizations.howAreYouFeelingToday,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGrey,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Pain Level',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Rate your overall pain level',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGrey,
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
          SizedBox(
            height: 400, // Fixed height for PainBodyMap
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Notes',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGrey,
            ),
          ).animate().fadeIn().slideX(begin: -0.2, end: 0),
          
          const SizedBox(height: 8),
          
          Text(
            'Capture your thoughts, feelings, and observations about your cycle',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGrey,
            ),
          ).animate().fadeIn(delay: 100.ms),
          
          const SizedBox(height: 30),
          
          // Notes Input Section
          Container(
            constraints: const BoxConstraints(minHeight: 200),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _notesController.text.isNotEmpty 
                    ? AppTheme.primaryRose.withValues(alpha: 0.3)
                    : Theme.of(context).dividerColor,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).shadowColor.withValues(alpha: 0.08),
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
                        AppTheme.primaryPurple.withValues(alpha: 0.05),
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
                        child: const Icon(
                          Icons.edit_note_rounded,
                          color: Colors.white,
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
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.darkGrey,
                              ),
                            ),
                            Text(
                              DateFormat('EEEE, MMMM d').format(_selectedDate),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.mediumGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_notesController.text.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentMint.withValues(alpha: 0.2),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    decoration: InputDecoration(
                      hintText: 'How are you feeling today? Any symptoms, mood changes, or observations you\'d like to remember?\n\nTip: Recording your thoughts helps identify patterns over time.',
                      hintStyle: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.5),
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
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.darkGrey,
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
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: AppTheme.lightGrey,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.darkGrey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.add_circle_outline,
              size: 16,
              color: AppTheme.mediumGrey,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: _hasUnsavedChanges ? _saveTrackingData : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _hasUnsavedChanges ? null : AppTheme.lightGrey,
            disabledBackgroundColor: AppTheme.lightGrey,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: _hasUnsavedChanges ? 4 : 0,
          ).copyWith(
            backgroundColor: _hasUnsavedChanges 
                ? WidgetStateProperty.all(null)
                : WidgetStateProperty.all(AppTheme.lightGrey),
          ),
          child: Container(
            decoration: _hasUnsavedChanges 
                ? const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  )
                : null,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_hasUnsavedChanges) ...[
                    Icon(
                      Icons.save,
                      color: Colors.white,
                      size: 20,
                    ),
                  ],
                  const SizedBox(width: 8),
                  Text(
                    _hasUnsavedChanges ? 'Save Tracking Data' : 'No Changes to Save',
                    style: TextStyle(
                      color: _hasUnsavedChanges ? Colors.white : AppTheme.mediumGrey,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3, end: 0);
  }
  
  Future<void> _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
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
}
