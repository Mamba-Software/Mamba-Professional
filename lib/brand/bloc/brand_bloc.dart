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
        super(const BrandInitial()) {
    initializeBrand();
  }

  // Getters
  Usuario get user => _userBloc.user;
  Brand get brand =>
      state is BrandLoaded ? (state as BrandLoaded).brand : Brand();
  List<Usuario> get getBrandTrainers => [];

  // Init Bloc Function
  void initializeBrand() {
    // Listen to changes in the UserBlocState
    userBlocStateSubscription = _userBloc.stream.listen((userState) {
      // Check User Is Loaded
      if (userState is UserLoaded) {
        // Get Brand Id
        String userId = userState.user.id!;
        String brandId = userState.user.brandId!;
        // Open Brand Subcription
        brandSubscription =
            _brandRepository.getBrandStream(brandId: brandId).listen(
          (Brand brand) async {
            // Load User Role
            int role = await getUserBrandRole(userId, brandId);
            currentUser.setBrandRole = role;
            // Purchases Role
            if (currentUser.id == currentBrand.adminID) {
              Purchases.logIn(currentBrand.id!);
            }
            // Define Current Brand
            brand.setUserList = await getBrandUsers(brandId);
            brand.brandActive = setBrandActive();
            // Emit Neww Brand State
            emit(BrandLoaded(brand: brand));

            // To Be Refactored
            // Global Vars CurrentUser and CurrentBrand should not be used
            updateCurrentUserGlobalVar(brand, role);
            // To Be Refactored
          },
        );
      }
    });
  }

  Future<int> getUserBrandRole(String userId, String brandId) async {
    int role = await _brandDataService.getUserBrandRole(brandId, userId);
    return role;
  }

  Future<List<Usuario>> getBrandUsers(String brandId) async {
    List<Usuario> brandUsers = await _brandDataService.getBrandUsers(brandId);
    return brandUsers;
  }

  void updateCurrentUserGlobalVar(Brand brand, int role) {
    // Update Current User
    currentBrand = brand;
    // Update Current User Role
    currentUser.brandRole = role;
  }

  void restoreBrand() {
    brandSubscription?.cancel();
    brandSubscription = null;
  }
}
