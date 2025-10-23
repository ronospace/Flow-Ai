import 'package:flutter/material.dart';

// === ENUMS ===

enum ChartType {
  lineChart,
  barChart,
  areaChart,
  pieChart,
  scatterPlot,
  heatmap,
  candlestickChart,
  radialChart,
}

enum AxisType {
  numeric,
  categorical,
  datetime,
  logarithmic,
}

enum LegendPosition {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

enum AnnotationType {
  verticalLine,
  horizontalLine,
  rectangle,
  circle,
  text,
  arrow,
}

enum PointShape {
  circle,
  square,
  diamond,
  triangle,
  cross,
  plus,
}

enum ImageFormat {
  png,
  jpg,
  svg,
  pdf,
}

// === CORE DATA MODELS ===

class DataPoint {
  final double x;
  final double y;
  final double? z; // For 3D charts or heatmaps
  final String label;
  final Map<String, dynamic> metadata;

  DataPoint({
    required this.x,
    required this.y,
    this.z,
    this.label = '',
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
      'label': label,
      'metadata': metadata,
    };
  }

  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      x: json['x'].toDouble(),
      y: json['y'].toDouble(),
      z: json['z']?.toDouble(),
      label: json['label'] ?? '',
      metadata: json['metadata'] ?? {},
    );
  }
}

class ChartSeries {
  final String name;
  final List<DataPoint> data;
  final Color color;
  final ChartSeriesStyle style;

  ChartSeries({
    required this.name,
    required this.data,
    required this.color,
    ChartSeriesStyle? style,
  }) : style = style ?? ChartSeriesStyle();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'data': data.map((d) => d.toJson()).toList(),
      'color': color.value,
      'style': style.toJson(),
    };
  }

  factory ChartSeries.fromJson(Map<String, dynamic> json) {
    return ChartSeries(
      name: json['name'],
      data: (json['data'] as List).map((d) => DataPoint.fromJson(d)).toList(),
      color: Color(json['color']),
      style: ChartSeriesStyle.fromJson(json['style']),
    );
  }
}

class ChartSeriesStyle {
  final double strokeWidth;
  final List<double> strokeDashPattern;
  final bool showPoints;
  final double pointRadius;
  final PointShape pointShape;
  final Color? pointColor;
  final double fillOpacity;
  final List<Color> heatmapColorScheme;

  ChartSeriesStyle({
    this.strokeWidth = 2.0,
    this.strokeDashPattern = const [],
    this.showPoints = false,
    this.pointRadius = 3.0,
    this.pointShape = PointShape.circle,
    this.pointColor,
    this.fillOpacity = 0.0,
    this.heatmapColorScheme = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'stroke_width': strokeWidth,
      'stroke_dash_pattern': strokeDashPattern,
      'show_points': showPoints,
      'point_radius': pointRadius,
      'point_shape': pointShape.name,
      'point_color': pointColor?.value,
      'fill_opacity': fillOpacity,
      'heatmap_color_scheme': heatmapColorScheme.map((c) => c.value).toList(),
    };
  }

  factory ChartSeriesStyle.fromJson(Map<String, dynamic> json) {
    return ChartSeriesStyle(
      strokeWidth: json['stroke_width'] ?? 2.0,
      strokeDashPattern: List<double>.from(json['stroke_dash_pattern'] ?? []),
      showPoints: json['show_points'] ?? false,
      pointRadius: json['point_radius'] ?? 3.0,
      pointShape: PointShape.values.firstWhere(
        (e) => e.name == json['point_shape'],
        orElse: () => PointShape.circle,
      ),
      pointColor: json['point_color'] != null ? Color(json['point_color']) : null,
      fillOpacity: json['fill_opacity'] ?? 0.0,
      heatmapColorScheme: (json['heatmap_color_scheme'] as List?)
          ?.map((c) => Color(c))
          .toList() ?? [],
    );
  }
}

// === AXIS CONFIGURATION ===

class AxisConfiguration {
  final String title;
  final AxisType type;
  final double? minimum;
  final double? maximum;
  final List<String> categories;
  final bool showGridLines;
  final bool showLabels;
  final bool showTitle;
  final TextStyle? titleStyle;
  final TextStyle? labelStyle;

  AxisConfiguration({
    this.title = '',
    this.type = AxisType.numeric,
    this.minimum,
    this.maximum,
    this.categories = const [],
    this.showGridLines = true,
    this.showLabels = true,
    this.showTitle = true,
    this.titleStyle,
    this.labelStyle,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type.name,
      'minimum': minimum,
      'maximum': maximum,
      'categories': categories,
      'show_grid_lines': showGridLines,
      'show_labels': showLabels,
      'show_title': showTitle,
    };
  }

