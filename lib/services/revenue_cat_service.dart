import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class RevenueCatService {
  static const String entitlementId = 'Premium';

  static const String apiKey =
      'goog_UuUlgmqEOgPsIfByfITIceeBKEv';

  static Future<void> initialize() async {
    await Purchases.configure(
      PurchasesConfiguration(apiKey),
    );
  }

  static Future<bool> isPremium() async {
    final customerInfo = await Purchases.getCustomerInfo();

    return customerInfo.entitlements.active
        .containsKey(entitlementId);
  }

  static Future<Offerings> getOfferings() async {
    return await Purchases.getOfferings();
  }

  static Future<CustomerInfo?> purchasePremium() async {
    final offerings = await Purchases.getOfferings();

    final offering = offerings.current;

    if (offering == null) {
      throw Exception(
        'No current RevenueCat offering is configured.',
      );
    }

    if (offering.monthly == null) {
      throw Exception(
        'No monthly package is configured in the current offering.',
      );
    }

    final result = await Purchases.purchasePackage(
      offering.monthly!,
    );

    return result.customerInfo;
  }
}

