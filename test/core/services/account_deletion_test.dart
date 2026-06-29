import 'package:flow_ai/core/services/local_user_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('local account deletion removes account and active session', () async {
    SharedPreferences.setMockInitialValues({});

    final service = LocalUserService();
    await service.initialize();

    await service.createUser(
      email: 'deletion-test@flowai.local',
      password: 'StrongPassword123!',
      displayName: 'Deletion Test',
    );

    final currentUser = await service.getCurrentUser();
    expect(currentUser, isNotNull);

    final deleted = await service.deleteUser(currentUser!.uid);

    expect(deleted, isTrue);
    expect(await service.getCurrentUser(), isNull);
    expect(await service.getUserByEmail('deletion-test@flowai.local'), isNull);
  });
}