  factory AxisConfiguration.fromJson(Map<String, dynamic> json) {
    return AxisConfiguration(
      title: json['title'] ?? '',
      type: AxisType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AxisType.numeric,
      ),
      minimum: json['minimum']?.toDouble(),
      maximum: json['maximum']?.toDouble(),
      categories: List<String>.from(json['categories'] ?? []),
      showGridLines: json['show_grid_lines'] ?? true,
      showLabels: json['show_labels'] ?? true,
      showTitle: json['show_title'] ?? true,
    );
  }
}

// === CHART CONFIGURATION ===

class ChartData {
  final ChartType type;
  final String title;
  final String subtitle;
  final List<ChartSeries> series;
  final AxisConfiguration xAxisConfig;
  final AxisConfiguration yAxisConfig;
  final ChartLegend legend;
  final ChartInteractivity interactivity;
  final List<ChartAnnotation> annotations;
  final ChartTheme? theme;
  final bool hasError;
  final String? errorMessage;

  ChartData({
    required this.type,
    required this.title,
    this.subtitle = '',
    required this.series,
    required this.xAxisConfig,
    required this.yAxisConfig,
    required this.legend,
    ChartInteractivity? interactivity,
    this.annotations = const [],
    this.theme,
    this.hasError = false,
    this.errorMessage,
  }) : interactivity = interactivity ?? ChartInteractivity();

  factory ChartData.empty(ChartType type, String message) {
    return ChartData(
      type: type,
      title: 'No Data',
      subtitle: message,
      series: [],
      xAxisConfig: AxisConfiguration(),
      yAxisConfig: AxisConfiguration(),
      legend: ChartLegend(show: false),
    );
  }

  factory ChartData.error(String errorMessage) {
    return ChartData(
      type: ChartType.lineChart,
      title: 'Error',
      subtitle: '',
      series: [],
      xAxisConfig: AxisConfiguration(),
      yAxisConfig: AxisConfiguration(),
      legend: ChartLegend(show: false),
      hasError: true,
      errorMessage: errorMessage,
    );
  }

  bool get isEmpty => series.isEmpty || series.every((s) => s.data.isEmpty);

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'subtitle': subtitle,
      'series': series.map((s) => s.toJson()).toList(),
      'x_axis_config': xAxisConfig.toJson(),
      'y_axis_config': yAxisConfig.toJson(),
      'legend': legend.toJson(),
      'interactivity': interactivity.toJson(),
      'annotations': annotations.map((a) => a.toJson()).toList(),
      'has_error': hasError,
      'error_message': errorMessage,
    };
  }

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      type: ChartType.values.firstWhere((e) => e.name == json['type']),
      title: json['title'],
      subtitle: json['subtitle'] ?? '',
      series: (json['series'] as List).map((s) => ChartSeries.fromJson(s)).toList(),
      xAxisConfig: AxisConfiguration.fromJson(json['x_axis_config']),
      yAxisConfig: AxisConfiguration.fromJson(json['y_axis_config']),
      legend: ChartLegend.fromJson(json['legend']),
      interactivity: ChartInteractivity.fromJson(json['interactivity']),
      annotations: (json['annotations'] as List?)
          ?.map((a) => ChartAnnotation.fromJson(a))
          .toList() ?? [],
      hasError: json['has_error'] ?? false,
      errorMessage: json['error_message'],
    );
  }
}

class ChartLegend {
  final bool show;
  final LegendPosition position;
  final bool showColorScale;
  final TextStyle? textStyle;

  ChartLegend({
    this.show = true,
    this.position = LegendPosition.bottom,
    this.showColorScale = false,
    this.textStyle,
  });

  Map<String, dynamic> toJson() {
    return {
      'show': show,
      'position': position.name,
      'show_color_scale': showColorScale,
    };
  }

  factory ChartLegend.fromJson(Map<String, dynamic> json) {
    return ChartLegend(
      show: json['show'] ?? true,
      position: LegendPosition.values.firstWhere(
        (e) => e.name == json['position'],
        orElse: () => LegendPosition.bottom,
      ),
      showColorScale: json['show_color_scale'] ?? false,
    );
  }
}

class ChartInteractivity {
  final bool enableZoom;
  final bool enablePan;
  final bool showTooltips;
  final bool enableSelection;
  final bool enableCrosshairs;
  final bool enableDataLabels;

