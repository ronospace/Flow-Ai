import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/biometric_data.dart';

class BiometricChartWidget extends StatefulWidget {
  final String title;
  final List<BiometricReading> data;
  final BiometricType type;
  final Color color;
  final String? subtitle;
  final bool showAverage;
  final bool showTrend;
  final Duration? animationDuration;

  const BiometricChartWidget({
    super.key,
    required this.title,
    required this.data,
    required this.type,
    required this.color,
    this.subtitle,
    this.showAverage = true,
    this.showTrend = true,
    this.animationDuration,
  });

  @override
  State<BiometricChartWidget> createState() => _BiometricChartWidgetState();
}

class _BiometricChartWidgetState extends State<BiometricChartWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  int? _selectedIndex;
  BiometricReading? _selectedReading;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration ?? const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (widget.data.isEmpty) {
      return _buildEmptyChart();
    }
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildChart(),
          if (_selectedReading != null) ...[
            const SizedBox(height: 16),
            _buildSelectedDataInfo(),
          ],
          if (widget.showAverage || widget.showTrend) ...[
            const SizedBox(height: 16),
            _buildStatistics(),
          ],
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3, end: 0);
  }
  
  Widget _buildHeader() {
    final theme = Theme.of(context);
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getIconForType(widget.type),
            color: widget.color,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGrey,
                ),
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.subtitle!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ],
          ),
        ),
        // Data point count
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: widget.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${widget.data.length} points',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: widget.color,
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildChart() {
    final chartHeight = 200.0;
    final maxValue = widget.data.map((r) => r.value).reduce((a, b) => a > b ? a : b);
    final minValue = widget.data.map((r) => r.value).reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;
    
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return SizedBox(
          height: chartHeight,
          width: double.infinity,
          child: CustomPaint(
            painter: BiometricChartPainter(
              data: widget.data,
              color: widget.color,
              minValue: minValue,
              maxValue: maxValue,
              selectedIndex: _selectedIndex,
              animationProgress: _animation.value,
              showAverage: widget.showAverage,
              showTrend: widget.showTrend,
            ),
            child: GestureDetector(
              onTapDown: (details) => _handleTap(details, chartHeight, range, minValue),
              onTap: () => setState(() {}),
              child: Container(),
            ),
          ),
        );
      },
    );
  }
  
  void _handleTap(TapDownDetails details, double chartHeight, double range, double minValue) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final localPosition = renderBox.globalToLocal(details.globalPosition);
    
    // Calculate which data point was tapped
    final chartWidth = renderBox.size.width - 40; // Account for padding
    final pointSpacing = chartWidth / (widget.data.length - 1);
    final tappedIndex = ((localPosition.dx - 20) / pointSpacing).round();
    
    if (tappedIndex >= 0 && tappedIndex < widget.data.length) {
      setState(() {
        _selectedIndex = tappedIndex;
        _selectedReading = widget.data[tappedIndex];
      });
    }
  }
  
  Widget _buildSelectedDataInfo() {
    if (_selectedReading == null) return const SizedBox();
    final theme = Theme.of(context);
    
    final reading = _selectedReading!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: widget.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: widget.color,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${reading.value.toStringAsFixed(1)} ${reading.unit}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
                Text(
                  _formatDateTime(reading.timestamp),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGrey,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => setState(() {
              _selectedIndex = null;
              _selectedReading = null;
            }),
            child: Icon(
              Icons.close,
              color: AppTheme.mediumGrey,
              size: 16,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
  
  Widget _buildStatistics() {
    final theme = Theme.of(context);
    final average = widget.data.map((r) => r.value).reduce((a, b) => a + b) / widget.data.length;
    final trend = _calculateTrend();
    
    return Row(
      children: [
        if (widget.showAverage) ...[
          Expanded(
            child: _buildStatItem(
              'Average',
              '${average.toStringAsFixed(1)} ${widget.data.first.unit}',
              Icons.analytics,
              widget.color,
            ),
          ),
        ],
        if (widget.showAverage && widget.showTrend)
          const SizedBox(width: 16),
        if (widget.showTrend) ...[
          Expanded(
            child: _buildStatItem(
              'Trend',
              trend > 0 ? '+${(trend * 100).toStringAsFixed(1)}%' : '${(trend * 100).toStringAsFixed(1)}%',
              trend > 0 ? Icons.trending_up : trend < 0 ? Icons.trending_down : Icons.trending_flat,
              trend > 0 ? AppTheme.successGreen : trend < 0 ? AppTheme.warningOrange : AppTheme.mediumGrey,
            ),
          ),
        ],
      ],
    );
  }
  
  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGrey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyChart() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightGrey),
      ),
      child: Column(
        children: [
          Icon(
            _getIconForType(widget.type),
            size: 48,
            color: AppTheme.mediumGrey.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${widget.title} Data',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.mediumGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Data will appear here once available',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGrey,
            ),
          ),
        ],
      ),
    );
  }
  
  double _calculateTrend() {
    if (widget.data.length < 2) return 0.0;
    
    final midPoint = widget.data.length ~/ 2;
    final firstHalf = widget.data.take(midPoint);
    final secondHalf = widget.data.skip(midPoint);
    
    final firstAvg = firstHalf.map((r) => r.value).reduce((a, b) => a + b) / firstHalf.length;
    final secondAvg = secondHalf.map((r) => r.value).reduce((a, b) => a + b) / secondHalf.length;
    
    return (secondAvg - firstAvg) / firstAvg;
  }
  
  IconData _getIconForType(BiometricType type) {
    switch (type) {
      case BiometricType.heartRate:
        return Icons.favorite;
      case BiometricType.heartRateVariability:
        return Icons.monitor_heart;
      case BiometricType.sleepAnalysis:
        return Icons.bedtime;
      case BiometricType.bodyTemperature:
        return Icons.thermostat;
      case BiometricType.stressLevel:
        return Icons.psychology;
      case BiometricType.activeEnergyBurned:
        return Icons.local_fire_department;
      case BiometricType.steps:
        return Icons.directions_walk;
      case BiometricType.respiratoryRate:
        return Icons.air;
      case BiometricType.oxygenSaturation:
        return Icons.opacity;
      default:
        return Icons.health_and_safety;
    }
  }
  
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

