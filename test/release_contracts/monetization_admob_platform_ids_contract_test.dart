import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production AdMob IDs remain bound to the correct platform', () {
    final source = File(
      'lib/core/services/admob_service.dart',
    ).readAsStringSync();

    const androidIds = <String>[
      'ca-app-pub-8707491489514576/5736358977',
      'ca-app-pub-8707491489514576/7416449761',
      'ca-app-pub-8707491489514576/3438849765',
      'ca-app-pub-8707491489514576/3748489887',
      'ca-app-pub-8707491489514576/5061571550',
      'ca-app-pub-8707491489514576/6804213858',
    ];

    const iosIds = <String>[
      'ca-app-pub-8707491489514576/7498939737',
      'ca-app-pub-8707491489514576/9591267529',
      'ca-app-pub-8707491489514576/8812021403',
      'ca-app-pub-8707491489514576/2837639998',
      'ca-app-pub-8707491489514576/8114534323',
      'ca-app-pub-8707491489514576/7894240148',
    ];

    for (final id in androidIds) {
      expect(source, contains(id));
    }

    for (final id in iosIds) {
      expect(source, contains(id));
    }

    expect(
      source,
      contains(
        'Platform.isAndroid ? _androidBannerAdUnitId : _iosBannerAdUnitId',
      ),
    );

    expect(
      source,
      contains(
        "Platform.isAndroid\n"
        "      ? _androidInterstitialAdUnitId\n"
        "      : _iosInterstitialAdUnitId",
      ),
    );

    expect(
      source,
      contains(
        'Platform.isAndroid ? _androidRewardedAdUnitId : _iosRewardedAdUnitId',
      ),
    );
  });
}
