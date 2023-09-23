import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Auth/cubit/AuthCubit.dart';
import 'package:mamba_castelldefels/Data/DataService/User/UserDataService.dart';
import 'package:equatable/equatable.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
part 'UnreadNotChatsState.dart';

class UnreadNotChatsCubit extends Cubit<List<int>> {

  late StreamSubscription<QuerySnapshot> _subscription;
  final _userDataService = UserDataService();
  int unreadNot = 0;
  int unreadChat = 0;
  List<int> unreadList = <int>[0, 0];

  UnreadNotChatsCubit(final cubitAuth) : super([]) {
    unreadList.add(0);
    unreadList.add(0);
    emit(unreadList);
    Stream<int> getUnreadNotificationsUserStream(String brandId) {
      return _userDataService.getUnreadNotificationsUserStream(currentUser.id!);
    }
    Stream<int> getUnreadConversationsUserStream(String brandId) {
      return _userDataService.getUnreadConversationsUserStream(currentUser.id!);
    }
    try {
      cubitAuth.stream.distinct().listen((state) {
        // Handle the state change
        if (state is AuthUserBrand || state is AuthUserNoBrand || state is AuthNewUser) {
          getUnreadNotificationsUserStream(currentUser.id!).listen((querySnapshot) async {
            unreadNot = querySnapshot;
          });
          getUnreadConversationsUserStream(currentUser.id!).listen((querySnapshot) async {
            unreadChat = querySnapshot;
          });
          unreadList.add(unreadNot);
          unreadList.add(unreadChat);
          emit(unreadList);
        }
      });
    }
    catch(e)
    {
      emit(unreadList);
    }
  }
}
