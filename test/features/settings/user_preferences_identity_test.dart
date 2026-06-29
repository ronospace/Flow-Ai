import 'package:flow_ai/features/settings/models/user_preferences.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('profile and greeting names survive preference serialization', () {
    final preferences = UserPreferences(
      userId: 'uid-1',
      displayName: 'Mohameth Gueye',
      greetingName: 'Mohameth',
      lastUpdated: DateTime.utc(2026, 6, 24),
    );

    final restored = UserPreferences.fromJson(preferences.toJson());

    expect(restored.displayName, 'Mohameth Gueye');
    expect(restored.greetingName, 'Mohameth');
  });

  test('legacy preferences without greetingName remain readable', () {
    final preferences = UserPreferences(
      userId: 'uid-1',
      displayName: 'Leah Brown',
      lastUpdated: DateTime.utc(2026, 6, 24),
    ).toJson()..remove('greetingName');

    final restored = UserPreferences.fromJson(preferences);

    expect(restored.displayName, 'Leah Brown');
    expect(restored.greetingName, isEmpty);
  });
}
