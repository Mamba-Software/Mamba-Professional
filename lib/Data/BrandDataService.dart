import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'FirebaseDatabaseService.dart';

// This class gives access to all of the Firebase Backend. This is the Data provider for the UI.
class BrandDataService {

  final _firebase = FirebaseDatabaseService();

  // Check Data
  Future<bool> checkIfBrandExists(String brandID) => _firebase.checkIfBrandExists(brandID);

  // Get Data
  Future<Brand> getBrandDetails(String brandID) => _firebase.getBrandDetails(brandID);
  Future<Brand> getBrandCoverDetails(String brandID) => _firebase.getBrandCoverDetails(brandID);
  Stream<QuerySnapshot> getBrandRequests(String brandID) => _firebase.getBrandRequests(brandID);

  // Add Data
  Future<void> addUserToBrand(String userId, String brandId, int role) => _firebase.addUserToBrand(userId, brandId, role);

  // Update Data
  Future<void> acceptRequestFromUser(RequestToBrand request) => _firebase.acceptRequestFromUser(request);

  // Delete Data
  Future<void> deleteUserFromBrand(String userId, String brandId) => _firebase.deleteUserFromBrand(userId, brandId);
  Future<void> deleteBrandUsers(String brandId) => _firebase.deleteBrandUsers(brandId);

}