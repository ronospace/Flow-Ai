import 'package:flutter/material.dart';

class InviteGatePage extends StatelessWidget {
  final String code;

  const InviteGatePage({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Invite code: $code'),
      ),
    );
  }
}
