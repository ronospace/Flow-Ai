import 'package:flow_ai/features/partner/services/local_partner_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('LocalPartnerService compiles with its local user dependency', () {
    expect(LocalPartnerService(), same(LocalPartnerService()));
  });
}
