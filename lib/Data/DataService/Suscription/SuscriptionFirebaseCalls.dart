
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';

// Brand Firebase Service Class. All calls to Firebase are in this class.
class SuscriptionFirebaseCalls {
  // Firebase Instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final batch = FirebaseFirestore.instance.batch();

  // Firebase collections
  String users = 'Users';
  String brands = 'Brands';
  String events = 'Events';
  String locations = 'Locations';
  String library = 'Library';
  String purchases = 'Purchases';
  String subscriptions = 'Subscriptions';
  String subscriptionsRevenueCat = '111testSubs';

  Future<Subscription> getBrandSubscription(String adminAppUserId) async {
    print('subscription');
    try {
      Subscription subscription = Subscription();
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await _firestore
              .collection(subscriptionsRevenueCat)
              .doc(adminAppUserId)
              .get();
      if (documentSnapshot.exists) {
        final data = documentSnapshot.data()!;
        if (data.containsKey('entitlements')) {
          final entitlements = documentSnapshot.get("entitlements");
          if (entitlements.containsKey(dotenv.env['REVCAT_ENTITLEMENT_ID']!)) {
            String expireDate =
                entitlements[dotenv.env['REVCAT_ENTITLEMENT_ID']!]
                    ['expires_date'];
            if ((DateTime.parse(expireDate).isAfter(DateTime.now()) ||
                DateTime.parse(expireDate).isAtSameMomentAs(DateTime.now()))) {
              String subId = entitlements[dotenv.env['REVCAT_ENTITLEMENT_ID']!]
                  ['product_identifier'];
              if (data.containsKey('subscriptions')) {
                final subscriptions = documentSnapshot.get("subscriptions");
                print(subscriptions[subId]['expires_date']);
                final subscription = Subscription.fromRevenueSubscription(
                    subscriptions[subId], subId);
                return subscription;
              }
            }
          }

          /*final subscriptionAux = (subscriptions.values).firstWhere(
                (subscription) => (DateTime.parse(subscription['expires_date']).isAfter(DateTime.now()) || DateTime.parse(subscription['expires_date']).isAtSameMomentAs(DateTime.now())));
        final subscription = Subscription.fromRevenueSubscription(subscriptions['month_sub']);*/
        }
      }
      return subscription;
    } catch (e) {
      print(e);
      return Subscription();
    }
  }
}
