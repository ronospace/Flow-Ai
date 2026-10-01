import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final exportService = File(
    'lib/core/services/data_export_service.dart',
  ).readAsStringSync();

  final settings = File(
    'lib/features/settings/screens/settings_screen.dart',
  ).readAsStringSync();

  final analytics = File(
    'lib/features/analytics/screens/enhanced_analytics_dashboard_screen.dart',
  ).readAsStringSync();

  test('PDF and CSV exports are execution-time Premium gated', () {
    expect(exportService, contains('format == ExportFormat.pdf'));
    expect(exportService, contains('format == ExportFormat.csv'));
    expect(exportService, contains('SubscriptionService()'));
    expect(exportService, contains('subscription.isPremium'));
    expect(
      exportService,
      contains('subscription.canAccessFeature(PremiumFeature.dataExport)'),
    );
  });

  test('premium export ownership is revalidated across async execution', () {
    expect(
      exportService,
      contains('ActiveAccountScope.instance.requireUserId()'),
    );
    expect(
      exportService,
      contains('ActiveAccountScope.instance.requireOwnership(expectedUserId)'),
    );
    expect(exportService, contains('_revalidatePremiumExportAccess'));
    expect(exportService, contains('_deleteGeneratedFileIfPresent'));
  });

  test('JSON remains available for personal data portability', () {
    expect(exportService, contains('case ExportFormat.json:'));
    expect(
      exportService,
      contains('format == ExportFormat.pdf || format == ExportFormat.csv'),
    );
  });

  test('Settings and Analytics provide Premium UX before execution', () {
    expect(settings, contains('checkPremiumAccess('));
    expect(analytics, contains('checkPremiumAccess('));
    expect(analytics, contains('PDF and CSV analytics exports'));
  });
}
