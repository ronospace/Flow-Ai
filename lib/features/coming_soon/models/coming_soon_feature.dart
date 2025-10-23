import 'package:flutter/material.dart';

/// Coming Soon Feature model
class ComingSoonFeature {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;
  final Color color;
  final DateTime estimatedRelease;
  final FeatureStatus status;
  final List<String> features;

  const ComingSoonFeature({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
    required this.color,
    required this.estimatedRelease,
    required this.status,
    required this.features,
  });
}

/// Feature development status
enum FeatureStatus {
  planning('Planning', Color(0xFF9575CD)),
  inDevelopment('In Development', Color(0xFF42A5F5)),
  testing('Testing', Color(0xFFFFA726)),
  comingSoon('Coming Soon', Color(0xFF66BB6A));

  const FeatureStatus(this.displayName, this.color);
  
  final String displayName;
  final Color color;
}
