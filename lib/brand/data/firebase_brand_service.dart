import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'dart:async';
class FirebaseBrandService {
  // Collections
  static final _brandsCollection = FirebaseFirestore.instance.collection('Brands');
  static final _brandDataService = BrandDataService();

  Stream<Brand> getBrandStream({required String brandId}) {
    return _brandsCollection.doc(brandId).snapshots().map((documentSnapshot) {
      // Assuming `Brand.fromObjectAllData` is a static method or similar
      // You need to return a new instance of Brand
      return Brand.fromObjectAllData(brandId, documentSnapshot);
    });
  }

  Future<bool> hasBrand({required String userId}) async {
    List<Brand> brands = await _brandDataService.getAllBrandsFromUser(userId);
    if (brands.isNotEmpty) {
      return true;
    }
    return false;
  }
}
