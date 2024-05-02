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
        brandId = '',
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
  String brandId;
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
          if (brands.isNotEmpty) {
            user.brandID = brands[0].id!;
            currentUser.setBrandList = brands;
            getBrandUser(userId, user.brandID!);
          } else {
            user.brandID = 'none';
          }
          currentUser.setBasicData =
              await _userDataService.getUserDetails(userId);

          brandId = user.brandID!;
          emit(state.copyWith(user: user));
        }
      },
    );
  }

  Future<void> getBrandUser(String userId, String brandId) async {
    // Get Role in Brand
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
