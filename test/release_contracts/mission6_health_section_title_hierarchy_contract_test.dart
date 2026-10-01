import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final header = File(
    'lib/features/health/widgets/health_section_header.dart',
  ).readAsStringSync();

  final card = File(
    'lib/features/health/widgets/healthkit_connection_card.dart',
  ).readAsStringSync();

  final health = File(
    'lib/features/health/screens/health_screen.dart',
  ).readAsStringSync();

  test('shared Health section hierarchy is centralized', () {
    expect(header, contains('Icon(icon, size: 24'));
    expect(header, contains('theme.textTheme.titleLarge'));
    expect(header, contains('FontWeight.bold'));
    expect(header, contains('return Wrap('));
    expect(header, isNot(contains('TextOverflow.ellipsis')));
    expect(header, isNot(contains('maxLines: 1')));
  });

  test('connection card keeps its intentional independent title hierarchy', () {
    final pos = card.indexOf('platformName,');
    expect(pos, greaterThanOrEqualTo(0));

    final end = (pos + 450).clamp(0, card.length);
    final segment = card.substring(pos, end);

    expect(segment, contains('theme.textTheme.titleMedium'));
    expect(segment, contains('FontWeight.bold'));
    expect(segment, isNot(contains('theme.textTheme.titleLarge')));
  });

  test('Data Coverage delegates heading style to HealthSectionHeader', () {
    final titlePos = health.indexOf("title: 'Data Coverage'");
    expect(titlePos, greaterThanOrEqualTo(0));

    final ownerPos = health.lastIndexOf('HealthSectionHeader(', titlePos);

    expect(ownerPos, greaterThanOrEqualTo(0));
    expect(titlePos - ownerPos, lessThan(500));
  });

  test(
    'Biometric Monitoring delegates heading style to HealthSectionHeader',
    () {
      final titlePos = health.indexOf("title: 'Biometric Monitoring'");
      expect(titlePos, greaterThanOrEqualTo(0));

      final ownerPos = health.lastIndexOf('HealthSectionHeader(', titlePos);

      expect(ownerPos, greaterThanOrEqualTo(0));
      expect(titlePos - ownerPos, lessThan(500));
    },
  );
}
