import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final auth = File(
    'lib/features/auth/screens/auth_screen.dart',
  ).readAsStringSync();

  test('form does not share a flutter_animate controller', () {
    expect(auth, isNot(contains('_formController')));
    expect(auth, isNot(contains('.animate(controller: _formController)')));
  });

  test('form keeps independent animate effects', () {
    expect(auth, contains('.animate()'));
    expect(auth, contains('.slideY('));
    expect(auth, contains('.fadeIn('));
  });

  test('header animation retains its dedicated controller', () {
    expect(auth, contains('_headerController'));
    expect(auth, contains('.animate(controller: _headerController)'));
  });
}
