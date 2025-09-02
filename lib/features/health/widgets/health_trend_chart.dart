import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

/// Interactive health trend chart with multiple time ranges and metrics
class HealthTrendChart extends StatefulWidget {
  final List<FlSpot> data;
  final String selectedMetric;
  final int timeRange;

  const HealthTrendChart({
    Key? key,
    required this.data,
    required this.selectedMetric,
    required this.timeRange,
  }) : super(key: key);

  @override
  State<HealthTrendChart> createState() => _HealthTrendChartState();
}

class _HealthTrendChartState extends State<HealthTrendChart>
    with TickerProviderStateMixin {
  late AnimationController _chartAnimationController;
  late Animation<double> _chartAnimation;

  int? _touchedSpotIndex;

  @override
  void initState() {
    super.initState();
    _chartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _chartAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _chartAnimationController,
      curve: Curves.easeInOutCubic,
    ));

    _chartAnimationController.forward();
  }

  @override
  void didUpdateWidget(HealthTrendChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedMetric != widget.selectedMetric ||
        oldWidget.timeRange != widget.timeRange) {
      _chartAnimationController.reset();
      _chartAnimationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildChartHeader(),
        const SizedBox(height: 16),
        Expanded(
          child: AnimatedBuilder(
            animation: _chartAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _chartAnimation.value,
                child: LineChart(
                  _buildChartData(),
                  duration: const Duration(milliseconds: 250),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildChartLegend(),
      ],
    );
  }

  Widget _buildChartHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _getMetricDisplayName(widget.selectedMetric),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getTimeRangeDescription(widget.timeRange),
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (widget.data.isNotEmpty)
          _buildCurrentValue(),
      ],
    );
  }

  Widget _buildCurrentValue() {
    final currentValue = widget.data.last.y;
    final previousValue = widget.data.length > 1 ? widget.data[widget.data.length - 2].y : currentValue;
    final change = ((currentValue - previousValue) / previousValue * 100);
    final isPositive = change > 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _getMetricColor(widget.selectedMetric).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getMetricColor(widget.selectedMetric).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '${currentValue.toStringAsFixed(1)} ${_getMetricUnit(widget.selectedMetric)}',
            style: TextStyle(
              color: _getMetricColor(widget.selectedMetric),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (change.abs() > 0.1)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: isPositive ? Colors.green : Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  '${change.abs().toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: isPositive ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildChartLegend() {
    return Row(
      children: [
        _buildLegendItem(
          color: _getMetricColor(widget.selectedMetric),
          label: _getMetricDisplayName(widget.selectedMetric),
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          color: Colors.white30,
          label: 'Target Range',
          isDotted: true,
        ),
      ],
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    bool isDotted = false,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: isDotted ? Colors.transparent : color,
            borderRadius: BorderRadius.circular(1.5),
            border: isDotted ? Border.all(color: color, width: 1) : null,
          ),
          child: isDotted
              ? CustomPaint(
                  painter: DottedLinePainter(color: color),
                )
              : null,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  LineChartData _buildChartData() {
    return LineChartData(
      minX: 0,
      maxX: widget.data.length.toDouble() - 1,
      minY: _getMinY(),
      maxY: _getMaxY(),
      lineTouchData: LineTouchData(
        enabled: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? touchResponse) {
          setState(() {
            if (touchResponse != null &&
                touchResponse.lineBarSpots != null &&
                touchResponse.lineBarSpots!.isNotEmpty) {
              _touchedSpotIndex = touchResponse.lineBarSpots![0].spotIndex;
            } else {
              _touchedSpotIndex = null;
            }
          });
        },
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: const Color(0xFF2A2D5A),
          tooltipRoundedRadius: 12,
          tooltipPadding: const EdgeInsets.all(12),
          tooltipMargin: 8,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              return LineTooltipItem(
                '${barSpot.y.toStringAsFixed(1)} ${_getMetricUnit(widget.selectedMetric)}\n${_getTimeLabel(barSpot.x.toInt())}',
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              );
            }).toList();
          },
        ),
        getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndexes) {
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(
                color: _getMetricColor(widget.selectedMetric),
                strokeWidth: 2,
                dashArray: [5, 5],
              ),
              FlDotData(
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 6,
                  color: _getMetricColor(widget.selectedMetric),
                  strokeWidth: 2,
                  strokeColor: Colors.white,
                ),
              ),
            );
          }).toList();
        },
      ),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (_getMaxY() - _getMinY()) / 5,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: (_getMaxY() - _getMinY()) / 4,
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                value.toStringAsFixed(0),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              );
            },
            reservedSize: 40,
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: math.max(1, (widget.data.length / 5).ceil().toDouble()),
            getTitlesWidget: (double value, TitleMeta meta) {
              return Text(
                _getTimeLabel(value.toInt()),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: widget.data.map((spot) {
            return FlSpot(
              spot.x,
              spot.y * _chartAnimation.value + _getMinY() * (1 - _chartAnimation.value),
            );
          }).toList(),
          isCurved: true,
          curveSmoothness: 0.35,
          color: _getMetricColor(widget.selectedMetric),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final isSelected = _touchedSpotIndex == index;
              return FlDotCirclePainter(
                radius: isSelected ? 6 : 3,
                color: _getMetricColor(widget.selectedMetric),
                strokeWidth: isSelected ? 2 : 0,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getMetricColor(widget.selectedMetric).withOpacity(0.3),
                _getMetricColor(widget.selectedMetric).withOpacity(0.05),
              ],
            ),
          ),
        ),
        // Target range line
        if (_hasTargetRange(widget.selectedMetric))
          LineChartBarData(
            spots: _getTargetRangeSpots(),
            isCurved: false,
            color: Colors.white30,
            barWidth: 1,
            dotData: const FlDotData(show: false),
            dashArray: [5, 5],
          ),
      ],
    );
  }

  double _getMinY() {
    if (widget.data.isEmpty) return 0;
    final values = widget.data.map((e) => e.y).toList();
    final minValue = values.reduce(math.min);
    return (minValue * 0.9).floorToDouble();
  }

  double _getMaxY() {
    if (widget.data.isEmpty) return 100;
    final values = widget.data.map((e) => e.y).toList();
    final maxValue = values.reduce(math.max);
    return (maxValue * 1.1).ceilToDouble();
  }

  String _getTimeLabel(int index) {
    switch (widget.timeRange) {
      case 1: // 1 hour
        return '${index * 5}m';
      case 24: // 24 hours
        return '${index}h';
      case 168: // 1 week
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][index % 7];
      default:
        return index.toString();
    }
  }

  String _getMetricDisplayName(String metric) {
    switch (metric) {
      case 'heart_rate': return 'Heart Rate';
      case 'temperature': return 'Body Temperature';
      case 'hrv': return 'Heart Rate Variability';
      case 'sleep': return 'Sleep Score';
      default: return metric;
    }
  }

  String _getMetricUnit(String metric) {
    switch (metric) {
      case 'heart_rate': return 'BPM';
      case 'temperature': return '°C';
      case 'hrv': return 'ms';
      case 'sleep': return '%';
      default: return '';
    }
  }

  Color _getMetricColor(String metric) {
    switch (metric) {
      case 'heart_rate': return Colors.red;
      case 'temperature': return Colors.orange;
      case 'hrv': return Colors.blue;
      case 'sleep': return Colors.purple;
      default: return Colors.pink;
    }
  }

  String _getTimeRangeDescription(int hours) {
    switch (hours) {
      case 1: return 'Last hour';
      case 24: return 'Last 24 hours';
      case 168: return 'Last 7 days';
      default: return 'Custom range';
    }
  }

  bool _hasTargetRange(String metric) {
    return ['heart_rate', 'temperature', 'sleep'].contains(metric);
  }

  List<FlSpot> _getTargetRangeSpots() {
    double targetValue;
    switch (widget.selectedMetric) {
      case 'heart_rate':
        targetValue = 70.0;
        break;
      case 'temperature':
        targetValue = 36.5;
        break;
      case 'sleep':
        targetValue = 85.0;
        break;
      default:
        targetValue = 50.0;
    }

    return [
      FlSpot(0, targetValue),
      FlSpot(widget.data.length.toDouble() - 1, targetValue),
    ];
  }

  @override
  void dispose() {
    _chartAnimationController.dispose();
    super.dispose();
  }
}

class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    const dashWidth = 3.0;
    const dashSpace = 2.0;
    double currentX = 0;

    while (currentX < size.width) {
      canvas.drawLine(
        Offset(currentX, size.height / 2),
        Offset(math.min(currentX + dashWidth, size.width), size.height / 2),
        paint,
      );
      currentX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
