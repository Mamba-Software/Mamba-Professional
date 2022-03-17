import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Data/Models/Brand.dart';
import 'package:mamba_castelldefels/Data/Models/ImageObject.dart';
import 'package:mamba_castelldefels/Data/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Data/Models/Usuario.dart';
import 'dart:io';
import 'FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class BrandDataService {

  final _firebase = FirebaseDatabaseService();

  // Check Data
  Future<bool> checkIfBrandExists(String brandId) => _firebase.checkIfBrandExists(brandId);
  Future<Brand?> checkUserIsBrandCreator(String userId) => _firebase.checkUserIsBrandCreator(userId);

  // Get Data
  Future<Brand> getBrandDetails(String brandId) => _firebase.getBrandDetails(brandId);
  Future<Brand> getBrandCoverDetails(String brandId) => _firebase.getBrandCoverDetails(brandId);
  Future<String> getBrandLogoUrl(String brandId) => _firebase.getBrandLogoUrl(brandId);
  Future<List<Usuario>> getBrandUsers(String brandId) => _firebase.getBrandUsers(brandId);
  Future<List<Usuario>> getBrandTrainers(String brandId) => _firebase.getBrandTrainers(brandId);
  Future<List<Usuario>> getBrandClients(String brandId) => _firebase.getBrandClients(brandId);
  Future<List<Brand>> getAllBrands() => _firebase.getAllBrands();
  Future<List<Brand>> getAllBrandsFromUser(String userId) => _firebase.getAllBrandsFromUser(userId);
  Future<List<ImageObject>> getBrandContentPictures(String userId) => _firebase.getBrandContentPictures(userId);

  // Add Data
  Future<String> addBrand(String name, File image, String description, List<double> workShift, int maxMembers) => _firebase.addBrand(name, image, description, workShift, maxMembers);
  Future<void> addUserToBrand(String userId, String brandId, int role) => _firebase.addUserToBrand(userId, brandId, role);
  Future<void> addBrandContentPictures(String brandID, List<File> images) => _firebase.addBrandContentPictures(brandID, images);
  Future<void> acceptRequestFromUser(RequestToBrand request) => _firebase.acceptRequestFromUser(request);
  Future<void> addBonoToBrand(String brandId, String title, String description, var price, var classes, bool isactive) => _firebase.addBonoToBrand(brandId, title, description, price, classes, isactive);
  Future<void> addBonoRequestToBrand(String brandId, String userId, String bonoId, String title, var price, var classes) => _firebase.addBonoRequestToBrand(brandId, userId, bonoId, title, price, classes);

  // Update Data
  Future<void> updateBrandInfo(String brandID, String name,String description, int maxMembers, List<double> workShift) => _firebase.updateBrandInfo(brandID, name, description, maxMembers, workShift);
  Future<String> updateBrandPhoto(String brandID, File image) => _firebase.updateBrandPhoto(brandID, image);
  Future<void> updateBrandBaseLocation(String brandID, String locationID) => _firebase.updateBrandBaseLocation(brandID, locationID);
  Future<void> updateBrandRoom(String brandID, String roomId) => _firebase.updateBrandRoom(brandID, roomId);
  Future<void> updateBono(String brandID, String bonoId, bool isActive) => _firebase.updateBono(brandID, bonoId, isActive);

  // Delete Data
  Future<void> deleteBrand(String brandId) => _firebase.deleteBrand(brandId);
  Future<void> deleteUserFromBrand(String userId, String brandId) => _firebase.deleteUserFromBrand(userId, brandId);
  Future<void> deleteBrandContentPictures(String brandID, String imageId) => _firebase.deleteBrandContentPictures(brandID, imageId);
  Future<void> deleteBrandUsers(String brandId) => _firebase.deleteBrandUsers(brandId);
  Future<void> deleteBrandEvents(String brandId) => _firebase.deleteBrandEvents(brandId);
  Future<void> deleteBrandLocations(String brandId) => _firebase.deleteBrandLocations(brandId);
  Future<void> deleteBrandBonoRequest(String brandId, String bonoId) => _firebase.deleteBrandBonoRequest(brandId ,bonoId);

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // STREAMS

  // Requests
  Stream<QuerySnapshot> getBrandRequests(String brandId) => _firebase.getBrandRequests(brandId);

  // Events
  Stream<QuerySnapshot> getAllEventsFromBrand(String brandId) => _firebase.getAllEventsFromBrand(brandId);
  Stream<QuerySnapshot> getAllBonosFromBrand(String brandId) => _firebase.getAllBonosFromBrand(brandId);

}