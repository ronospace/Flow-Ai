import 'package:in_app_purchase/in_app_purchase.dart';

class StoreProducts {
  static const ids = {"zyra_premium_monthly", "zyra_premium_yearly"};

  static Future<List<ProductDetails>> load() async {
    final response = await InAppPurchase.instance.queryProductDetails(ids);
    return response.productDetails;
  }
}
