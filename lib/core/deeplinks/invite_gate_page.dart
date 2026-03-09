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
    debugPrint('🔗 InviteGatePage _handleInvite start code=${widget.code}');
    if (!mounted || _handled) return;
    _handled = true;

    debugPrint('🔗 InviteGate: handling code=${widget.code}');

    AuthService? auth;
    try {
      auth = context.read<AuthService>();
    } catch (e) {
      debugPrint('❌ InviteGate: AuthService not found in context: $e');
    }

    final isAuthed = auth == null ? false : await auth.isAuthenticated;
    debugPrint('🔗 InviteGatePage isAuthed=$isAuthed');
    if (!mounted) return;

    if (!isAuthed) {
      debugPrint('🔗 InviteGate: not authed -> /auth/choice');
      context.go('/auth/choice');
      return;
    }

    debugPrint('🔗 InviteGate: authed -> showing JoinPartnerDialog');

    PartnerService? partnerService;
    try {
      partnerService = context.read<PartnerService>();
    } catch (e) {
      debugPrint('❌ InviteGate: PartnerService not found in context: $e');
    }

    debugPrint('🔗 InviteGatePage partnerService=' + (partnerService == null ? 'null' : 'ok'));

    if (partnerService == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Partner service unavailable. Please restart the app.'),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (_) => JoinPartnerDialog(
        initialCode: widget.code,
        onJoinWithCode: (c) async {
          await partnerService!.acceptPartnerInvitation(c);
        },
      ),
    );

    if (!mounted) return;
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔗 InviteGatePage built: code=${widget.code}');
    return Scaffold(body: Center(child: Text('Invite code: ${widget.code}')));
  }
}
