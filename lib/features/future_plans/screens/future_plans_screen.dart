import 'package:flutter/material.dart';
import '../../../features/coming_soon/widgets/coming_soon_card.dart';

class FuturePlansScreen extends StatefulWidget {
  const FuturePlansScreen({super.key});

  @override
  State<FuturePlansScreen> createState() => _FuturePlansScreenState();
}

class _FuturePlansScreenState extends State<FuturePlansScreen>
    with TickerProviderStateMixin {
  late AnimationController _headerAnimationController;
  late Animation<double> _headerAnimation;
  
  String _selectedCategory = 'all';
  final List<String> _categories = ['all', 'ai', 'health', 'tech', 'social'];

  @override
  void initState() {
    super.initState();
    _headerAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _headerAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));
    _headerAnimationController.repeat();
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    super.dispose();
  }

  List<Widget> _getFilteredFeatures() {
    final allFeatures = [
      // AI Features
      const AIFeatureCard(
        title: 'AI Cycle Predictor',
        description: 'Advanced machine learning to predict your cycle with 95% accuracy using pattern recognition and health data.',
        eta: 'Q2 2025',
      ),
      const AIFeatureCard(
        title: 'Smart Symptom Analysis',
        description: 'AI-powered symptom tracking that learns your patterns and provides personalized health insights.',
        eta: 'Q1 2025',
      ),
      const AIFeatureCard(
        title: 'Personalized AI Coach',
        description: 'Your dedicated AI health coach that adapts to your lifestyle and provides real-time guidance.',
        eta: 'Q3 2025',
      ),
      
      // Health Features
      const HealthFeatureCard(
        title: 'Fertility Planning Hub',
        description: 'Comprehensive fertility tracking with ovulation prediction, conception probability, and family planning tools.',
        eta: 'Q2 2025',
      ),
      const HealthFeatureCard(
        title: 'Mental Health Companion',
        description: 'Mood tracking, mindfulness exercises, and personalized mental health support integrated with your cycle.',
        eta: 'Q1 2025',
      ),
      const HealthFeatureCard(
        title: 'Nutrition Intelligence',
        description: 'Smart meal planning based on your cycle phase, nutritional needs, and health goals.',
        eta: 'Q3 2025',
      ),
      
      // Tech Features
      const TechFeatureCard(
        title: 'Apple Watch Integration',
        description: 'Seamless health data sync, cycle reminders, and discreet notifications on your wrist.',
        eta: 'Q1 2025',
      ),
      const TechFeatureCard(
        title: 'Smart Device Ecosystem',
        description: 'Connect with smart scales, thermometers, and other IoT devices for automatic health tracking.',
        eta: 'Q2 2025',
      ),
      const TechFeatureCard(
        title: 'AR Body Insights',
        description: 'Augmented reality visualization of your cycle, health metrics, and body changes over time.',
        eta: 'Q4 2025',
      ),
      
      // Social Features
      ComingSoonCard(
        title: 'Community Connect',
        description: 'Connect with others on similar health journeys, share experiences, and get support.',
        icon: Icons.people_outline,
        gradientColors: const [Color(0xFF4CAF50), Color(0xFF8BC34A)],
        eta: 'Q2 2025',
      ),
      ComingSoonCard(
        title: 'Partner Sharing',
        description: 'Securely share selected health insights with your partner or healthcare provider.',
        icon: Icons.share_outlined,
        gradientColors: const [Color(0xFFFF9800), Color(0xFFFF5722)],
        eta: 'Q1 2025',
      ),
      ComingSoonCard(
        title: 'Telehealth Integration',
        description: 'Direct consultations with healthcare providers using your Flow Ai data.',
        icon: Icons.video_call_outlined,
        gradientColors: const [Color(0xFF3F51B5), Color(0xFF9C27B0)],
        eta: 'Q3 2025',
      ),
    ];

    if (_selectedCategory == 'all') return allFeatures;
    
    return allFeatures.where((feature) {
      switch (_selectedCategory) {
        case 'ai':
          return feature is AIFeatureCard;
        case 'health':
          return feature is HealthFeatureCard;
        case 'tech':
          return feature is TechFeatureCard;
        case 'social':
          return feature is ComingSoonCard && 
                 !(feature is AIFeatureCard) && 
                 !(feature is HealthFeatureCard) && 
                 !(feature is TechFeatureCard);
        default:
          return true;
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Animated App Bar
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                children: [
                  // Animated gradient background
                  AnimatedBuilder(
                    animation: _headerAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color.lerp(
                                const Color(0xFFFF6B9D),
                                const Color(0xFF6C63FF),
                                _headerAnimation.value,
                              )!,
                              Color.lerp(
                                const Color(0xFF9B59B6),
                                const Color(0xFF00BCD4),
                                _headerAnimation.value,
                              )!,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [0.0, 1.0],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Floating particles effect
                  AnimatedBuilder(
                    animation: _headerAnimation,
                    builder: (context, child) {
                      return Positioned.fill(
                        child: CustomPaint(
                          painter: ParticlePainter(_headerAnimation.value),
                        ),
                      );
                    },
                  ),
                  
                  // Content
                  const Positioned(
                    bottom: 40,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🚀 Future Plans',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Discover what\'s coming next in Flow Ai',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Category Filter
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Category',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _categories.map((category) {
                        final isSelected = _selectedCategory == category;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCategory = category),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFFF6B9D) : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: isSelected ? [
                                BoxShadow(
                                  color: const Color(0xFFFF6B9D).withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ] : null,
                            ),
                            child: Text(
                              category.toUpperCase(),
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.grey.shade600,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Features Grid
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final features = _getFilteredFeatures();
                  if (index >= features.length) return null;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: features[index],
                  );
                },
                childCount: _getFilteredFeatures().length,
              ),
            ),
          ),
          
          // Footer
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF9C27B0)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Have an idea?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We\'d love to hear your feature requests and ideas for the future of Flow Ai.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to feedback screen
                      Navigator.pushNamed(context, '/feedback');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF6C63FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text('Share Your Ideas'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for animated particles in the header
class ParticlePainter extends CustomPainter {
  final double animationValue;

  ParticlePainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 20; i++) {
      final x = (i * 0.05 * size.width + animationValue * 50) % size.width;
      final y = (i * 0.1 * size.height + animationValue * 30) % size.height;
      final radius = 2.0 + (i % 3);
      
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(ParticlePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue;
  }
}
