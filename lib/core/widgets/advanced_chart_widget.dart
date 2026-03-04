import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

/// Advanced 3D-like Chart Widget with Animations
/// Uses gradient effects and shadows to create depth perception
class AdvancedChartWidget extends StatefulWidget {
  final List<ChartDataPoint> data;
  final String title;
  final ChartType type;
  final Color primaryColor;
  final bool showGrid;
  final bool animated;

  const AdvancedChartWidget({
    Key? key,
    required this.data,
    required this.title,
    this.type = ChartType.line,
    this.primaryColor = const Color(0xFFC147E9),
    this.showGrid = true,
    this.animated = true,
  }) : super(key: key);

  @override
  State<AdvancedChartWidget> createState() => _AdvancedChartWidgetState();
}

class _AdvancedChartWidgetState extends State<AdvancedChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );

    if (widget.animated) {
      _animationController.forward();
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            widget.primaryColor.withOpacity(0.1),
            widget.primaryColor.withOpacity(0.05),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: widget.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return SizedBox(height: 250, child: _buildChart());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    switch (widget.type) {
      case ChartType.line:
        return _buildLineChart();
      case ChartType.bar:
        return _buildBarChart();
      case ChartType.area:
        return _buildAreaChart();
      case ChartType.pie:
        return _buildPieChart();
    }
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: widget.showGrid,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1);
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(0),
                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: widget.data.length.toDouble() - 1,
        minY: 0,
        maxY: widget.data.map((e) => e.value).reduce(math.max) * 1.2,
        lineBarsData: [
          LineChartBarData(
            spots: widget.data.asMap().entries.map((entry) {
              final index = entry.key;
              final point = entry.value;
              return FlSpot(index.toDouble(), point.value * _animation.value);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                widget.primaryColor,
                widget.primaryColor.withOpacity(0.5),
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.primaryColor.withOpacity(0.3),
                  widget.primaryColor.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        gridData: FlGridData(show: widget.showGrid),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: widget.data.asMap().entries.map((entry) {
          final index = entry.key;
          final point = entry.value;
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: point.value * _animation.value,
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    widget.primaryColor,
                    widget.primaryColor.withOpacity(0.7),
                  ],
                ),
                width: 20,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAreaChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: widget.showGrid),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: widget.data.asMap().entries.map((entry) {
              return FlSpot(
                entry.key.toDouble(),
                entry.value.value * _animation.value,
              );
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                widget.primaryColor,
                widget.primaryColor.withOpacity(0.3),
              ],
            ),
            barWidth: 3,
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  widget.primaryColor.withOpacity(0.5),
                  widget.primaryColor.withOpacity(0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 60,
        sections: widget.data.map((point) {
          return PieChartSectionData(
            value: point.value * _animation.value,
            title: point.label,
            color: _getColorForIndex(widget.data.indexOf(point)),
            radius: 50,
          );
        }).toList(),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      widget.primaryColor,
      widget.primaryColor.withOpacity(0.8),
      widget.primaryColor.withOpacity(0.6),
      widget.primaryColor.withOpacity(0.4),
    ];
    return colors[index % colors.length];
  }
}

enum ChartType { line, bar, area, pie }

class ChartDataPoint {
  final double value;
  final String label;

  ChartDataPoint({required this.value, required this.label});
}
