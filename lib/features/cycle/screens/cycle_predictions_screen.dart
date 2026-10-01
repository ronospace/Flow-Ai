import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/cycle_calculation_engine.dart';
import '../providers/cycle_provider.dart';

class CyclePredictionsScreen extends StatelessWidget {
  const CyclePredictionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prediction = context.watch<CycleProvider>().predictions;

    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Predictions')),
      body: prediction == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Prediction unavailable. More recorded cycle history is needed before Flow Ai can calculate a personal prediction.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : _PredictionContent(prediction: prediction),
    );
  }
}

class _PredictionContent extends StatelessWidget {
  const _PredictionContent({required this.prediction});

  final CyclePredictions prediction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidencePercent = (prediction.confidence.score * 100).round();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _PredictionTile(
          label: 'Next period',
          value: _formatDate(prediction.nextPeriodDate),
        ),
        _PredictionTile(
          label: 'Cycle length',
          value: '${prediction.cycleLength} days',
        ),
        _PredictionTile(label: 'Confidence', value: '$confidencePercent%'),
        _PredictionTile(
          label: 'Cycle regularity',
          value: _formatEnum(prediction.cycleRegularity.name),
        ),
        _PredictionTile(
          label: 'Current phase',
          value: _formatEnum(prediction.currentPhase.name),
        ),
        if (prediction.ovulationDate != null)
          _PredictionTile(
            label: 'Estimated ovulation',
            value: _formatDate(prediction.ovulationDate!),
          ),
        _PredictionTile(
          label: 'Fertile window',
          value:
              '${_formatDate(prediction.fertileWindowStart)} – ${_formatDate(prediction.fertileWindowEnd)}',
        ),
        const SizedBox(height: 12),
        Text(
          'Predictions are estimates based on recorded cycle history and can change as more data is recorded.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.'
        '${date.month.toString().padLeft(2, '0')}.'
        '${date.year}';
  }

  static String _formatEnum(String value) {
    if (value.isEmpty) return 'Unavailable';
    return value
        .replaceAllMapped(
          RegExp(r'([a-z])([A-Z])'),
          (match) => '${match.group(1)} ${match.group(2)}',
        )
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}${word.substring(1)}',
        )
        .join(' ');
  }
}

class _PredictionTile extends StatelessWidget {
  const _PredictionTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
