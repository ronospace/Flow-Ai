import 'dart:async';

import 'package:flow_ai/core/services/app_state_service.dart';
import 'package:flow_ai/core/ui/adaptive_messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/subscription_models.dart';
import '../providers/subscription_provider.dart';

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
  BillingPeriod _selectedPeriod = BillingPeriod.yearly;
  final GlobalKey _subscriptionOptionsKey = GlobalKey();
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
      setState(() {
        _catalogLoading = false;
        _catalogMessage = 'Please sign in to load subscription plans.';
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
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Consumer<SubscriptionProvider>(
          builder: (context, subscriptionProvider, child) {
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
                        Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        Theme.of(
                          context,
                        ).colorScheme.secondary.withOpacity(0.1),
                      ],
                    ),
                  ),
                ),

                // Content
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // Close button
                            if (widget.showCloseButton)
                              Align(
                                alignment: Alignment.topRight,
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back_ios_new),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),

                            const SizedBox(height: 16),

                            // Crown icon
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.amber.shade400,
                                    Colors.amber.shade700,
                                  ],
                                ),
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                size: 64,
                                color: Colors.white,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // Title
                            Text(
                              'Unlock Premium',
                              style: Theme.of(context).textTheme.headlineLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),

                            const SizedBox(height: 8),

                            // Subtitle
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                'Get unlimited access to all premium features',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyLarge
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.7),
                                    ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // Premium features
                            _buildFeaturesList(context),

                            const SizedBox(height: 32),

                            // Subscription catalog
                            _buildCatalogSection(
                              context,
                              subscriptionProvider,
                              hasYearlyBillingOption,
                            ),

                            const SizedBox(height: 16),

                            // Restore purchases
                            TextButton(
                              onPressed: () => _restorePurchases(
                                context,
                                subscriptionProvider,
                              ),
                              child: const Text('Restore Purchases'),
                            ),

                            const SizedBox(height: 8),

                            // Terms and privacy
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                              ),
                              child: Text(
                                'Subscription automatically renews unless canceled. Terms and Privacy Policy apply.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurface.withOpacity(0.5),
                                    ),
                              ),
                            ),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Loading overlay
                if (subscriptionProvider.isLoading)
                  Container(
                    color: Colors.transparent,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeaturesList(BuildContext context) {
    final features = [
      _Feature(
        icon: Icons.auto_awesome,
        title: 'Unlimited AI Insights',
        description: 'Get personalized health insights anytime',
        highlight: widget.highlightFeature == 'insights',
      ),
      _Feature(
        icon: Icons.analytics,
        title: 'Advanced Analytics',
        description: 'Deep health condition detection & tracking',
        highlight: widget.highlightFeature == 'analytics',
      ),
      _Feature(
        icon: Icons.file_download,
        title: 'Export Your Data',
        description: 'Download reports in PDF or CSV format',
        highlight: widget.highlightFeature == 'export',
      ),
      _Feature(
        icon: Icons.block,
        title: 'Ad-Free Experience',
        description: 'Enjoy the app without interruptions',
        highlight: widget.highlightFeature == 'ad-free',
      ),
      _Feature(
        icon: Icons.support_agent,
        title: 'Priority Support',
        description: 'Get help faster when you need it',
        highlight: widget.highlightFeature == 'support',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: features.map((feature) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: feature.highlight
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: feature.highlight
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: feature.highlight ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
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
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withOpacity(0.7),
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
              color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
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
        const SizedBox(height: 24),
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
                setState(() {
                  _selectedPeriod = BillingPeriod.monthly;
                });
              },
            ),

          if (monthlyProduct != null && yearlyProduct != null)
            const SizedBox(height: 12),

          // Yearly option
          if (yearlyProduct != null)
            _buildSubscriptionOption(
              context,
              product: yearlyProduct,
              isSelected: _selectedPeriod == BillingPeriod.yearly,
              isPopular: true,
              savingsText: hasYearlyBillingOption ? 'Yearly billing' : null,
              onTap: () {
                setState(() {
                  _selectedPeriod = BillingPeriod.yearly;
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
    bool isPopular = false,
    String? savingsText,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline,
                  width: 2,
                ),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 16),

            // Product info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        product.billingPeriod == BillingPeriod.yearly
                            ? 'Yearly'
                            : 'Monthly',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      if (isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'YEARLY',
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  color: Colors.amber.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (savingsText != null)
                    Text(
                      savingsText,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.priceString,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                if (product.billingPeriod == BillingPeriod.yearly)
                  Text(
                    'Billed yearly by your app store',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
              ],
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
        onPressed: provider.isLoading
            ? null
            : () => _subscribe(context, provider, selectedProduct.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          minimumSize: const Size(double.infinity, 56),
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

    final result = await provider.purchaseSubscription(productId);

    if (!mounted) return;

    if (result.success) {
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(
            'Purchase started. Premium will activate after secure verification.',
          ),
        ),
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

    final restored = await provider.restorePurchases(userId);

    if (!mounted) return;

    if (restored) {
      AdaptiveMessages.showSuccess(
        messenger?.context ?? navigator.context,
        '✅ Purchases restored successfully!',
      );
      navigator.pop(true);
    } else {
      AdaptiveMessages.showInfo(
        messenger?.context ?? navigator.context,
        'No purchases found to restore',
      );
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
