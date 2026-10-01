import 'dart:io';

import 'package:flow_ai/core/identity/active_account_scope.dart';
import 'package:flow_ai/features/partner/services/local_partner_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('LocalPartnerService requires canonical authenticated ownership', () {
    final source = File(
      'lib/features/partner/services/local_partner_service.dart',
    ).readAsStringSync();

    expect(source, contains('ActiveAccountScope.instance.requireUserId()'));

    expect(
      source,
      isNot(contains("'user_\${DateTime.now().millisecondsSinceEpoch}'")),
    );

    expect(source, isNot(contains("'current_user_id'")));
    expect(source, isNot(contains("'current_user_name'")));
    expect(source, isNot(contains("'current_user_email'")));
  });

  test('created local invitation is owned by active account', () async {
    SharedPreferences.setMockInitialValues({});

    ActiveAccountScope.instance.configure(() async => 'partner-test-user-a');

    final service = LocalPartnerService();
    await service.initialize();

    final invitation = await service.createPartnerInvitation(
      personalMessage: 'Authenticated invitation',
    );

    expect(invitation.inviterId, 'partner-test-user-a');
    expect(invitation.inviterId, isNot(startsWith('user_')));
  });
}
