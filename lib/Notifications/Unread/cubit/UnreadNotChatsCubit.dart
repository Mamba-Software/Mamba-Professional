import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
part 'UnreadNotChatsState.dart';

class UnreadNotChatsCubit extends Cubit<List<int>> {

  final _userDataService = UserDataService();
  int unreadNot = 0;
  int unreadChat = 0;
  List<int> unreadList = <int>[0, 0];
  late StreamSubscription<List<int>> _combinedStreamSubscription;

  UnreadNotChatsCubit(final cubitAuth) : super([]) {
    unreadList.add(0);
    unreadList.add(0);
    emit(unreadList);
    Stream<List<int>> getCombinedUnreadStreams(String brandId) {
      return _userDataService.getCombinedUnreadStreams(currentUser.id!);
    }
    try {
      cubitAuth.stream.distinct().listen((state) {
        // Handle the state change
        if (!isExecuted && state is AuthUserBrand || state is AuthUserNoBrand || state is AuthNewUser) {
          isExecuted = true;
          _combinedStreamSubscription = getCombinedUnreadStreams(currentUser.id!).listen((querySnapshot) async {
            unreadNot = querySnapshot[0];
            unreadChat = querySnapshot[1];

            unreadList = [unreadNot, unreadChat]; // creating a new list instance
            emit(unreadList);

          });

        }
        else if(isExecuted) {
          _combinedStreamSubscription.cancel();
          isExecuted = false;
        }
      });
    }
    catch(e)
    {
      emit(unreadList);
    }
  }

  // Don't forget to cancel the subscription when the cubit is closed
  @override
  Future<void> close() {
    _combinedStreamSubscription.cancel();
    return super.close();
  }
}
