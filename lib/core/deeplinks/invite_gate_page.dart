import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../ui/adaptive_messages.dart';

import '../services/app_state_service.dart';
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


    final appState = AppStateService();
    final isAuthed = await appState.isUserAuthenticated();
    if (!mounted) return;

    if (!isAuthed) {
      context.go('/auth/choice');
      return;
    }


    PartnerService? partnerService;
    try {
      partnerService = context.read<PartnerService>();
    } catch (e) {
    }


    if (partnerService == null) {
      if (!mounted) return;
      AdaptiveMessages.showError(
        context,
        'Partner service unavailable. Please restart the app.',
      );
      return;
    }

    final partnership = await partnerService.acceptPartnerInvitation(
      widget.code,
    );

    if (!mounted) return;

    if (partnership != null) {
      Navigator.of(context).pop(true);
      return;
    }

    AdaptiveMessages.showError(
      context,
      'Invitation code invalid, expired, or not found.',
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
