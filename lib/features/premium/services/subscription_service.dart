import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'receipt_validation_service.dart';
import '../models/subscription_models.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final ReceiptValidationService _receiptValidationService =
      ReceiptValidationService();
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  // Product IDs (configure these in App Store Connect and Google Play Console)
  static const String monthlyProductId = 'flow_ai_premium_monthly';
  static const String yearlyProductId = 'flow_ai_premium_yearly';

  static const Set<String> _productIds = {monthlyProductId, yearlyProductId};

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  UserSubscription? _currentSubscription;

  // Getters
  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;
  UserSubscription? get currentSubscription => _currentSubscription;
  bool get isPremium => _currentSubscription?.isPremium ?? false;

  bool get _isPurchaseValidationConfigured {
    if (Platform.isIOS) {
      return _receiptValidationService.canValidateAppleReceipts;
    }

    if (Platform.isAndroid) {
      return _receiptValidationService.canValidateGooglePlayReceipts;
    }

    return false;
  }

  /// Initialize the service
  Future<void> initialize(String userId) async {
    if (kDebugMode) {
      print('🔐 Initializing SubscriptionService for user: $userId');
    }

    // Check if IAP is available
    _isAvailable = await _iap.isAvailable();

    if (!_isAvailable) {
      if (kDebugMode) {
        print('⚠️ In-app purchases not available');
      }
      _currentSubscription = UserSubscription.free(userId);
      return;
    }

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      (purchaseDetails) => unawaited(_onPurchaseUpdate(purchaseDetails)),
      onDone: () => _subscription.cancel(),
      onError: (error) {
        if (kDebugMode) {
          print('❌ Purchase stream error: $error');
        }
      },
    );

    // Load products
    await _loadProducts();

    // Restore previous purchases
    await restorePurchases(userId);

    if (kDebugMode) {
      print('✅ SubscriptionService initialized');
    }
  }

  /// Load available products from store
  Future<void> _loadProducts() async {
    if (!_isAvailable) return;

    try {
      final response = await _iap.queryProductDetails(_productIds);

      if (response.error != null) {
        if (kDebugMode) {
          print('❌ Error loading products: ${response.error}');
        }
        return;
      }

      if (response.notFoundIDs.isNotEmpty) {
        if (kDebugMode) {
          print('⚠️ Products not found: ${response.notFoundIDs}');
        }
      }

      _products = response.productDetails;

      if (kDebugMode) {
        print('✅ Loaded ${_products.length} products');
        for (final product in _products) {
          print('  - ${product.id}: ${product.price}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Exception loading products: $e');
      }
    }
  }

  /// Convert product details to our model
  SubscriptionProduct _convertToSubscriptionProduct(ProductDetails product) {
    final isYearly = product.id == yearlyProductId;
    return SubscriptionProduct(
      id: product.id,
      name: isYearly ? 'Flow Ai Premium (Yearly)' : 'Flow Ai Premium (Monthly)',
      description: product.description,
      tier: SubscriptionTier.premium,
      billingPeriod: isYearly ? BillingPeriod.yearly : BillingPeriod.monthly,
      price: double.tryParse(product.rawPrice.toString()) ?? 0,
      currency: product.currencyCode,
      priceString: product.price,
      features: [
        'Unlimited AI insights',
        'Advanced health condition detection',
        'Export data to PDF/CSV',
        'Ad-free experience',
        'Priority support',
        if (isYearly) 'Yearly billing through your app store',
      ],
      isPopular: isYearly,
    );
  }

  /// Get all available subscription products
  List<SubscriptionProduct> getAvailableProducts() {
    return _products.map(_convertToSubscriptionProduct).toList();
  }

  /// Purchase a subscription
  Future<PurchaseResult> purchaseSubscription(String productId) async {
    if (!_isAvailable) {
      return PurchaseResult.failure(
        'In-app purchases are not available',
        PurchaseError.productNotAvailable,
      );
    }

    if (!_isPurchaseValidationConfigured) {
      return PurchaseResult.failure(
        'Secure purchase validation is not configured',
        PurchaseError.unknown,
      );
    }

    final product = _products.firstWhere(
      (p) => p.id == productId,
      orElse: () => throw Exception('Product not found'),
    );

    try {
      if (kDebugMode) {
        print('🛒 Purchasing: ${product.id}');
      }

      final purchaseParam = PurchaseParam(productDetails: product);

      // For subscriptions, use buyNonConsumable on iOS, subscribe on Android
      if (Platform.isIOS) {
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        // Android subscriptions
        await _iap.buyNonConsumable(purchaseParam: purchaseParam);
      }

      // Purchase will be processed in _onPurchaseUpdate
      return PurchaseResult(success: true);
    } catch (e) {
      if (kDebugMode) {
        print('❌ Purchase error: $e');
      }
      return PurchaseResult.failure(
        'Purchase failed: ${e.toString()}',
        PurchaseError.unknown,
      );
    }
  }

  /// Handle purchase updates
  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (kDebugMode) {
        print('📦 Purchase update: ${purchaseDetails.status}');
      }

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _handlePending(purchaseDetails);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          await _handlePurchased(purchaseDetails);
          break;
        case PurchaseStatus.error:
          _handleError(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _handleCanceled(purchaseDetails);
          break;
      }

      // Complete the purchase after local processing has finished. Premium is
      // granted only when backend validation succeeds.
      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }
  }

  void _handlePending(PurchaseDetails purchaseDetails) {
    if (kDebugMode) {
      print('⏳ Purchase pending: ${purchaseDetails.productID}');
    }
  }

  Future<void> _handlePurchased(PurchaseDetails purchaseDetails) async {
    if (kDebugMode) {
      print('✅ Purchase successful: ${purchaseDetails.productID}');
    }

    final validationResult = await _validatePurchase(purchaseDetails);

    if (validationResult?.isValid == true) {
      await _grantPremiumAccess(purchaseDetails, validationResult!);
      return;
    }

    if (kDebugMode) {
      print(
        '❌ Purchase validation failed: '
        '${validationResult?.errorMessage ?? 'missing validation result'}',
      );
    }
  }

  void _handleError(PurchaseDetails purchaseDetails) {
    if (kDebugMode) {
      print('❌ Purchase error: ${purchaseDetails.error}');
    }
  }

  void _handleCanceled(PurchaseDetails purchaseDetails) {
    if (kDebugMode) {
      print('🚫 Purchase canceled: ${purchaseDetails.productID}');
    }
  }

  /// Validate purchases through Flow AI backend before granting Premium.
  Future<ReceiptValidationResult?> _validatePurchase(
    PurchaseDetails purchaseDetails,
  ) async {
    final verificationData =
        purchaseDetails.verificationData.serverVerificationData;

    if (verificationData.isEmpty) {
      return ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Missing store verification data',
      );
    }

    try {
      if (Platform.isIOS) {
        return await _receiptValidationService.validateAppleReceipt(
          receiptData: verificationData,
          productId: purchaseDetails.productID,
          isProduction: kReleaseMode,
        );
      }

      if (Platform.isAndroid) {
        final packageInfo = await PackageInfo.fromPlatform();

        return await _receiptValidationService.validateGooglePlayReceipt(
          purchaseToken: verificationData,
          productId: purchaseDetails.productID,
          packageName: packageInfo.packageName,
        );
      }

      return ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Unsupported purchase platform',
      );
    } catch (e) {
      return ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Purchase validation failed: ${e.toString()}',
      );
    }
  }

  /// Grant premium access after successful purchase
  Future<void> _grantPremiumAccess(
    PurchaseDetails purchaseDetails,
    ReceiptValidationResult validationResult,
  ) async {
    final userId = _currentSubscription?.userId ?? 'unknown';
    final isYearly = purchaseDetails.productID == yearlyProductId;

    // Calculate expiry date
    final purchaseDate = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(purchaseDetails.transactionDate ?? '0') ??
          DateTime.now().millisecondsSinceEpoch,
    );
    final fallbackExpiryDate = isYearly
        ? purchaseDate.add(const Duration(days: 365))
        : purchaseDate.add(const Duration(days: 30));
    final expiryDate = validationResult.expirationDate ?? fallbackExpiryDate;

    _currentSubscription = UserSubscription.premium(
      userId: userId,
      productId: purchaseDetails.productID,
      billingPeriod: isYearly ? BillingPeriod.yearly : BillingPeriod.monthly,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      transactionId:
          validationResult.transactionId ?? purchaseDetails.purchaseID,
      originalTransactionId:
          validationResult.originalTransactionId ?? purchaseDetails.purchaseID,
    );

    // Save to persistent storage
    await _saveSubscription();

    if (kDebugMode) {
      print('🎉 Premium access granted until: $expiryDate');
    }
  }

  /// Restore previous purchases
  Future<bool> restorePurchases(String userId) async {
    if (!_isAvailable) {
      _currentSubscription = UserSubscription.free(userId);
      return false;
    }

    try {
      if (kDebugMode) {
        print('🔄 Restoring purchases...');
      }

      await _iap.restorePurchases();

      // Restore events are delivered through purchaseStream and must pass
      // backend validation before Premium is granted. Local storage alone is
      // never trusted as proof of entitlement.
      final restoredIsPremium = _currentSubscription?.isPremium ?? false;

      if (!restoredIsPremium) {
        _currentSubscription = UserSubscription.free(userId);
        if (kDebugMode) {
          print('ℹ️ No backend-validated restored subscription found');
        }
      }

      return restoredIsPremium;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error restoring purchases: $e');
      }
      _currentSubscription = UserSubscription.free(userId);
      return false;
    }
  }

  /// Save subscription to storage
  Future<void> _saveSubscription() async {
    if (_currentSubscription == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'user_subscription',
      jsonEncode(_currentSubscription!.toJson()),
    );
  }

  /// Check if user can access a premium feature
  bool canAccessFeature(PremiumFeature feature) {
    return _currentSubscription?.canAccessFeature(feature) ?? false;
  }

  /// Increment AI insights usage
  Future<void> incrementInsightsUsage() async {
    if (_currentSubscription == null) return;

    _currentSubscription = _currentSubscription!.copyWith(
      aiInsightsUsed: _currentSubscription!.aiInsightsUsed + 1,
    );

    await _saveSubscription();
  }

  /// Get remaining free insights
  int getRemainingFreeInsights() {
    if (_currentSubscription == null) return 0;
    if (_currentSubscription!.hasUnlimitedInsights) return -1; // Unlimited

    return (_currentSubscription!.aiInsightsLimit -
            _currentSubscription!.aiInsightsUsed)
        .clamp(0, 999);
  }

  /// Dispose
  void dispose() {
    _subscription.cancel();
  }
}
