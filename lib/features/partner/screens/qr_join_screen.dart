import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class QrJoinScreen extends StatefulWidget {
  const QrJoinScreen({super.key});

  @override
  State<QrJoinScreen> createState() => _QrJoinScreenState();
}

class _QrJoinScreenState extends State<QrJoinScreen> {

  bool scanned = false;

  void handleCode(String code) {
    if (scanned) return;

    final raw = code.trim();

    String? normalizedCode;

    // Prefer real invite links like /invite/ABC123
    final linkMatch = RegExp(r'/invite/([A-Z0-9]{6})', caseSensitive: false)
        .firstMatch(raw);
    if (linkMatch != null) {
      normalizedCode = linkMatch.group(1)!.toUpperCase();
    } else {
      // Fallback: plain 6-char code only
      final plainMatch = RegExp(r'^[A-Z0-9]{6}$', caseSensitive: false)
          .firstMatch(raw);
      if (plainMatch != null) {
        normalizedCode = plainMatch.group(0)!.toUpperCase();
      }
    }

    if (normalizedCode == null || normalizedCode == 'INVITE') return;

    scanned = true;

    if (mounted) {
      context.push('/invite/$normalizedCode');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Partner QR")),
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
        ),
        onDetect: (capture) {
          final String? code = capture.barcodes.first.rawValue;
          if (code != null) {
            handleCode(code);
          }
        },
      ),
    );
  }
}
