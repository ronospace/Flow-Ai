import 'package:flow_ai/core/services/admob_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('production ads stay disabled in debug tests', () async {
    expect(AdMobService.adsEnabled, isFalse);
    expect(AdMobService.canLoadAds, isFalse);

    await AdMobService.initialize();

    expect(AdMobService.canLoadAds, isFalse);
  });
}
