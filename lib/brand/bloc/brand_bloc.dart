import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/brand/data/brand_repository.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
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

  
  String get getBrandId => brandId;

  
  void initBrand({required String brandId, required String userId}) {
    this.brandId = brandId;
    this.userId = userId;
    _brandSubscription = _brandRepository.getBrandStream(uid: brandId).listen(
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

  void avoidPayWall() {
    Brand brand = new Brand();
    brand = state.brand;
    emit(state.copyWith(brand: brand));
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
        if (userState.user.brandID == '') {
          emit(state.copyWith(brand: Brand()));
        } else {
          // Assuming there is a UserAuthenticated state
          initBrand(
              brandId: userState.user.brandID!, userId: userState.user.id!);
        } // Assuming user has a brandId attribute
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
