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
  // Data Repositories
  final BrandRepository _brandRepository;

  // State Blocs
  final UserBloc _userBloc;

  // Other Vars
  StreamSubscription? userBlocStateSubscription;
  StreamSubscription<Brand>? brandSubscription;

  final _brandDataService = BrandDataService();

  BrandBloc({
    // Data Repositories
    required BrandRepository brandRepository,
    // State Blocs
    required UserBloc userBloc,
  })  : _brandRepository = brandRepository,
        _userBloc = userBloc,
        super(BrandState(brand: Brand())) {
    initializeBrand();
  }

  // Getters
  Usuario get user => _userBloc.user;
  Brand get brand => state.brand;
  List<Usuario> get getBrandTrainers => [];

  // Init Bloc Function
  void initializeBrand() {
    // Listen to changes in the UserBlocState
    userBlocStateSubscription = _userBloc.stream.listen((userState) {
      // Check User Is Loaded
      if (userState is UserLoaded) {
        // Get Brand Id
        String userId = userState.user.id!;
        String brandId = userState.user.brandID!;
        // Open Brand Subcription
        brandSubscription = _brandRepository.getBrandStream(brandId: brandId).listen(
          (Brand brand) async {
            if (state.brand != brand && brand != Brand()) {
              // Get Brand Users
              currentBrand.setUserList =
                  await _brandDataService.getBrandUsers(brandId);
              // Load Current Role
              int role = await _brandDataService.getUserBrandRole(brandId, userId);
              currentUser.setBrandRole = role;
              // Purchases Role
              if (currentUser.id == currentBrand.adminID) {
                Purchases.logIn(currentBrand.id!);
              }
              // Define Current Brand
              currentBrand.id = brand.id!;
              currentBrand.setBasicData = brand;
              currentBrand.brandActive = setBrandActive();
              // Emit Neww Brand State
              emit(state.copyWith(brand: brand));
            }
          },
        );
      } else {
        restoreBrand();
      }
    });
  }

  void restoreBrand() {
    brandSubscription?.cancel();
    brandSubscription = null;
  }
}
