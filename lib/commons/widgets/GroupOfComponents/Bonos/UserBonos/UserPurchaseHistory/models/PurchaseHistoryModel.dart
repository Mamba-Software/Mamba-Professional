import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba/data/Models/Bono.dart';
import 'package:mamba/data/Models/BonoRequest.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Purchase.dart';
import 'package:mamba/data/Models/Usuario.dart';

enum PurchaseStatus {
  CONFIRMED,
  TO_CONFIRM,
  DIRECT,
}

class PurchaseHistoryModel {
  Usuario user;
  Brand brand;
  Bono bono;
  BonoRequest? bonoReq;
  Purchase? purchase;
  PurchaseStatus purchaseStatus;
  Timestamp purchasedAt;

  PurchaseHistoryModel({
    required this.user,
    required this.brand,
    required this.bono,
    required this.bonoReq,
    required this.purchase,
    required this.purchaseStatus,
    required this.purchasedAt,
  });
}
