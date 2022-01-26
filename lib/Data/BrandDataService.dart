import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba_castelldefels/Models/Brand.dart';
import 'package:mamba_castelldefels/Models/RequestToBrand.dart';
import 'package:mamba_castelldefels/Models/Usuario.dart';
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
  Future<void> addUserToBrand(String userId, String brandId, int role) => _firebase.addUserToBrand(userId, brandId, role);

  // Update Data
  Future<void> acceptRequestFromUser(RequestToBrand request) => _firebase.acceptRequestFromUser(request);

  // Delete Data
  Future<void> deleteUserFromBrand(String userId, String brandId) => _firebase.deleteUserFromBrand(userId, brandId);
  Future<void> deleteBrandUsers(String brandId) => _firebase.deleteBrandUsers(brandId);

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
  // STREAMS
  
  Stream<QuerySnapshot> getBrandRequests(String brandId) => _firebase.getBrandRequests(brandId);

}