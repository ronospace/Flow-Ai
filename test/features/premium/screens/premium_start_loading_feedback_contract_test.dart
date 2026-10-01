import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final paywall = File(
    'lib/features/premium/screens/premium_paywall_screen.dart',
  ).readAsStringSync();

  test(
    'Start Premium never fails silently while subscription state is loading',
    () {
      expect(
        paywall,
        isNot(
          contains(
            'onPressed: provider.isLoading\n'
            '            ? null',
          ),
        ),
      );

      expect(paywall, contains("if (provider.isLoading) {"));

      expect(
        paywall,
        contains("'Verifying your existing subscription. Please wait.'"),
      );

      expect(
        paywall,
        contains("'Subscription setup is still finishing. Please wait.'"),
      );
    },
  );

  test(
    'checkout still delegates to authoritative provider after loading ends',
    () {
      expect(
        paywall,
        contains(
          'unawaited(_subscribe(context, provider, selectedProduct.id));',
        ),
      );
    },
  );
}
