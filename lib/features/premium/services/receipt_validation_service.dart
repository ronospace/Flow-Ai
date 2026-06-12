import 'dart:convert';
import 'package:http/http.dart' as http;

/// Receipt Validation Service
/// Validates purchase receipts from App Store and Google Play through
/// Flow AI backend only. The client never grants entitlement from local
/// receipt presence.
class ReceiptValidationService {
  // Backend receipt validation endpoints are injected at build time.
  static const String _appleValidationEndpoint = String.fromEnvironment(
    'FLOW_AI_APPLE_RECEIPT_VALIDATION_ENDPOINT',
  );
  static const String _googleValidationEndpoint = String.fromEnvironment(
    'FLOW_AI_GOOGLE_RECEIPT_VALIDATION_ENDPOINT',
  );
  static const String _subscriptionStatusEndpoint = String.fromEnvironment(
    'FLOW_AI_SUBSCRIPTION_STATUS_ENDPOINT',
  );

  bool get canValidateAppleReceipts =>
      _isConfiguredSecureEndpoint(_appleValidationEndpoint);
  bool get canValidateGooglePlayReceipts =>
      _isConfiguredSecureEndpoint(_googleValidationEndpoint);
  bool get canValidateSubscriptionStatus =>
      _isConfiguredSecureEndpoint(_subscriptionStatusEndpoint);

  static bool _isConfiguredSecureEndpoint(String endpoint) {
    final uri = Uri.tryParse(endpoint.trim());
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }

  /// Validate App Store receipt through Flow AI backend only.
  Future<ReceiptValidationResult> validateAppleReceipt({
    required String receiptData,
    required String productId,
    required String userId,
    required String transactionId,
    required bool isProduction,
  }) async {
    try {
      final backendResult = await _validateThroughBackend(
        endpoint: _appleValidationEndpoint,
        receiptData: receiptData,
        productId: productId,
        platform: 'ios',
        additionalData: {
          'environment': isProduction ? 'production' : 'sandbox',
          'transactionId': transactionId,
          'userId': userId,
        },
      );

      return backendResult ??
          ReceiptValidationResult(
            isValid: false,
            errorMessage: 'Backend validation unavailable',
          );
    } catch (e) {
      return ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Failed to validate receipt: ${e.toString()}',
      );
    }
  }

  /// Validate Google Play receipt through Flow AI backend only.
  Future<ReceiptValidationResult> validateGooglePlayReceipt({
    required String purchaseToken,
    required String productId,
    required String packageName,
    required String userId,
  }) async {
    try {
      final result = await _validateThroughBackend(
        endpoint: _googleValidationEndpoint,
        receiptData: purchaseToken,
        productId: productId,
        platform: 'android',
        additionalData: {'packageName': packageName, 'userId': userId},
      );

      return result ??
          ReceiptValidationResult(
            isValid: false,
            errorMessage: 'Backend validation unavailable',
          );
    } catch (e) {
      return ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Failed to validate receipt: ${e.toString()}',
      );
    }
  }

  /// Validate through configured backend receipt service.
  Future<ReceiptValidationResult?> _validateThroughBackend({
    required String endpoint,
    required String receiptData,
    required String productId,
    required String platform,
    Map<String, dynamic>? additionalData,
  }) async {
    final uri = Uri.tryParse(endpoint.trim());
    if (!_isConfiguredSecureEndpoint(endpoint) || uri == null) {
      return null;
    }

    try {
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'receipt': receiptData,
              'productId': productId,
              'platform': platform,
              ...?additionalData,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReceiptValidationResult(
          isValid: data['valid'] == true,
          expirationDate: data['expirationDate'] != null
              ? DateTime.parse(data['expirationDate'])
              : null,
          transactionId: data['transactionId'],
          originalTransactionId: data['originalTransactionId'],
          errorMessage: data['error'],
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }

  /// Verify subscription is still active through Flow AI backend only.
  Future<bool> verifySubscriptionActive({
    required String userId,
    required String subscriptionId,
  }) async {
    final endpoint = _subscriptionStatusEndpoint.trim();
    final baseUri = Uri.tryParse(endpoint);
    if (!canValidateSubscriptionStatus || baseUri == null) {
      return false;
    }

    final uri = baseUri.replace(
      pathSegments: [
        ...baseUri.pathSegments.where((segment) => segment.isNotEmpty),
        userId,
        subscriptionId,
      ],
    );

    try {
      final response = await http
          .get(uri, headers: {'Content-Type': 'application/json'})
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['active'] == true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }
}

/// Receipt Validation Result
class ReceiptValidationResult {
  final bool isValid;
  final DateTime? expirationDate;
  final String? transactionId;
  final String? originalTransactionId;
  final String? errorMessage;

  const ReceiptValidationResult({
    required this.isValid,
    this.expirationDate,
    this.transactionId,
    this.originalTransactionId,
    this.errorMessage,
  });

  /// Check if subscription is expired
  bool get isExpired {
    if (expirationDate == null) return false;
    return DateTime.now().isAfter(expirationDate!);
  }

  /// Days until expiration
  int? get daysUntilExpiration {
    if (expirationDate == null) return null;
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
