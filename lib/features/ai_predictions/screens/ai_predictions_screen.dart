import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../../../core/ui/adaptive_messages.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_header_components.dart';
import '../../../core/ai/period_prediction_engine.dart';
import '../widgets/ai_prediction_card.dart';

class AIPredictionsScreen extends StatefulWidget {
  const AIPredictionsScreen({super.key});

  @override
  State<AIPredictionsScreen> createState() => _AIPredictionsScreenState();
}

class _AIPredictionsScreenState extends State<AIPredictionsScreen>
    with TickerProviderStateMixin {
  PeriodPrediction? currentPrediction;
  bool isLoading = false;
  bool _showRefreshAction = false;
  Timer? _refreshVisibilityTimer;
  late AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _generatePrediction();
  }

  @override
  void dispose() {
    _refreshVisibilityTimer?.cancel();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _generatePrediction() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      // Simulate loading time for better UX
      await Future.delayed(const Duration(milliseconds: 800));

      final prediction = await PeriodPredictionEngine().predictNextPeriod(
        'anonymous_user',
      );

      if (mounted) {
        setState(() {
          currentPrediction = prediction;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        AdaptiveMessages.showError(
          context,
          'Failed to generate prediction: $e',
        );
      }
    }
  }

  Future<void> _refreshPrediction() async {
    _refreshVisibilityTimer?.cancel();

    if (_showRefreshAction && mounted) {
      setState(() {
        _showRefreshAction = false;
      });
    }

    _refreshController.reset();
    _refreshController.forward();
    await _generatePrediction();
  }

  bool _handleRefreshScroll(UserScrollNotification notification) {
    if (notification.direction == ScrollDirection.reverse) {
      _refreshVisibilityTimer?.cancel();

      if (_showRefreshAction && mounted) {
        setState(() {
          _showRefreshAction = false;
        });
      }

      return false;
    }

    if (notification.direction == ScrollDirection.forward) {
      if (!_showRefreshAction && mounted) {
        setState(() {
          _showRefreshAction = true;
        });
      }

      _scheduleRefreshActionHide();
      return false;
    }

    if (notification.direction == ScrollDirection.idle) {
      _scheduleRefreshActionHide();
    }

    return false;
  }

  void _scheduleRefreshActionHide() {
    _refreshVisibilityTimer?.cancel();
    _refreshVisibilityTimer = Timer(const Duration(milliseconds: 1400), () {
      if (!mounted || !_showRefreshAction) return;

      setState(() {
        _showRefreshAction = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NotificationListener<UserScrollNotification>(
        onNotification: _handleRefreshScroll,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverPadding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if (isLoading) ...[
                    _buildLoadingCard(),
                    const SizedBox(height: 20),
                  ] else if (currentPrediction != null) ...[
                    AIPredictionCard(
                      prediction: currentPrediction!,
                      onTap: () => _showPredictionDetails(currentPrediction!),
                    ),
                    const SizedBox(height: 20),
                  ],
                  _buildEducationSection(),
                  const SizedBox(height: 20),
                  _buildHistorySection(),
                ]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildTransientRefreshAction(),
    );
  }

  Widget _buildAppBar() {
    final theme = Theme.of(context);
    return SliverAppBar(
      floating: false,
      pinned: true,
      toolbarHeight: 72,
      leadingWidth: 56,
      titleSpacing: 8,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: AppBackButton(onPressed: () => Navigator.of(context).pop()),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryRose, AppTheme.primaryPurple],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryRose.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'AI Predictions',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryRose.withValues(alpha: 0.1),
                      AppTheme.primaryPurple.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.psychology_rounded,
                  color: AppTheme.primaryRose,
                  size: 30,
                ),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1200.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1))
              .then()
              .scale(
                begin: const Offset(1.1, 1.1),
                end: const Offset(0.9, 0.9),
              ),
          const SizedBox(height: 20),
          Text(
            'Analyzing Your Cycle',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'AI is processing your data to generate accurate predictions...',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 20),
          LinearProgressIndicator(
                backgroundColor: theme.colorScheme.onSurface.withValues(
                  alpha: 0.1,
                ),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryRose,
                ),
                borderRadius: BorderRadius.circular(4),
              )
              .animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 800.ms),
        ],
      ),
    );
  }

  Widget _buildEducationSection() {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.secondaryBlue.withValues(alpha: 0.1),
            AppTheme.accentMint.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppTheme.secondaryBlue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'How AI Predictions Work',
                  softWrap: true,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildEducationItem(
            Icons.analytics_rounded,
            'Machine Learning',
            'Neural networks analyze your cycle patterns and symptoms',
          ),
          const SizedBox(height: 12),
          _buildEducationItem(
            Icons.timeline_rounded,
            'Pattern Recognition',
            'Advanced algorithms detect subtle trends in your data',
          ),
          const SizedBox(height: 12),
          _buildEducationItem(
            Icons.psychology_alt_rounded,
            'Continuous Learning',
            'The AI improves accuracy as it learns from your cycles',
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildEducationItem(IconData icon, String title, String description) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.secondaryBlue),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistorySection() {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.history_rounded,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.68),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Prediction History',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Previous predictions will appear here as you track more cycles.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildTransientRefreshAction() {
    final isVisible = _showRefreshAction && !isLoading;

    return ExcludeSemantics(
      excluding: !isVisible,
      child: IgnorePointer(
        ignoring: !isVisible,
        child: AnimatedSlide(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          offset: isVisible ? Offset.zero : const Offset(0, 0.35),
          child: AnimatedOpacity(
            key: const ValueKey('ai_predictions_refresh_visibility'),
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            opacity: isVisible ? 1 : 0,
            child: _buildRefreshFAB(),
          ),
        ),
      ),
    );
  }

  Widget _buildRefreshFAB() {
    final actionLabel = isLoading
        ? 'Generating prediction'
        : 'Refresh prediction';

    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: actionLabel,
        child: Semantics(
          button: true,
          enabled: !isLoading,
          label: actionLabel,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isLoading ? null : _refreshPrediction,
              customBorder: const CircleBorder(),
              child: SizedBox.square(
                dimension: 48,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Ink(
                    width: 42,
                    height: 42,
                    decoration: ShapeDecoration(
                      color: isLoading
                          ? AppTheme.primaryRose.withValues(alpha: 0.55)
                          : AppTheme.primaryRose,
                      shape: const CircleBorder(),
                      shadows: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: 8,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: RotationTransition(
                        turns: _refreshController,
                        child: const Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 19,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 600.ms).scale(begin: const Offset(0.8, 0.8));
  }

  void _showPredictionDetails(PeriodPrediction prediction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prediction Details',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    const SizedBox(height: 20),
                    AIPredictionCard(prediction: prediction),
                    const SizedBox(height: 20),
                    if (prediction.insights.length > 2) ...[
                      Text(
                        'All AI Insights',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                      ),
                      const SizedBox(height: 12),
                      ...prediction.insights.map(
                        (insight) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.accentMint.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.accentMint.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.lightbulb_rounded,
                                size: 16,
                                color: AppTheme.accentMint,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  insight,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.82),
                                        height: 1.4,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 100),
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
