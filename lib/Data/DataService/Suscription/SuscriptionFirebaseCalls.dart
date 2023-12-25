
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';

// Brand Firebase Service Class. All calls to Firebase are in this class.
class SuscriptionFirebaseCalls {
  // Firebase Instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;
  final batch = FirebaseFirestore.instance.batch();

  // Firebase collections
  String library = isProduction ? 'Library' : 'Library';
  String brands = isProduction ? 'Brands' : '7777 Brands';
  String users = isProduction ? 'Users' : '7777 Users';
  String events = isProduction ? 'Events' : '7777 Events';
  String locations = isProduction ? 'Locations' : '7777 Locations';
  String purchases = isProduction ? 'Purchases' : '7777 Purchases';
  String subscriptions = isProduction ? 'Subscriptions' : '7777 Subscriptions';
  String subscriptionsRevenueCat = isProduction ? '111testSubs' : '111testSubs';

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
