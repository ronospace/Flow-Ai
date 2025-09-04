import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../generated/app_localizations.dart';
import '../../../core/models/cycle_data.dart';
import '../providers/cycle_provider.dart';
import '../../../core/services/cycle_calculation_engine.dart' as calc_engine;
import '../widgets/calendar_legend.dart';
import '../widgets/day_detail_sheet.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _fadeController;
  late final AnimationController _scaleController;
  
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _selectedDay = DateTime.now();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CycleProvider>().loadCycles();
    });
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
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
              // Custom Header
              _buildHeader(),
              
              // Calendar Legend
              _buildCalendarLegend(),
              
              // Calendar Widget
              Expanded(
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: theme.shadowColor.withValues(alpha: 0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Consumer<CycleProvider>(
                      builder: (context, cycleProvider, child) {
                        return SingleChildScrollView(
                          child: _buildCalendar(cycleProvider),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              // Current Cycle Info
              _buildCurrentCycleInfo(),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                    Text(
                      AppLocalizations.of(context)!.calendarTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ).animate().fadeIn().slideX(begin: -0.3, end: 0),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
          ),
          
          // View Toggle Button
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _calendarFormat = _calendarFormat == CalendarFormat.month
                        ? CalendarFormat.twoWeeks
                        : CalendarFormat.month;
                  });
                  HapticFeedback.selectionClick();
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(padding: const EdgeInsets.all(12),
                  child: Icon(
                    _calendarFormat == CalendarFormat.month
                        ? Icons.calendar_view_week
                        : Icons.calendar_view_month,
                    color: AppTheme.primaryRose,
                    size: 20,
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 200.ms).scale(),
          
          const SizedBox(width: 12),
          
          // Today Button
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  setState(() {
                    _focusedDay = DateTime.now();
                    _selectedDay = DateTime.now();
                  });
                  HapticFeedback.lightImpact();
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    AppLocalizations.of(context)!.todayButton,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.3, end: 0),
        ],
      ),
    );
  }
  
  Widget _buildCalendarLegend() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: const CalendarLegend(),
    ).animate().fadeIn(delay: 400.ms).slideY(begin: -0.2, end: 0);
  }
  
  Widget _buildCalendar(CycleProvider cycleProvider) {
    final theme = Theme.of(context);
    return TableCalendar<CycleData>(
      firstDay: DateTime.utc(2020, 1, 1),
      lastDay: DateTime.utc(2030, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: _calendarFormat,
      selectedDayPredicate: (day) {
        return isSameDay(_selectedDay, day);
      },
      eventLoader: (day) {
        // Return cycle data for this day
        return cycleProvider.cycles
            .where((cycle) => _isDateInCycle(day, cycle))
            .toList();
      },
      startingDayOfWeek: StartingDayOfWeek.sunday,
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendTextStyle: TextStyle(color: AppTheme.darkGrey),
        holidayTextStyle: TextStyle(color: AppTheme.primaryRose),
        
        // Today styling
        todayDecoration: BoxDecoration(
          color: AppTheme.accentMint.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        
        // Selected day styling
        selectedDecoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
          ),
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        
        // Default cell styling
        defaultDecoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        weekendDecoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        
        // Marker styling
        markersMaxCount: 1,
        markerDecoration: const BoxDecoration(
          color: AppTheme.primaryRose,
          shape: BoxShape.circle,
        ),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        titleCentered: true,
        leftChevronVisible: true,
        rightChevronVisible: true,
        titleTextStyle: theme.textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
        leftChevronIcon: const Icon(
          Icons.chevron_left,
          color: AppTheme.primaryRose,
        ),
        rightChevronIcon: const Icon(
          Icons.chevron_right,
          color: AppTheme.primaryRose,
        ),
        headerPadding: const EdgeInsets.symmetric(vertical: 16),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
        weekdayStyle: TextStyle(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
      calendarBuilders: CalendarBuilders<CycleData>(
        defaultBuilder: (context, day, focusedDay) {
          return _buildCalendarDay(day, cycleProvider, false);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildCalendarDay(day, cycleProvider, true);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildCalendarDay(day, cycleProvider, false, isToday: true);
        },
      ),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });
        
        HapticFeedback.selectionClick();
        _showDayDetailSheet(selectedDay, cycleProvider);
      },
      onPageChanged: (focusedDay) {
        setState(() {
          _focusedDay = focusedDay;
        });
      },
    );
  }
  
  Widget _buildCalendarDay(DateTime day, CycleProvider cycleProvider, bool isSelected, {bool isToday = false}) {
    final dayInfo = _getDayInfo(day, cycleProvider);
    final theme = Theme.of(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        gradient: isSelected
            ? const LinearGradient(
                colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
              )
            : isToday
                ? LinearGradient(
                    colors: [AppTheme.accentMint.withValues(alpha: 0.8), AppTheme.accentMint],
                  )
                : dayInfo.color != null
                    ? LinearGradient(
                        colors: [dayInfo.color!.withValues(alpha: 0.3), dayInfo.color!.withValues(alpha: 0.6)],
                      )
                    : null,
        color: dayInfo.color == null && !isSelected && !isToday
            ? Colors.transparent
            : null,
        shape: BoxShape.circle,
        border: dayInfo.isPredicted
            ? Border.all(
                color: AppTheme.secondaryBlue,
                width: 2,
                style: BorderStyle.solid,
              )
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Day number
          Text(
            '${day.day}',
            style: TextStyle(
              color: isSelected || isToday
                  ? Colors.white
                  : dayInfo.color != null
                      ? Colors.white
                      : theme.colorScheme.onSurface,
              fontWeight: isSelected || isToday || dayInfo.color != null
                  ? FontWeight.bold
                  : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          
          // Period tracking emoji overlay
          if (dayInfo.phase != null && (dayInfo.flowIntensity != null && dayInfo.flowIntensity != FlowIntensity.none))
            Positioned(
              bottom: 0,
              child: Text(
                _getPhaseEmoji(dayInfo.phase!, dayInfo.flowIntensity),
                style: TextStyle(
                  fontSize: _getEmojiSize(dayInfo.flowIntensity!),
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      offset: const Offset(0.5, 0.5),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
            
          // Alternative flow intensity indicator for non-period days
          if ((dayInfo.flowIntensity == null || dayInfo.flowIntensity == FlowIntensity.none) && dayInfo.phase != null)
            Positioned(
              bottom: 1,
              child: Text(
                _getPhaseEmoji(dayInfo.phase!, null),
                style: const TextStyle(
                  fontSize: 8,
                ),
              ),
            ),
            
          // AI prediction indicator
          if (dayInfo.isPredicted)
            Positioned(
              top: 1,
              right: 1,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.secondaryBlue.withValues(alpha: 0.3),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🤖',
                    style: TextStyle(
                      fontSize: 4,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  DayInfo _getDayInfo(DateTime day, CycleProvider cycleProvider) {
    // Check if day is in current cycle
    final currentCycle = cycleProvider.cycleData?.currentCycle;
    if (currentCycle != null && _isDateInCycle(day, currentCycle)) {
      final dayInCycle = day.difference(currentCycle.startDate).inDays + 1;
      return DayInfo(
        cycleDay: dayInCycle,
        color: _getCyclePhaseColor(dayInCycle, currentCycle.length),
        flowIntensity: currentCycle.flowIntensity,
        phase: _getCyclePhase(dayInCycle, currentCycle.length),
      );
    }
    
    // Check if day is in predicted next period
    final predictions = cycleProvider.predictions;
    if (predictions != null && predictions.nextPeriodDate != null) {
      final nextPeriodStart = predictions.nextPeriodDate!;
      final periodLength = 5; // Typical period length
      final nextPeriodEnd = nextPeriodStart.add(Duration(days: periodLength - 1));
      
      if (day.isAfter(nextPeriodStart.subtract(const Duration(days: 1))) &&
          day.isBefore(nextPeriodEnd.add(const Duration(days: 1)))) {
        final dayInPeriod = day.difference(nextPeriodStart).inDays + 1;
        return DayInfo(
          cycleDay: dayInPeriod,
          color: AppTheme.primaryRose,
          phase: CyclePhase.menstrual,
          isPredicted: true,
        );
      }
      
      // Check if day is in fertile window
      if (predictions.fertileWindowStart != null && predictions.fertileWindowEnd != null) {
        final fertileStart = predictions.fertileWindowStart!;
        final fertileEnd = predictions.fertileWindowEnd!;
        
        if (day.isAfter(fertileStart.subtract(const Duration(days: 1))) &&
            day.isBefore(fertileEnd.add(const Duration(days: 1)))) {
          return DayInfo(
            color: AppTheme.accentMint,
            phase: CyclePhase.follicular,
            isPredicted: true,
            isFertileWindow: true,
          );
        }
      }
      
      // Check if day is ovulation day
      if (predictions.ovulationDate != null) {
        final ovulationDay = predictions.ovulationDate!;
        if (day.isAtSameMomentAs(ovulationDay) ||
            (day.isAfter(ovulationDay.subtract(const Duration(days: 1))) &&
             day.isBefore(ovulationDay.add(const Duration(days: 1))))) {
          return DayInfo(
            color: AppTheme.secondaryBlue,
            phase: CyclePhase.ovulatory,
            isPredicted: true,
            isOvulation: true,
          );
        }
      }
    }
    
    return DayInfo();
  }
  
  Color _getCyclePhaseColor(int dayInCycle, int cycleLength) {
    if (dayInCycle <= 7) {
      // Menstrual phase
      return AppTheme.primaryRose;
    } else if (dayInCycle <= cycleLength ~/ 2) {
      // Follicular phase
      return AppTheme.accentMint;
    } else if (dayInCycle <= (cycleLength ~/ 2) + 3) {
      // Ovulation phase
      return AppTheme.secondaryBlue;
    } else {
      // Luteal phase
      return AppTheme.primaryPurple;
    }
  }
  
  CyclePhase _getCyclePhase(int dayInCycle, int cycleLength) {
    if (dayInCycle <= 7) {
      return CyclePhase.menstrual;
    } else if (dayInCycle <= cycleLength ~/ 2) {
      return CyclePhase.follicular;
    } else if (dayInCycle <= (cycleLength ~/ 2) + 3) {
      return CyclePhase.ovulatory;
    } else {
      return CyclePhase.luteal;
    }
  }
  
  double _getFlowIndicatorSize(FlowIntensity intensity) {
    switch (intensity) {
      case FlowIntensity.none:
        return 0;
      case FlowIntensity.spotting:
        return 4;
      case FlowIntensity.light:
        return 8;
      case FlowIntensity.medium:
        return 12;
      case FlowIntensity.heavy:
        return 16;
      case FlowIntensity.veryHeavy:
        return 20;
    }
  }
  
  String _getPhaseEmoji(CyclePhase phase, FlowIntensity? flowIntensity) {
    switch (phase) {
      case CyclePhase.menstrual:
        if (flowIntensity != null) {
          switch (flowIntensity) {
            case FlowIntensity.spotting:
              return '💧';
            case FlowIntensity.light:
              return '🩸';
            case FlowIntensity.medium:
              return '🩸';
            case FlowIntensity.heavy:
              return '🔴';
            case FlowIntensity.veryHeavy:
              return '🔴';
            case FlowIntensity.none:
              return '✨';
          }
        }
        return '🩸';
      case CyclePhase.follicular:
        return '🌱';
      case CyclePhase.ovulatory:
        return '🥚';
      case CyclePhase.luteal:
        return '🌙';
      case CyclePhase.unknown:
        return '❓';
    }
  }
  
  double _getEmojiSize(FlowIntensity intensity) {
    switch (intensity) {
      case FlowIntensity.none:
        return 6;
      case FlowIntensity.spotting:
        return 8;
      case FlowIntensity.light:
        return 10;
      case FlowIntensity.medium:
        return 12;
      case FlowIntensity.heavy:
        return 14;
      case FlowIntensity.veryHeavy:
        return 16;
    }
  }
  
  bool _isDateInCycle(DateTime date, CycleData cycle) {
    final cycleEnd = cycle.endDate ?? DateTime.now();
    return date.isAfter(cycle.startDate.subtract(const Duration(days: 1))) &&
           date.isBefore(cycleEnd.add(const Duration(days: 1)));
  }
  
  Widget _buildCurrentCycleInfo() {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, child) {
        final theme = Theme.of(context);
        final currentCycle = cycleProvider.cycleData?.currentCycle;
        final predictions = cycleProvider.predictions;
        
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
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
          child: Row(
            children: [
              // Current Cycle Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Cycle',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (currentCycle != null) ...[
                      Text(
                        'Day ${DateTime.now().difference(currentCycle.startDate).inDays + 1}',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryRose,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getCurrentPhaseText(currentCycle),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ] else
                      Text(
                        'No active cycle',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Next Period Prediction
              if (predictions != null && predictions.nextPeriodDate != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Period',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'In ${predictions.daysUntilNextPeriod} days',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppTheme.secondaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d').format(predictions.nextPeriodDate!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, end: 0);
  }
  
  String _getCurrentPhaseText(CycleData cycle) {
    final dayInCycle = DateTime.now().difference(cycle.startDate).inDays + 1;
    final phase = _getCyclePhase(dayInCycle, cycle.length);
    
    switch (phase) {
      case CyclePhase.menstrual:
        return 'Menstrual Phase';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.ovulatory:
        return 'Ovulatory Phase';
      case CyclePhase.luteal:
        return 'Luteal Phase';
      case CyclePhase.unknown:
        return 'Unknown Phase';
    }
  }
  
  void _showDayDetailSheet(DateTime selectedDay, CycleProvider cycleProvider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DayDetailSheet(
        selectedDate: selectedDay,
        dayInfo: _getDayInfo(selectedDay, cycleProvider),
      ),
    );
  }
}

class DayInfo {
  final int? cycleDay;
  final Color? color;
  final FlowIntensity? flowIntensity;
  final CyclePhase? phase;
  final bool isPredicted;
  final bool isFertileWindow;
  final bool isOvulation;
  
  DayInfo({
    this.cycleDay,
    this.color,
    this.flowIntensity,
    this.phase,
    this.isPredicted = false,
    this.isFertileWindow = false,
    this.isOvulation = false,
  });
}

