import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba/data/DataService/User/UserDataService.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba/commons/constants/GlobalVars.dart';
import 'package:mamba/user/bloc/user_bloc.dart';
part 'UnreadNotChatsState.dart';

class UnreadNotChatsCubit extends Cubit<List<int>> {
  final _userDataService = UserDataService();
  int unreadNot = 0;
  int unreadChat = 0;
  List<int> unreadList = <int>[0, 0];
  late StreamSubscription<List<int>> _combinedStreamSubscription;

  UnreadNotChatsCubit(final UserBloc userBloc) : super([]) {
    unreadList.add(0);
    unreadList.add(0);
    emit(unreadList);
    Stream<List<int>> getCombinedUnreadStreams(String brandId) {
      return _userDataService.getCombinedUnreadStreams(currentUser.id!);
    }

    try {
      userBloc.stream.distinct().listen((state) {
        // Handle the state change
        if (!isExecuted && state.user.id != null && state.user.id != '') {
          //TODO COMPROBAR QUE HI HAGI USUARI
          isExecuted = true;
          _combinedStreamSubscription =
              getCombinedUnreadStreams(currentUser.id!)
                  .listen((querySnapshot) async {
            unreadNot = querySnapshot[0];
            unreadChat = querySnapshot[1];

            unreadList = [
              unreadNot,
              unreadChat
            ]; // creating a new list instance
            emit(unreadList);
          });
        } else if (isExecuted) {
          _combinedStreamSubscription.cancel();
          isExecuted = false;
        }
      });
    } catch (e) {
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
