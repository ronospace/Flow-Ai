import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flow_ai/features/partner/widgets/partner_invitation_dialog.dart';
import 'package:flow_ai/features/partner/services/partner_service.dart';
import 'package:flow_ai/generated/app_localizations.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets('Partner invitation dialog renders tabs', (tester) async {
    await tester.pumpWidget(
      wrap(
        PartnerInvitationDialog(
          partnerService: PartnerService(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.byType(TabBarView), findsOneWidget);
    expect(find.textContaining('Email'), findsWidgets);
    expect(find.textContaining('QR'), findsWidgets);
    expect(find.textContaining('Link'), findsWidgets);
  });

  testWidgets('Can switch to QR and Link tabs', (tester) async {
    await tester.pumpWidget(
      wrap(
        PartnerInvitationDialog(
          partnerService: PartnerService(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('QR').first);
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Link').first);
    await tester.pumpAndSettle();

    expect(find.byType(TabBarView), findsOneWidget);
  });
}
