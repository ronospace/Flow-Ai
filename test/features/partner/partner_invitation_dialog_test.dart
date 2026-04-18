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

  testWidgets('Email validation shows required error for empty input', (tester) async {
    await tester.pumpWidget(
      wrap(
        PartnerInvitationDialog(
          partnerService: PartnerService(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.ensureVisible(find.textContaining('Send').first);
    await tester.tap(find.textContaining('Send').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Please enter an email address'), findsOneWidget);
  });

  testWidgets('Email validation rejects malformed email', (tester) async {
    await tester.pumpWidget(
      wrap(
        PartnerInvitationDialog(
          partnerService: PartnerService(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('invite_email_field')),
      'bad-email',
    );
    await tester.ensureVisible(find.textContaining('Send').first);
    await tester.tap(find.textContaining('Send').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Please enter a valid email address'), findsOneWidget);
  });

  testWidgets('Email validation detects typo domain', (tester) async {
    await tester.pumpWidget(
      wrap(
        PartnerInvitationDialog(
          partnerService: PartnerService(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('invite_email_field')),
      'user@gmail.co',
    );
    await tester.ensureVisible(find.textContaining('Send').first);
    await tester.tap(find.textContaining('Send').first, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Did you mean .com?'), findsOneWidget);
  });

  testWidgets('Valid email does not show validation errors', (tester) async {
    await tester.pumpWidget(
      wrap(
        PartnerInvitationDialog(
          partnerService: PartnerService(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('invite_email_field')),
      'user@example.com',
    );
    await tester.ensureVisible(find.textContaining('Send').first);
    await tester.tap(find.textContaining('Send').first, warnIfMissed: false);
    await tester.pump();

    expect(find.text('Please enter an email address'), findsNothing);
    expect(find.text('Please enter a valid email address'), findsNothing);
    expect(find.text('Did you mean .com?'), findsNothing);
  });
}
