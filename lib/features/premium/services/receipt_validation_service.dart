import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Receipt Validation Service
/// Validates purchase receipts from App Store and Google Play through
/// Flow AI backend only. The client never grants entitlement from local
/// receipt presence.
class ReceiptValidationService {
  // Backend receipt validation endpoints.
  static const String _appleValidationEndpoint = '';
  static const String _googleValidationEndpoint = '';
  static const String _subscriptionStatusEndpoint = '';

  bool get canValidateAppleReceipts =>
      _appleValidationEndpoint.trim().isNotEmpty;
  bool get canValidateGooglePlayReceipts =>
      _googleValidationEndpoint.trim().isNotEmpty;
  bool get canValidateSubscriptionStatus =>
      _subscriptionStatusEndpoint.trim().isNotEmpty;

  /// Validate App Store receipt through Flow AI backend only.
  Future<ReceiptValidationResult> validateAppleReceipt({
    required String receiptData,
    required String productId,
    bool isProduction = false,
  }) async {
    try {
      final environment = isProduction ? 'production' : 'sandbox';
      debugPrint(
        '🍎 Validating Apple receipt through backend for product: '
        '$productId ($environment)',
      );

      final backendResult = await _validateThroughBackend(
        endpoint: _appleValidationEndpoint,
        receiptData: receiptData,
        productId: productId,
        platform: 'ios',
      );

      return backendResult ??
          ReceiptValidationResult(
            isValid: false,
            errorMessage: 'Backend validation unavailable',
          );
    } catch (e) {
      debugPrint('❌ Apple receipt validation error: $e');
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
  }) async {
    try {
      debugPrint('🤖 Validating Google Play receipt for product: $productId');

      final result = await _validateThroughBackend(
        endpoint: _googleValidationEndpoint,
        receiptData: purchaseToken,
        productId: productId,
        platform: 'android',
        additionalData: {'packageName': packageName},
      );

      return result ??
          ReceiptValidationResult(
            isValid: false,
            errorMessage: 'Backend validation unavailable',
          );
    } catch (e) {
      debugPrint('❌ Google Play receipt validation error: $e');
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
    if (endpoint.trim().isEmpty) {
      debugPrint('Receipt validation backend is not configured');
      return null;
    }

    try {
      final response = await http
          .post(
            Uri.parse(endpoint),
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

      debugPrint('Backend validation failed: ${response.statusCode}');
      return null;
    } catch (e) {
      debugPrint('Backend validation error: $e');
      return null;
    }
  }

  /// Verify subscription is still active through Flow AI backend only.
  Future<bool> verifySubscriptionActive({
    required String userId,
    required String subscriptionId,
  }) async {
    if (!canValidateSubscriptionStatus) {
      debugPrint('Subscription status endpoint is not configured');
      return false;
    }

    try {
      final response = await http
          .get(
            Uri.parse('$_subscriptionStatusEndpoint/$userId/$subscriptionId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['active'] == true;
      }

      return false;
    } catch (e) {
      debugPrint('Error verifying subscription: $e');
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
