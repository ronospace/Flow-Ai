import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

Future<void> initAds() async {
  if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
    
    await MobileAds.instance.initialize();
  }
}
