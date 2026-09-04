import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('M5.8B clinical reporting has only a fail-closed production path', () {
    final source = File(
      'lib/features/clinical/services/'
      'clinical_intelligence_service.dart',
    ).readAsStringSync();

    final start = source.indexOf(
      'Future<ClinicalReport> generateClinicalReport',
    );

    expect(start, greaterThanOrEqualTo(0));

    final exportStart = source.indexOf(
      'Future<String> exportClinicalReport',
      start,
    );

    final end = exportStart >= 0 ? exportStart : source.length;

    final body = source.substring(start, end);

    expect(body.contains('throw ClinicalException('), isTrue);

    expect(body.contains('return ClinicalReport('), isFalse);

    for (final forbidden in <String>[
      '_getCycleClinicalData',
      '_getSymptomClinicalData',
      '_getBiometricClinicalData',
      '_getBehavioralClinicalData',
      '_performClinicalAnalysis',
      '_generateRiskAssessments',
      '_generateClinicalRecommendations',
      '_generateMedicalInsights',
      '_performTrendAnalysis',
      '_performCorrelationAnalysis',
      '_assessDepressionRisk',
      '_assessPCOSRisk',
      '_assessCardiovascularRisk',
      '_calculateRiskProbability',
      'correlation: 0.72',
      'correlation: -0.45',
      'evidenceScore: 0.',
      'confidence: 0.',
    ]) {
      expect(
        source.contains(forbidden),
        isFalse,
        reason: 'Unsupported clinical behavior survived: $forbidden',
      );
    }

    final lower = source.toLowerCase();

    for (final forbidden in <String>[
      'mock',
      'fake',
      'dummy',
      'simulated',
      'sample data',
    ]) {
      expect(lower.contains(forbidden), isFalse);
    }
  });
}
