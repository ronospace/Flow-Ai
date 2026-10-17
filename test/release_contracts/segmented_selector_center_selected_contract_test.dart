import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_ai/core/ui/app_segmented_selector.dart';

Finder capsuleFor(String label) {
  return find.ancestor(of: find.text(label), matching: find.byType(InkWell));
}

void main() {
  testWidgets(
    'centerSelected centers middle capsules and clamps edge capsules',
    (tester) async {
      final selected = ValueNotifier<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 320,
                child: ValueListenableBuilder<int>(
                  valueListenable: selected,
                  builder: (context, index, _) {
                    return AppSegmentedSelector(
                      labels: const [
                        'Flow',
                        'Symptoms',
                        'Mood',
                        'Pain',
                        'Notes',
                      ],
                      icons: const [
                        Icons.water_drop,
                        Icons.health_and_safety,
                        Icons.mood,
                        Icons.healing,
                        Icons.note_alt,
                      ],
                      selectedIndex: index,
                      centerSelected: true,
                      onSelected: (value) => selected.value = value,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final viewport = find.byType(Scrollable);
      final viewportCenter = tester.getRect(viewport).center.dx;

      selected.value = 2;
      await tester.pump();
      await tester.pumpAndSettle();

      final moodCenter = tester.getRect(capsuleFor('Mood')).center.dx;

      expect((moodCenter - viewportCenter).abs(), lessThan(1.0));

      selected.value = 4;
      await tester.pump();
      await tester.pumpAndSettle();

      final position = tester.state<ScrollableState>(viewport).position;

      expect((position.pixels - position.maxScrollExtent).abs(), lessThan(1.0));

      selected.value = 0;
      await tester.pump();
      await tester.pumpAndSettle();

      expect(position.pixels.abs(), lessThan(1.0));
    },
  );
}
