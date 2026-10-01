import 'package:flow_ai/core/services/app_state_service.dart';
import 'package:flow_ai/core/services/auth_service.dart';
import 'package:flow_ai/features/premium/models/subscription_models.dart';
import 'package:flow_ai/features/premium/providers/subscription_provider.dart';
import 'package:flow_ai/features/premium/screens/premium_paywall_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _TestAuthService implements AuthService {
  @override
  bool get isInitialized => true;

  @override
  Future<void> initialize() async {}

  @override
  Future<dynamic> getCurrentUser() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _TestAppStateService implements AppStateService {
  final AuthService _auth = _TestAuthService();

  @override
  AuthService get auth => _auth;

  @override
  bool get isInitialized => true;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _GeometrySubscriptionProvider extends SubscriptionProvider {
  static const monthly = SubscriptionProduct(
    id: 'test.monthly',
    name: 'Flow Ai Premium',
    description: 'Monthly Premium subscription',
    tier: SubscriptionTier.premium,
    billingPeriod: BillingPeriod.monthly,
    price: 5.99,
    currency: 'EUR',
    priceString: '€5.99',
    features: <String>[],
  );

  static const yearly = SubscriptionProduct(
    id: 'test.yearly',
    name: 'Flow Ai Premium',
    description: 'Yearly Premium subscription',
    tier: SubscriptionTier.premium,
    billingPeriod: BillingPeriod.yearly,
    price: 47.99,
    currency: 'EUR',
    priceString: '€47.99',
    features: <String>[],
    isPopular: true,
  );

  @override
  List<SubscriptionProduct> get availableProducts =>
      const <SubscriptionProduct>[monthly, yearly];

  @override
  bool get isPremium => false;

  @override
  bool get isLoading => false;

  @override
  bool get isRestoring => false;

  @override
  String? get errorMessage => null;

  @override
  bool get hasDurableMonetizationIdentity => false;

  @override
  bool canOwnMonetizationFor(String userId) => false;

  @override
  SubscriptionProduct? getMonthlyProduct() => monthly;

  @override
  SubscriptionProduct? getYearlyProduct() => yearly;

  @override
  Future<void> initialize(String userId) async {}

  @override
  Future<void> loadStoreCatalog() async {}

  @override
  Future<void> refreshProducts(String userId) async {}
}

class _ViewportCase {
  final String name;
  final Size size;
  final double textScale;
  final EdgeInsets safePadding;
  final EdgeInsets rawViewPadding;

  const _ViewportCase(
    this.name,
    this.size,
    this.textScale, {
    this.safePadding = EdgeInsets.zero,
    this.rawViewPadding = EdgeInsets.zero,
  });
}

const _cases = <_ViewportCase>[
  _ViewportCase(
    'small_320x568',
    Size(320, 568),
    1.0,
    safePadding: EdgeInsets.only(top: 24, bottom: 16),
  ),
  _ViewportCase(
    'compact_360x640',
    Size(360, 640),
    1.0,
    safePadding: EdgeInsets.only(top: 24, bottom: 16),
  ),
  _ViewportCase(
    'standard_390x844',
    Size(390, 844),
    1.0,
    safePadding: EdgeInsets.only(top: 24, bottom: 16),
  ),
  _ViewportCase(
    'android_ref_411x914_edge_to_edge',
    Size(411.428571, 914.285714),
    1.1,
    safePadding: EdgeInsets.only(top: 32.380952, bottom: 14.857143),
    rawViewPadding: EdgeInsets.only(top: 32.380952, bottom: 14.857143),
  ),
  _ViewportCase(
    'tall_430x932',
    Size(430, 932),
    1.0,
    safePadding: EdgeInsets.only(top: 24, bottom: 16),
  ),
  _ViewportCase(
    'large_480x1040',
    Size(480, 1040),
    1.15,
    safePadding: EdgeInsets.only(top: 28, bottom: 20),
  ),
  _ViewportCase(
    'accessibility_390x844',
    Size(390, 844),
    1.3,
    safePadding: EdgeInsets.only(top: 24, bottom: 16),
  ),
];

Finder _text(String value) => find.text(value);

Rect _rect(WidgetTester tester, String text) {
  final finder = _text(text);
  expect(
    finder,
    findsOneWidget,
    reason: 'Expected exactly one "$text" widget.',
  );
  return tester.getRect(finder);
}

Rect _finderRect(WidgetTester tester, Finder finder, {required String label}) {
  expect(finder, findsOneWidget, reason: 'Expected exactly one $label widget.');
  return tester.getRect(finder);
}

List<Object> _drainExceptions(WidgetTester tester) {
  final errors = <Object>[];
  Object? error;

  while ((error = tester.takeException()) != null) {
    errors.add(error!);
  }

  return errors;
}

Future<void> _mountCase(
  WidgetTester tester,
  _ViewportCase viewport, {
  TargetPlatform? platform,
}) async {
  addTearDown(() {
    tester.view.resetPadding();
    tester.view.resetViewPadding();
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  tester.view.physicalSize = viewport.size;
  tester.view.devicePixelRatio = 1.0;

  tester.view.padding = FakeViewPadding(
    left: viewport.rawViewPadding.left,
    top: viewport.rawViewPadding.top,
    right: viewport.rawViewPadding.right,
    bottom: viewport.rawViewPadding.bottom,
  );

  tester.view.viewPadding = FakeViewPadding(
    left: viewport.rawViewPadding.left,
    top: viewport.rawViewPadding.top,
    right: viewport.rawViewPadding.right,
    bottom: viewport.rawViewPadding.bottom,
  );

  final appState = _TestAppStateService();
  final subscriptions = _GeometrySubscriptionProvider();

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        Provider<AppStateService>.value(value: appState),
        ChangeNotifierProvider<SubscriptionProvider>.value(
          value: subscriptions,
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(platform: platform),
        home: MediaQuery(
          data: MediaQueryData(
            size: viewport.size,
            padding: viewport.safePadding,
            viewPadding: viewport.safePadding,
            devicePixelRatio: 1.0,
            textScaler: TextScaler.linear(viewport.textScale),
          ),
          child: const PremiumPaywallScreen(),
        ),
      ),
    ),
  );

  // Initial layout + paywall animation + post-frame catalog no-op.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 900));
  await tester.pump();

  final initialErrors = _drainExceptions(tester);

  expect(
    initialErrors,
    isEmpty,
    reason:
        '${viewport.name}: initial render produced Flutter exceptions: '
        '$initialErrors',
  );
}

Future<void> _unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump();

  final errors = _drainExceptions(tester);
  expect(
    errors,
    isEmpty,
    reason: 'Unmount must not hide asynchronous exceptions: $errors',
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  tearDown(() {
    final binding = TestWidgetsFlutterBinding.instance;
    binding.platformDispatcher.clearAllTestValues();
  });

  for (final viewport in _cases) {
    testWidgets('free Premium geometry is responsive: ${viewport.name}', (
      tester,
    ) async {
      await _mountCase(tester, viewport);

      expect(_text('Unlock Premium'), findsOneWidget);
      expect(_text('Unlimited AI Insights'), findsOneWidget);
      expect(_text('Advanced Analytics'), findsOneWidget);
      expect(_text('Export Your Data'), findsOneWidget);
      expect(_text('Start Premium'), findsOneWidget);

      final unlock = _rect(tester, 'Unlock Premium');

      final unlimited = _finderRect(
        tester,
        find.byKey(const ValueKey('premium-feature-unlimited-ai-insights')),
        label: 'Unlimited AI Insights feature card',
      );

      final subtitle = _rect(tester, 'Access Unlimited Premium Features');

      final analytics = _finderRect(
        tester,
        find.byKey(const ValueKey('premium-feature-advanced-analytics')),
        label: 'Advanced Analytics feature card',
      );

      final export = _finderRect(
        tester,
        find.byKey(const ValueKey('premium-feature-export-your-data')),
        label: 'Export Your Data feature card',
      );
      final monthlyInitial = _finderRect(
        tester,
        find.byKey(const ValueKey('subscription-option-test.monthly')),
        label: 'Monthly subscription card',
      );
      final yearlyInitial = _finderRect(
        tester,
        find.byKey(const ValueKey('subscription-option-test.yearly')),
        label: 'Yearly subscription card',
      );

      expect(
        unlock.bottom,
        lessThan(unlimited.top),
        reason: '${viewport.name}: header/features overlap.',
      );
      expect(
        unlimited.bottom,
        lessThan(analytics.top),
        reason: '${viewport.name}: feature cards overlap.',
      );
      expect(
        analytics.bottom,
        lessThan(export.top),
        reason: '${viewport.name}: feature cards overlap.',
      );

      // Capture only geometry that must exist at scroll origin.
      // Restore Purchases is allowed to live in a lazy downstream sliver.
      final startInitial = _finderRect(
        tester,
        find.ancestor(
          of: _text('Start Premium'),
          matching: find.byType(ElevatedButton),
        ),
        label: 'Start Premium button',
      );

      final safeTop = viewport.safePadding.top;
      final safeBottom = viewport.size.height - viewport.safePadding.bottom;

      final startInitiallyFullyVisible =
          startInitial.top >= safeTop && startInitial.bottom <= safeBottom;

      final topGap = unlimited.top - subtitle.bottom;
      final bottomGap = safeBottom - startInitial.bottom;

      expect(
        topGap,
        greaterThan(0),
        reason: '${viewport.name}: header/features spacing collapsed.',
      );

      if (startInitiallyFullyVisible) {
        expect(
          bottomGap,
          greaterThanOrEqualTo(0),
          reason: '${viewport.name}: Start Premium is clipped at origin.',
        );
      }

      expect(
        startInitial.width,
        greaterThan(0),
        reason: '${viewport.name}: Start Premium collapsed.',
      );
      expect(
        startInitial.height,
        greaterThan(0),
        reason: '${viewport.name}: Start Premium collapsed.',
      );

      final scrollable = find.byType(Scrollable).first;
      expect(scrollable, findsOneWidget);

      final scrollState = tester.state<ScrollableState>(scrollable);
      final position = scrollState.position;

      final initialPixels = position.pixels;
      final maxScrollExtent = position.maxScrollExtent;

      expect(
        initialPixels,
        equals(0),
        reason: '${viewport.name}: test did not begin at scroll origin.',
      );

      expect(
        maxScrollExtent,
        greaterThanOrEqualTo(0),
        reason: '${viewport.name}: invalid scroll extent.',
      );

      await tester.ensureVisible(_text('Start Premium'));
      await tester.pumpAndSettle();

      final startReached = _finderRect(
        tester,
        find.ancestor(
          of: _text('Start Premium'),
          matching: find.byType(ElevatedButton),
        ),
        label: 'Start Premium button after scroll',
      );

      expect(
        startReached.bottom,
        lessThanOrEqualTo(safeBottom + 0.5),
        reason: '${viewport.name}: Start Premium is not reachable.',
      );

      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('restore-purchases-idle')),
        160,
        scrollable: scrollable,
        maxScrolls: 30,
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('restore-purchases-idle')),
        findsOneWidget,
        reason:
            '${viewport.name}: Restore Purchases was not built '
            'after scrolling.',
      );

      final restoreReached = _finderRect(
        tester,
        find.ancestor(
          of: find.byKey(const ValueKey('restore-purchases-idle')),
          matching: find.byType(TextButton),
        ),
        label: 'Restore Purchases button after scroll',
      );

      expect(
        restoreReached.bottom,
        lessThanOrEqualTo(safeBottom + 0.5),
        reason: '${viewport.name}: Restore Purchases is not reachable.',
      );

      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();

      final finalErrors = _drainExceptions(tester);

      expect(
        finalErrors,
        isEmpty,
        reason:
            '${viewport.name}: scrolling/full composition produced '
            'Flutter exceptions: $finalErrors',
      );

      print(
        'PREMIUM_GEOMETRY '
        'case=${viewport.name} '
        'size=${viewport.size.width}x${viewport.size.height} '
        'textScale=${viewport.textScale.toStringAsFixed(2)} '
        'unlock=${unlock.top.toStringAsFixed(1)}..'
        '${unlock.bottom.toStringAsFixed(1)} '
        'unlimited=${unlimited.top.toStringAsFixed(1)}..'
        '${unlimited.bottom.toStringAsFixed(1)} '
        'analytics=${analytics.top.toStringAsFixed(1)}..'
        '${analytics.bottom.toStringAsFixed(1)} '
        'export=${export.top.toStringAsFixed(1)}..'
        '${export.bottom.toStringAsFixed(1)} '
        'monthlyInitial=${monthlyInitial.top.toStringAsFixed(1)}..'
        '${monthlyInitial.bottom.toStringAsFixed(1)} '
        'yearlyInitial=${yearlyInitial.top.toStringAsFixed(1)}..'
        '${yearlyInitial.bottom.toStringAsFixed(1)} '
        'safe=${safeTop.toStringAsFixed(1)}..'
        '${safeBottom.toStringAsFixed(1)} '
        'startInitial=${startInitial.top.toStringAsFixed(1)}..'
        '${startInitial.bottom.toStringAsFixed(1)} '
        'startVisible=$startInitiallyFullyVisible '
        'restoreReached=${restoreReached.top.toStringAsFixed(1)}..'
        '${restoreReached.bottom.toStringAsFixed(1)} '
        'initialScroll=${initialPixels.toStringAsFixed(1)} '
        'maxScroll=${maxScrollExtent.toStringAsFixed(1)}',
      );

      await _unmount(tester);
    });
  }

  testWidgets('plan cards physically change selected state when tapped', (
    tester,
  ) async {
    final viewport = _cases.firstWhere(
      (item) => item.name == 'standard_390x844',
    );

    await _mountCase(tester, viewport);

    final monthly = find.byKey(
      const ValueKey('subscription-option-test.monthly'),
    );
    final yearly = find.byKey(
      const ValueKey('subscription-option-test.yearly'),
    );

    expect(monthly, findsOneWidget);
    expect(yearly, findsOneWidget);

    // Yearly is the production default.
    expect(
      find.descendant(of: yearly, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );
    expect(
      find.descendant(of: monthly, matching: find.byIcon(Icons.check)),
      findsNothing,
    );

    await tester.ensureVisible(monthly);
    await tester.pump();

    await tester.tap(monthly);
    await tester.pump();

    expect(
      find.descendant(of: monthly, matching: find.byIcon(Icons.check)),
      findsOneWidget,
      reason: 'Monthly tap must visibly select Monthly.',
    );
    expect(
      find.descendant(of: yearly, matching: find.byIcon(Icons.check)),
      findsNothing,
      reason: 'Monthly tap must deselect Yearly.',
    );

    await tester.ensureVisible(yearly);
    await tester.pump();

    await tester.tap(yearly);
    await tester.pump();

    expect(
      find.descendant(of: yearly, matching: find.byIcon(Icons.check)),
      findsOneWidget,
      reason: 'Yearly tap must visibly re-select Yearly.',
    );
    expect(
      find.descendant(of: monthly, matching: find.byIcon(Icons.check)),
      findsNothing,
      reason: 'Yearly tap must deselect Monthly.',
    );

    await _unmount(tester);
  });

  testWidgets('iOS plan cards change selected state when tapped', (
    tester,
  ) async {
    final viewport = _cases.firstWhere(
      (item) => item.name == 'standard_390x844',
    );

    await _mountCase(tester, viewport, platform: TargetPlatform.iOS);

    final monthly = find.byKey(
      const ValueKey('subscription-option-test.monthly'),
    );
    final yearly = find.byKey(
      const ValueKey('subscription-option-test.yearly'),
    );

    expect(monthly, findsOneWidget);
    expect(yearly, findsOneWidget);

    expect(
      find.descendant(of: yearly, matching: find.byIcon(Icons.check)),
      findsOneWidget,
    );

    await tester.ensureVisible(monthly);
    await tester.pump();

    await tester.tap(monthly);
    await tester.pump();

    expect(
      find.descendant(of: monthly, matching: find.byIcon(Icons.check)),
      findsOneWidget,
      reason: 'iOS Monthly tap must visibly select Monthly.',
    );

    expect(
      find.descendant(of: yearly, matching: find.byIcon(Icons.check)),
      findsNothing,
      reason: 'iOS Monthly tap must deselect Yearly.',
    );

    await tester.ensureVisible(yearly);
    await tester.pump();

    await tester.tap(yearly);
    await tester.pump();

    expect(
      find.descendant(of: yearly, matching: find.byIcon(Icons.check)),
      findsOneWidget,
      reason: 'iOS Yearly tap must visibly re-select Yearly.',
    );

    expect(
      find.descendant(of: monthly, matching: find.byIcon(Icons.check)),
      findsNothing,
      reason: 'iOS Yearly tap must deselect Monthly.',
    );

    await _unmount(tester);
  });
}
