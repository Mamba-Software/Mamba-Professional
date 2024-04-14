// This class represents the Object <Event> that will be showed in the Calendar Widget.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

class Subscription {
  String? id;
  String? title;
  String? description;
  String? descriptionAdapted;
  Timestamp? startDate;
  Timestamp? endDate;
  bool? isActive;
  int? duration;
  String? promotion;
  String? subscriptionId;
  double? price;
  String? priceString;
  String? subscriptionPeriod;
  Package? package;
  bool? unsuscribed;


  Subscription({
    this.id,
    this.title,
    this.descriptionAdapted,
    this.startDate,
    this.endDate,
    this.isActive,
    this.duration,
    this.promotion,
    this.subscriptionId,
    this.price,
    this.priceString,
    this.subscriptionPeriod,
    this.description,
    this.package,
    this.unsuscribed
  });

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Subscription.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('title')) {
      title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('descriptionEsp')) {
      descriptionAdapted = documentSnapshot.get("descriptionEsp").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('descriptionCat')) {
      description = documentSnapshot.get("descriptionCat").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('subscriptionId')) {
      subscriptionId = documentSnapshot.get("subscriptionId").toString();
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('duration')) {
      duration = documentSnapshot.get("duration");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('startDate')) {
      startDate = documentSnapshot.get("startDate");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('endDate')) {
      endDate = documentSnapshot.get("endDate");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('isActive')) {
      isActive = documentSnapshot.get("isActive");
    } else {
      isActive = false;
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('promotion')) {
      promotion = documentSnapshot.get("promotion");
    }
    if ((documentSnapshot.data() as Map<String,dynamic>).containsKey('price')) {
      priceString = documentSnapshot.get("price").toString();
    }
  }

  Subscription.fromOfferingAllData(StoreProduct? storeProduct, String desc, Package _package ) {
    title = storeProduct?.title;
    description = storeProduct?.description;
    subscriptionId = storeProduct?.identifier;
    subscriptionPeriod = storeProduct?.subscriptionPeriod;
    descriptionAdapted = desc;
    price = storeProduct?.price;
    priceString = storeProduct?.priceString;
    package = _package;
  }

  Subscription.fromRevenueSubscription(var sub, String subId) {
    title = sub['product_plan_identifier'];
    description = sub['product_plan_identifier'];
    subscriptionId = subId;
    subscriptionPeriod = sub['product_plan_identifier'];
    endDate = Timestamp.fromDate(DateTime.parse(sub['expires_date']).toLocal());
    startDate = Timestamp.fromDate(DateTime.parse(sub['purchase_date']).toLocal());

    if(sub['unsubscribe_detected_at'] == null) {
      unsuscribed = false;
    }
    else {
      unsuscribed = true;
    }

  }
}