class BiometricChartPainter extends CustomPainter {
  final List<BiometricReading> data;
  final Color color;
  final double minValue;
  final double maxValue;
  final int? selectedIndex;
  final double animationProgress;
  final bool showAverage;
  final bool showTrend;

  BiometricChartPainter({
    required this.data,
    required this.color,
    required this.minValue,
    required this.maxValue,
    this.selectedIndex,
    required this.animationProgress,
    this.showAverage = true,
    this.showTrend = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final pointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final selectedPointPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();
    final range = maxValue - minValue;
    
    if (range == 0) return;

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = (size.width * i / (data.length - 1));
      final normalizedValue = (data[i].value - minValue) / range;
      final y = size.height - (normalizedValue * size.height);
      points.add(Offset(x, y));
    }

    // Animate the line drawing
    final animatedPointCount = (points.length * animationProgress).round();
    final animatedPoints = points.take(animatedPointCount).toList();

    if (animatedPoints.isNotEmpty) {
      // Create the line path
      path.moveTo(animatedPoints.first.dx, animatedPoints.first.dy);
      fillPath.moveTo(animatedPoints.first.dx, size.height);
      fillPath.lineTo(animatedPoints.first.dx, animatedPoints.first.dy);

      for (int i = 1; i < animatedPoints.length; i++) {
        path.lineTo(animatedPoints[i].dx, animatedPoints[i].dy);
        fillPath.lineTo(animatedPoints[i].dx, animatedPoints[i].dy);
      }

      // Complete the fill path
      if (animatedPoints.isNotEmpty) {
        fillPath.lineTo(animatedPoints.last.dx, size.height);
        fillPath.close();
      }

      // Draw the fill area
      canvas.drawPath(fillPath, fillPaint);
      
      // Draw the line
      canvas.drawPath(path, paint);

      // Draw points
      for (int i = 0; i < animatedPoints.length; i++) {
        final point = animatedPoints[i];
        final isSelected = selectedIndex == i;
        final pointRadius = isSelected ? 6.0 : 4.0;
        
        if (isSelected) {
          // Draw selection ring
          canvas.drawCircle(
            point,
            pointRadius + 4,
            Paint()
              ..color = color.withValues(alpha: 0.3)
              ..style = PaintingStyle.fill,
          );
        }
        
        canvas.drawCircle(point, pointRadius, isSelected ? selectedPointPaint : pointPaint);
        
        // Draw white center for contrast
        canvas.drawCircle(
          point,
          pointRadius - 1.5,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
      }

      // Draw average line if enabled
      if (showAverage && animationProgress > 0.5) {
        final avgValue = data.map((r) => r.value).reduce((a, b) => a + b) / data.length;
        final normalizedAvg = (avgValue - minValue) / range;
        final avgY = size.height - (normalizedAvg * size.height);
        
        final avgPaint = Paint()
          ..color = color.withValues(alpha: 0.5)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeDashPattern = [5, 5];

        canvas.drawLine(
          Offset(0, avgY),
          Offset(size.width, avgY),
          avgPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant BiometricChartPainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
           oldDelegate.selectedIndex != selectedIndex ||
           oldDelegate.data != data;
  }
}

// Extension for drawing dashed lines
extension DashedPainting on Paint {
  set strokeDashPattern(List<double> dashPattern) {
    // This would require a custom implementation or third-party package
    // For now, we'll use a solid line
  }
}