  ChartInteractivity({
    this.enableZoom = false,
    this.enablePan = false,
    this.showTooltips = true,
    this.enableSelection = false,
    this.enableCrosshairs = false,
    this.enableDataLabels = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'enable_zoom': enableZoom,
      'enable_pan': enablePan,
      'show_tooltips': showTooltips,
      'enable_selection': enableSelection,
      'enable_crosshairs': enableCrosshairs,
      'enable_data_labels': enableDataLabels,
    };
  }

  factory ChartInteractivity.fromJson(Map<String, dynamic> json) {
    return ChartInteractivity(
      enableZoom: json['enable_zoom'] ?? false,
      enablePan: json['enable_pan'] ?? false,
      showTooltips: json['show_tooltips'] ?? true,
      enableSelection: json['enable_selection'] ?? false,
      enableCrosshairs: json['enable_crosshairs'] ?? false,
      enableDataLabels: json['enable_data_labels'] ?? false,
    );
  }
}

// === ANNOTATIONS ===

class ChartAnnotation {
  final AnnotationType type;
  final double value;
  final double? value2; // For rectangle annotations
  final String label;
  final AnnotationStyle style;

  ChartAnnotation({
    required this.type,
    required this.value,
    this.value2,
    this.label = '',
    AnnotationStyle? style,
  }) : style = style ?? AnnotationStyle();

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'value': value,
      'value2': value2,
      'label': label,
      'style': style.toJson(),
    };
  }

  factory ChartAnnotation.fromJson(Map<String, dynamic> json) {
    return ChartAnnotation(
      type: AnnotationType.values.firstWhere((e) => e.name == json['type']),
      value: json['value'].toDouble(),
      value2: json['value2']?.toDouble(),
      label: json['label'] ?? '',
      style: AnnotationStyle.fromJson(json['style']),
    );
  }
}

class AnnotationStyle {
  final Color color;
  final double strokeWidth;
  final List<double> strokeDashPattern;
  final double opacity;
  final TextStyle? textStyle;

  AnnotationStyle({
    this.color = Colors.grey,
    this.strokeWidth = 1.0,
    this.strokeDashPattern = const [],
    this.opacity = 1.0,
    this.textStyle,
  });

  Map<String, dynamic> toJson() {
    return {
      'color': color.value,
      'stroke_width': strokeWidth,
      'stroke_dash_pattern': strokeDashPattern,
      'opacity': opacity,
    };
  }

  factory AnnotationStyle.fromJson(Map<String, dynamic> json) {
    return AnnotationStyle(
      color: Color(json['color'] ?? Colors.grey.value),
      strokeWidth: json['stroke_width'] ?? 1.0,
      strokeDashPattern: List<double>.from(json['stroke_dash_pattern'] ?? []),
      opacity: json['opacity'] ?? 1.0,
    );
  }
}

// === CHART THEME ===

class ChartTheme {
  final Color backgroundColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color textColor;
  final Color gridLineColor;
  final List<Color> colorPalette;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final TextStyle axisLabelStyle;
  final TextStyle axisTitleStyle;
  final TextStyle legendStyle;

  ChartTheme({
    required this.backgroundColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.textColor,
    required this.gridLineColor,
    required this.colorPalette,
    required this.titleStyle,
    required this.subtitleStyle,
    required this.axisLabelStyle,
    required this.axisTitleStyle,
    required this.legendStyle,
  });

  factory ChartTheme.fromAppTheme(ThemeData appTheme) {
    return ChartTheme(
      backgroundColor: appTheme.scaffoldBackgroundColor,
      primaryColor: appTheme.primaryColor,
      secondaryColor: appTheme.colorScheme.secondary,
      textColor: appTheme.textTheme.bodyLarge?.color ?? Colors.black,
      gridLineColor: appTheme.dividerColor,
      colorPalette: [
        appTheme.primaryColor,
        appTheme.colorScheme.secondary,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.teal,
        Colors.red,
        Colors.indigo,
      ],
      titleStyle: appTheme.textTheme.headlineSmall ?? const TextStyle(),
      subtitleStyle: appTheme.textTheme.titleMedium ?? const TextStyle(),
      axisLabelStyle: appTheme.textTheme.bodySmall ?? const TextStyle(),
      axisTitleStyle: appTheme.textTheme.labelLarge ?? const TextStyle(),
      legendStyle: appTheme.textTheme.bodyMedium ?? const TextStyle(),
    );
  }

  factory ChartTheme.light() {
    return ChartTheme(
      backgroundColor: Colors.white,
      primaryColor: Colors.blue,
      secondaryColor: Colors.blueAccent,
      textColor: Colors.black87,
      gridLineColor: Colors.grey.shade300,
      colorPalette: [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.red,
        Colors.teal,
        Colors.indigo,
        Colors.pink,
      ],
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      subtitleStyle: const TextStyle(fontSize: 14),
      axisLabelStyle: const TextStyle(fontSize: 12),
      axisTitleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      legendStyle: const TextStyle(fontSize: 12),
    );
  }

