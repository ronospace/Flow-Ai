import 'dart:io';

import 'package:flow_ai/core/constants/app_layout.dart';
import 'package:flow_ai/core/theme/app_theme.dart';
import 'package:flow_ai/core/widgets/modern_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class SaveActionHarness extends StatelessWidget {
  const SaveActionHarness({
    super.key,
    required this.visible,
    required this.brightness,
    required this.scale,
    required this.width,
  });

  final bool visible;
  final Brightness brightness;
  final double scale;
  final double width;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 844),
          textScaler: TextScaler.linear(scale),
          disableAnimations: true,
        ),
        child: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: AnimatedSize(
              key: const ValueKey('action-area'),
              duration: AppTheme.motionFast,
              child: visible
                  ? Padding(
                      key: const ValueKey('action-padding'),
                      padding: AppLayout.bottomActionPadding,
                      child: ModernButton(
                        key: const ValueKey('action-button'),
                        text: 'Save Changes',
                        onPressed: () {},
                        icon: Icons.save_rounded,
                        type: ModernButtonType.primary,
                        size: ModernButtonSize.medium,
                        isExpanded: true,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  test('Track Save state appears on edits and hides after saving', () {
    final source = File(
      'lib/features/cycle/screens/tracking_screen.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('_hasUnsavedChanges || _isSaving || _recentlySaved'),
    );
    expect(source, contains('Timer(const Duration(milliseconds: 1000)'));
    expect(source, contains('_recentlySaved = false'));
    expect(source, isNot(contains('fadeIn(delay: 500.ms)')));
  });

  const widths = [360.0, 390.0, 420.0, 440.0];
  const scales = [1.0, 1.3, 2.0];
  const themes = [Brightness.light, Brightness.dark];

  for (final width in widths) {
    for (final scale in scales) {
      for (final brightness in themes) {
        testWidgets(
          'Save action $width scale $scale $brightness is exactly 60px',
          (tester) async {
            tester.view.physicalSize = Size(width, 844);
            tester.view.devicePixelRatio = 1;

            addTearDown(tester.view.resetPhysicalSize);
            addTearDown(tester.view.resetDevicePixelRatio);

            await tester.pumpWidget(
              SaveActionHarness(
                visible: true,
                brightness: brightness,
                scale: scale,
                width: width,
              ),
            );
            await tester.pump(const Duration(milliseconds: 250));

            final area = tester.getSize(
              find.byKey(const ValueKey('action-area')),
            );
            final padding = tester.getSize(
              find.byKey(const ValueKey('action-padding')),
            );
            final button = tester.getSize(
              find.byKey(const ValueKey('action-button')),
            );

            expect(button.height, 44);
            expect(padding.height, 60);
            expect(area.height, 60);
            expect(tester.takeException(), isNull);

            await tester.pumpWidget(
              SaveActionHarness(
                visible: false,
                brightness: brightness,
                scale: scale,
                width: width,
              ),
            );
            await tester.pump(const Duration(milliseconds: 250));

            expect(
              tester.getSize(find.byKey(const ValueKey('action-area'))).height,
              0,
            );
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
