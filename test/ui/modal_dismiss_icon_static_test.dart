import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'modal and sheet dismiss controls use down chevrons instead of X icons',
    () {
      final modalMarkers = <String>[
        'showModalBottomSheet',
        'showDialog',
        'AlertDialog',
        'Dialog(',
        'BottomSheet',
        'DraggableScrollableSheet',
        'Modal',
        'Medical Sources',
        'Sources',
      ];

      final dismissMarkers = <String>[
        'Navigator.pop',
        'Navigator.of(context).pop',
        '.pop(context)',
        'maybePop',
        'onClose',
        'dismiss',
        'Dismiss',
        'close',
        'Close',
      ];

      final excludeMarkers = <String>[
        'delete',
        'Delete',
        'remove',
        'Remove',
        'selected-symptom-remove',
        'chip',
        'Chip',
        'tag',
        'Tag',
        'clear',
        'Clear',
        'cancel',
        'Cancel',
      ];

      final closeIconPattern = RegExp(r'Icons\.(close|close_rounded)\b');
      final libDir = Directory('lib');

      final failures = <String>[];

      for (final entity in libDir.listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }

        final source = entity.readAsStringSync();
        if (!source.contains('Icons.close')) {
          continue;
        }

        final fileHasModalContext = modalMarkers.any(source.contains);
        if (!fileHasModalContext) {
          continue;
        }

        for (final match in closeIconPattern.allMatches(source)) {
          final start = match.start;
          final windowStart = start - 900 < 0 ? 0 : start - 900;
          final windowEnd = start + 900 > source.length
              ? source.length
              : start + 900;
          final window = source.substring(windowStart, windowEnd);

          final hasDismissContext = dismissMarkers.any(window.contains);
          final hasExcludedContext = excludeMarkers.any(window.contains);

          if (hasDismissContext && !hasExcludedContext) {
            final line = '\n'.allMatches(source.substring(0, start)).length + 1;
            failures.add('${entity.path}:$line ${match.group(0)}');
          }
        }
      }

      expect(
        failures,
        isEmpty,
        reason:
            'Modal/sheet dismiss controls should use Icons.keyboard_arrow_down_rounded. '
            'Keep X only for true remove/delete/clear actions.',
      );
    },
  );
}
