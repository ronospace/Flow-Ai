import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Receipt Validation Service
/// Validates purchase receipts from App Store and Google Play
class ReceiptValidationService {
  // Backend API endpoints (replace with your actual backend URLs)
  static const String _appleValidationEndpoint = 
      'https://your-backend.com/api/validate-apple-receipt';
  static const String _googleValidationEndpoint = 
      'https://your-backend.com/api/validate-google-receipt';
  
  // Apple Sandbox vs Production
  static const String _appleSandboxUrl = 
      'https://sandbox.itunes.apple.com/verifyReceipt';
  static const String _appleProductionUrl = 
      'https://buy.itunes.apple.com/verifyReceipt';

  /// Validate App Store receipt
  /// Returns true if receipt is valid, false otherwise
  Future<ReceiptValidationResult> validateAppleReceipt({
    required String receiptData,
    required String productId,
    bool isProduction = false,
  }) async {
    try {
      debugPrint('🍎 Validating Apple receipt for product: $productId');
      
      // Option 1: Validate through your backend (RECOMMENDED)
      final backendResult = await _validateThroughBackend(
        endpoint: _appleValidationEndpoint,
        receiptData: receiptData,
        productId: productId,
        platform: 'ios',
      );
      
      if (backendResult != null) {
        return backendResult;
      }
      
      // Option 2: Direct validation with Apple (fallback, less secure)
      return await _validateWithAppleDirect(
        receiptData: receiptData,
        isProduction: isProduction,
      );
    } catch (e) {
      debugPrint('❌ Apple receipt validation error: $e');
      return ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Failed to validate receipt: ${e.toString()}',
      );
    }
  }

  /// Validate Google Play receipt
  Future<ReceiptValidationResult> validateGooglePlayReceipt({
    required String purchaseToken,
    required String productId,
    required String packageName,
  }) async {
    try {
      debugPrint('🤖 Validating Google Play receipt for product: $productId');
      
      // Validate through your backend (REQUIRED for Google Play)
      final result = await _validateThroughBackend(
        endpoint: _googleValidationEndpoint,
        receiptData: purchaseToken,
        productId: productId,
        platform: 'android',
        additionalData: {
          'packageName': packageName,
        },
      );
      
      return result ?? ReceiptValidationResult(
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

  /// Validate through your backend server (RECOMMENDED)
  Future<ReceiptValidationResult?> _validateThroughBackend({
    required String endpoint,
    required String receiptData,
    required String productId,
    required String platform,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers if needed
          // 'Authorization': 'Bearer YOUR_API_KEY',
        },
        body: jsonEncode({
          'receipt': receiptData,
          'productId': productId,
          'platform': platform,
          ...?additionalData,
        }),
      ).timeout(const Duration(seconds: 10));

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
      } else {
        debugPrint('Backend validation failed: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('Backend validation error: $e');
      return null;
    }
  }

  /// Direct validation with Apple (fallback, less secure)
  /// Note: Apple recommends validating on your own server
  Future<ReceiptValidationResult> _validateWithAppleDirect({
    required String receiptData,
    required bool isProduction,
  }) async {
    final url = isProduction ? _appleProductionUrl : _appleSandboxUrl;
    
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'receipt-data': receiptData,
          'password': '', // Your App-Specific Shared Secret
          'exclude-old-transactions': true,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'] as int;
        
        // Status 0 = valid receipt
        if (status == 0) {
          final latestReceiptInfo = data['latest_receipt_info'];
          if (latestReceiptInfo != null && latestReceiptInfo.isNotEmpty) {
            final receipt = latestReceiptInfo[0];
            
            return ReceiptValidationResult(
              isValid: true,
              expirationDate: _parseAppleDate(receipt['expires_date_ms']),
              transactionId: receipt['transaction_id'],
              originalTransactionId: receipt['original_transaction_id'],
            );
          }
        } else if (status == 21007) {
          // Receipt is from sandbox but sent to production
          // Retry with sandbox
          return await _validateWithAppleDirect(
            receiptData: receiptData,
            isProduction: false,
          );
        }
        
        return ReceiptValidationResult(
          isValid: false,
          errorMessage: _getAppleErrorMessage(status),
        );
      }
      
      return ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Invalid response from Apple: ${response.statusCode}',
      );
    } catch (e) {
      return ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Network error: ${e.toString()}',
      );
    }
  }

  /// Parse Apple timestamp (milliseconds since epoch)
  DateTime? _parseAppleDate(dynamic milliseconds) {
    if (milliseconds == null) return null;
    try {
      final ms = int.parse(milliseconds.toString());
      return DateTime.fromMillisecondsSinceEpoch(ms);
    } catch (e) {
      return null;
    }
  }

  /// Get human-readable error message for Apple status codes
  String _getAppleErrorMessage(int status) {
    switch (status) {
      case 21000:
        return 'The App Store could not read the receipt data.';
      case 21002:
        return 'The receipt data was malformed.';
      case 21003:
        return 'The receipt could not be authenticated.';
      case 21004:
        return 'The shared secret does not match.';
      case 21005:
        return 'The receipt server is not available.';
      case 21006:
        return 'This receipt is valid but expired.';
      case 21007:
        return 'This receipt is from the sandbox environment.';
      case 21008:
        return 'This receipt is from the production environment.';
      case 21010:
        return 'This receipt could not be authorized.';
      default:
        return 'Unknown error (status: $status)';
    }
  }

  /// Verify subscription is still active
  Future<bool> verifySubscriptionActive({
    required String userId,
    required String subscriptionId,
  }) async {
    try {
      // Query your backend to check subscription status
      final response = await http.get(
        Uri.parse('https://your-backend.com/api/subscription/status/$userId/$subscriptionId'),
        headers: {
          'Content-Type': 'application/json',
          // Add authentication headers
        },
      ).timeout(const Duration(seconds: 10));

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
