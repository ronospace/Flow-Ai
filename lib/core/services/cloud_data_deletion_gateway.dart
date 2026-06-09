import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

typedef CloudDeleteInvoker =
    Future<Object?> Function(String name, Map<String, dynamic> data);

typedef CurrentCloudUserId = String? Function();

class CloudDataDeletionGateway {
  CloudDataDeletionGateway({
    CurrentCloudUserId? currentUserId,
    CloudDeleteInvoker? invoke,
  }) : _currentUserId =
           currentUserId ?? (() => FirebaseAuth.instance.currentUser?.uid),
       _invoke = invoke ?? _defaultInvoke;

  final CurrentCloudUserId _currentUserId;
  final CloudDeleteInvoker _invoke;

  static Future<Object?> _defaultInvoke(
    String name,
    Map<String, dynamic> data,
  ) async {
    final callable = FirebaseFunctions.instance.httpsCallable(name);
    final result = await callable.call<Map<String, dynamic>>(data);
    return result.data;
  }

  Future<int> deleteCurrentUserCloudData() async {
    final uid = _currentUserId();
    if (uid == null || uid.trim().isEmpty) {
      throw StateError('Cloud data deletion is temporarily unavailable.');
    }

    final response = await _invoke('deleteMyCloudData', const {});

    if (response is! Map) {
      throw StateError('Cloud data deletion returned an invalid response.');
    }

    if (response['ok'] != true) {
      throw StateError('Cloud data deletion could not be confirmed.');
    }

    final deletedDocuments = response['deletedDocuments'];
    return deletedDocuments is int ? deletedDocuments : 0;
  }
}
