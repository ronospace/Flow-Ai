import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'receipt_validation_service.dart';
import '../constants/store_product_ids.dart';
import '../models/subscription_models.dart';
import '../../../core/services/app_runtime_metadata_service.dart';

enum _BackendSubscriptionResolution { active, notActive, unknownPreserved }

class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  final ReceiptValidationService _receiptValidationService =
      ReceiptValidationService();
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  Completer<bool>? _restoreCompleter;

  // Serializes the short authoritative checkout-launch window only.
  // Purchase completion remains owned by the app-store purchase stream.
  bool _purchaseLaunchInFlight = false;
  String? _lastReceiptValidationError;

  String? _activeUserId;
  int _identityGeneration = 0;

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
  bool get isPremium =>
      hasDurableMonetizationIdentity &&
      _currentSubscription?.userId == _activeUserId &&
      (_currentSubscription?.isPremium ?? false);

  bool canOwnMonetizationFor(String userId) {
    return _receiptValidationService.canOwnMonetizationFor(userId);
  }

  String? get lastReceiptValidationError => _lastReceiptValidationError;

  bool get hasDurableMonetizationIdentity {
    final userId = _activeUserId;

    return userId != null &&
        _receiptValidationService.canOwnMonetizationFor(userId);
  }

  bool get _isPurchaseValidationConfigured {
    if (Platform.isIOS) {
      return _receiptValidationService.canValidateAppleReceipts;
    }

    if (Platform.isAndroid) {
      return _receiptValidationService.canValidateGooglePlayReceipts;
    }

    return false;
  }

  /// Initialize the service for one authoritative account.
  Future<void> initialize(String userId) async {
    final normalizedUserId = userId.trim();
    _lastReceiptValidationError = null;

    if (normalizedUserId.isEmpty) {
      throw ArgumentError.value(userId, 'userId', 'User ID cannot be empty');
    }

    // Invalidate all callbacks belonging to the previous account first.
    final generation = ++_identityGeneration;
    _activeUserId = normalizedUserId;

    final previousRestore = _restoreCompleter;
    _restoreCompleter = null;

    if (previousRestore != null && !previousRestore.isCompleted) {
      previousRestore.complete(false);
    }

    final previousPurchaseSubscription = _subscription;
    _subscription = null;

    // Fail closed immediately. Never expose the previous account's Premium.
    _currentSubscription = UserSubscription.free(normalizedUserId);

    await previousPurchaseSubscription?.cancel();

    if (!_isActiveIdentity(normalizedUserId, generation)) {
      return;
    }

    final available = await _iap.isAvailable();

    if (!_isActiveIdentity(normalizedUserId, generation)) {
      return;
    }

    _isAvailable = available;

    if (!_isAvailable) {
      return;
    }

    _subscription = _iap.purchaseStream.listen(
      (purchaseDetails) {
        unawaited(
          _onPurchaseUpdate(purchaseDetails, normalizedUserId, generation),
        );
      },
      onDone: () {
        if (!_isActiveIdentity(normalizedUserId, generation)) {
          return;
        }

        final completer = _restoreCompleter;
        if (completer != null && !completer.isCompleted) {
          completer.complete(false);
        }
      },
      onError: (Object error) {
        if (!_isActiveIdentity(normalizedUserId, generation)) {
          return;
        }

        final completer = _restoreCompleter;
        if (completer != null && !completer.isCompleted) {
          completer.complete(false);
        }
      },
    );

    await _loadProducts();

    if (!_isActiveIdentity(normalizedUserId, generation)) {
      return;
    }

    await _loadBackendVerifiedSubscription(normalizedUserId, generation);

    if (!_isActiveIdentity(normalizedUserId, generation)) {
      return;
    }

    // Existing store ownership must survive process restarts without relying
    // on a local Premium flag. If backend state has not already resolved an
    // active entitlement, silently ask the store for owned purchases. Any
    // restored purchase still flows through _handlePurchased() and the
    // authoritative receipt-validation backend before Premium is granted.
    if (!(_currentSubscription?.isPremium ?? false)) {
      await _restoreOwnedPurchasesOnStartup(normalizedUserId, generation);
    }

    if (!_isActiveIdentity(normalizedUserId, generation)) {
      return;
    }
  }

  bool _isActiveIdentity(String userId, int generation) {
    return _activeUserId == userId && _identityGeneration == generation;
  }

  /// Load available products from store
  Future<void> _loadProducts() async {
    if (!_isAvailable) return;

    try {
      final response = await _iap.queryProductDetails(_productIds);

      if (response.error != null) {
        return;
      }

      _products = response.productDetails;
    } catch (e) {}
  }

  /// Re-query the app store after an unavailable or empty response.
  Future<void> reloadProducts() async {
    _isAvailable = await _iap.isAvailable();
    _products = [];

    if (!_isAvailable) {
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
        'Advanced health trends and tracked patterns',
        'Export data to PDF/CSV',

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
    final userId = _activeUserId;
    final generation = _identityGeneration;

    if (userId == null ||
        !_receiptValidationService.canOwnMonetizationFor(userId)) {
      return PurchaseResult.failure(
        'Premium purchases require a secure signed-in account. '
        'Legacy local and anonymous sessions cannot own store purchases.',
        PurchaseError.unknown,
      );
    }

    if (!_isAvailable) {
      return PurchaseResult.failure(
        'Purchases are temporarily unavailable. Please try again.',
        PurchaseError.productNotAvailable,
      );
    }

    if (_lastReceiptValidationError == 'receipt_owner_conflict') {
      return PurchaseResult.failure(
        'This App Store subscription is linked to a different Flow Ai account. '
        'Sign in with the Flow Ai account that owns the subscription.',
        PurchaseError.unknown,
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

    if (!_isActiveIdentity(userId, generation)) {
      return PurchaseResult.failure(
        'Your subscription state changed. Please try again.',
        PurchaseError.unknown,
      );
    }

    final activeRestore = _restoreCompleter;

    if (_purchaseLaunchInFlight ||
        (activeRestore != null && !activeRestore.isCompleted)) {
      return PurchaseResult.failure(
        'Another subscription action is already in progress. Please wait.',
        PurchaseError.unknown,
      );
    }

    _purchaseLaunchInFlight = true;

    try {
      final backendResolution = await _loadBackendVerifiedSubscription(
        userId,
        generation,
      );

      if (!_isActiveIdentity(userId, generation)) {
        return PurchaseResult.failure(
          'Your subscription state changed. Please try again.',
          PurchaseError.unknown,
        );
      }

      if (backendResolution == _BackendSubscriptionResolution.active &&
          _currentSubscription?.userId == userId &&
          (_currentSubscription?.isPremium ?? false)) {
        return PurchaseResult.failure(
          'Premium is already active for this account.',
          PurchaseError.alreadyPurchased,
        );
      }

      try {
        final purchaseParam = PurchaseParam(productDetails: product);

        debugPrint(
          '[PREMIUM-CHECKOUT] launch-request '
          'platform=${Platform.operatingSystem} '
          'product=$productId',
        );

        final launched = await _iap.buyNonConsumable(
          purchaseParam: purchaseParam,
        );

        debugPrint(
          '[PREMIUM-CHECKOUT] launch-return '
          'platform=${Platform.operatingSystem} '
          'product=$productId '
          'launched=$launched',
        );

        if (!launched) {
          return PurchaseResult.failure(
            'Your app store could not open the purchase screen. Please try again.',
            PurchaseError.paymentFailed,
          );
        }

        return PurchaseResult.launched();
      } catch (error) {
        return PurchaseResult.failure(
          'We could not start the purchase. Please try again.',
          PurchaseError.paymentFailed,
        );
      }
    } finally {
      _purchaseLaunchInFlight = false;
    }
  }

  /// Handle purchase updates
  Future<void> _onPurchaseUpdate(
    List<PurchaseDetails> purchaseDetailsList,
    String userId,
    int generation,
  ) async {
    if (!_isActiveIdentity(userId, generation)) {
      return;
    }

    var restoredValidationSucceeded = false;

    for (final purchaseDetails in purchaseDetailsList) {
      debugPrint(
        '[PREMIUM-CHECKOUT] stream-update '
        'platform=${Platform.operatingSystem} '
        'product=${purchaseDetails.productID} '
        'status=${purchaseDetails.status.name} '
        'pendingComplete=${purchaseDetails.pendingCompletePurchase}',
      );

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _handlePending(purchaseDetails);
          break;
        case PurchaseStatus.purchased:
          await _handlePurchased(purchaseDetails, userId, generation);
          break;
        case PurchaseStatus.restored:
          restoredValidationSucceeded =
              await _handlePurchased(purchaseDetails, userId, generation) ||
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

    if (!_isActiveIdentity(userId, generation)) {
      return;
    }

    final restoreCompleter = _restoreCompleter;

    if (restoreCompleter != null && !restoreCompleter.isCompleted) {
      restoreCompleter.complete(restoredValidationSucceeded);
    }
  }

  void _handlePending(PurchaseDetails purchaseDetails) {
    debugPrint(
      '[PREMIUM-CHECKOUT] pending '
      'product=${purchaseDetails.productID}',
    );
  }

  /// A purchase must pass backend validation before Premium is granted.
  Future<bool> _handlePurchased(
    PurchaseDetails purchaseDetails,
    String userId,
    int generation,
  ) async {
    if (!_isActiveIdentity(userId, generation)) {
      return false;
    }

    _lastReceiptValidationError = null;
    final validationResult = await _validatePurchase(purchaseDetails, userId);

    if (!_isActiveIdentity(userId, generation)) {
      return false;
    }

    if (validationResult?.grantsActiveEntitlement == true) {
      await _grantPremiumAccess(
        purchaseDetails,
        validationResult!,
        userId,
        generation,
      );
      return true;
    }

    final validationError = validationResult?.errorMessage?.trim();
    _lastReceiptValidationError =
        validationError == null || validationError.isEmpty
        ? null
        : validationError;

    return false;
  }

  void _handleError(PurchaseDetails purchaseDetails) {
    debugPrint(
      '[PREMIUM-CHECKOUT] error '
      'product=${purchaseDetails.productID} '
      'code=${purchaseDetails.error?.code ?? 'none'}',
    );
  }

  void _handleCanceled(PurchaseDetails purchaseDetails) {
    debugPrint(
      '[PREMIUM-CHECKOUT] canceled '
      'product=${purchaseDetails.productID}',
    );
  }

  /// Validate purchases through Flow AI backend before granting Premium.
  Future<ReceiptValidationResult?> _validatePurchase(
    PurchaseDetails purchaseDetails,
    String userId,
  ) async {
    final verificationData =
        purchaseDetails.verificationData.serverVerificationData;

    if (userId.trim().isEmpty ||
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

        final packageName =
            await AppRuntimeMetadataService.instance.packageName;

        return await _receiptValidationService.validateGooglePlayReceipt(
          purchaseToken: verificationData,
          productId: purchaseDetails.productID,
          packageName: packageName,
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
    String userId,
    int generation,
  ) async {
    if (!_isActiveIdentity(userId, generation)) {
      return;
    }

    if (!validationResult.grantsActiveEntitlement) {
      throw StateError('Receipt lifecycle does not grant Premium entitlement');
    }

    final validatedProductId = validationResult.productId;

    if (validatedProductId == null ||
        (validatedProductId != monthlyProductId &&
            validatedProductId != yearlyProductId)) {
      throw StateError('Validated subscription product is not recognized');
    }

    final isYearly = validatedProductId == yearlyProductId;

    // Entitlement duration must come exclusively from verified store data.
    final purchaseDate = DateTime.fromMillisecondsSinceEpoch(
      int.tryParse(purchaseDetails.transactionDate ?? '0') ??
          DateTime.now().millisecondsSinceEpoch,
    );
    final expiryDate = validationResult.expirationDate!;

    if (!expiryDate.isAfter(DateTime.now())) {
      throw StateError('Verified subscription expiry is not active');
    }

    if (!_isActiveIdentity(userId, generation)) {
      return;
    }

    _currentSubscription = UserSubscription.premium(
      userId: userId,
      productId: validatedProductId,
      billingPeriod: isYearly ? BillingPeriod.yearly : BillingPeriod.monthly,
      purchaseDate: purchaseDate,
      expiryDate: expiryDate,
      transactionId: validationResult.transactionId,
      originalTransactionId: validationResult.originalTransactionId,
    );

    // Save to persistent storage
    await _saveSubscription(userId, generation);

    if (!_isActiveIdentity(userId, generation)) {
      return;
    }

    final validatedSubscription = _currentSubscription;
    if (validatedSubscription != null) {
      _entitlementController.add(validatedSubscription);
    }
  }

  /// Restore previous purchases for the active account.
  Future<void> _restoreOwnedPurchasesOnStartup(
    String userId,
    int generation,
  ) async {
    if (!_isActiveIdentity(userId, generation) || !_isAvailable) {
      return;
    }

    // Do not issue a store restore while authoritative checkout launch is
    // already resolving/opening.
    if (_purchaseLaunchInFlight) {
      return;
    }

    final previousRestore = _restoreCompleter;

    // Never interfere with an explicit user-triggered restore already active.
    if (previousRestore != null && !previousRestore.isCompleted) {
      return;
    }

    try {
      // Startup restoration is intentionally non-blocking with respect to the
      // checkout lock. StoreKit 2 can complete restorePurchases() with no
      // purchaseStream event when there are no current entitlements, while
      // restored transaction callbacks may also arrive asynchronously after
      // this Future completes. The active purchaseStream remains responsible
      // for validating and publishing any restored entitlement.
      await _iap.restorePurchases();
    } catch (error) {
      // Startup restoration is best-effort and remains fail-closed.
    }
  }

  Future<bool> restorePurchases(String userId) async {
    final normalizedUserId = userId.trim();
    _lastReceiptValidationError = null;
    final generation = _identityGeneration;

    if (_purchaseLaunchInFlight) {
      return false;
    }

    if (!_isActiveIdentity(normalizedUserId, generation)) {
      return false;
    }

    if (!_receiptValidationService.canOwnMonetizationFor(normalizedUserId)) {
      return false;
    }

    if (!_isAvailable) {
      _currentSubscription = UserSubscription.free(normalizedUserId);
      return false;
    }

    final activeRestore = _restoreCompleter;

    if (activeRestore != null && !activeRestore.isCompleted) {
      return activeRestore.future.timeout(
        _restoreTimeout,
        onTimeout: () => false,
      );
    }

    final previouslyVerifiedPremium =
        _currentSubscription?.userId == normalizedUserId &&
        (_currentSubscription?.isPremium ?? false);

    final completer = Completer<bool>();
    _restoreCompleter = completer;

    try {
      await _iap.restorePurchases();

      final restored = await completer.future.timeout(
        _restoreTimeout,
        onTimeout: () {
          return false;
        },
      );

      if (!_isActiveIdentity(normalizedUserId, generation)) {
        return false;
      }

      final entitlementIsPremium =
          restored ||
          (_currentSubscription?.userId == normalizedUserId &&
              (_currentSubscription?.isPremium ?? false));

      if (!entitlementIsPremium && !previouslyVerifiedPremium) {
        _currentSubscription = UserSubscription.free(normalizedUserId);
      }

      return entitlementIsPremium || previouslyVerifiedPremium;
    } catch (error) {
      if (_isActiveIdentity(normalizedUserId, generation) &&
          !previouslyVerifiedPremium) {
        _currentSubscription = UserSubscription.free(normalizedUserId);
      }

      return false;
    } finally {
      if (identical(_restoreCompleter, completer)) {
        _restoreCompleter = null;
      }
    }
  }

  /// Save subscription to storage
  Future<void> _saveSubscription(String userId, int generation) async {
    if (!_isActiveIdentity(userId, generation)) {
      return;
    }

    final subscription = _currentSubscription;

    if (subscription == null || subscription.userId != userId) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();

    if (!_isActiveIdentity(userId, generation)) {
      return;
    }

    await prefs.setString(
      'user_subscription',
      jsonEncode(subscription.toJson()),
    );
  }

  /// Load persisted subscription state only after backend status verification.
  Future<_BackendSubscriptionResolution> _loadBackendVerifiedSubscription(
    String userId,
    int generation,
  ) async {
    if (!_isActiveIdentity(userId, generation)) {
      return _BackendSubscriptionResolution.notActive;
    }
    if (!_receiptValidationService.canValidateSubscriptionStatus ||
        !_receiptValidationService.isAuthenticatedUser(userId)) {
      _currentSubscription = UserSubscription.free(userId);
      return _BackendSubscriptionResolution.notActive;
    }

    final prefs = await SharedPreferences.getInstance();
    final storedSubscription = prefs.getString('user_subscription');
    if (storedSubscription == null || storedSubscription.trim().isEmpty) {
      _currentSubscription = UserSubscription.free(userId);
      return _BackendSubscriptionResolution.notActive;
    }

    try {
      final decoded = jsonDecode(storedSubscription);
      if (decoded is! Map<String, dynamic>) {
        _currentSubscription = UserSubscription.free(userId);
        return _BackendSubscriptionResolution.notActive;
      }

      final candidate = UserSubscription.fromJson(decoded);
      final subscriptionId =
          candidate.originalTransactionId ?? candidate.transactionId;

      if (candidate.userId != userId ||
          candidate.tier == SubscriptionTier.free ||
          subscriptionId == null ||
          subscriptionId.trim().isEmpty) {
        _currentSubscription = UserSubscription.free(userId);
        return _BackendSubscriptionResolution.notActive;
      }

      final backendStatus = await _receiptValidationService
          .fetchSubscriptionStatus(subscriptionId: subscriptionId);

      if (!_isActiveIdentity(userId, generation)) {
        return _BackendSubscriptionResolution.notActive;
      }

      if (backendStatus?.active == true) {
        final productId = backendStatus!.productId;
        final expiryDate = backendStatus.expirationDate;
        final transactionId = backendStatus.transactionId;
        final originalTransactionId = backendStatus.originalTransactionId;

        if (productId == null ||
            (productId != monthlyProductId && productId != yearlyProductId) ||
            expiryDate == null ||
            !expiryDate.isAfter(DateTime.now()) ||
            transactionId == null ||
            transactionId.isEmpty ||
            originalTransactionId == null ||
            originalTransactionId.isEmpty) {
          _currentSubscription = UserSubscription.free(userId);
          return _BackendSubscriptionResolution.notActive;
        }

        final isYearly = productId == yearlyProductId;

        _currentSubscription = UserSubscription.premium(
          userId: userId,
          productId: productId,
          billingPeriod: isYearly
              ? BillingPeriod.yearly
              : BillingPeriod.monthly,
          purchaseDate: candidate.purchaseDate,
          expiryDate: expiryDate,
          transactionId: transactionId,
          originalTransactionId: originalTransactionId,
        );

        await _saveSubscription(userId, generation);

        if (!_isActiveIdentity(userId, generation)) {
          return _BackendSubscriptionResolution.notActive;
        }

        final validatedSubscription = _currentSubscription;
        if (validatedSubscription != null) {
          _entitlementController.add(validatedSubscription);
        }

        return _BackendSubscriptionResolution.active;
      }

      if (backendStatus?.active == false) {
        _currentSubscription = UserSubscription.free(userId);
        return _BackendSubscriptionResolution.notActive;
      }

      // Backend status is temporarily unknown. Preserve only the already
      // persisted entitlement for this same user while it remains locally
      // valid and unexpired. Never manufacture or extend Premium access.
      if (candidate.isPremium) {
        _currentSubscription = candidate;
        return _BackendSubscriptionResolution.unknownPreserved;
      }

      _currentSubscription = UserSubscription.free(userId);
      return _BackendSubscriptionResolution.notActive;
    } catch (e) {
      _currentSubscription = UserSubscription.free(userId);
      return _BackendSubscriptionResolution.notActive;
    }
  }

  /// Check if user can access a premium feature
  bool canAccessFeature(PremiumFeature feature) {
    return isPremium &&
        (_currentSubscription?.canAccessFeature(feature) ?? false);
  }

  /// Increment AI insights usage
  Future<void> incrementInsightsUsage() async {
    final userId = _activeUserId;
    final generation = _identityGeneration;
    final subscription = _currentSubscription;

    if (userId == null ||
        subscription == null ||
        subscription.userId != userId ||
        !_isActiveIdentity(userId, generation)) {
      return;
    }

    _currentSubscription = subscription.copyWith(
      aiInsightsUsed: subscription.aiInsightsUsed + 1,
    );

    await _saveSubscription(userId, generation);
  }

  /// Get remaining free insights
  int getRemainingFreeInsights() {
    if (_currentSubscription == null) return 0;
    if (canAccessFeature(PremiumFeature.unlimitedInsights)) return -1;

    return (_currentSubscription!.aiInsightsLimit -
            _currentSubscription!.aiInsightsUsed)
        .clamp(0, 999);
  }

  /// Dispose
  void dispose() {
    _identityGeneration++;
    _activeUserId = null;

    final restoreCompleter = _restoreCompleter;
    _restoreCompleter = null;

    if (restoreCompleter != null && !restoreCompleter.isCompleted) {
      restoreCompleter.complete(false);
    }

    final subscription = _subscription;
    _subscription = null;
    unawaited(subscription?.cancel());

    _entitlementController.close();
  }
}
