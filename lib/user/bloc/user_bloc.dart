import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/auth/models/auth_user.dart';
import 'package:mamba/user/data/user_repository.dart';
import 'package:mamba/user/models/users/user.dart';

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
  //final ActivityRepository _activityRepository;
  String userId;
  StreamSubscription<Usuario>? _userSubscription;
  //StreamSubscription<List<GroupPreview>>? _groupsSubscription;
  //StreamSubscription<List<ActivityPreview>>? _activitiesSubscription;

  void initUser({required String userId}) {
    this.userId = userId;
    _userSubscription = _userRepository.getUserStream(uid: userId).listen(
      (user) {
        if (state.user != user && user != AuthUser.empty) {
          emit(state.copyWith(user: user));
        }
      },
    );
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