  factory ChartTheme.dark() {
    return ChartTheme(
      backgroundColor: Colors.grey.shade900,
      primaryColor: Colors.blueAccent,
      secondaryColor: Colors.lightBlueAccent,
      textColor: Colors.white70,
      gridLineColor: Colors.grey.shade700,
      colorPalette: [
        Colors.blueAccent,
        Colors.greenAccent,
        Colors.orangeAccent,
        Colors.purpleAccent,
        Colors.redAccent,
        Colors.tealAccent,
        Colors.indigoAccent,
        Colors.pinkAccent,
      ],
      titleStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      subtitleStyle: const TextStyle(fontSize: 14, color: Colors.white70),
      axisLabelStyle: const TextStyle(fontSize: 12, color: Colors.white60),
      axisTitleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white70),
      legendStyle: const TextStyle(fontSize: 12, color: Colors.white70),
    );
  }
}

// === CHART CONFIGURATION ===

class ChartConfiguration {
  final ChartType type;
  ChartTheme theme;
  final ChartAnimations animations;
  final Map<String, dynamic> customSettings;

  ChartConfiguration({
    required this.type,
    required this.theme,
    ChartAnimations? animations,
    this.customSettings = const {},
  }) : animations = animations ?? ChartAnimations();

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'animations': animations.toJson(),
      'custom_settings': customSettings,
    };
  }
}

class ChartAnimations {
  final bool enabled;
  final Duration duration;
  final Curve curve;
  final bool staggered;

  ChartAnimations({
    this.enabled = true,
    this.duration = const Duration(milliseconds: 600),
    this.curve = Curves.easeInOut,
    this.staggered = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'duration_ms': duration.inMilliseconds,
      'staggered': staggered,
    };
  }

  factory ChartAnimations.fromJson(Map<String, dynamic> json) {
    return ChartAnimations(
      enabled: json['enabled'] ?? true,
      duration: Duration(milliseconds: json['duration_ms'] ?? 600),
      staggered: json['staggered'] ?? false,
    );
  }
}

// === VISUALIZATION CONFIGURATION ===

class VisualizationConfig {
  final String title;
  final String? subtitle;
  final ChartType chartType;
  final Color? primaryColor;
  final ChartSeriesStyle? seriesStyle;
  final AxisConfiguration? xAxisConfig;
  final AxisConfiguration? yAxisConfig;
  final ChartLegend? legend;
  final ChartInteractivity? interactivity;
  final List<ChartAnnotation>? annotations;

  VisualizationConfig({
    required this.title,
    this.subtitle,
    required this.chartType,
    this.primaryColor,
    this.seriesStyle,
    this.xAxisConfig,
    this.yAxisConfig,
    this.legend,
    this.interactivity,
    this.annotations,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'chart_type': chartType.name,
      'primary_color': primaryColor?.value,
      'series_style': seriesStyle?.toJson(),
      'x_axis_config': xAxisConfig?.toJson(),
      'y_axis_config': yAxisConfig?.toJson(),
      'legend': legend?.toJson(),
      'interactivity': interactivity?.toJson(),
      'annotations': annotations?.map((a) => a.toJson()).toList(),
    };
  }
}

// === DATE RANGE ===

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange({
    required this.start,
    required this.end,
  });

  Duration get duration => end.difference(start);

  bool contains(DateTime date) {
    return date.isAfter(start) && date.isBefore(end) ||
           date.isAtSameMomentAs(start) ||
           date.isAtSameMomentAs(end);
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
  }

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      start: DateTime.parse(json['start']),
      end: DateTime.parse(json['end']),
    );
  }

  @override
  String toString() => '${start.toString().split(' ')[0]} - ${end.toString().split(' ')[0]}';
}

// === EXPORT MODELS ===

class ChartExportOptions {
  final int width;
  final int height;
  final ImageFormat format;
  final double scaleFactor;
  final bool includeBackground;
  final Map<String, dynamic> customOptions;

  ChartExportOptions({
    this.width = 800,
    this.height = 600,
    this.format = ImageFormat.png,
    this.scaleFactor = 1.0,
    this.includeBackground = true,
    this.customOptions = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'width': width,
      'height': height,
      'format': format.name,
      'scale_factor': scaleFactor,
      'include_background': includeBackground,
      'custom_options': customOptions,
    };
  }
}
