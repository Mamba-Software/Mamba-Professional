import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/brand/data/brand_repository.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Usuario.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
part 'brand_state.dart';

class BrandBloc extends Cubit<BrandState> {
  
  final UserBloc userBloc;
  StreamSubscription? userBlocSubscription;
  final BrandRepository _brandRepository;
  String brandId = ''; 
  Brand brand = Brand(); 
  String userId = '';
  StreamSubscription<Brand>? brandSubscription;

  final _brandDataService = BrandDataService();

  BrandBloc({
    required BrandRepository brandRepository,
    required this.userBloc,
  })  : _brandRepository = brandRepository,
        super(BrandState(brand: Brand())) {
    // Assuming Brand.empty() is a valid initializer for an empty Brand
    // Listen to changes in the UserBloc
    userBlocSubscription = userBloc.stream.listen((userState) {
      if (userState.user.id != '') {
        if (userState.user.brandID == '') {
          emit(state.copyWith(brand: Brand()));
        } else {
          // Assuming there is a UserAuthenticated state
          initBrand(
            brandId: userState.user.brandID!,
            userId: userState.user.id!,
          );
        } // Assuming user has a brandId attribute
      } else {
        resetBrand();
      }
    });
  }

  String get getBrandId => brandId;
  
  Brand get getBrand => brand;
  List<Usuario> get getBrandTrainers => [];

  void initBrand({required String brandId, required String userId}) {
    this.brandId = brandId;
    this.userId = userId;
    brandSubscription = _brandRepository.getBrandStream(brandId: brandId).listen(
      (brand) async {
        if (state.brand != brand && brand != Brand()) {
          await getBrandUser(brand.id!, userId);
          currentBrand.id = brand.id!;
          currentBrand.setBasicData = brand;
          currentBrand.brandActive = setBrandActive();
          emit(state.copyWith(brand: brand));
        }
      },
    );
  }

  Future<void> getBrandUser(String brandId, String userId) async {
    currentBrand.setUserList = await _brandDataService.getBrandUsers(brandId);

    int role = await _brandDataService.getUserBrandRole(brandId, userId);
    currentUser.setBrandRole = role;
    if (currentUser.id == currentBrand.adminID) {
      Purchases.logIn(currentBrand.id!);
    }
    mixpanel!.getPeople().set("Brands Roles", [role]);
  }

  void resetBrand() {
    brandId = '';
    brandSubscription?.cancel();
    brandSubscription = null;
  }

  @override
  Future<void> close() {
    brandSubscription?.cancel();
    return super.close();
  }
}
