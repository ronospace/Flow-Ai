import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = File(
    'lib/features/premium/screens/premium_paywall_screen.dart',
  ).readAsStringSync();

  test('subtitle fades before pinned header collapses its height', () {
    final normalized = source.replaceAll(RegExp(r'\s+'), ' ');

    expect(
      normalized,
      contains(
        'final subtitleOpacity = (1.0 - (progress * 4.0)).clamp(0.0, 1.0);',
      ),
    );

    expect(
      normalized,
      contains(
        'final subtitleHeightFactor = progress <= 0.25 ? 1.0 : '
        '((1.0 - progress) / 0.75).clamp(0.0, 1.0);',
      ),
    );

    expect(normalized, contains('heightFactor: subtitleHeightFactor'));

    expect(normalized, contains('opacity: subtitleOpacity'));

    expect(source, isNot(contains('heightFactor: 1.0 - progress')));

    expect(source, isNot(contains('opacity: 1.0 - progress')));
  });

  test('physical top composition band preserves accepted iPhone geometry', () {
    final normalized = source.replaceAll(RegExp(r'\s+'), ' ');

    expect(normalized, contains('const acceptedTopBandRatio = 243.0 / 844.0;'));

    expect(
      normalized,
      contains('final safeTop = view.viewPadding.top / view.devicePixelRatio;'),
    );

    expect(
      normalized,
      contains(
        'return (physicalTopBand - safeTop).clamp(196.0, 232.0).toDouble();',
      ),
    );

    expect(normalized, contains('const maxComfortableTopBand = 243.0;'));
    expect(
      normalized,
      contains(
        'final physicalTopBand = proportionalTopBand.clamp( 0.0, maxComfortableTopBand, );',
      ),
    );

    expect(source, isNot(contains('Platform.isAndroid')));
    expect(source, isNot(contains('TargetPlatform.android')));
  });

  test('Premium header is pinned and collapsible', () {
    expect(source, contains('SliverPersistentHeader('));
    expect(source, contains('pinned: true'));
    expect(source, contains('_PremiumPinnedHeaderDelegate'));
    expect(source, contains("'Unlock Premium'"));
    expect(source, contains('Icons.workspace_premium'));
    expect(source, contains('shrinkOffset'));
  });

  test('subscription cards use one clean information hierarchy', () {
    expect(
      source,
      contains("final duration = isYearly ? '12 months' : '1 month'"),
    );
    expect(source, contains('product.priceString'));
    expect(source, isNot(contains("'YEARLY'")));
    expect(source, isNot(contains('Yearly billing')));
    expect(source, isNot(contains('Billed yearly by your app store')));
  });

  test('Apple legal links remain clearly discoverable', () {
    expect(source, contains("'premium-legal-card'"));
    expect(source, contains("'Privacy Policy'"));
    expect(source, contains("label: 'Terms of Use'"));
    expect(source, contains('Icons.keyboard_arrow_down_rounded'));
    expect(source, contains('https://flowai-demo-project.web.app/privacy.html'));
    expect(
      source,
      contains(
        'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
      ),
    );
  });

  test(
    'Premium header geometry stays responsive rather than device-specific',
    () {
      expect(source, contains('_premiumPinnedHeaderMinExtent'));
      expect(source, contains('_premiumPinnedHeaderMaxExtent'));
      expect(source, contains('MediaQuery.sizeOf(context).height'));
    },
  );

  test(
    'pinned Premium header paints an opaque surface over scrolling content',
    () {
      expect(source, contains('color: theme.colorScheme.surface,'));

      expect(source, isNot(contains('alpha: overlapsContent ? 0.98 : 0.94')));

      expect(source, contains('elevation: overlapsContent ? 1 : 0'));
    },
  );
}
