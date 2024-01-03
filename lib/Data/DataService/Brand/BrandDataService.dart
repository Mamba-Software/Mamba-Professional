import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/DataService/Brand/BrandFirebaseCalls.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Events/crud_events/models/Event.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Subscription.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'dart:io';
import '../../Models/Bono.dart';
import '../../Models/Condition.dart';
import '../../Models/Purchase.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class BrandDataService {

  final _firebase = BrandFirebaseCalls();

  // Check Data
  Future<bool> checkIfBrandExists(String brandId) => _firebase.checkIfBrandExists(brandId);
  Future<Brand?> checkUserIsBrandCreator(String userId) => _firebase.checkUserIsBrandCreator(userId);
  Future<bool> checkIfBrandBonoHasPurchases(String brandId, String bonoId) => _firebase.checkIfBrandBonoHasPurchases(brandId, bonoId);

  // Get Data
  Future<Brand> getBrandDetails(String brandId) => _firebase.getBrandDetails(brandId);
  Future<Brand> getBrandCoverDetails(String brandId) => _firebase.getBrandCoverDetails(brandId);
  Future<String> getBrandLogoUrl(String brandId) => _firebase.getBrandLogoUrl(brandId);
  Future<int> getBrandNumberRequests(String brandId) => _firebase.getBrandNumberRequests(brandId);
  Future<List<Usuario>> getBrandUsers(String brandId) => _firebase.getBrandUsers(brandId);
  Future<List<Usuario>> getBrandTrainers(String brandId) => _firebase.getBrandTrainers(brandId);
  Future<List<Usuario>> getBrandClients(String brandId) => _firebase.getBrandClients(brandId);
  Future<List<Brand>> getAllBrands() => _firebase.getAllBrands();
  Future<List<Brand>> getAllBrandsFromUser(String userId) => _firebase.getAllBrandsFromUser(userId);
  Future<List<ImageObject>> getBrandContentPictures(String brandId) => _firebase.getBrandContentPictures(brandId);
  Future<String> getRandomBrandPhoto(String brandId) => _firebase.getRandomBrandPhoto(brandId);
  Future<List<Bono>> getAllBonosFromBrandList(String brandId) => _firebase.getAllBonosFromBrandList(brandId);
  Future<Bono> getBonoInfo(String brandId, String bonoId) => _firebase.getBonoInfo(brandId, bonoId);
  Future<int> getUserBrandRole(String brandId, String userId) => _firebase.getUserBrandRole(brandId, userId);
  Future<List<Event>> getAllEventsFromBrandStats(String brandId) => _firebase.getAllEventsFromBrandStats(brandId);
  Future<List<Usuario>> getBrandUsersStats(String brandId) => _firebase.getBrandUsersStats(brandId);
  Future<List<Purchase>> getBrandPurchases(String brandId) => _firebase.getBrandPurchases(brandId);
  Future<List<Bono>> getAllBonosFromBrandStats(String brandId) => _firebase.getAllBonosFromBrandStats(brandId);
  Future<Subscription> getBrandSubscription(String brandId, String subscriptionId) => _firebase.getBrandSubscription(brandId, subscriptionId);

  // Add Data
  Future<String> addBrand(String name, File image, String description, List<double> workShift, int maxMembers, int bookingWindow) => _firebase.addBrand(name, image, description, workShift, maxMembers, bookingWindow);
  Future<void> addUserToBrand(String userId, String brandId, int role, [bool invitedDirectly = false]) => _firebase.addUserToBrand(userId, brandId, role, invitedDirectly);
  Future<void> addBrandContentPictureIndividual(String brandID, File image) => _firebase.addBrandContentPictureIndividual(brandID, image);
  Future<void> addBrandContentPictures(String brandID, List<File> images) => _firebase.addBrandContentPictures(brandID, images);
  Future<void> acceptRequestFromUser(RequestToBrand request) => _firebase.acceptRequestFromUser(request);
  Future<void> addBonoToBrand(String brandId, Bono bono, Condition condition) => _firebase.addBonoToBrand(brandId, bono, condition);
  Future<void> addBonoRequestToBrand(String brandId, String userId, String bonoId, String title, var price, var classes, Timestamp timeRequested) => _firebase.addBonoRequestToBrand(brandId, userId, bonoId, title, price, classes, timeRequested);

  // Update Data
  Future<void> updateBrandInfo(String brandID, String name,String description, int maxMembers, List<double> workShift, int bookingWindow, int bookingWindowMin, bool? directPurchase, bool? freeSession) => _firebase.updateBrandInfo(brandID, name, description, maxMembers, workShift, bookingWindow, bookingWindowMin, directPurchase, freeSession);
  Future<String> updateBrandPhoto(String brandID, File image) => _firebase.updateBrandPhoto(brandID, image);
  Future<void> updateBrandBaseImage(String brandID, ImageObject newBaseImage, String? oldBaseImage) => _firebase.updateBrandBaseImage(brandID, newBaseImage, oldBaseImage);
  Future<void> updateBrandBaseLocation(String brandID, String locationID) => _firebase.updateBrandBaseLocation(brandID, locationID);
  Future<void> updateBrandRoom(String brandID, String roomId) => _firebase.updateBrandRoom(brandID, roomId);
  Future<void> updateBono(String brandId, Bono bono, Condition condition) => _firebase.updateBono(brandId, bono, condition);
  Future<void> updateBonoCompras(String brandID, String bonoId) => _firebase.updateBonoCompras(brandID, bonoId);
  Future<void> updateBonoActive(String brandID, String bonoId, bool isActive) => _firebase.updateBonoActive(brandID, bonoId, isActive);
  Future<void> updateUserBrandRole(String userId, String brandId, int role) => _firebase.updateUserBrandRole(userId, brandId, role);
  Future<void> updateBrandPay(String brandID, int time, String subscriptionId, String title, DateTime endDate, bool revenueCatSub) => _firebase.updateBrandPay(brandID, time, subscriptionId, title, endDate, revenueCatSub);
  Future<void> updateBrandSubscriptionRevenueCat(String brandID, String? expiresDate, String? originalPurchaseDate, String? productPlanIdentifier, String? unsuscribedAT) => _firebase.updateBrandSubscriptionRevenueCat(brandID, expiresDate,  originalPurchaseDate, productPlanIdentifier, unsuscribedAT);

  // Delete Data
  Future<void> deleteBrand(String brandId) => _firebase.deleteBrand(brandId);
  Future<void> deleteUserFromBrand(String userId, String brandId) => _firebase.deleteUserFromBrand(userId, brandId);
  Future<void> deleteBrandContentPictures(String brandID, String imageId, String imageUrl) => _firebase.deleteBrandContentPictures(brandID, imageId, imageUrl);
  Future<void> deleteBrandCoverPicture(String brandID, String imageId, String imageUrl) => _firebase.deleteBrandCoverPicture(brandID, imageId, imageUrl);
  Future<void> deleteBrandUsers(String brandId) => _firebase.deleteBrandUsers(brandId);
  Future<void> deleteBrandEvents(String brandId) => _firebase.deleteBrandEvents(brandId);
  Future<void> deleteBrandLocations(String brandId) => _firebase.deleteBrandLocations(brandId);
  Future<void> deleteBrandBono(String brandId, String bonoId) => _firebase.deleteBrandBono(brandId, bonoId);
  Future<void> deleteBrandBonoRequest(String brandId, String userId, String? bonoRequestId) => _firebase.deleteBrandBonoRequest(brandId, userId, bonoRequestId);
  Future<void> deleteUserBrandBonos(String brandId, String userId) => _firebase.deleteUserBrandBonos(brandId, userId);

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // STREAMS

  // Users
  Stream<QuerySnapshot> getBrandTrainersStream(String brandId) => _firebase.getBrandTrainersStream(brandId);

  // Requests
  Stream<QuerySnapshot> getBrandRequestsStream(String brandId) => _firebase.getBrandRequestsStream(brandId);

  // Events
  Stream<QuerySnapshot> getAllEventsFromBrand(String brandId) => _firebase.getAllEventsFromBrand(brandId);

  // Bonos
  Stream<QuerySnapshot> getAllBonosFromBrand(String brandId) => _firebase.getAllBonosFromBrand(brandId);
  Stream<QuerySnapshot> getBonosRequestsFromBrand(String brandId) => _firebase.getBonosRequestsFromBrand(brandId);
  Stream<DocumentSnapshot> getBonoInfoStream(String brandId, String bonoId) => _firebase.getBonoInfoStream(brandId, bonoId);

  // Purchases
  Stream<QuerySnapshot> getBrandPurchasesStream(String brandId) => _firebase.getBrandPurchasesStream(brandId);

  //Subscription
  Stream<DocumentSnapshot> getBrandSubscriptionStream(String brandId) => _firebase.getBrandSubscriptionStream(brandId);

}