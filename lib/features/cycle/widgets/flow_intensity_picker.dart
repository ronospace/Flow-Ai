import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/models/cycle_data.dart';

class FlowIntensityPicker extends StatefulWidget {
  final FlowIntensity selectedIntensity;
  final Function(FlowIntensity) onIntensitySelected;

  const FlowIntensityPicker({
    super.key,
    required this.selectedIntensity,
    required this.onIntensitySelected,
  });

  @override
  State<FlowIntensityPicker> createState() => _FlowIntensityPickerState();
}

class _FlowIntensityPickerState extends State<FlowIntensityPicker> {
  
  final List<FlowIntensityOption> _intensityOptions = [
    FlowIntensityOption(
      intensity: FlowIntensity.none,
      title: 'None',
      subtitle: 'No menstrual flow',
      emoji: '✨',
      color: AppTheme.lightGrey,
      description: 'Complete absence of menstrual flow. This is normal before your period starts or after it ends.',
      medicalInfo: 'No menstruation occurring',
      products: [],
      hourlyChanges: 0,
    ),
    FlowIntensityOption(
      intensity: FlowIntensity.spotting,
      title: 'Spotting',
      subtitle: 'Minimal discharge',
      emoji: '💧',
      color: AppTheme.accentMint,
      description: 'Very light pink or brown discharge. Often occurs at the beginning or end of your cycle.',
      medicalInfo: 'Less than 5ml per day',
      products: ['Panty liners', 'Period underwear'],
      hourlyChanges: 0,
    ),
    FlowIntensityOption(
      intensity: FlowIntensity.light,
      title: 'Light Flow',
      subtitle: 'Comfortable protection',
      emoji: '🌸',
      color: AppTheme.secondaryBlue,
      description: 'Light menstrual flow requiring minimal protection. Usually lasts 1-3 days.',
      medicalInfo: '5-40ml per day',
      products: ['Light pads', 'Tampons (regular)', 'Menstrual cups'],
      hourlyChanges: 1,
    ),
    FlowIntensityOption(
      intensity: FlowIntensity.medium,
      title: 'Normal Flow',
      subtitle: 'Typical menstruation',
      emoji: '🌺',
      color: AppTheme.primaryPurple,
      description: 'Regular menstrual flow. This is the most common flow intensity for healthy cycles.',
      medicalInfo: '40-70ml per day',
      products: ['Regular pads', 'Tampons (super)', 'Menstrual cups', 'Period underwear'],
      hourlyChanges: 2,
    ),
    FlowIntensityOption(
      intensity: FlowIntensity.heavy,
      title: 'Heavy Flow',
      subtitle: 'High absorption needed',
      emoji: '🌹',
      color: AppTheme.primaryRose,
      description: 'Heavy menstrual flow requiring frequent changes. Consider consulting a healthcare provider.',
      medicalInfo: '70-100ml per day',
      products: ['Super pads', 'Tampons (super+)', 'Menstrual cups (large)', 'Period underwear (heavy)'],
      hourlyChanges: 3,
    ),
    FlowIntensityOption(
      intensity: FlowIntensity.veryHeavy,
      title: 'Very Heavy',
      subtitle: 'Medical attention advised',
      emoji: '🔴',
      color: Color(0xFFD32F2F),
      description: 'Very heavy flow that may interfere with daily activities. Strongly recommend consulting a healthcare provider.',
      medicalInfo: 'Over 100ml per day',
      products: ['Ultra pads', 'Tampons (ultra)', 'Menstrual cups (XL)', 'Medical consultation'],
      hourlyChanges: 4,
    ),
  ];
  
