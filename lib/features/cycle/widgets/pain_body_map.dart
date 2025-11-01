import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class PainBodyMap extends StatefulWidget {
  final Map<String, double> painAreas;
  final Function(String, double) onPainAreaChanged;

  const PainBodyMap({
    super.key,
    required this.painAreas,
    required this.onPainAreaChanged,
  });

  @override
  State<PainBodyMap> createState() => _PainBodyMapState();
}

class _PainBodyMapState extends State<PainBodyMap> {
  String? _selectedArea;
  
  final Map<String, PainArea> _bodyAreas = {
    'head': PainArea(
      name: 'Head',
      emoji: '🤕',
      position: const Offset(0.5, 0.12),
    ),
    'neck': PainArea(
      name: 'Neck',
      emoji: '🔗',
      position: const Offset(0.5, 0.22),
    ),
    'shoulders': PainArea(
      name: 'Shoulders',
      emoji: '💪',
      position: const Offset(0.35, 0.28),
    ),
    'chest': PainArea(
      name: 'Chest',
      emoji: '💓',
      position: const Offset(0.5, 0.35),
    ),
    'upper_back': PainArea(
      name: 'Upper Back',
      emoji: '🔺',
      position: const Offset(0.75, 0.35),
    ),
    'lower_back': PainArea(
      name: 'Lower Back',
      emoji: '🔻',
      position: const Offset(0.75, 0.52),
    ),
    'abdomen': PainArea(
      name: 'Abdomen',
      emoji: '🔥',
      position: const Offset(0.5, 0.48),
    ),
    'pelvis': PainArea(
      name: 'Pelvis',
      emoji: '⚡',
      position: const Offset(0.5, 0.58),
    ),
    'hips': PainArea(
      name: 'Hips',
      emoji: '🦴',
      position: const Offset(0.35, 0.62),
    ),
    'thighs': PainArea(
      name: 'Thighs',
      emoji: '🦵',
      position: const Offset(0.5, 0.72),
    ),
    'knees': PainArea(
      name: 'Knees',
      emoji: '🦽',
      position: const Offset(0.5, 0.82),
    ),
    'calves': PainArea(
      name: 'Calves',
      emoji: '🍗',
      position: const Offset(0.5, 0.90),
    ),
    'feet': PainArea(
      name: 'Feet',
      emoji: '👣',
      position: const Offset(0.5, 0.96),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        // Body map
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.shadowColor.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                children: [
                  // Background body silhouette
                  Positioned.fill(
                    child: CustomPaint(
                      painter: BodySilhouettePainter(),
                    ),
                  ),
                  
                  // Pain area indicators  
                  Builder(
                    builder: (context) {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          return Stack(
                            children: _bodyAreas.entries.map((entry) {
                              final areaId = entry.key;
                              final area = entry.value;
                              final intensity = widget.painAreas[areaId] ?? 0.0;
                              final isActive = intensity > 0;
                              final isSelected = _selectedArea == areaId;
                              
                              return Positioned(
                                left: area.position.dx * constraints.maxWidth - 30,
                                top: area.position.dy * constraints.maxHeight - 30,
                                child: _buildPainIndicator(
                                  areaId,
                                  area,
                                  intensity,
                                  isActive,
                                  isSelected,
                                ),
                              );
                            }).toList(),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Selected area details
        if (_selectedArea != null)
          _buildSelectedAreaDetails(),
        
        const SizedBox(height: 20),
        
        // Quick access pain levels
        _buildQuickPainLevels(),
      ],
    );
  }

  Widget _buildPainIndicator(
    String areaId,
    PainArea area,
    double intensity,
    bool isActive,
    bool isSelected,
  ) {
    final theme = Theme.of(context);
    final color = _getColorForIntensity(intensity);
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedArea = areaId;
        });
        HapticFeedback.mediumImpact();
      },
      onLongPress: () {
        // REVOLUTIONARY: Quick pain level picker on long press
        _showQuickPainPicker(areaId, area);
        HapticFeedback.heavyImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.elasticOut,
        width: isSelected ? 70 : (isActive ? 55 : 45),
        height: isSelected ? 70 : (isActive ? 55 : 45),
        decoration: BoxDecoration(
          gradient: isActive ? LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.9),
              color.withValues(alpha: 0.6),
            ],
          ) : null,
          color: !isActive ? theme.colorScheme.surface : null,
          border: Border.all(
            color: isSelected 
                ? AppTheme.primaryRose
                : (isActive ? color : AppTheme.lightGrey),
            width: isSelected ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(isSelected ? 35 : 27),
          boxShadow: [
            BoxShadow(
              color: (isSelected ? AppTheme.primaryRose : color).withValues(alpha: 0.4),
              blurRadius: isSelected ? 20 : (isActive ? 12 : 6),
              offset: Offset(0, isSelected ? 8 : 4),
              spreadRadius: isSelected ? 2 : 0,
            ),
            if (isSelected) BoxShadow(
              color: theme.colorScheme.surface,
              blurRadius: 3,
              offset: Offset(0, -1),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Pulsing animation for active areas
            if (isActive && intensity >= 4.0)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(isSelected ? 35 : 27),
                    gradient: RadialGradient(
                      colors: [
                        color.withValues(alpha: 0.8),
                        color.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat())
                  .fadeIn(duration: 800.ms)
                  .then(delay: 200.ms)
                  .fadeOut(duration: 800.ms),
              ),
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    area.emoji,
                    style: TextStyle(
                      fontSize: isSelected ? 20 : (isActive ? 18 : 16),
                    ),
                  ),
                  if (isActive && intensity > 0) ...[
                    const SizedBox(height: 2),
                    Text(
                      intensity.round().toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isActive ? theme.colorScheme.onPrimary : color,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: Duration(milliseconds: areaId.hashCode % 500))
      .fadeIn()
      .scale(begin: const Offset(0.8, 0.8));
  }

  Widget _buildSelectedAreaDetails() {
    final theme = Theme.of(context);
    final area = _bodyAreas[_selectedArea!]!;
    final intensity = widget.painAreas[_selectedArea!] ?? 0.0;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryRose,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryRose.withValues(alpha: 0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.primaryRose.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    area.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      area.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    Text(
                      intensity > 0 
                          ? 'Pain Level: ${_getPainLevelText(intensity)}'
                          : 'No pain recorded',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: intensity > 0 
                            ? _getColorForIntensity(intensity)
                            : AppTheme.mediumGrey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Remove pain button
              if (intensity > 0)
                IconButton(
                  onPressed: () {
                    widget.onPainAreaChanged(_selectedArea!, 0);
                    HapticFeedback.lightImpact();
                    
                    // Clear selection after removing pain
                    setState(() {
                      _selectedArea = null;
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    color: AppTheme.mediumGrey,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Pain intensity slider
          _buildPainIntensitySlider(),
        ],
      ),
    ).animate().fadeIn().slideY(begin: 0.3, end: 0);
  }

  Widget _buildPainIntensitySlider() {
    final theme = Theme.of(context);
    final intensity = widget.painAreas[_selectedArea!] ?? 0.0;
    final color = _getColorForIntensity(intensity);
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Pain Intensity',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _getPainLevelText(intensity),
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 6,
          ),
          child: Slider(
            value: intensity,
            min: 0,
            max: 5,
            divisions: 5,
            onChanged: (value) {
              widget.onPainAreaChanged(_selectedArea!, value);
              HapticFeedback.selectionClick();
              
              // Auto-dismiss selection after a short delay to show the body map
              if (value > 0) {
                Future.delayed(const Duration(milliseconds: 800), () {
                  if (mounted) {
                    setState(() {
                      _selectedArea = null;
                    });
                  }
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickPainLevels() {
    final theme = Theme.of(context);
    if (_selectedArea == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.lightGrey.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              Icons.touch_app,
              color: AppTheme.mediumGrey,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Tap on any body area to track pain',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGrey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Pain Levels',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(6, (index) {
              final level = index.toDouble();
              final isSelected = (widget.painAreas[_selectedArea!] ?? 0.0) == level;
              final color = _getColorForIntensity(level);
              
              return GestureDetector(
                onTap: () {
                  widget.onPainAreaChanged(_selectedArea!, level);
                  HapticFeedback.selectionClick();
                  
                  // Auto-dismiss selection after pain level is set
                  if (level > 0) {
                    Future.delayed(const Duration(milliseconds: 600), () {
                      if (mounted) {
                        setState(() {
                          _selectedArea = null;
                        });
                      }
                    });
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: isSelected ? color : color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: color,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        level.round().toString(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? theme.colorScheme.onPrimary : color,
                        ),
                      ),
                      Text(
                        _getPainLevelEmoji(level),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Color _getColorForIntensity(double intensity) {
    if (intensity == 0) return AppTheme.lightGrey;
    
    // Gradient from green (low pain) to red (high pain)
    const colors = [
      AppTheme.lightGrey,      // 0 - No pain
      AppTheme.accentMint,     // 1 - Very mild
      Color(0xFFFFC107),       // 2 - Mild
      Color(0xFFFF9800),       // 3 - Moderate
      Color(0xFFFF5722),       // 4 - Severe
      AppTheme.primaryRose,    // 5 - Very severe
    ];
    
    final index = intensity.round().clamp(0, colors.length - 1);
    return colors[index];
  }

  String _getPainLevelText(double intensity) {
    switch (intensity.round()) {
      case 0: return 'None';
      case 1: return 'Very Mild';
      case 2: return 'Mild';
      case 3: return 'Moderate';
      case 4: return 'Severe';
      case 5: return 'Very Severe';
      default: return 'None';
    }
  }

  String _getPainLevelEmoji(double intensity) {
    switch (intensity.round()) {
      case 0: return '😌';
      case 1: return '😕';
      case 2: return '😣';
      case 3: return '😖';
      case 4: return '😫';
      case 5: return '😭';
      default: return '😌';
    }
  }

  void _showQuickPainPicker(String areaId, PainArea area) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final theme = Theme.of(modalContext);
        return Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Header
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRose.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      area.emoji,
                      style: const TextStyle(fontSize: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        area.name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.darkGrey,
                        ),
                      ),
                      Text(
                        'Set your current pain level',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.mediumGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Pain level grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1,
              ),
              itemCount: 6,
              itemBuilder: (context, index) {
                final level = index.toDouble();
                final color = _getColorForIntensity(level);
                final emoji = _getPainLevelEmoji(level);
                final text = _getPainLevelText(level);
                
                return GestureDetector(
                  onTap: () {
                    widget.onPainAreaChanged(areaId, level);
                    HapticFeedback.mediumImpact();
                    Navigator.pop(context);
                    
                    // Clear selection to show full body map
                    setState(() {
                      _selectedArea = null;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: color.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          level.round().toString(),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: color.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ).animate(delay: Duration(milliseconds: index * 100))
                    .fadeIn()
                    .scale(begin: const Offset(0.8, 0.8)),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Pro tip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentMint.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.accentMint.withValues(alpha: 0.3),
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
                      'Tip: Long press any body area for quick pain logging',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.accentMint,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        );
      },
    );
  }
}

class PainArea {
  final String name;
  final String emoji;
  final Offset position;

  const PainArea({
    required this.name,
    required this.emoji,
    required this.position,
  });
}

class BodySilhouettePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.lightGrey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();
    
    // Simple body outline
    final centerX = size.width * 0.5;
    final headRadius = size.width * 0.08;
    
    // Head
    canvas.drawCircle(
      Offset(centerX, size.height * 0.15),
      headRadius,
      paint,
    );
    
    // Body
    path.moveTo(centerX, size.height * 0.23); // Neck
    path.lineTo(centerX - size.width * 0.12, size.height * 0.32); // Left shoulder
    path.lineTo(centerX - size.width * 0.15, size.height * 0.55); // Left side
    path.lineTo(centerX - size.width * 0.08, size.height * 0.65); // Left hip
    path.lineTo(centerX - size.width * 0.06, size.height * 0.85); // Left leg
    path.lineTo(centerX - size.width * 0.04, size.height * 0.98); // Left foot
    path.lineTo(centerX + size.width * 0.04, size.height * 0.98); // Right foot
    path.lineTo(centerX + size.width * 0.06, size.height * 0.85); // Right leg
    path.lineTo(centerX + size.width * 0.08, size.height * 0.65); // Right hip
    path.lineTo(centerX + size.width * 0.15, size.height * 0.55); // Right side
    path.lineTo(centerX + size.width * 0.12, size.height * 0.32); // Right shoulder
    path.lineTo(centerX, size.height * 0.23); // Back to neck
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
