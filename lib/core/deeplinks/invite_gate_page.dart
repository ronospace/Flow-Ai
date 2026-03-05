import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../../features/partner/dialogs/join_partner_dialog.dart';
import '../../features/partner/services/partner_service.dart';

class InviteGatePage extends StatefulWidget {
  final String code;

  const InviteGatePage({super.key, required this.code});

  @override
  State<InviteGatePage> createState() => _InviteGatePageState();
}

class _InviteGatePageState extends State<InviteGatePage> {
  bool _handled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleInvite();
    });
  }

  Future<void> _handleInvite() async {
    if (!mounted || _handled) return;
    _handled = true;

    final auth = context.read<AuthService>();
    final isAuthed = await auth.isAuthenticated;

    if (!mounted) return;

    if (!isAuthed) {
      context.go('/auth/choice');
      return;
    }

    final partnerService = context.read<PartnerService>();

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => JoinPartnerDialog(
        initialCode: widget.code,
        onJoinWithCode: (c) async {
          await partnerService.acceptPartnerInvitation(c);
        },
      ),
    );

    if (!mounted) return;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Invite code: ${widget.code}'),
      ),
    );
  }
}
