import 'package:purchases_flutter/purchases_flutter.dart';

class RevenueCatService {
  static const String entitlementId = 'Premium';

  // KEEP YOUR ACTUAL TEST STORE API KEY HERE.
  static const String apiKey = 'test_qzdNdHboOvwCyyikJhtEVDQgqvm';

  static Future<void> initialize() async {
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  static Future<bool> isPremium() async {
    final customerInfo = await Purchases.getCustomerInfo();

    print(
      'ACTIVE ENTITLEMENTS: '
      '${customerInfo.entitlements.active.keys}',
    );

    return customerInfo.entitlements.active.containsKey(entitlementId);
  }

  static Future<Offerings> getOfferings() async {
    return await Purchases.getOfferings();
  }

  static Future<CustomerInfo?> purchasePremium() async {
    final offerings = await getOfferings();

    final offering = offerings.current;

    if (offering == null || offering.monthly == null) {
      return null;
    }

    final purchaseResult = await Purchases.purchasePackage(offering.monthly!);

    print(
      'PURCHASE ENTITLEMENTS: '
      '${purchaseResult.customerInfo.entitlements.active.keys}',
    );

    return purchaseResult.customerInfo;
  }
}
