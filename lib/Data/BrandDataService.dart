import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
import 'dart:io';
import 'FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class BrandDataService {

  final _firebase = FirebaseDatabaseService();

  // Check Data
  Future<bool> checkIfBrandExists(String brandId) => _firebase.checkIfBrandExists(brandId);

  // Get Data
  Future<List<Brand>> getAllBrands() => _firebase.getAllBrands();
  Future<List<Brand>> getAllBrandsFromUser(String userId) => _firebase.getAllBrandsFromUser(userId);
  Future<Brand> getBrandDetails(String brandId) => _firebase.getBrandDetails(brandId);
  Future<Brand> getBrandCoverDetails(String brandId) => _firebase.getBrandCoverDetails(brandId);
  Future<List<Usuario>> getBrandUsers(String brandId) => _firebase.getBrandUsers(brandId);

  // Add Data
  Future<String> addBrand(String name, File image, String description, List<double> workShift, int maxMembers) => _firebase.addBrand(name, image, description, workShift, maxMembers);
  Future<void> addUserToBrand(String userId, String brandId, int role) => _firebase.addUserToBrand(userId, brandId, role);
  Future<void> acceptRequestFromUser(RequestToBrand request) => _firebase.acceptRequestFromUser(request);

  // Update Data
  Future<void> updateBrandInfo(String brandID, String name,String description, int maxMembers, List<double> workShift) => _firebase.updateBrandInfo(brandID, name, description, maxMembers, workShift);
  Future<String> updateCurrentBrandPhoto(String brandID, File image) => _firebase.updateCurrentBrandPhoto(brandID, image);
  Future<void> updateBrandBaseLocation(String brandID, String locationID) => _firebase.updateBrandBaseLocation(brandID, locationID);

  // Delete Data
  Future<void> deleteUserFromBrand(String userId, String brandId) => _firebase.deleteUserFromBrand(userId, brandId);
  Future<void> deleteBrandUsers(String brandId) => _firebase.deleteBrandUsers(brandId);

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // STREAMS

  // Requests
  Stream<QuerySnapshot> getBrandRequests(String brandId) => _firebase.getBrandRequests(brandId);

  // Events
  Stream<QuerySnapshot> getAllEventsFromBrand(String brandId) => _firebase.getAllEventsFromBrand(brandId);

}