import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

/// Authenticated client for the isolated Flow AI receipt service.
///
/// Each protected request uses a Firebase ID token. The backend derives
/// entitlement ownership exclusively from the verified token; this client
/// never submits a UID as trusted request data.
class ReceiptValidationService {
  ReceiptValidationService({FirebaseAuth? auth, http.Client? httpClient})
    : _authOverride = auth,
      _httpClient = httpClient ?? http.Client();

  static const String _serviceBaseUrl = String.fromEnvironment(
    'FLOW_AI_RECEIPT_SERVICE_BASE_URL',
    defaultValue: 'https://flow-ai-receipt-service-v2-ylrxu2v7qq-uc.a.run.app',
  );

  static const Duration _requestTimeout = Duration(seconds: 15);

  final FirebaseAuth? _authOverride;
  final http.Client _httpClient;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;

  String? get authenticatedUserId => _auth.currentUser?.uid;

  bool get hasDurableMonetizationIdentity {
    final user = _auth.currentUser;
    final uid = user?.uid.trim();

    return user != null && !user.isAnonymous && uid != null && uid.isNotEmpty;
  }

  bool canOwnMonetizationFor(String userId) {
    final normalizedUserId = userId.trim();

    return normalizedUserId.isNotEmpty &&
        hasDurableMonetizationIdentity &&
        authenticatedUserId == normalizedUserId;
  }

  bool isAuthenticatedUser(String userId) {
    return canOwnMonetizationFor(userId);
  }

  bool get canValidateAppleReceipts => _hasSecureServiceBaseUrl;

  bool get canValidateGooglePlayReceipts => _hasSecureServiceBaseUrl;

  bool get canValidateSubscriptionStatus => _hasSecureServiceBaseUrl;

  bool get _hasSecureServiceBaseUrl {
    final uri = Uri.tryParse(_serviceBaseUrl.trim());

    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty;
  }

  Future<ReceiptValidationResult> validateAppleReceipt({
    required String productId,
    required String transactionId,
    required bool isProduction,
  }) async {
    final uri = _routeUri(const <String>['v1', 'receipts', 'apple']);

    if (uri == null) {
      return const ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Secure receipt validation is not configured',
      );
    }

