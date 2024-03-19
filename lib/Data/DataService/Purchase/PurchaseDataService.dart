import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/data/DataService/Purchase/PurchaseFirebaseCalls.dart';
import 'package:mamba_castelldefels/data/Models/Bono.dart';
import 'package:mamba_castelldefels/data/Models/Brand.dart';
import 'package:mamba_castelldefels/data/Models/Purchase.dart';
import 'package:mamba_castelldefels/data/Models/Usuario.dart';
import 'package:mamba_castelldefels/events/crud_events/models/Event.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class PurchaseDataService {
  final _firebase = PurchaseFirebaseCalls();

  // Check Data
  Future<bool> checkIfEventInPurchase(String purchaseId, String eventId) =>
      _firebase.checkIfEventInPurchase(purchaseId, eventId);
  Future<String> checkIfUserHasActivePurchase(String userId, String eventId,
          List<String> selectedBonos, String brandId) =>
      _firebase.checkIfUserHasActivePurchase(
          userId, eventId, selectedBonos, brandId);

  // Get Data
  Future<Purchase> getPurchaseInfo(String purchaseId) =>
      _firebase.getPurchaseInfo(purchaseId);
  Future<List<Purchase>> getBrandPurchases(
          String brandId, DateTime startDate, DateTime endDate,
          [bool applyThreshold = false]) =>
      _firebase.getBrandPurchases(brandId, startDate, endDate, applyThreshold);
  Future<List<Purchase>> getBrandUserPurchases(
          String userId, String brandId, DateTime startDate, DateTime endDate,
          [bool applyThreshold = false]) =>
      _firebase.getBrandUserPurchases(
          userId, brandId, startDate, endDate, applyThreshold);
  Future<List<Purchase>> getBrandFirstPurchasesLimit(
          String brandId, int limit) =>
      _firebase.getBrandFirstPurchasesLimit(brandId, limit);
  Future<List<Purchase>> getBrandMorePurchasesLimit(
          String brandId, String purchaseId, int limit) =>
      _firebase.getBrandMorePurchasesLimit(brandId, purchaseId, limit);
  Future<List<Purchase>> getAllUserPurchasesFromBrand(
          String userId, String brandId) =>
      _firebase.getAllUserPurchasesFromBrand(userId, brandId);
  Future<Purchase> getPurchaseEvents(Purchase purchase) =>
      _firebase.getPurchaseEvents(purchase);
  Future<List<Event>> getPurchaseEventsLast30Days(
          Purchase purchase, String brandId) =>
      _firebase.getPurchaseEventsLast30Days(purchase, brandId);
  Future<List<Purchase>> getPurchasesByEventId(String eventId) =>
      _firebase.getPurchasesByEventId(eventId);
  Future<List<Usuario>> getUsersByBonosAndActivePurchase(
          List<String> selectedBonos, String brandId) =>
      _firebase.getUsersByBonosAndActivePurchase(selectedBonos, brandId);
  Future<List<Bono>> getBonosByBonosString(
          List<String> selectedBonos, String brandId) =>
      _firebase.getBonosByBonosString(selectedBonos, brandId);
  Future<List<dynamic>> getRecurrentPurchaseGroup(String purchaseGroupId) =>
      _firebase.getRecurrentPurchaseGroup(purchaseGroupId);

  // Add Data
  Future<String> addPurchase(
          Purchase purchase, Bono bonoSelected, Brand brand) =>
      _firebase.addPurchase(purchase, bonoSelected, brand);
  Future<void> addEventToPurchase(String purchaseId, String eventId) =>
      _firebase.addEventToPurchase(purchaseId, eventId);

  // Update Data
  Future<void> updateUserPurchaseSessions(String userId, String brandId,
          String purchaseId, int sessions, String bonoId) =>
      _firebase.updateUserPurchaseSessions(
          userId, brandId, purchaseId, sessions, bonoId);
  Future<void> updatePurchaseEvents(String purchaseId, String userId,
          List<Event> eventsToAdd, List<Event> eventsToDelete) =>
      _firebase.updatePurchaseEvents(
          purchaseId, userId, eventsToAdd, eventsToDelete);
  Future<void> updatePurchasePaymentStatus(String purchaseId, bool isPaid) =>
      _firebase.updatePurchasePaymentStatus(purchaseId, isPaid);

  // Delete Data
  Future<void> deletePurchase(String purchaseId, String userId, String brandId,
          String? purchaseGroupId) =>
      _firebase.detelePurchase(purchaseId, userId, brandId, purchaseGroupId);
  Future<void> deleteEventFromPurchase(String purchaseId, String eventId) =>
      _firebase.deleteEventFromPurchase(purchaseId, eventId);
  Future<void> deletedPurchaseUserFromEvent(Usuario user, String eventId) =>
      _firebase.deletedPurchaseUserFromEvent(user, eventId);

  /////////////////////////////////////////////////////////////////// STREAMS

  Stream<DocumentSnapshot> getPurchaseInfoStream(String purchaseId) =>
      _firebase.getPurchaseInfoStream(purchaseId);
  Stream<QuerySnapshot> getPurchaseEventsStream(String purchaseId) =>
      _firebase.getPurchaseEventsStream(purchaseId);
}
