import 'package:flutter_test/flutter_test.dart';
import 'package:flow_ai/core/examples/personalization_example.dart';

void main() {
  test('demoPersonalization runs successfully', () async {
    final result = await demoPersonalization();
    
    expect(result.reminders.isNotEmpty, isTrue);
    expect(result.phaseNotification.title.isNotEmpty, isTrue);
    expect(result.phaseNotification.body.isNotEmpty, isTrue);
    
    // Verify some reminders have expected categories
    final categories = result.reminders.map((r) => r.category.name).toSet();
    expect(categories.contains('hydration'), isTrue);
    expect(categories.contains('movement'), isTrue);
    expect(categories.contains('sleep'), isTrue);
  });
}
