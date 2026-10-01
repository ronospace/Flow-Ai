import 'dart:async';

import 'package:flow_ai/core/services/app_state_service.dart';
import 'package:flow_ai/core/theme/app_theme.dart';
import 'package:flow_ai/core/services/source_link_launcher.dart';
import 'package:flow_ai/core/ui/adaptive_messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription_models.dart';
import '../providers/subscription_provider.dart';

import '../services/subscription_management_service.dart';

class PremiumPaywallScreen extends StatefulWidget {
  final bool showCloseButton;
  final String? highlightFeature;

  const PremiumPaywallScreen({
    super.key,
    this.showCloseButton = true,
    this.highlightFeature,
  });

  @override
  State<PremiumPaywallScreen> createState() => _PremiumPaywallScreenState();
}

class _PremiumPaywallScreenState extends State<PremiumPaywallScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late final ScrollController _premiumScrollController;
  BillingPeriod _selectedPeriod = BillingPeriod.yearly;
  final GlobalKey _subscriptionOptionsKey = GlobalKey();
  final GlobalKey _ownershipConflictKey = GlobalKey();
  String? _subscriptionUserId;
  String? _catalogMessage;
  bool _catalogLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _premiumScrollController = ScrollController();
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        unawaited(_initializeSubscriptionCatalog());
      }
    });
  }

  Future<void> _initializeSubscriptionCatalog({
    bool forceRefresh = false,
  }) async {
    if (mounted) {
      setState(() {
        _catalogLoading = true;
        if (forceRefresh) {
          _catalogMessage = null;
        }
      });
    }

    final appState = context.read<AppStateService>();
    final userId = _subscriptionUserId ?? await _resolveCurrentUserId(appState);

    if (!mounted) return;

    if (userId == null) {
      final provider = context.read<SubscriptionProvider>();
      await provider.loadStoreCatalog();

      if (!mounted) return;

      setState(() {
        _catalogLoading = false;
        _catalogMessage = provider.availableProducts.isEmpty
            ? provider.errorMessage ??
                  'Subscription plans are temporarily unavailable.'
            : null;
      });
      return;
    }

    _subscriptionUserId = userId;
    final provider = context.read<SubscriptionProvider>();

    if (forceRefresh) {
      await provider.refreshProducts(userId);
    } else {
      await provider.initialize(userId);
    }

    if (!mounted) return;

    setState(() {
      _catalogLoading = false;
      _catalogMessage = provider.availableProducts.isEmpty
          ? provider.errorMessage ??
                'Subscription plans are temporarily unavailable.'
          : null;
    });
  }

  @override
  void dispose() {
    _premiumScrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String? _restoreStatusMessage;

  bool _handlePremiumScrollEnd(
    BuildContext context,
    ScrollEndNotification notification,
  ) {
    if (Theme.of(context).platform != TargetPlatform.iOS) return false;
    if (!_premiumScrollController.hasClients) return false;

    final position = _premiumScrollController.position;
    final offset = position.pixels;

    if (offset <= 0.0) return false;

    final collapseRange =
        _premiumPinnedHeaderMaxExtent(context) -
        _premiumPinnedHeaderMinExtent(context);

    if (offset <= collapseRange + 0.5) {
      _premiumScrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
      );
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Consumer<SubscriptionProvider>(
          builder: (context, subscriptionProvider, child) {
            final isPremium = subscriptionProvider.isPremium;
            final hasYearlyBillingOption =
                subscriptionProvider.getMonthlyProduct() != null &&
                subscriptionProvider.getYearlyProduct() != null;

            return Stack(
              children: [
                // Gradient background
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),

                // Content
                NotificationListener<ScrollEndNotification>(
                  onNotification: (notification) =>
                      _handlePremiumScrollEnd(context, notification),
                  child: CustomScrollView(
                    controller: _premiumScrollController,
                    physics: const BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    slivers: [
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _PremiumPinnedHeaderDelegate(
                          isPremium: isPremium,
                          minHeaderExtent: _premiumPinnedHeaderMinExtent(
                            context,
                          ),
                          maxHeaderExtent: _premiumPinnedHeaderMaxExtent(
                            context,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Padding(
                            padding: EdgeInsets.only(
                              top:
                                  _premiumAdaptiveGap(
                                    context,
                                    compact: 8,
                                    comfortable: 14,
                                  ) +
                                  _premiumFreeRootBalanceShift(context),
                            ),
                            child: Column(
                              children: [
                                KeyedSubtree(
                                  child: _buildFeaturesList(context),
                                ),
                                SizedBox(
                                  height: _premiumTallFreeValue(
                                    context,
                                    regular: _premiumAdaptiveGap(
                                      context,
                                      compact: 7,
                                      comfortable: 10,
                                    ),
                                    tall: 12,
                                  ),
                                ),
                                if (isPremium)
                                  KeyedSubtree(
                                    child: _buildActiveSubscriptionDetails(
                                      context,
                                      subscriptionProvider,
                                    ),
                                  ),
                                if (!isPremium)
                                  _buildCatalogSection(
                                    context,
                                    subscriptionProvider,
                                    hasYearlyBillingOption,
                                  ),
                                if (isPremium)
                                  SizedBox(
                                    height: _premiumPostActionRootGap(
                                      context,
                                      isPremium: isPremium,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!isPremium)
                        SliverToBoxAdapter(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                height: _premiumPostActionRootGap(
                                  context,
                                  isPremium: isPremium,
                                ),
                              ),
                              _buildRestorePurchasesButton(
                                context,
                                subscriptionProvider,
                              ),
                              const SizedBox(height: 8),
                              if (_restoreStatusMessage != null) ...[
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                  ),
                                  child: KeyedSubtree(
                                    key: _ownershipConflictKey,
                                    child: Text(
                                      _restoreStatusMessage!,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                              ],
                            ],
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: _buildPremiumLegalSection(context),
                      ),
                    ],
                  ),
                ),

                // Loading presentation must not intercept plan-card taps.
                // Store actions remain protected by provider.isLoading.
                if (subscriptionProvider.isLoading)
                  const IgnorePointer(
                    ignoring: true,
                    child: Center(child: CircularProgressIndicator()),
                  ),

                if (widget.showCloseButton)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Semantics(
                      button: true,
                      label: 'Back',
                      child: Material(
                        color: Colors.transparent,
                        child: InkResponse(
                          radius: 26,
                          onTap: () => Navigator.of(context).pop(),
                          child: Container(
                            width: 48,
                            height: 48,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.surface.withValues(alpha: 0.08),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_back_ios_new,
                              size: 24,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.82),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _premiumPinnedHeaderMinExtent(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return (height * 0.082).clamp(92.0, 108.0).toDouble();
  }

  double _premiumPinnedHeaderMaxExtent(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final view = View.of(context);
    final safeTop = view.viewPadding.top / view.devicePixelRatio;

    // Preserve the accepted iPhone physical top composition:
    // (47dp safe top + 196dp header) / 844dp viewport.
    const acceptedTopBandRatio = 243.0 / 844.0;
    const maxComfortableTopBand = 243.0;

    // Scale the expanded composition on smaller viewports, but do not
    // continuously enlarge the header on tall screens. The body already
    // owns tall-screen vertical rhythm through _premiumVerticalDensity.
    final proportionalTopBand = height * acceptedTopBandRatio;
    final physicalTopBand = proportionalTopBand.clamp(
      0.0,
      maxComfortableTopBand,
    );

    return (physicalTopBand - safeTop).clamp(196.0, 232.0).toDouble();
  }

  String _premiumTermsUrl(BuildContext context) {
    final platform = Theme.of(context).platform;

    if (platform == TargetPlatform.iOS) {
      return 'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';
    }

    return 'https://flowai-demo-project.web.app/terms.html';
  }

  Widget _buildPremiumLegalSection(BuildContext context) {
    final theme = Theme.of(context);

    Widget legalCard({
      required Key key,
      required IconData icon,
      required String label,
      required String url,
    }) {
      return Material(
        key: key,
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => launchSourceLink(context, url),
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 19, color: theme.colorScheme.primary),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 19,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.48),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final privacyCard = legalCard(
      key: const ValueKey('premium-privacy-policy-link'),
      icon: Icons.privacy_tip_outlined,
      label: 'Privacy Policy',
      url: 'https://flowai-demo-project.web.app/privacy.html',
    );

    final termsCard = legalCard(
      key: const ValueKey('premium-terms-link'),
      icon: Icons.description_outlined,
      label: 'Terms of Use',
      url: _premiumTermsUrl(context),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(
        _premiumHorizontalPadding(context),
        6,
        _premiumHorizontalPadding(context),
        _premiumFreeAdaptiveValue(context, compact: 12, comfortable: 20),
      ),
      child: Column(
        children: [
          Text(
            'Subscription automatically renews unless canceled.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.58),
            ),
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 300) {
                return Column(
                  children: [privacyCard, const SizedBox(height: 7), termsCard],
                );
              }

              return Row(
                key: const ValueKey('premium-legal-card'),
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: privacyCard),
                  const SizedBox(width: 8),
                  Expanded(child: termsCard),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  double _premiumFreeVerticalDensity(BuildContext context) {
    final media = MediaQuery.of(context);
    final usableHeight =
        media.size.height - media.padding.top - media.padding.bottom;

    // Free paywall carries more content than the active state.
    // Compact earlier so the complete purchase/legal surface
    // remains visible on shorter viewports.
    return ((usableHeight - 760.0) / 220.0).clamp(0.0, 1.0).toDouble();
  }

  double _premiumFreeAdaptiveValue(
    BuildContext context, {
    required double compact,
    required double comfortable,
  }) {
    final density = _premiumFreeVerticalDensity(context);

    return compact + ((comfortable - compact) * density);
  }

  double _premiumVerticalDensity(BuildContext context) {
    final media = MediaQuery.of(context);
    final usableHeight =
        media.size.height - media.padding.top - media.padding.bottom;

    // Tall screens retain generous rhythm.
    // Shorter viewports compact only vertical spacing,
    // never typography/content truth.
    return ((usableHeight - 720.0) / 180.0).clamp(0.0, 1.0).toDouble();
  }

  double _premiumAdaptiveGap(
    BuildContext context, {
    required double compact,
    required double comfortable,
  }) {
    final density = _premiumVerticalDensity(context);

    return compact + ((comfortable - compact) * density);
  }

  double _premiumLayoutScale(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;

    final heightScale = (height / 844.0).clamp(0.94, 1.10).toDouble();

    final textCompensation = (1 / textScale.clamp(1.0, 1.15)).toDouble();

    return (heightScale * textCompensation).clamp(0.92, 1.08).toDouble();
  }

  double _premiumGap(
    BuildContext context,
    double base, {
    double? min,
    double? max,
  }) {
    final scaled = base * _premiumLayoutScale(context);

    return scaled.clamp(min ?? base * 0.90, max ?? base * 1.12).toDouble();
  }

  double _premiumTallViewportTransferFactor(BuildContext context) {
    final media = MediaQuery.of(context);
    final view = View.of(context);
    final dpr = view.devicePixelRatio;

    final rawSafeTop = view.viewPadding.top / dpr;
    final rawSafeBottom = view.viewPadding.bottom / dpr;
    final usableHeight = media.size.height - rawSafeTop - rawSafeBottom;

    // Responsive constraint band:
    // <= 800dp: compact composition — preserve accepted geometry.
    // >= 860dp: tall composition — fully redistribute redundant
    // post-action spacing toward the header.
    return ((usableHeight - 800.0) / 60.0).clamp(0.0, 1.0).toDouble();
  }

  double _premiumTallFreeValue(
    BuildContext context, {
    required double regular,
    required double tall,
  }) {
    final factor = _premiumTallViewportTransferFactor(context);
    return regular + ((tall - regular) * factor);
  }

  double _premiumFreeRootBalanceShift(BuildContext context) {
    final factor = _premiumTallViewportTransferFactor(context);

    return 4.79 + ((0.95562 - 4.79) * factor);
  }

  double _premiumPostActionRootGap(
    BuildContext context, {
    required bool isPremium,
  }) {
    final baseGap = _premiumGap(context, 8, min: 6, max: 10);
    final factor = _premiumTallViewportTransferFactor(context);

    if (!isPremium) {
      return 27.92 + ((8.0 - 27.92) * factor);
    }

    return baseGap * (1.0 - factor);
  }

  double _premiumHorizontalPadding(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return (width * 0.058).clamp(20.0, 28.0).toDouble();
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      _Feature(
        icon: Icons.auto_awesome,
        title: 'Unlimited AI Insights',
        description: 'Personalized health insights anytime',
        highlight: widget.highlightFeature == 'insights',
      ),
      _Feature(
        icon: Icons.analytics,
        title: 'Advanced Analytics',
        description: 'Explore your health trends and patterns',
        highlight: widget.highlightFeature == 'analytics',
      ),
      _Feature(
        icon: Icons.file_download,
        title: 'Export Your Data',
        description: 'Download reports in PDF or CSV format',
        highlight: widget.highlightFeature == 'export',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: _premiumTallFreeValue(context, regular: 8, tall: 6),
            ),
            child: _buildFeatureItem(context, feature),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, _Feature feature) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        key: ValueKey(
          'premium-feature-${feature.title.toLowerCase().replaceAll(" ", "-")}',
        ),
        borderRadius: BorderRadius.circular(16),
        onTap: () => _handleFeatureTap(context, feature),
        child: Ink(
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: _premiumTallFreeValue(context, regular: 12, tall: 7),
          ),
          decoration: BoxDecoration(
            color: feature.highlight
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: feature.highlight
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.2),
              width: feature.highlight ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  feature.icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      feature.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      feature.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              if (feature.highlight)
                Icon(Icons.star, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _handleFeatureTap(BuildContext context, _Feature feature) {
    final provider = context.read<SubscriptionProvider>();
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (provider.availableProducts.isEmpty) {
      unawaited(_initializeSubscriptionCatalog(forceRefresh: true));

      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Loading subscription plans for ${feature.title}.'),
        ),
      );
      return;
    }

    final optionsContext = _subscriptionOptionsKey.currentContext;

    if (optionsContext != null) {
      Scrollable.ensureVisible(
        optionsContext,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    }

    messenger?.hideCurrentSnackBar();
    messenger?.showSnackBar(
      SnackBar(
        content: Text('Choose a plan below to unlock ${feature.title}.'),
      ),
    );
  }

  Widget _buildRestorePurchasesButton(
    BuildContext context,
    SubscriptionProvider provider,
  ) {
    return TextButton(
      onPressed: provider.isLoading
          ? null
          : () => _restorePurchases(context, provider),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: provider.isRestoring
            ? const Row(
                key: ValueKey('restore-purchases-progress'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 8),
                  Text('Restoring…'),
                ],
              )
            : const Text(
                'Restore Purchases',
                key: ValueKey('restore-purchases-idle'),
              ),
      ),
    );
  }

  String _formatPremiumExpiry(DateTime expiryDate) {
    final now = DateTime.now();

    final date =
        '${expiryDate.day.toString().padLeft(2, '0')}.'
        '${expiryDate.month.toString().padLeft(2, '0')}.'
        '${expiryDate.year}';

    final expiresToday =
        expiryDate.year == now.year &&
        expiryDate.month == now.month &&
        expiryDate.day == now.day;

    if (!expiresToday) {
      return date;
    }

    final time =
        '${expiryDate.hour.toString().padLeft(2, '0')}:'
        '${expiryDate.minute.toString().padLeft(2, '0')}';

    return '$date, $time';
  }

  Widget _buildActiveSubscriptionDetails(
    BuildContext context,
    SubscriptionProvider provider,
  ) {
    final billingPeriod = provider.billingPeriodText;
    final expiryDate = provider.expiryDate?.toLocal();

    final expiryText = expiryDate == null
        ? null
        : _formatPremiumExpiry(expiryDate);

    final planText = billingPeriod == null
        ? 'Premium'
        : '$billingPeriod Premium';

    final colorScheme = Theme.of(context).colorScheme;
    final width = MediaQuery.sizeOf(context).width;

    final actionWidth = (width * 0.72).clamp(270.0, 320.0).toDouble();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: _premiumHorizontalPadding(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: _premiumAdaptiveGap(
                context,
                compact: 11,
                comfortable: 15,
              ),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: colorScheme.primary.withValues(alpha: 0.30),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Current subscription',
                  textAlign: TextAlign.center,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(
                  height: _premiumAdaptiveGap(
                    context,
                    compact: 5,
                    comfortable: 8,
                  ),
                ),
                Icon(
                  Icons.verified_rounded,
                  size: 42,
                  color: colorScheme.primary,
                ),
                SizedBox(
                  height: _premiumAdaptiveGap(
                    context,
                    compact: 5,
                    comfortable: 8,
                  ),
                ),
                Text(
                  planText,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (expiryText != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Active until $expiryText',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),

          SizedBox(
            height: _premiumAdaptiveGap(context, compact: 7, comfortable: 10),
          ),

          SizedBox(
            width: actionWidth,
            child: OutlinedButton.icon(
              onPressed: SubscriptionManagementService.open,
              icon: const Icon(Icons.manage_accounts_outlined),
              label: const Text('Manage Subscription'),
            ),
          ),

          // Restore belongs to the same action cluster.
          // Keep this intentionally tight.
          SizedBox(
            height: _premiumAdaptiveGap(context, compact: 0, comfortable: 2),
          ),

          _buildRestorePurchasesButton(context, provider),
        ],
      ),
    );
  }

  Widget _buildCatalogSection(
    BuildContext context,
    SubscriptionProvider provider,
    bool hasYearlyBillingOption,
  ) {
    if (_catalogLoading ||
        (provider.isLoading && provider.availableProducts.isEmpty)) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.availableProducts.isEmpty) {
      final message =
          _catalogMessage ??
          provider.errorMessage ??
          'Subscription plans are temporarily unavailable.';

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(
                context,
              ).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.cloud_off_outlined,
                size: 36,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                'Plans temporarily unavailable',
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                key: const ValueKey('premium-catalog-retry'),
                onPressed: provider.isLoading
                    ? null
                    : () => unawaited(
                        _initializeSubscriptionCatalog(forceRefresh: true),
                      ),
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        KeyedSubtree(
          key: _subscriptionOptionsKey,
          child: _buildSubscriptionOptions(
            context,
            provider,
            hasYearlyBillingOption,
          ),
        ),
        SizedBox(
          height: _premiumTallFreeValue(
            context,
            regular: _premiumAdaptiveGap(context, compact: 12, comfortable: 20),
            tall: 12,
          ),
        ),
        _buildSubscribeButton(context, provider),
      ],
    );
  }

  Widget _buildSubscriptionOptions(
    BuildContext context,
    SubscriptionProvider provider,
    bool hasYearlyBillingOption,
  ) {
    final monthlyProduct = provider.getMonthlyProduct();
    final yearlyProduct = provider.getYearlyProduct();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Monthly option
          if (monthlyProduct != null)
            _buildSubscriptionOption(
              context,
              product: monthlyProduct,
              isSelected: _selectedPeriod == BillingPeriod.monthly,
              onTap: () {
                debugPrint(
                  '[UX2-F17] onTap monthly '
                  'providerLoading=${provider.isLoading} '
                  'catalogLoading=$_catalogLoading '
                  'selectedBefore=$_selectedPeriod',
                );

                setState(() {
                  _selectedPeriod = BillingPeriod.monthly;
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  debugPrint(
                    '[UX2-F17] postFrame monthly '
                    'selected=$_selectedPeriod',
                  );
                });
              },
            ),

          if (monthlyProduct != null && yearlyProduct != null)
            SizedBox(
              height: _premiumTallFreeValue(
                context,
                regular: _premiumAdaptiveGap(
                  context,
                  compact: 8,
                  comfortable: 12,
                ),
                tall: 8,
              ),
            ),

          // Yearly option
          if (yearlyProduct != null)
            _buildSubscriptionOption(
              context,
              product: yearlyProduct,
              isSelected: _selectedPeriod == BillingPeriod.yearly,
              onTap: () {
                debugPrint(
                  '[UX2-F17] onTap yearly '
                  'providerLoading=${provider.isLoading} '
                  'catalogLoading=$_catalogLoading '
                  'selectedBefore=$_selectedPeriod',
                );

                setState(() {
                  _selectedPeriod = BillingPeriod.yearly;
                });

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (!mounted) return;
                  debugPrint(
                    '[UX2-F17] postFrame yearly '
                    'selected=$_selectedPeriod',
                  );
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOption(
    BuildContext context, {
    required SubscriptionProduct product,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isYearly = product.billingPeriod == BillingPeriod.yearly;
    final title = product.name.replaceFirst(
      RegExp(r'\s*\((Monthly|Yearly)\)\s*$'),
      '',
    );
    final billingLabel = isYearly ? '[Yearly]' : '[Monthly]';
    final duration = isYearly ? '12 months' : '1 month';

    return GestureDetector(
      key: ValueKey('subscription-option-${product.id}'),
      onTapDown: (_) {
        if (Theme.of(context).platform == TargetPlatform.iOS) {
          debugPrint(
            '[UX2-F17] pointerDown '
            'product=${product.id} '
            'selected=$isSelected',
          );
        }
      },
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: _premiumTallFreeValue(
            context,
            regular: _premiumAdaptiveGap(context, compact: 14, comfortable: 20),
            tall: 13,
          ),
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                  width: 2,
                ),
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: billingLabel,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.78,
                            ),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text: ' · $duration',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.62,
                            ),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              product.priceString,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscribeButton(
    BuildContext context,
    SubscriptionProvider provider,
  ) {
    final selectedProduct = _selectedPeriod == BillingPeriod.yearly
        ? provider.getYearlyProduct()
        : provider.getMonthlyProduct();

    if (selectedProduct == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () {
          if (provider.isLoading) {
            AdaptiveMessages.showInfo(
              context,
              provider.isRestoring
                  ? 'Verifying your existing subscription. Please wait.'
                  : 'Subscription setup is still finishing. Please wait.',
            );
            return;
          }

          final ownershipConflict = provider.ownershipConflictMessage;
          if (ownershipConflict != null) {
            _showRestoreStatus(ownershipConflict, autoClear: false);
            AdaptiveMessages.showError(context, ownershipConflict);
            return;
          }

          unawaited(_subscribe(context, provider, selectedProduct.id));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(
            vertical: _premiumFreeAdaptiveValue(
              context,
              compact: 12,
              comfortable: 16,
            ),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: Size(
            double.infinity,
            _premiumFreeAdaptiveValue(context, compact: 50, comfortable: 56),
          ),
        ),
        child: Text(
          'Start Premium',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Future<void> _subscribe(
    BuildContext context,
    SubscriptionProvider provider,
    String productId,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (!provider.hasDurableMonetizationIdentity) {
      AdaptiveMessages.showError(
        messenger?.context ?? navigator.context,
        'Premium purchases require a secure signed-in account. '
        'Your current local or anonymous session remains available, '
        'but it cannot safely own App Store or Google Play purchases.',
      );
      return;
    }

    final result = await provider.purchaseSubscription(productId);

    if (!mounted) return;

    if (result.success) {
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(
            'Purchase request sent to your store. Premium activates after secure verification.',
          ),
        ),
      );
      return;
    }

    if (result.error == PurchaseError.alreadyPurchased) {
      messenger?.showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Premium is already active.'),
        ),
      );
      return;
    }

    final ownershipConflict = provider.ownershipConflictMessage;
    if (ownershipConflict != null) {
      _showRestoreStatus(ownershipConflict, autoClear: false);
      AdaptiveMessages.showError(
        messenger?.context ?? navigator.context,
        ownershipConflict,
      );
      return;
    }

    if (result.error != PurchaseError.cancelled) {
      AdaptiveMessages.showError(
        messenger?.context ?? navigator.context,
        result.errorMessage ?? 'Purchase failed',
      );
    }
  }

  void _showRestoreStatus(String message, {bool autoClear = true}) {
    if (!mounted) return;

    setState(() {
      _restoreStatusMessage = message;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _restoreStatusMessage != message) return;

      final conflictContext = _ownershipConflictKey.currentContext;
      if (conflictContext == null) return;

      Scrollable.ensureVisible(
        conflictContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
        alignment: 0.72,
      );
    });

    if (!autoClear) return;

    Future<void>.delayed(const Duration(seconds: 4), () {
      if (!mounted || _restoreStatusMessage != message) return;

      setState(() {
        _restoreStatusMessage = null;
      });
    });
  }

  Future<void> _restorePurchases(
    BuildContext context,
    SubscriptionProvider provider,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final appState = context.read<AppStateService>();

    final userId = await _resolveCurrentUserId(appState);

    if (!mounted) return;

    if (userId == null) {
      AdaptiveMessages.showError(
        messenger?.context ?? navigator.context,
        'Please sign in before restoring purchases.',
      );
      return;
    }

    if (!provider.canOwnMonetizationFor(userId)) {
      AdaptiveMessages.showError(
        messenger?.context ?? navigator.context,
        'Restore requires a secure signed-in account that can prove '
        'ownership of the App Store or Google Play subscription.',
      );
      return;
    }

    _showRestoreStatus('Verifying subscription…', autoClear: false);

    final restored = await provider.restorePurchases(userId);

    if (!mounted) return;

    if (restored) {
      _showRestoreStatus('Subscription verified — Premium is active.');

      AdaptiveMessages.showSuccess(
        messenger?.context ?? navigator.context,
        '✅ Purchases restored successfully!',
      );
      // Keep paywall visible after successful restore.
    } else {
      final restoreError = provider.restoreOwnershipErrorMessage;

      if (restoreError != null) {
        _showRestoreStatus(restoreError, autoClear: false);
        AdaptiveMessages.showError(
          messenger?.context ?? navigator.context,
          restoreError,
        );
      } else {
        _showRestoreStatus(
          'No subscription found to restore.',
          autoClear: false,
        );
        AdaptiveMessages.showInfo(
          messenger?.context ?? navigator.context,
          'No purchases found to restore',
        );
      }
    }
  }
}

Future<String?> _resolveCurrentUserId(AppStateService appState) async {
  final auth = appState.auth;
  if (!auth.isInitialized) {
    await auth.initialize();
  }

  final currentUser = await auth.getCurrentUser();
  if (currentUser == null) return null;

  final uid = _readStringProperty(currentUser, 'uid');
  if (uid != null) return uid;

  return _readStringProperty(currentUser, 'id');
}

String? _readStringProperty(Object source, String propertyName) {
  try {
    final dynamic user = source;
    final Object? value = propertyName == 'uid' ? user.uid : user.id;
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }
  } catch (_) {
    return null;
  }

  return null;
}

class _PremiumPinnedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final bool isPremium;
  final double minHeaderExtent;
  final double maxHeaderExtent;

  const _PremiumPinnedHeaderDelegate({
    required this.isPremium,
    required this.minHeaderExtent,
    required this.maxHeaderExtent,
  });

  @override
  double get minExtent => minHeaderExtent;

  @override
  double get maxExtent => maxHeaderExtent;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final theme = Theme.of(context);

    final subtitleFontSize = MediaQuery.sizeOf(context).width >= 400.0
        ? 15.0
        : 14.0;

    final range = (maxExtent - minExtent).clamp(1.0, double.infinity);
    final progress = (shrinkOffset / range).clamp(0.0, 1.0);

    double lerp(double expanded, double collapsed) {
      return expanded + ((collapsed - expanded) * progress);
    }

    final badgeSize = lerp(92, 46);

    // Fade the subtitle completely before reducing its layout height.
    // This prevents partially clipped text during pinned-header collapse.
    final subtitleOpacity = (1.0 - (progress * 4.0)).clamp(0.0, 1.0);
    final subtitleHeightFactor = progress <= 0.25
        ? 1.0
        : ((1.0 - progress) / 0.75).clamp(0.0, 1.0);

    final titleStyle = TextStyle.lerp(
      PremiumHeaderTypography.expanded(context),
      PremiumHeaderTypography.collapsed(context),
      progress,
    );

    return Material(
      // Pinned content scrolls behind this header. The paint surface must
      // therefore remain fully opaque so underlying Premium cards cannot
      // bleed through the collapsed header.
      color: theme.colorScheme.surface,
      elevation: overlapsContent ? 1 : 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary.withValues(alpha: 0.08),
              theme.colorScheme.secondary.withValues(alpha: 0.06),
            ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 64),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: badgeSize,
                height: badgeSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade400, Colors.amber.shade700],
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.workspace_premium,
                  size: badgeSize * 0.52,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: lerp(14, 6)),
              Text(
                isPremium ? 'Premium Active' : 'Unlock Premium',
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: titleStyle,
              ),
              ClipRect(
                child: Align(
                  heightFactor: subtitleHeightFactor,
                  child: Opacity(
                    opacity: subtitleOpacity,
                    child: Padding(
                      padding: EdgeInsets.only(top: lerp(8, 0)),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          isPremium
                              ? 'Premium Subscription Active'
                              : 'Access Unlimited Premium Features',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          softWrap: false,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: subtitleFontSize,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.68,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PremiumPinnedHeaderDelegate oldDelegate) {
    return oldDelegate.isPremium != isPremium ||
        oldDelegate.minHeaderExtent != minHeaderExtent ||
        oldDelegate.maxHeaderExtent != maxHeaderExtent;
  }
}

class _Feature {
  final IconData icon;
  final String title;
  final String description;
  final bool highlight;

  _Feature({
    required this.icon,
    required this.title,
    required this.description,
    this.highlight = false,
  });
}
