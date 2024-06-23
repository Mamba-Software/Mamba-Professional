import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/auth/models/auth_user.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/data/DataService/Brand/BrandDataService.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:mamba/data/Models/Brand.dart';
import 'package:mamba/data/Models/Subscription.dart';
import 'package:mamba/user/data/user_repository.dart';
import 'package:mamba/user/models/users/user.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

part 'subscription_state.dart';

class SubscriptionBloc extends Cubit<SubscriptionState> {
  SubscriptionBloc({
    //required AnalyticsRepository analyticsRepository, TODO
    required UserRepository userRepository,
    //required ActivityRepository activityRepository, TODO
  })  : userId = '',
        brandId = '',
        //_analyticsRepository = analyticsRepository,
        _userRepository = userRepository,
        //_activityRepository = activityRepository,
        super(SubscriptionState(subscription: Subscription()));

  //final AnalyticsRepository _analyticsRepository;
  final UserRepository _userRepository;
  final _userDataService = UserDataService();
  final _brandDataService = BrandDataService();
  //final ActivityRepository _activityRepository;
  String userId;
  String brandId;
  StreamSubscription<Subscription>? _userSubscription;
  //StreamSubscription<List<GroupPreview>>? _groupsSubscription;
  //StreamSubscription<List<ActivityPreview>>? _activitiesSubscription;

  void initUser({required String userId}) {
    return null;
    /*
    this.userId = userId;
    _userSubscription = _userRepository.getUserStream(uid: userId).listen(
      (subsription) async {
        if (state.subscription != subsription &&
            subsription != AuthUser.empty) {
          List<Brand> brands =
              await _brandDataService.getAllBrandsFromUser(userId);
          if (brands.isNotEmpty) {
            subsription.brandID = brands[0].id!;
            currentUser.setBrandList = brands;
            getBrandUser(userId, subsription.brandID!);
          } else {
            subsription.brandID = 'none';
          }
          currentUser.setBasicData =
              await _userDataService.getUserDetails(userId);

          brandId = subsription.brandID!;
          emit(state.copyWith(subsription: subsription));
        }
      },
    );*/
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
