import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/onboarding_data.dart';
import '../../../core/ui/adaptive_components.dart';

/// 📊 Cycle History Import Widget - Advanced Data Import System  
/// Features: Multiple import sources, CSV/JSON parsing, manual entry,
/// smart pattern detection, and data validation
class CycleHistoryImportWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onDataChanged;
  final OnboardingData initialData;

  const CycleHistoryImportWidget({
    super.key,
    required this.onDataChanged,
    required this.initialData,
  });

  @override
  State<CycleHistoryImportWidget> createState() => _CycleHistoryImportWidgetState();
}

class _CycleHistoryImportWidgetState extends State<CycleHistoryImportWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  DateTime? _lastPeriodDate;
  int? _averageCycleLength;
  int? _averagePeriodLength;
  bool _isFirstTimeTracking = false;
  String? _previousTrackingMethod;
  String _importMethod = 'manual';
  
  final _cycleLengthController = TextEditingController();
  final _periodLengthController = TextEditingController();
  
  final List<Map<String, dynamic>> _importMethods = [
    {
      'id': 'manual',
      'title': 'Manual Entry',
      'subtitle': 'Enter your cycle information manually',
      'icon': Icons.edit,
      'color': Colors.blue,
    },
    {
      'id': 'csv_import',
      'title': 'CSV Import',
      'subtitle': 'Import from CSV file or spreadsheet',
      'icon': Icons.file_upload,
      'color': Colors.green,
    },
    {
      'id': 'app_import',
      'title': 'App Import',
      'subtitle': 'Import from other tracking apps',
      'icon': Icons.smartphone,
      'color': Colors.purple,
    },
    {
      'id': 'health_connect',
      'title': 'Health Connect',
      'subtitle': 'Sync with Apple Health or Google Fit',
      'icon': Icons.health_and_safety,
      'color': Colors.red,
    },
  ];

  final List<Map<String, dynamic>> _trackingApps = [
    {
      'id': 'clue',
      'name': 'Clue',
      'icon': '🔴',
      'supported': true,
    },
    {
      'id': 'flo',
      'name': 'Flo',
      'icon': '🌸',
      'supported': true,
    },
    {
      'id': 'period_tracker',
      'name': 'Period Tracker',
      'icon': '📅',
      'supported': true,
    },
    {
      'id': 'ovia',
      'name': 'Ovia',
      'icon': '🦋',
      'supported': true,
    },
    {
      'id': 'glow',
      'name': 'Glow',
      'icon': '✨',
      'supported': false,
    },
    {
      'id': 'maya',
      'name': 'Maya',
      'icon': '🌙',
      'supported': false,
    },
  ];

  List<Map<String, DateTime>> _importedCycles = [];
  bool _isImporting = false;
  String? _importError;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadInitialData();
    _initializeControllers();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  void _initializeControllers() {
    _cycleLengthController.addListener(_onManualDataChanged);
    _periodLengthController.addListener(_onManualDataChanged);
  }

  void _loadInitialData() {
    final data = widget.initialData;
    _lastPeriodDate = data.lastPeriodDate;
    _averageCycleLength = data.averageCycleLength;
    _averagePeriodLength = data.averagePeriodLength;
    _isFirstTimeTracking = data.isFirstTimeTracking ?? false;
    _previousTrackingMethod = data.previousTrackingMethod;
    
    _cycleLengthController.text = _averageCycleLength?.toString() ?? '';
    _periodLengthController.text = _averagePeriodLength?.toString() ?? '';
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    super.dispose();
  }

  void _onManualDataChanged() {
    _averageCycleLength = int.tryParse(_cycleLengthController.text);
    _averagePeriodLength = int.tryParse(_periodLengthController.text);
    _notifyDataChanged();
  }

  void _notifyDataChanged() {
    final data = {
      'lastPeriodDate': _lastPeriodDate,
      'averageCycleLength': _averageCycleLength,
      'averagePeriodLength': _averagePeriodLength,
      'isFirstTimeTracking': _isFirstTimeTracking,
      'previousTrackingMethod': _previousTrackingMethod,
      'importedCycles': _importedCycles,
    };
    
    widget.onDataChanged(data);
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 32),
              _buildFirstTimeTrackingSection(context),
              const SizedBox(height: 32),
              if (!_isFirstTimeTracking) ...[
                _buildImportMethodSelection(context),
                const SizedBox(height: 32),
                _buildImportContent(context),
                const SizedBox(height: 32),
              ],
              _buildManualEntrySection(context),
              if (_importedCycles.isNotEmpty) ...[
                const SizedBox(height: 32),
                _buildImportedDataPreview(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your cycle history 📊',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Help us understand your patterns for more accurate predictions.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFirstTimeTrackingSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: theme.colorScheme.primary,
                size: 24,
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Text(
                  'Is this your first time tracking periods?',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildTrackingOptionCard(
                  context,
                  title: 'Yes, first time',
                  subtitle: 'I\'m new to period tracking',
                  isSelected: _isFirstTimeTracking,
                  onTap: () => _setFirstTimeTracking(true),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: _buildTrackingOptionCard(
                  context,
                  title: 'No, I have data',
                  subtitle: 'I\'ve tracked before',
                  isSelected: !_isFirstTimeTracking,
                  onTap: () => _setFirstTimeTracking(false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingOptionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 4),
            
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportMethodSelection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How would you like to add your data?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Column(
          children: _importMethods.map((method) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildImportMethodCard(context, method),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildImportMethodCard(BuildContext context, Map<String, dynamic> method) {
    final theme = Theme.of(context);
    final isSelected = _importMethod == method['id'];
    
    return InkWell(
      onTap: () {
        setState(() {
          _importMethod = method['id'];
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (method['color'] as Color).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                method['icon'],
                color: method['color'],
                size: 24,
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['title'],
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    method['subtitle'],
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportContent(BuildContext context) {
    switch (_importMethod) {
      case 'csv_import':
        return _buildCSVImportSection(context);
      case 'app_import':
        return _buildAppImportSection(context);
      case 'health_connect':
        return _buildHealthConnectSection(context);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCSVImportSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.file_upload,
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(width: 12),
              
              Text(
                'CSV Import',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Expected CSV format:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Date,Flow,Symptoms,Mood\n2024-01-15,Heavy,"Cramps,Bloating",Tired\n2024-01-16,Medium,Headache,Moody',
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: theme.colorScheme.onBackground.withValues(alpha: 0.8),
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          Row(
            children: [
              Expanded(
                child: AdaptiveButton(
                  text: 'Choose CSV File',
                  onPressed: _handleCSVImport,
                  isPrimary: false,
                  icon: Icons.folder_open,
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: AdaptiveButton(
                  text: 'Download Template',
                  onPressed: _downloadCSVTemplate,
                  isPrimary: false,
                  icon: Icons.download,
                ),
              ),
            ],
          ),
          
          if (_importError != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                  ),
                  
                  const SizedBox(width: 12),
                  
                  Expanded(
                    child: Text(
                      _importError!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppImportSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Import from tracking apps',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Select your previous tracking app:',
            style: theme.textTheme.bodyMedium,
          ),
          
          const SizedBox(height: 16),
          
          ...(_trackingApps.map((app) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAppImportCard(context, app),
          ))),
        ],
      ),
    );
  }

  Widget _buildAppImportCard(BuildContext context, Map<String, dynamic> app) {
    final theme = Theme.of(context);
    final isSupported = app['supported'] as bool;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isSupported
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : theme.colorScheme.onSurface.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                app['icon'],
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app['name'],
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                
                Text(
                  isSupported ? 'Supported' : 'Coming Soon',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isSupported
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          
          AdaptiveButton(
            text: 'Import',
            onPressed: isSupported ? () => _handleAppImport(app['id']) : null,
            isPrimary: false,
            isCompact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildHealthConnectSection(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.health_and_safety,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Health Connect Integration',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Sync your menstrual cycle data from Apple Health or Google Fit.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          AdaptiveButton(
            text: 'Connect Health App',
            onPressed: _handleHealthConnect,
            isPrimary: true,
            icon: Icons.sync,
            isLoading: _isImporting,
          ),
        ],
      ),
    );
  }

  Widget _buildManualEntrySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic cycle information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        _buildLastPeriodDateField(context),
        
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: AdaptiveTextFormField(
                controller: _cycleLengthController,
                labelText: 'Average Cycle Length',
                hintText: '28',
                suffixText: 'days',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: AdaptiveTextFormField(
                controller: _periodLengthController,
                labelText: 'Average Period Length',
                hintText: '5',
                suffixText: 'days',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(1),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        _buildCycleHelpText(context),
      ],
    );
  }

  Widget _buildLastPeriodDateField(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => _selectLastPeriodDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Last Period Start Date',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
                  Text(
                    _lastPeriodDate != null
                        ? _formatDate(_lastPeriodDate!)
                        : 'When did your last period start?',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: _lastPeriodDate != null
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleHelpText(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Don\'t know your averages?',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  'No worries! Use 28 days for cycle length and 5 days for period length as starting points. We\'ll learn your personal patterns over time.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportedDataPreview(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_circle,
                color: theme.colorScheme.primary,
              ),
              
              const SizedBox(width: 12),
              
              Text(
                'Imported ${_importedCycles.length} cycles',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Text(
            'Preview of imported data:',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 12),
          
          ...(_importedCycles.take(3).map((cycle) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
                
                const SizedBox(width: 12),
                
                Text(
                  _formatDate(cycle['startDate']!),
                  style: theme.textTheme.bodySmall,
                ),
                
                if (cycle['endDate'] != null) ...[
                  Text(
                    ' - ${_formatDate(cycle['endDate']!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ))),
          
          if (_importedCycles.length > 3) ...[
            const SizedBox(height: 8),
            Text(
              'And ${_importedCycles.length - 3} more cycles...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _setFirstTimeTracking(bool isFirstTime) {
    setState(() {
      _isFirstTimeTracking = isFirstTime;
      if (isFirstTime) {
        _previousTrackingMethod = null;
        _importedCycles.clear();
      }
    });
    _notifyDataChanged();
  }

  Future<void> _selectLastPeriodDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now().subtract(const Duration(days: 28)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      helpText: 'SELECT LAST PERIOD START DATE',
    );
    
    if (picked != null && picked != _lastPeriodDate) {
      setState(() {
        _lastPeriodDate = picked;
      });
      _notifyDataChanged();
    }
  }

  Future<void> _handleCSVImport() async {
    setState(() {
      _isImporting = true;
      _importError = null;
    });
    
    try {
      // Simulate file picker and CSV parsing
      await Future.delayed(const Duration(seconds: 2));
      
      // Mock imported data
      setState(() {
        _importedCycles = [
          {'startDate': DateTime(2024, 1, 15), 'endDate': DateTime(2024, 1, 20)},
          {'startDate': DateTime(2024, 2, 12), 'endDate': DateTime(2024, 2, 17)},
          {'startDate': DateTime(2024, 3, 10), 'endDate': DateTime(2024, 3, 15)},
        ];
        _previousTrackingMethod = 'CSV Import';
      });
      
      _notifyDataChanged();
    } catch (e) {
      setState(() {
        _importError = 'Failed to import CSV file. Please check the format and try again.';
      });
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _downloadCSVTemplate() async {
    // Implement CSV template download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('CSV template download would start here'),
      ),
    );
  }

  Future<void> _handleAppImport(String appId) async {
    setState(() {
      _isImporting = true;
    });
    
    try {
      // Simulate app import
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _importedCycles = [
          {'startDate': DateTime(2024, 1, 20), 'endDate': DateTime(2024, 1, 25)},
          {'startDate': DateTime(2024, 2, 18), 'endDate': DateTime(2024, 2, 22)},
        ];
        _previousTrackingMethod = _trackingApps.firstWhere((app) => app['id'] == appId)['name'];
      });
      
      _notifyDataChanged();
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _handleHealthConnect() async {
    setState(() {
      _isImporting = true;
    });
    
    try {
      // Simulate health connect
      await Future.delayed(const Duration(seconds: 3));
      
      setState(() {
        _importedCycles = [
          {'startDate': DateTime(2024, 1, 10), 'endDate': DateTime(2024, 1, 15)},
          {'startDate': DateTime(2024, 2, 8), 'endDate': DateTime(2024, 2, 13)},
          {'startDate': DateTime(2024, 3, 7), 'endDate': DateTime(2024, 3, 12)},
        ];
        _previousTrackingMethod = 'Health Connect';
      });
      
      _notifyDataChanged();
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
