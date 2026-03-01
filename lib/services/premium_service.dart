import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PremiumService extends ChangeNotifier {
  static const String _premiumKey = "is_premium";
  static const String monthlyId = "zyra_premium_monthly";
  static const String yearlyId = "zyra_premium_yearly";

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isPremium = false;
  bool get isPremium => _isPremium;

  StreamSubscription<List<PurchaseDetails>>? _sub;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(_premiumKey) ?? false;

    _sub = _iap.purchaseStream.listen(_handlePurchase);
    notifyListeners();
  }

  Future<bool> isStoreAvailable() async {
    return await _iap.isAvailable();
  }

  Future<List<ProductDetails>> loadProducts() async {
    final response = await _iap.queryProductDetails({monthlyId, yearlyId});
    return response.productDetails;
  }

  Future<void> disposeService() async {
    await _sub?.cancel();
  }

  Future<void> buy(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  Future<void> restore() async {
    await _iap.restorePurchases();
  }

  Future<void> _handlePurchase(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        await _setPremium(true);
      }

      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
    _isPremium = value;
    notifyListeners();
  }
}
