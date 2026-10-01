import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flow_ai/core/identity/active_account_scope.dart';
import 'package:flow_ai/core/services/enhanced_ai_chat_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final chat = EnhancedAIChatService();
  var activeUserId = 'user_a';

  setUp(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    activeUserId = 'user_a';
    ActiveAccountScope.instance.configure(() async => activeUserId);
    await chat.resetSession();
  });

  tearDown(() async {
    await chat.resetSession();
  });

  test('chat rejects a claimed owner that is not the active account', () async {
    await expectLater(
      chat.initialize(userId: 'user_b', userName: 'User B'),
      throwsStateError,
    );
  });

  test('account switch clears prior account UI state', () async {
    await chat.initialize(userId: 'user_a', userName: 'User A');

    await chat.sendMessage(
      types.TextMessage(
        author: const types.User(id: 'user_a'),
        id: 'a-private-message',
        text: 'alpha_private_marker',
      ),
    );

    expect(
      chat.messages.whereType<types.TextMessage>().any(
        (message) => message.text.contains('alpha_private_marker'),
      ),
      isTrue,
    );

    activeUserId = 'user_b';

    await chat.initialize(userId: 'user_b', userName: 'User B');

    expect(chat.currentUser?.id, 'user_b');

    expect(
      chat.messages.whereType<types.TextMessage>().any(
        (message) =>
            message.author.id == 'user_a' ||
            message.text.contains('alpha_private_marker'),
      ),
      isFalse,
    );
  });

  test('account-scoped persistence never writes A data into B keys', () async {
    await chat.initialize(userId: 'user_a', userName: 'User A');

    await chat.sendMessage(
      types.TextMessage(
        author: const types.User(id: 'user_a'),
        id: 'a-storage-message',
        text: 'alpha_storage_marker',
      ),
    );

    final prefsAfterA = await SharedPreferences.getInstance();
    final aHistory =
        prefsAfterA.getString('ai_conversation_history_user_a') ?? '';

    expect(aHistory, contains('alpha_storage_marker'));

    activeUserId = 'user_b';

    await chat.initialize(userId: 'user_b', userName: 'User B');

    await chat.sendMessage(
      types.TextMessage(
        author: const types.User(id: 'user_b'),
        id: 'b-storage-message',
        text: 'beta_storage_marker',
      ),
    );

    final prefsAfterB = await SharedPreferences.getInstance();
    final bHistory =
        prefsAfterB.getString('ai_conversation_history_user_b') ?? '';

    expect(bHistory, contains('beta_storage_marker'));
    expect(bHistory, isNot(contains('alpha_storage_marker')));
  });

  test('in-flight A response cannot mutate B session after switch', () async {
    await chat.initialize(userId: 'user_a', userName: 'User A');

    final pending = chat.sendMessage(
      types.TextMessage(
        author: const types.User(id: 'user_a'),
        id: 'a-inflight-message',
        text: 'Explain artificial intelligence in several sentences please',
      ),
    );

    await Future<void>.delayed(const Duration(milliseconds: 20));

    activeUserId = 'user_b';

    await chat.initialize(userId: 'user_b', userName: 'User B');

    await pending;

    expect(chat.currentUser?.id, 'user_b');

    expect(
      chat.messages.whereType<types.TextMessage>().any(
        (message) => message.author.id == 'user_a',
      ),
      isFalse,
    );
  });
}
