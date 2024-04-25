import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/auth/models/auth_user.dart';
import 'package:mamba/brand/data/brand_repository.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
import 'package:mamba/user/data/user_repository.dart';
import 'package:mamba/user/models/users/user.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'brand_state.dart';

class BrandBloc extends Cubit<BrandState> {
  final UserBloc userBloc;
  StreamSubscription? userBlocSubscription;
  final BrandRepository _brandRepository;
  String brandId = '';
  String userId = '';
  StreamSubscription<Brand>? _brandSubscription;

  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();

  void initBrand({required String brandId, required String userId}) {
    this.brandId = brandId;
    this.userId = userId;
    _brandSubscription = _brandRepository.getBrandStream(uid: brandId).listen(
      (brand) async {
        if (state.brand != brand && brand != Brand()) {
          getBrandUser(state.brand.id!, userId);
          emit(state.copyWith(brand: brand));
        }
      },
    );
  }

  void getBrandUser(String brandId, String userId) async {
    // Get User Main Data
    currentUser.setBasicData = await _userDataService.getUserDetails(userId);
    // Get User Brand
    List<Brand> brands = await _brandDataService.getAllBrandsFromUser(userId);
    currentUser.setBrandList = brands;
    if (currentUser.brandsList.isNotEmpty) {
      // Setting the Brand to the User
      hasBrand = true;
      Brand brand = currentUser.brandsList[0];
      currentBrand.setBasicData =
          await _brandDataService.getBrandDetails(brand.id!);
      currentBrand.setUserList =
          await _brandDataService.getBrandUsers(brand.id!);

      // Get Role in Brand
      int role =
          await _brandDataService.getUserBrandRole(brand.id!, currentUser.id!);
      currentUser.setBrandRole = role;
      if (currentUser.id == currentBrand.adminID) {
        Purchases.logIn(currentBrand.id!);
      }
      mixpanel!.getPeople().set("Brands Roles", [role]);
      setBrandActive();
    }
  }

  void resetBrand() {
    brandId = '';
    _brandSubscription?.cancel();
    _brandSubscription = null;
  }

  BrandBloc({
    //required AnalyticsRepository analyticsRepository, TODO
    required BrandRepository brandRepository,
    required this.userBloc,
    //required ActivityRepository activityRepository, TODO
  })  : _brandRepository = brandRepository,
        super(BrandState(brand: Brand())) {
    // Assuming Brand.empty() is a valid initializer for an empty Brand

    // Listen to changes in the UserBloc
    userBlocSubscription = userBloc.stream.listen((userState) {
      if (userState.user.id != '') {
        // Assuming there is a UserAuthenticated state
        initBrand(
            brandId: userState.user.brandID!,
            userId:
                userState.user.id!); // Assuming user has a brandId attribute
      } else {
        resetBrand();
      }
    });

    //final AnalyticsRepository _analyticsRepository;

    //final ActivityRepository _activityRepository;
    //StreamSubscription<List<GroupPreview>>? _groupsSubscription;
    //StreamSubscription<List<ActivityPreview>>? _activitiesSubscription;

    @override
    Future<void> close() {
      _brandSubscription?.cancel();
      return super.close();
    }
  }
}
