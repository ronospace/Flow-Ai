import 'dart:ui';
import 'package:flutter/material.dart';
import 'partner_dialog_tokens.dart';

class PartnerDialogShell extends StatelessWidget {
  final Widget child;
  const PartnerDialogShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height * 0.78;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: PartnerDialogTokens.maxWidth,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            PartnerDialogTokens.radiusOuter,
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              constraints: BoxConstraints(maxHeight: h),
              padding: PartnerDialogTokens.shellPadding,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .72),
                borderRadius: BorderRadius.circular(
                  PartnerDialogTokens.radiusOuter,
                ),
                boxShadow: PartnerDialogTokens.shadow,
                border: Border.all(
                  color: Colors.white.withValues(alpha: .45),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
