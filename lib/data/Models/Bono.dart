// This class represents the Object <Event> that will be showed in the Calendar Widget.
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Condition.dart';

class Bono {
  String? id;
  String? title;
  String? description;
  double? price;
  int? sessions;
  bool? isActive;
  int? compras;
  String? color;
  String? imageUrl;
  bool? isDegradate;
  double? opacity;
  Condition? condition = Condition(
    expirationTime: 0,
    cancelTime: 0,
    weeklySessions: 0,
  );
  // Ids
  String? purchaseId;
  String? brandId;
  bool? isRecurrent = false;
  String? priceId;

  Bono(
      {this.id,
      this.title,
      this.description,
      this.price,
      this.sessions,
      this.isActive,
      this.compras,
      this.color,
      this.imageUrl,
      this.isDegradate,
      this.opacity,
      this.condition,
      this.purchaseId,
      this.brandId,
      this.isRecurrent,
      this.priceId});

  //////////////////// CONSTRUCTORS ///////////////////////////////////////////////////////////////////////////////////////////

  Bono.fromObjectAllData(String documentId, DocumentSnapshot documentSnapshot) {
    id = documentId;
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('title')) {
      title = documentSnapshot.get("title").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('description')) {
      description = documentSnapshot.get("description").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('price')) {
      price = documentSnapshot.get("price").toDouble();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('sessions')) {
      sessions = documentSnapshot.get("sessions");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isActive')) {
      isActive = documentSnapshot.get("isActive");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('compras')) {
      compras = documentSnapshot.get("compras");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('color')) {
      color = documentSnapshot.get("color");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('imageUrl')) {
      imageUrl = documentSnapshot.get("imageUrl").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isDegradate')) {
      isDegradate = documentSnapshot.get("isDegradate");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('opacity')) {
      opacity = documentSnapshot.get("opacity");
    }
    // Conditions
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('expirationTime')) {
      condition!.expirationTime = documentSnapshot.get("expirationTime");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('cancelTime')) {
      condition!.cancelTime = documentSnapshot.get("cancelTime");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('weeklySessions')) {
      condition!.weeklySessions = documentSnapshot.get("weeklySessions");
    }
    // Purchases
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('purchaseId')) {
      purchaseId = documentSnapshot.get("purchaseId").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('brandId')) {
      brandId = documentSnapshot.get("brandId").toString();
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('isRecurrent')) {
      isRecurrent = documentSnapshot.get("isRecurrent");
    }
    if ((documentSnapshot.data() as Map<String, dynamic>)
        .containsKey('priceId')) {
      priceId = documentSnapshot.get("priceId");
    }
  }

  //////////////////// SETTERS ///////////////////////////////////////////////////////////////////////////////////////////

  // Set Basic Data
  set setBasicData(Bono bono) {
    id = bono.id;
    title = bono.title;
    description = bono.description;
    price = bono.price;
    sessions = bono.sessions;
    isActive = bono.isActive;
    compras = bono.compras;
    color = bono.color;
    imageUrl = bono.imageUrl;
    isDegradate = bono.isDegradate;
    opacity = bono.opacity;
    purchaseId = bono.purchaseId;
    brandId = bono.brandId;
    isRecurrent = bono.isRecurrent;
    priceId = bono.priceId;
  }

  // Set Basic Data
  set setBonoSessions(int sessions) {
    this.sessions = sessions;
  }

  // Set Price
  set setBonoPrice(double price) {
    this.price = price;
  }

  // Set Basic Data
  set setConditionsData(Condition condition) {
    this.condition = condition;
  }

  // Set Basic Data
  set setPurchaseId(String purchaseId) {
    this.purchaseId = purchaseId;
  }

  // Set Basic Data
  set setBrandId(String brandId) {
    this.brandId = brandId;
  }
}
