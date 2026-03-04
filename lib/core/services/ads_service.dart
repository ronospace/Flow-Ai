import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> initAds() async {
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: <String>['SIMULATOR']),
      );
    }
    await MobileAds.instance.initialize();
  }
}
