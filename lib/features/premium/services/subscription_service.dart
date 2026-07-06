import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'receipt_validation_service.dart';
import '../constants/store_product_ids.dart';
import '../models/subscription_models.dart';

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final ReceiptValidationService _receiptValidationService =
      ReceiptValidationService();
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  Completer<bool>? _restoreCompleter;

  static const Duration _restoreTimeout = Duration(seconds: 15);

  // Product IDs configured in App Store Connect and Google Play Console.
  static const String monthlyProductId = StoreProductIds.premiumMonthly;
  static const String yearlyProductId = StoreProductIds.premiumYearly;

  static const Set<String> _productIds = StoreProductIds.subscriptions;

  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  UserSubscription? _currentSubscription;
  final StreamController<UserSubscription> _entitlementController =
      StreamController<UserSubscription>.broadcast();

  // Getters
  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;
  UserSubscription? get currentSubscription => _currentSubscription;
  Stream<UserSubscription> get entitlementChanges =>
      _entitlementController.stream;
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
      onDone: () {
        final restoreCompleter = _restoreCompleter;
        if (restoreCompleter != null && !restoreCompleter.isCompleted) {
          restoreCompleter.complete(false);
        }
        unawaited(_subscription.cancel());
      },
      onError: (error) {
        final restoreCompleter = _restoreCompleter;
        if (restoreCompleter != null && !restoreCompleter.isCompleted) {
          restoreCompleter.complete(false);
        }

        if (kDebugMode) {
          print('❌ Purchase stream error: $error');
        }
      },
    );

    // Load products
    await _loadProducts();

    // Load only backend-verified entitlement state before restore.
    await _loadBackendVerifiedSubscription(userId);

    // Restore is explicitly user-initiated. Store callbacks are
    // asynchronous and must not block subscription catalog initialization.

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

  /// Re-query the app store after an unavailable or empty response.
  Future<void> reloadProducts() async {
    _isAvailable = await _iap.isAvailable();
    _products = [];

    if (!_isAvailable) {
      if (kDebugMode) {
        print('⚠️ In-app purchases are not available during refresh');
      }
      return;
    }

    await _loadProducts();
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
        'Purchases are temporarily unavailable. Please try again.',
        PurchaseError.productNotAvailable,
      );
    }

    if (!_isPurchaseValidationConfigured) {
      return PurchaseResult.failure(
        'Secure purchase validation is temporarily unavailable.',
        PurchaseError.unknown,
      );
    }

    ProductDetails? product;

    for (final candidate in _products) {
      if (candidate.id == productId) {
        product = candidate;
        break;
      }
    }

    if (product == null) {
      return PurchaseResult.failure(
        'This subscription plan is temporarily unavailable.',
        PurchaseError.productNotAvailable,
      );
    }

    try {
      if (kDebugMode) {
        print('🛒 Opening app-store checkout for: ${product.id}');
      }

      final purchaseParam = PurchaseParam(productDetails: product);
      final launched = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!launched) {
        return PurchaseResult.failure(
          'Your app store could not open the purchase screen. Please try again.',
          PurchaseError.paymentFailed,
        );
      }

      return PurchaseResult.launched();
    } catch (error) {
      if (kDebugMode) {
        print('❌ Purchase launch error: $error');
      }

      return PurchaseResult.failure(
        'We could not start the purchase. Please try again.',
        PurchaseError.paymentFailed,
      );
    }
  }

  /// Handle purchase updates
  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    var restoredValidationSucceeded = false;

    for (final purchaseDetails in purchaseDetailsList) {
      if (kDebugMode) {
        print('📦 Purchase update: ${purchaseDetails.status}');
      }

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _handlePending(purchaseDetails);
          break;
        case PurchaseStatus.purchased:
          await _handlePurchased(purchaseDetails);
          break;
        case PurchaseStatus.restored:
          restoredValidationSucceeded =
              await _handlePurchased(purchaseDetails) ||
              restoredValidationSucceeded;
          break;
        case PurchaseStatus.error:
          _handleError(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _handleCanceled(purchaseDetails);
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        await _iap.completePurchase(purchaseDetails);
      }
    }

    final restoreCompleter = _restoreCompleter;

    if (restoreCompleter != null && !restoreCompleter.isCompleted) {
      restoreCompleter.complete(restoredValidationSucceeded);
    }
  }

  void _handlePending(PurchaseDetails purchaseDetails) {
    if (kDebugMode) {
      print('⏳ Purchase pending: ${purchaseDetails.productID}');
    }
  }

  /// A purchase must pass backend validation before Premium is granted.
  Future<bool> _handlePurchased(PurchaseDetails purchaseDetails) async {
    if (kDebugMode) {
      print('✅ Store purchase received: ${purchaseDetails.productID}');
    }

    final validationResult = await _validatePurchase(purchaseDetails);

    if (validationResult?.isValid == true) {
      await _grantPremiumAccess(purchaseDetails, validationResult!);
      return true;
    }

    if (kDebugMode) {
      print(
        '❌ Purchase validation failed: '
        '${validationResult?.errorMessage ?? 'missing validation result'}',
      );
    }

    return false;
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
    final userId = _currentSubscription?.userId;

    if (userId == null ||
        userId.trim().isEmpty ||
        !_receiptValidationService.isAuthenticatedUser(userId)) {
      return const ReceiptValidationResult(
        isValid: false,
        errorMessage: 'Firebase purchase identity is unavailable or mismatched',
      );
    }

    try {
      if (Platform.isIOS) {
        final transactionId = purchaseDetails.purchaseID;
        if (transactionId == null || transactionId.trim().isEmpty) {
          return const ReceiptValidationResult(
            isValid: false,
            errorMessage: 'Missing App Store transaction identifier',
          );
        }

        return await _receiptValidationService.validateAppleReceipt(
          productId: purchaseDetails.productID,
          transactionId: transactionId,
          isProduction: kReleaseMode,
        );
      }

      if (Platform.isAndroid) {
        if (verificationData.trim().isEmpty) {
          return const ReceiptValidationResult(
            isValid: false,
            errorMessage: 'Missing Google Play purchase token',
          );
        }

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
        errorMessage: 'Purchase validation failed',
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

    final validatedSubscription = _currentSubscription;
    if (validatedSubscription != null) {
      _entitlementController.add(validatedSubscription);
    }

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

    final activeRestore = _restoreCompleter;

    if (activeRestore != null && !activeRestore.isCompleted) {
      return activeRestore.future.timeout(
        _restoreTimeout,
        onTimeout: () => false,
      );
    }

    final previouslyVerifiedPremium = _currentSubscription?.isPremium ?? false;
    final completer = Completer<bool>();
    _restoreCompleter = completer;

    try {
      if (kDebugMode) {
        print('🔄 Requesting app-store purchase restoration');
      }

      await _iap.restorePurchases();

      final restored = await completer.future.timeout(
        _restoreTimeout,
        onTimeout: () => false,
      );

      final entitlementIsPremium =
          restored || (_currentSubscription?.isPremium ?? false);

      if (!entitlementIsPremium && !previouslyVerifiedPremium) {
        _currentSubscription = UserSubscription.free(userId);
      }

      return entitlementIsPremium || previouslyVerifiedPremium;
    } catch (error) {
      if (kDebugMode) {
        print('❌ Restore request failed: $error');
      }

      if (!previouslyVerifiedPremium) {
        _currentSubscription = UserSubscription.free(userId);
      }

      return previouslyVerifiedPremium;
    } finally {
      if (identical(_restoreCompleter, completer)) {
        _restoreCompleter = null;
      }
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

  /// Load persisted subscription state only after backend status verification.
  Future<bool> _loadBackendVerifiedSubscription(String userId) async {
    if (!_receiptValidationService.canValidateSubscriptionStatus ||
        !_receiptValidationService.isAuthenticatedUser(userId)) {
      _currentSubscription = UserSubscription.free(userId);
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedSubscription = prefs.getString('user_subscription');
    if (storedSubscription == null || storedSubscription.trim().isEmpty) {
      _currentSubscription = UserSubscription.free(userId);
      return false;
    }

    try {
      final decoded = jsonDecode(storedSubscription);
      if (decoded is! Map<String, dynamic>) {
        _currentSubscription = UserSubscription.free(userId);
        return false;
      }

      final candidate = UserSubscription.fromJson(decoded);
      final subscriptionId =
          candidate.originalTransactionId ?? candidate.transactionId;

      if (candidate.userId != userId ||
          candidate.tier == SubscriptionTier.free ||
          subscriptionId == null ||
          subscriptionId.trim().isEmpty) {
        _currentSubscription = UserSubscription.free(userId);
        return false;
      }

      final isActive = await _receiptValidationService.verifySubscriptionActive(
        subscriptionId: subscriptionId,
      );

      _currentSubscription = isActive
          ? candidate
          : UserSubscription.free(userId);
      return isActive;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Failed to load backend-verified subscription: $e');
      }
      _currentSubscription = UserSubscription.free(userId);
      return false;
    }
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
    _entitlementController.close();
  }
}
