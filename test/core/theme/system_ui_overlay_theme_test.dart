import 'dart:io';

import 'package:flow_ai/core/theme/system_ui_overlay_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SystemUiOverlayTheme', () {
    test('light surfaces use dark Android and iOS system glyphs', () {
      final style = SystemUiOverlayTheme.forBrightness(Brightness.light);

      expect(style.statusBarIconBrightness, Brightness.dark);
      expect(style.statusBarBrightness, Brightness.light);
      expect(style.systemNavigationBarIconBrightness, Brightness.dark);
      expect(style.statusBarColor, Colors.transparent);
      expect(style.systemNavigationBarColor, Colors.transparent);
    });

    test('dark surfaces use light Android and iOS system glyphs', () {
      final style = SystemUiOverlayTheme.forBrightness(Brightness.dark);

      expect(style.statusBarIconBrightness, Brightness.light);
      expect(style.statusBarBrightness, Brightness.dark);
      expect(style.systemNavigationBarIconBrightness, Brightness.light);
      expect(style.statusBarColor, Colors.transparent);
      expect(style.systemNavigationBarColor, Colors.transparent);
    });

    test('entry points use the centralized policy', () {
      final main = File('lib/main.dart').readAsStringSync();
      final platform = File(
        'lib/core/services/platform_service.dart',
      ).readAsStringSync();

      expect(main.contains('SystemUiOverlayTheme.forBrightness'), isTrue);
      expect(platform.contains('SystemUiOverlayTheme.forBrightness'), isTrue);
      expect(main.contains('SystemUiOverlayStyle('), isFalse);
      expect(platform.contains('SystemUiOverlayStyle('), isFalse);
      expect(
        main.contains(
          'brightness: isDark ? Brightness.dark : Brightness.light',
        ),
        isTrue,
      );
      expect(main.contains('scaffoldBackgroundColor: isDark'), isTrue);
    });
  });
}
