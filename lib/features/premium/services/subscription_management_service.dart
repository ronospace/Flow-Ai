import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

abstract final class SubscriptionManagementService {
  static final Uri _androidSubscriptions = Uri.parse(
    'https://play.google.com/store/account/subscriptions'
    '?package=com.flowai.app',
  );

  static final Uri _appleSubscriptions = Uri.parse(
    'https://apps.apple.com/account/subscriptions',
  );

  static void open() {
    unawaited(_openForCurrentPlatform());
  }

  static Future<void> _openForCurrentPlatform() async {
    final uri = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => _appleSubscriptions,
      _ => _androidSubscriptions,
    };

    final openedExternally = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!openedExternally) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }
}
