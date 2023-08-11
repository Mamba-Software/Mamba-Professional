import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/BonoRequest.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';


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