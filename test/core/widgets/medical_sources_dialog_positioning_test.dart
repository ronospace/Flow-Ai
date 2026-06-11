import 'package:flow_ai/core/constants/app_layout.dart';
import 'package:flow_ai/core/theme/app_theme.dart';
import 'package:flow_ai/core/widgets/medical_sources_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> measureCase(
    WidgetTester tester, {
    required String name,
    required Size size,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;

    final navigatorKey = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: Scaffold(
          body: const SizedBox.expand(),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              key: ValueKey<String>('bottom-nav-carrier-$name'),
              height: AppLayout.bottomNavigationHeight,
              alignment: Alignment.center,
              child: const Text('Home Calendar Track Insights Health Settings'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    showMedicalSourcesDialog(navigatorKey.currentContext!);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    final screenSize = tester.view.physicalSize / tester.view.devicePixelRatio;
    final navRect = tester.getRect(
      find.byKey(ValueKey<String>('bottom-nav-carrier-$name')),
    );
    final dialogShellRect = tester.getRect(
      find.byKey(const ValueKey<String>('medical-sources-dialog-shell')),
    );

    final leftMargin = dialogShellRect.left;
    final rightMargin = screenSize.width - dialogShellRect.right;
    final bottomGapToNavTop = navRect.top - dialogShellRect.bottom;
    final overlapIntoNavCarrier = dialogShellRect.bottom - navRect.top;

    print(
      'POSITION name=$name screen_width=${screenSize.width.toStringAsFixed(1)}',
    );
    print(
      'POSITION name=$name screen_height=${screenSize.height.toStringAsFixed(1)}',
    );
    print('POSITION name=$name nav_top=${navRect.top.toStringAsFixed(1)}');
    print(
      'POSITION name=$name nav_height=${navRect.height.toStringAsFixed(1)}',
    );
    print(
      'POSITION name=$name dialog_left=${dialogShellRect.left.toStringAsFixed(1)}',
    );
    print(
      'POSITION name=$name dialog_top=${dialogShellRect.top.toStringAsFixed(1)}',
    );
    print(
      'POSITION name=$name dialog_right=${dialogShellRect.right.toStringAsFixed(1)}',
    );
    print(
      'POSITION name=$name dialog_bottom=${dialogShellRect.bottom.toStringAsFixed(1)}',
    );
    print(
      'POSITION name=$name dialog_width=${dialogShellRect.width.toStringAsFixed(1)}',
    );
    print(
      'POSITION name=$name dialog_height=${dialogShellRect.height.toStringAsFixed(1)}',
    );
    print(
      'POSITION name=$name dialog_left_margin=${leftMargin.toStringAsFixed(1)}',
    );
    print(
      'POSITION name=$name dialog_right_margin=${rightMargin.toStringAsFixed(1)}',
    );
    print(
      'POSITION name=$name bottom_gap_to_nav_top=${bottomGapToNavTop.toStringAsFixed(1)}',
    );
    print(
      'POSITION name=$name overlap_into_nav_carrier=${overlapIntoNavCarrier.toStringAsFixed(1)}',
    );

    expect(leftMargin, closeTo(16.0, 0.1));
    expect(rightMargin, closeTo(16.0, 0.1));
    expect(bottomGapToNavTop, greaterThanOrEqualTo(15.9));
    expect(overlapIntoNavCarrier, lessThanOrEqualTo(-15.9));
    expect(tester.takeException(), isNull);

    navigatorKey.currentState!.pop();
    await tester.pumpAndSettle();
  }

  testWidgets('Medical Sources dialog stays above bottom nav carrier', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await measureCase(
      tester,
      name: 'compact_360x780',
      size: const Size(360, 780),
    );

    await measureCase(
      tester,
      name: 'iphone_air_390x844',
      size: const Size(390, 844),
    );

    await measureCase(
      tester,
      name: 'large_430x932',
      size: const Size(430, 932),
    );
  });
}
