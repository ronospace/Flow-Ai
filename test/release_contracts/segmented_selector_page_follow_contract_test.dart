import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flow_ai/core/ui/app_segmented_selector.dart';

void main() {
  testWidgets(
    'selected capsule becomes visible when page selection moves beyond viewport',
    (tester) async {
      final selected = ValueNotifier<int>(0);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 220,
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
                      selectedIndex: index,
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

      selected.value = 4;
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Notes').hitTestable(), findsOneWidget);
    },
  );
}