  @override
  Widget build(BuildContext context) {
    final selectedOption = _intensityOptions.firstWhere(
      (option) => option.intensity == widget.selectedIntensity,
      orElse: () => _intensityOptions[0],
    );
    
    return Column(
      children: [
        // Optimized Grid View - Using better scrolling with more space
        Expanded(
          flex: 3,
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            physics: const BouncingScrollPhysics(), // Better scrolling performance
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.8, // Improved ratio for better visibility
            ),
            itemCount: _intensityOptions.length,
            itemBuilder: (context, index) {
              final option = _intensityOptions[index];
              final isSelected = option.intensity == widget.selectedIntensity;
              
              return GestureDetector(
                onTap: () {
                  HapticFeedback.mediumImpact();
                  widget.onIntensitySelected(option.intensity);
                },
                onLongPress: () {
                  _showMedicalInfo(option);
                  HapticFeedback.heavyImpact();
                },
                child: _buildFlowIntensityCard(option, isSelected),
              );
            },
          ),
        ),
        
        // AI Insights Panel - Positioned at bottom for better layout
        if (widget.selectedIntensity != FlowIntensity.none)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: _buildAIInsightsPanel(selectedOption),
          ),
      ],
    );
  }
  
  Widget _buildFlowVisualization(FlowIntensityOption option) {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            option.color.withValues(alpha: 0.1),
            option.color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: option.color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Flow Indicator
          Expanded(
            flex: 2,
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      option.color.withValues(alpha: 0.8),
                      option.color.withValues(alpha: 0.4),
                      option.color.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    option.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
            ),
          ),
          
          // Medical Information
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    option.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: option.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.medicalInfo,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.darkGrey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (option.hourlyChanges > 0)
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: option.color,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '~${option.hourlyChanges}/hour changes',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.mediumGrey,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAIInsightsPanel(FlowIntensityOption option) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.secondaryBlue, AppTheme.accentMint],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.secondaryBlue.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Icon(
              Icons.psychology,
              color: Colors.white,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Health Insights',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getAIInsight(option),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFlowIntensityCard(FlowIntensityOption option, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200), // Reduced animation time
      decoration: BoxDecoration(
        gradient: isSelected 
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  option.color.withValues(alpha: 0.15),
                  option.color.withValues(alpha: 0.05),
                ],
              )
            : null,
        color: isSelected ? null : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected ? option.color : AppTheme.lightGrey.withValues(alpha: 0.5),
          width: isSelected ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected 
                ? option.color.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: isSelected ? 15.0 : 8.0,
            offset: Offset(0, isSelected ? 8.0 : 4.0),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon Container - Simplified
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: option.color.withValues(alpha: isSelected ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  option.emoji,
                  style: TextStyle(
                    fontSize: isSelected ? 28 : 24,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Title
            Flexible(
              child: Text(
                option.title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? option.color : AppTheme.darkGrey,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            const SizedBox(height: 2),
            
            // Subtitle
            Flexible(
              child: Text(
                option.subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.mediumGrey,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            
            // Medical indicator for heavy flows
            if (option.intensity == FlowIntensity.heavy || 
                option.intensity == FlowIntensity.veryHeavy) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: option.color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.health_and_safety,
                      size: 10,
                      color: option.color,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      'Monitor',
                      style: TextStyle(
                        color: option.color,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const Spacer(),
            
            // Selection indicator
            if (isSelected) 
              Container(
                width: 24,
                height: 3,
                decoration: BoxDecoration(
                  color: option.color,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  String _getAIInsight(FlowIntensityOption option) {
    switch (option.intensity) {
      case FlowIntensity.spotting:
        return 'Spotting is often normal at cycle start/end. Track patterns for insights.';
      case FlowIntensity.light:
        return 'Light flow detected. Consider stress levels and nutrition for optimal health.';
      case FlowIntensity.medium:
        return 'Normal flow pattern. Your cycle appears healthy and regular.';
      case FlowIntensity.heavy:
        return 'Heavy flow detected. Monitor symptoms and consider iron-rich foods.';
      case FlowIntensity.veryHeavy:
        return 'Very heavy flow may need medical attention. Track duration carefully.';
      default:
        return 'No flow detected. Track other symptoms for comprehensive insights.';
    }
  }
  
  void _showMedicalInfo(FlowIntensityOption option) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: AppTheme.lightGrey,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [option.color, option.color.withValues(alpha: 0.7)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        option.emoji,
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
                          option.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGrey,
                          ),
                        ),
                        Text(
                          option.medicalInfo,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: option.color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      'About This Flow Level',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      option.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: AppTheme.darkGrey,
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Recommended Products
                    if (option.products.isNotEmpty) ...[
                      Text(
                        'Recommended Products',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...option.products.map((product) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: option.color,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              product,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      )),
                    ],
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlowIntensityOption {
  final FlowIntensity intensity;
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final String description;
  final String medicalInfo;
  final List<String> products;
  final int hourlyChanges;

  const FlowIntensityOption({
    required this.intensity,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.description,
    required this.medicalInfo,
    required this.products,
    required this.hourlyChanges,
  });
}
