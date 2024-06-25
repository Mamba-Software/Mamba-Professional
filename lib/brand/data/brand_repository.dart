import 'package:mamba/brand/data/firebase_brand_service.dart';
import 'package:mamba/data/Models/Brand.dart';

class BrandRepository {
  final FirebaseBrandService _firebaseService;

  BrandRepository({
    FirebaseBrandService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseBrandService();

  Stream<Brand> getBrandStream({required String brandId}) {
    return _firebaseService.getBrandStream(brandId: brandId);
  }

  Future<bool> hasBrand({required String userId}) {
    return _firebaseService.hasBrand(userId: userId);
  }
}
