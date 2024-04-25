import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/auth/models/auth_user.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/user/data/user_repository.dart';
import 'package:mamba/user/models/users/user.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'user_state.dart';

class UserBloc extends Cubit<UserState> {
  UserBloc({
    //required AnalyticsRepository analyticsRepository, TODO
    required UserRepository userRepository,
    //required ActivityRepository activityRepository, TODO
  })  : userId = '',
        //_analyticsRepository = analyticsRepository,
        _userRepository = userRepository,
        //_activityRepository = activityRepository,
        super(UserState(user: Usuario.empty));

  //final AnalyticsRepository _analyticsRepository;
  final UserRepository _userRepository;
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  //final ActivityRepository _activityRepository;
  String userId;
  StreamSubscription<Usuario>? _userSubscription;
  //StreamSubscription<List<GroupPreview>>? _groupsSubscription;
  //StreamSubscription<List<ActivityPreview>>? _activitiesSubscription;

  void initUser({required String userId}) {
    this.userId = userId;
    _userSubscription = _userRepository.getUserStream(uid: userId).listen(
      (user) async {
        if (state.user != user && user != AuthUser.empty) {
          List<Brand> brands =
              await _brandDataService.getAllBrandsFromUser(userId);
          user.brandID = brands[0].id!;
          emit(state.copyWith(user: user));
        }
      },
    );
  }

  void getUserAndBrand(String userId) async {
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

  void resetUser() {
    userId = '';
    _userSubscription?.cancel();
    _userSubscription = null;
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
