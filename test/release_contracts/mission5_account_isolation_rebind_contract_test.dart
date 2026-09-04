import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('private persistence is live-account scoped', () {
    final core = File(
      'lib/core/database/database_service.dart',
    ).readAsStringSync();
    final feelings = File(
      'lib/features/tracking/services/feelings_database_service.dart',
    ).readAsStringSync();
    final cycle = File(
      'lib/core/services/real_cycle_service.dart',
    ).readAsStringSync();
    final tracker = File(
      'lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart',
    ).readAsStringSync();

    expect(core, contains("id = ? AND user_id = ?"));
    expect(core, contains("user_id = ? AND start_date >= ?"));
    expect(core, contains("user_id = ? AND timestamp < ?"));
    expect(core, isNot(contains("String whereClause = '1=1'")));

    expect(feelings, isNot(contains("'current_user'")));
    expect(feelings, contains("id = ? AND user_id = ?"));
    expect(feelings, contains("user_id = ? AND expires_at IS NOT NULL"));

    expect(cycle, contains("ActiveAccountScope.instance.requireUserId()"));
    expect(cycle, isNot(contains("userId: 'unknown'")));
    expect(tracker, isNot(contains("userId: 'current_user'")));
  });
}
