import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/cycle_data.dart';
import '../providers/cycle_provider.dart';
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
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
                  'Calendar',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ).animate().fadeIn().slideX(begin: -0.3, end: 0),
                Text(
                  DateFormat('MMMM yyyy').format(_focusedDay),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ).animate().fadeIn(delay: 100.ms),
              ],
            ),
          ),
          
          // View Toggle Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
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
                child: Padding(
                  padding: const EdgeInsets.all(12),
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
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Text(
                    'Today',
                    style: TextStyle(
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
          color: AppTheme.accentMint.withOpacity(0.8),
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
        titleTextStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
          color: AppTheme.darkGrey,
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
          color: AppTheme.mediumGrey,
          fontWeight: FontWeight.w500,
        ),
        weekdayStyle: TextStyle(
          color: AppTheme.mediumGrey,
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
                    colors: [AppTheme.accentMint.withOpacity(0.8), AppTheme.accentMint],
                  )
                : dayInfo.color != null
                    ? LinearGradient(
                        colors: [dayInfo.color!.withOpacity(0.3), dayInfo.color!.withOpacity(0.6)],
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
                      : AppTheme.darkGrey,
              fontWeight: isSelected || isToday || dayInfo.color != null
                  ? FontWeight.bold
                  : FontWeight.w500,
              fontSize: 16,
            ),
          ),
          
          // Flow intensity indicator
          if (dayInfo.flowIntensity != null && dayInfo.flowIntensity != FlowIntensity.none)
            Positioned(
              bottom: 2,
              child: Container(
                width: _getFlowIndicatorSize(dayInfo.flowIntensity!),
                height: 3,
                decoration: BoxDecoration(
                  color: isSelected || isToday ? Colors.white : Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
          // AI prediction indicator
          if (dayInfo.isPredicted)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBlue,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white,
                    width: 1,
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
    for (final cycle in cycleProvider.cycles) {
      if (_isDateInCycle(day, cycle)) {
        final dayInCycle = day.difference(cycle.startDate).inDays + 1;
        return DayInfo(
          cycleDay: dayInCycle,
          color: _getCyclePhaseColor(dayInCycle, cycle.length),
          flowIntensity: cycle.flowIntensity,
          phase: _getCyclePhase(dayInCycle, cycle.length),
        );
      }
    }
    
    // Check if day is predicted
    final prediction = cycleProvider.nextCyclePrediction;
    if (prediction != null) {
      if (day.isAfter(prediction.predictedStartDate.subtract(const Duration(days: 1))) &&
          day.isBefore(prediction.predictedEndDate.add(const Duration(days: 1)))) {
        final dayInCycle = day.difference(prediction.predictedStartDate).inDays + 1;
        return DayInfo(
          cycleDay: dayInCycle,
          color: _getCyclePhaseColor(dayInCycle, prediction.predictedLength),
          phase: _getCyclePhase(dayInCycle, prediction.predictedLength),
          isPredicted: true,
        );
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
      return CyclePhase.ovulation;
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
  
  bool _isDateInCycle(DateTime date, CycleData cycle) {
    final cycleEnd = cycle.endDate ?? DateTime.now();
    return date.isAfter(cycle.startDate.subtract(const Duration(days: 1))) &&
           date.isBefore(cycleEnd.add(const Duration(days: 1)));
  }
  
  Widget _buildCurrentCycleInfo() {
    return Consumer<CycleProvider>(
      builder: (context, cycleProvider, child) {
        final currentCycle = cycleProvider.currentCycle;
        final prediction = cycleProvider.nextCyclePrediction;
        
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
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
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (currentCycle != null) ...[
                      Text(
                        'Day ${DateTime.now().difference(currentCycle.startDate).inDays + 1}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryRose,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getCurrentPhaseText(currentCycle),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                    ] else
                      Text(
                        'No active cycle',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Next Period Prediction
              if (prediction != null)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next Period',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'In ${prediction.daysUntilStart} days',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.secondaryBlue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat('MMM d').format(prediction.predictedStartDate),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mediumGrey,
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
      case CyclePhase.ovulation:
        return 'Ovulation Phase';
      case CyclePhase.luteal:
        return 'Luteal Phase';
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
  
  DayInfo({
    this.cycleDay,
    this.color,
    this.flowIntensity,
    this.phase,
    this.isPredicted = false,
  });
}

enum CyclePhase {
  menstrual,
  follicular,
  ovulation,
  luteal,
}
