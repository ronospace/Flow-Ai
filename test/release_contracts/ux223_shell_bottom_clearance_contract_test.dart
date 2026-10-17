import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final tracking = File(
    'lib/features/cycle/screens/tracking_screen.dart',
  ).readAsStringSync();

  final settings = File(
    'lib/features/settings/screens/settings_screen.dart',
  ).readAsStringSync();

  final partner = File(
    'lib/features/partner/screens/partner_dashboard_screen.dart',
  ).readAsStringSync();

  final faq = File(
    'lib/features/insights/screens/faq_browser_screen.dart',
  ).readAsStringSync();

  final router = File('lib/core/routing/app_router.dart').readAsStringSync();

  test('MainShell remains the persistent bottom-navigation owner', () {
    expect(router, contains('bottomNavigationBar: SafeArea('));
    expect(router, contains('height: AppLayout.bottomNavigationHeight'));
  });

  test('shell children do not duplicate fixed 100px navigation clearance', () {
    expect(
      tracking,
      isNot(contains('const SizedBox(height: 100), // Extra bottom padding')),
    );

    expect(
      settings,
      isNot(contains('const SizedBox(height: 100), // Bottom spacing')),
    );

    expect(
      partner,
      isNot(
        contains('const SizedBox(height: 100), // Space for bottom navigation'),
      ),
    );
  });

  test('Settings keeps only tokenized bottom breathing space', () {
    expect(
      settings,
      contains(
        'height: AppTheme.spaceXl,\n'
        '                      ), // Bottom breathing space.',
      ),
    );
    expect(
      settings,
      isNot(contains('const SizedBox(height: 100), // Bottom spacing')),
    );
  });

  test('FAQ retains its screen-owned FAB clearance', () {
    expect(
      faq,
      contains('floatingActionButton: FloatingActionButton.extended('),
    );
    expect(
      faq,
      contains('const SliverToBoxAdapter(child: SizedBox(height: 100))'),
    );
  });
}
