import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:uuid/uuid.dart';

import '../../Models/Purchase.dart';

// Firebase Payment Service Class. All calls to Firebase are in this class.
class PaymentFirebaseCalls {

  // Firebase Instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final batch = FirebaseFirestore.instance.batch();

  // Firebase collections
  String payments = isProduction ? 'Payments' : '7777 Payments';

  //Adders

  Future<String> addPurchaseToPayments(Purchase purchase, Bono bonoSelected) async {
    var uid = const Uuid().v4();
    await _firestore
    .collection(payments)
    .doc("Purchases")
    .collection("Purchases")
    .doc(uid)
    .set({
      "purchasedAt": purchase.purchasedAt!,
      "userId": purchase.userId,
      "brandId": purchase.brandId!,
      "bonoId": purchase.bonoId,
      "price": purchase.price, //bonoSelected.price
      "sessions": bonoSelected.sessions,
      "weeklySessions": bonoSelected.condition?.weeklySessions,
      "cancelTime": bonoSelected.condition?.cancelTime,
      "expirationTime": bonoSelected.condition?.expirationTime,
      "paymentMethod": purchase.paymentMethod,
    }).catchError((err) {
      print(err);
    });
    return uid;
  }

}
