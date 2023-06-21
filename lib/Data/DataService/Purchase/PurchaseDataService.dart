import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/DataService/Purchase/PurchaseFirebaseCalls.dart';
import 'package:mamba_castelldefels/Data/Models/Bono.dart';
import 'package:mamba_castelldefels/Data/Models/Purchase.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class PurchaseDataService {

  final _firebase = PurchaseFirebaseCalls();

  // Check Data
  Future<bool> checkIfEventInPurchase(String purchaseId, String eventId) => _firebase.checkIfEventInPurchase(purchaseId, eventId);

  // Get Data
  Future<Purchase> getPurchaseInfo(String purchaseId) => _firebase.getPurchaseInfo(purchaseId);
  Future<List<Purchase>> getAllUserPurchasesFromBrand(String userId, String brandId) => _firebase.getAllUserPurchasesFromBrand(userId, brandId);

  // Add Data
  Future<String> addPurchase(Purchase purchase, Bono bonoSelected) => _firebase.addPurchase(purchase, bonoSelected);
  Future<void> addEventToPurchase(String purchaseId, String eventId) => _firebase.addEventToPurchase(purchaseId, eventId);

  // Update Data

  // Delete Data
  Future<void> deleteEventFromPurchase(String purchaseId, String eventId) => _firebase.deleteEventFromPurchase(purchaseId, eventId);

  /////////////////////////////////////////////////////////////////// STREAMS

  Stream<DocumentSnapshot> getPurchaseInfoStream(String purchaseId) => _firebase.getPurchaseInfoStream(purchaseId);

}