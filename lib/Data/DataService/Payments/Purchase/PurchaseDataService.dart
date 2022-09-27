import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/DataService/Payments/Purchase/PurchaseFirebaseCalls.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class PurchaseDataService {

  final _firebase = PurchaseFirebaseCalls();

  // Check Data

  // Get Data
  Future<Purchase> getPurchaseInfo(String? purchaseId) => _firebase.getPurchaseInfo(purchaseId);

  // Add Data

  // Update Data

  // Delete Data

  /////////////////////////////////////////////////////////////////// STREAMS

  Stream<DocumentSnapshot> getPurchaseInfoStream(String purchaseId) => _firebase.getPurchaseInfoStream(purchaseId);

}