    try {
      final response = await _postAuthenticated(uri, <String, dynamic>{
        'environment': isProduction ? 'production' : 'sandbox',
        'productId': productId,
        'transactionId': transactionId,
      });

      return _parseValidationResponse(response);
    } catch (_) {
      return const ReceiptValidationResult(
        isValid: false,
        errorMessage: 'App Store validation request failed',
      );
    }
  }

  Future<ReceiptValidationResult> validateGooglePlayReceipt({
    required String purchaseToken,
    required String productId,
    required String packageName,
  }) async {
    final uri = _routeUri(const <String>['v1', 'receipts', 'google']);

    if (uri == null) {
      return const ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Secure receipt validation is not configured',
      );
    }

    try {
      final response = await _postAuthenticated(uri, <String, dynamic>{
        'purchaseToken': purchaseToken,
        'productId': productId,
        'packageName': packageName,
      });

      return _parseValidationResponse(response);
    } catch (_) {
      return const ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Google Play validation request failed',
      );
    }
  }

  Future<SubscriptionStatusProjection?> fetchSubscriptionStatus({
    required String subscriptionId,
  }) async {
    final normalizedId = subscriptionId.trim();

    if (normalizedId.isEmpty) {
      return const SubscriptionStatusProjection(active: false);
    }

    final uri = _routeUri(<String>['v1', 'subscriptions', normalizedId]);

    if (uri == null) {
      return null;
    }

    try {
      final response = await _getAuthenticated(uri);

      if (response == null || response.statusCode != 200) {
        return null;
      }

      final decoded = _decodeObject(response.body);
      final active = decoded?['active'];

      if (active is! bool) {
        return null;
      }

      if (!active) {
        return const SubscriptionStatusProjection(active: false);
      }

      final expirationDate = _parseDate(decoded?['expirationDate']);

      final productId = decoded?['productId'] is String
          ? (decoded!['productId'] as String).trim()
          : null;

      final transactionId = decoded?['transactionId'] is String
          ? (decoded!['transactionId'] as String).trim()
          : null;

      final originalTransactionId = decoded?['originalTransactionId'] is String
          ? (decoded!['originalTransactionId'] as String).trim()
          : null;

      if (expirationDate == null ||
          !expirationDate.isAfter(DateTime.now()) ||
          productId == null ||
          productId.isEmpty ||
          transactionId == null ||
          transactionId.isEmpty ||
          originalTransactionId == null ||
          originalTransactionId.isEmpty) {
        return null;
      }

      return SubscriptionStatusProjection(
        active: true,
        expirationDate: expirationDate,
        productId: productId,
        transactionId: transactionId,
        originalTransactionId: originalTransactionId,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool?> verifySubscriptionActive({
    required String subscriptionId,
  }) async {
    final projection = await fetchSubscriptionStatus(
      subscriptionId: subscriptionId,
    );

    return projection?.active;
  }

  Uri? _routeUri(List<String> routeSegments) {
    if (!_hasSecureServiceBaseUrl) {
      return null;
    }

    final baseUri = Uri.parse(_serviceBaseUrl.trim());

    return baseUri.replace(
      pathSegments: <String>[
        ...baseUri.pathSegments.where((segment) => segment.trim().isNotEmpty),
        ...routeSegments,
      ],
      query: null,
      fragment: null,
    );
  }

  Future<http.Response?> _postAuthenticated(
    Uri uri,
    Map<String, dynamic> body,
  ) {
    return _sendAuthenticated(
      (headers) => _httpClient
          .post(
            uri,
            headers: <String, String>{
              ...headers,
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout),
    );
  }

  Future<http.Response?> _getAuthenticated(Uri uri) {
    return _sendAuthenticated(
      (headers) =>
          _httpClient.get(uri, headers: headers).timeout(_requestTimeout),
    );
  }

  Future<http.Response?> _sendAuthenticated(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    final initialHeaders = await _authenticationHeaders(forceRefresh: false);

    if (initialHeaders == null) {
      return null;
    }

    var response = await request(initialHeaders);

    if (response.statusCode != 401) {
      return response;
    }

    final refreshedHeaders = await _authenticationHeaders(forceRefresh: true);

    if (refreshedHeaders == null) {
      return response;
    }

    return request(refreshedHeaders);
  }

  Future<Map<String, String>?> _authenticationHeaders({
    required bool forceRefresh,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      return null;
    }

    final token = await user.getIdToken(forceRefresh);

    if (token == null || token.trim().isEmpty) {
      return null;
    }

    return <String, String>{
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  ReceiptValidationResult _parseValidationResponse(http.Response? response) {
    if (response == null) {
      return const ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Firebase authentication is required',
      );
    }

    final data = _decodeObject(response.body);

    if (response.statusCode != 200 || data == null) {
      return ReceiptValidationResult(
        isValid: false,
        errorMessage: data?['error'] is String
            ? data!['error'] as String
            : 'Receipt validation failed with HTTP '
                  '${response.statusCode}',
      );
    }

    final expirationDate = _parseDate(data['expirationDate']);
    final transactionId = data['transactionId'] is String
        ? (data['transactionId'] as String).trim()
        : null;
    final originalTransactionId = data['originalTransactionId'] is String
        ? (data['originalTransactionId'] as String).trim()
        : null;

    final productId = data['productId'] is String
        ? (data['productId'] as String).trim()
        : null;
    final backendError = data['error'];
    final lifecycleStatus = ReceiptLifecycleStatus.fromBackendValue(
      data['lifecycleStatus'],
    );

    final responseGrantsEntitlement =
        data['valid'] == true &&
        lifecycleStatus?.grantsEntitlement == true &&
        expirationDate != null &&
        transactionId != null &&
        transactionId.isNotEmpty &&
        originalTransactionId != null &&
        originalTransactionId.isNotEmpty &&
        productId != null &&
        productId.isNotEmpty;

    return ReceiptValidationResult(
      isValid: responseGrantsEntitlement,
      expirationDate: expirationDate,
      lifecycleStatus: lifecycleStatus,
      transactionId: transactionId,
      originalTransactionId: originalTransactionId,
      productId: productId,
      errorMessage: responseGrantsEntitlement
          ? null
          : backendError is String && backendError.trim().isNotEmpty
          ? backendError
          : 'Receipt validation response was incomplete or expired',
    );
  }

  static Map<String, dynamic>? _decodeObject(String value) {
    try {
      final decoded = jsonDecode(value);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return decoded.map((key, item) => MapEntry(key.toString(), item));
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value is! String || value.trim().isEmpty) {
      return null;
    }

    return DateTime.tryParse(value);
  }
}

class SubscriptionStatusProjection {
  final bool active;
  final DateTime? expirationDate;
  final String? productId;
  final String? transactionId;
  final String? originalTransactionId;

  const SubscriptionStatusProjection({
    required this.active,
    this.expirationDate,
    this.productId,
    this.transactionId,
    this.originalTransactionId,
  });
}

enum ReceiptLifecycleStatus {
  active,
  gracePeriod,
  paidThroughCancellation;

  static ReceiptLifecycleStatus? fromBackendValue(dynamic value) {
    if (value is! String) {
      return null;
    }

    switch (value.trim()) {
      case 'active':
        return ReceiptLifecycleStatus.active;
      case 'grace_period':
        return ReceiptLifecycleStatus.gracePeriod;
      case 'paid_through_cancellation':
        return ReceiptLifecycleStatus.paidThroughCancellation;
      default:
        return null;
    }
  }

  bool get grantsEntitlement {
    switch (this) {
      case ReceiptLifecycleStatus.active:
      case ReceiptLifecycleStatus.gracePeriod:
      case ReceiptLifecycleStatus.paidThroughCancellation:
        return true;
    }
  }
}

class ReceiptValidationResult {
  final bool isValid;
  final DateTime? expirationDate;
  final ReceiptLifecycleStatus? lifecycleStatus;
  final String? transactionId;
  final String? originalTransactionId;
  final String? productId;
  final String? errorMessage;

  const ReceiptValidationResult({
    required this.isValid,
    this.expirationDate,
    this.lifecycleStatus,
    this.transactionId,
    this.originalTransactionId,
    this.productId,
    this.errorMessage,
  });

  bool get grantsActiveEntitlement {
    final normalizedTransactionId = transactionId?.trim();
    final normalizedOriginalTransactionId = originalTransactionId?.trim();
    final expiry = expirationDate;

    return isValid &&
        expiry != null &&
        expiry.isAfter(DateTime.now()) &&
        normalizedTransactionId != null &&
        normalizedTransactionId.isNotEmpty &&
        normalizedOriginalTransactionId != null &&
        normalizedOriginalTransactionId.isNotEmpty;
  }

  bool get isExpired {
    final expiry = expirationDate;

    return expiry == null || !expiry.isAfter(DateTime.now());
  }

  int? get daysUntilExpiration {
    if (expirationDate == null) {
      return null;
    }

    return expirationDate!.difference(DateTime.now()).inDays;
  }

  @override
  String toString() {
    return 'ReceiptValidationResult(isValid: $isValid, '
        'expirationDate: $expirationDate, '
        'transactionId: $transactionId, '
        'error: $errorMessage)';
  }
}
