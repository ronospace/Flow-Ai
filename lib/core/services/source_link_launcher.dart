import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

bool isSupportedSourceUrl(String value) {
  final uri = Uri.tryParse(value);

  return uri != null &&
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.isNotEmpty;
}

Future<void> launchSourceLink(BuildContext context, String value) async {
  if (!isSupportedSourceUrl(value)) {
    _showLaunchFailure(context);
    return;
  }

  try {
    final launched = await launchUrl(
      Uri.parse(value),
      mode: LaunchMode.externalApplication,
    );

    if (!launched && context.mounted) {
      _showLaunchFailure(context);
    }
  } catch (_) {
    if (context.mounted) {
      _showLaunchFailure(context);
    }
  }
}

void _showLaunchFailure(BuildContext context) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    const SnackBar(content: Text('Unable to open this source right now.')),
  );
}
