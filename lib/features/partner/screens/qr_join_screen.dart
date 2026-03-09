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
    if (!RegExp(r"^[A-Z2-9]{6}$").hasMatch(code)) return;
    scanned = true;

    if (mounted) {
      context.go('/invite/$code');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Partner QR")),
      body: MobileScanner(
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
