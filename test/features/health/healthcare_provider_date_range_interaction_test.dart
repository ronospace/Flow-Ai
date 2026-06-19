import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_ai/features/healthcare/screens/healthcare_provider_portal_screen.dart';

void main() {
  testWidgets('all export date ranges respond and retain selection', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(600, 932));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: HealthcareProviderPortalScreen()),
    );
    await tester.pumpAndSettle();

    const labels = [
      'Last 3 Months',
      'Last 6 Months',
      'Last 12 Months',
      'All Time',
    ];

    for (final selected in labels) {
      final target = find.byKey(ValueKey<String>('date-range-$selected'));
      expect(target, findsOneWidget);

      await tester.ensureVisible(target);
      await tester.tap(target);
      await tester.pumpAndSettle();

      for (final label in labels) {
        final chip = tester.widget<FilterChip>(
          find.byKey(ValueKey<String>('date-range-$label')),
        );
        expect(chip.selected, label == selected);
      }
      expect(tester.takeException(), isNull);
    }
  });
}
