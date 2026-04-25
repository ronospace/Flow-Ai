import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:flow_ai/core/deeplinks/invite_gate_page.dart';

class QrJoinScreen extends StatefulWidget {
  const QrJoinScreen({super.key});

  @override
  State<QrJoinScreen> createState() => _QrJoinScreenState();
}

class _QrJoinScreenState extends State<QrJoinScreen> {
  bool scanned = false;

  Future<void> handleCode(String code) async {
    if (scanned) return;

    final raw = code.trim();

    String? normalizedCode;

    // Prefer real invite links like /invite/ABC123
    final linkMatch = RegExp(
      r'/invite/([A-Z0-9]{6})',
      caseSensitive: false,
    ).firstMatch(raw);
    if (linkMatch != null) {
      normalizedCode = linkMatch.group(1)!.toUpperCase();
    } else {
      // Fallback: plain 6-char code only
      final plainMatch = RegExp(
        r'^[A-Z0-9]{6}$',
        caseSensitive: false,
      ).firstMatch(raw);
      if (plainMatch != null) {
        normalizedCode = plainMatch.group(0)!.toUpperCase();
      }
    }

    if (normalizedCode == null || normalizedCode == 'INVITE') return;

    scanned = true;

    if (mounted) {
      final joined = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => InviteGatePage(code: normalizedCode!),
        ),
      );
      if (!mounted) return;

      if (joined == true) {
        Navigator.of(context).pop(true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text("Scan Partner QR"),
      ),
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
