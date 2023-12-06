// This class represents the Object <Event> that will be showed in the Calendar Widget.

import 'package:cloud_firestore/cloud_firestore.dart';

class lPaymentMethod {
  String? id;
  String? name;

  lPaymentMethod({
    this.id,
    this.name,
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  lPaymentMethod.fromObjectAllData(
      String documentId, DocumentSnapshot documentSnapshot) {
    this.id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>).containsKey('name')) {
      this.name = documentSnapshot.get("name").toString();
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(lPaymentMethod paymentMethod) {
    this.id = paymentMethod.id;
    this.name = paymentMethod.name;
  }
}
