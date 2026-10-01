import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String source;
  late String active;

  setUpAll(() {
    source = File(
      'lib/features/premium/screens/premium_paywall_screen.dart',
    ).readAsStringSync();

    final start = source.indexOf('Widget _buildActiveSubscriptionDetails(');
    expect(start, greaterThanOrEqualTo(0));

    final nextMethod = source.indexOf('\n  Widget _', start + 20);

    active = nextMethod < 0
        ? source.substring(start)
        : source.substring(start, nextMethod);
  });

  test('Premium geometry remains centrally adaptive', () {
    expect(source, contains('double _premiumVerticalDensity('));
    expect(source, contains('double _premiumAdaptiveGap('));
    expect(source, contains('double _premiumHorizontalPadding('));

    expect(source, isNot(contains('Platform.isAndroid')));
    expect(source, isNot(contains('Platform.isIOS')));
  });

  test('approved subscription hierarchy remains ordered', () {
    final title = active.indexOf("'Current subscription'");
    final badge = active.indexOf('Icons.verified_rounded');
    final plan = active.indexOf('Text(\n                  planText');
    final expiry = active.indexOf("'Active until \$expiryText'");
    final manage = active.indexOf("'Manage Subscription'");
    final restore = active.indexOf('_buildRestorePurchasesButton(');

    expect(title, greaterThanOrEqualTo(0));
    expect(badge, greaterThan(title));
    expect(plan, greaterThan(badge));
    expect(expiry, greaterThan(plan));
    expect(manage, greaterThan(expiry));
    expect(restore, greaterThan(manage));

    expect(active, contains('size: 42'));
  });

  test('approved action cluster stays compact', () {
    expect(active, contains('compact: 0'));
    expect(active, contains('comfortable: 2'));
  });

  test('legal footer remains complete', () {
    expect(
      source,
      contains('Subscription automatically renews unless canceled.'),
    );
    expect(
      source,
      contains('Subscription automatically renews unless canceled.'),
    );
    expect(source, contains("label: 'Privacy Policy'"));
    expect(source, contains("label: 'Terms of Use'"));
    expect(source, contains('https://flowai-demo-project.web.app/privacy.html'));
    expect(
      source,
      contains(
        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
      ),
    );
  });

  test('Premium retains shared spring physics', () {
    expect(source, contains('BouncingScrollPhysics'));
    expect(source, contains('AlwaysScrollableScrollPhysics'));
  });

  test('free Premium catalog uses adaptive vertical density', () {
    expect(source, contains('_premiumAdaptiveGap('));
    expect(source, contains('compact: 14'));
    expect(source, contains('compact: 12'));
  });

  test('same-day entitlement expiry exposes verified local time', () {
    expect(source, contains('String _formatPremiumExpiry('));
    expect(source, contains('final expiresToday ='));
    expect(source, contains("return '\$date, \$time';"));
  });

  test('active Premium uses the shared root-level post-action gap', () {
    final normalized = source.replaceAll(RegExp(r'\s+'), ' ');

    expect(
      normalized,
      isNot(
        contains(
          'if (isPremium) ...[ KeyedSubtree( child: _buildActiveSubscriptionDetails',
        ),
      ),
    );

    final buildStart = source.indexOf('Widget build(BuildContext context)');
    final activeStart = source.indexOf(
      'Widget _buildActiveSubscriptionDetails(',
    );
    final rootGap = source.indexOf('_premiumPostActionRootGap(', buildStart);
    final restore = source.indexOf('_buildRestorePurchasesButton(', rootGap);

    expect(buildStart, greaterThanOrEqualTo(0));
    expect(rootGap, greaterThan(buildStart));
    expect(activeStart, greaterThan(rootGap));
    expect(restore, greaterThan(rootGap));

    final nextMethod = source.indexOf('\n  Widget _', activeStart + 20);
    final activeBlock = nextMethod < 0
        ? source.substring(activeStart)
        : source.substring(activeStart, nextMethod);

    expect(activeBlock, isNot(contains('_premiumPostActionRootGap(')));
  });
}

// C4/C8 physical-truth extension:
// Free paywall uses centralized viewport density rather than fixed
// Android/iOS geometry, and same-day verified expiry includes local time.
