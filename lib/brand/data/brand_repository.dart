import 'package:mamba/brand/data/firebase_brand_service.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/user/data/firebase_user_repository.dart';
import 'package:mamba/user/models/users/user.dart';

class BrandRepository {
  final FirebaseBrandService _firebaseService;

  BrandRepository({
    FirebaseBrandService? firebaseService,
  }) : _firebaseService = firebaseService ?? FirebaseBrandService();

  Stream<Brand> getBrandStream({required String uid}) {
    return _firebaseService.geBrandStream(uid: uid);
  }
}
