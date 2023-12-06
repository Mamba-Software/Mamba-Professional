import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mamba_castelldefels/Globals/GlobalVars.dart';
import 'package:mamba_castelldefels/Globals/Styles/AppColors/AppColors.dart';
import 'package:mamba_castelldefels/Globals/Widgets/Components/Badges/CounterBadgeIcon.dart';
import 'package:mamba_castelldefels/Notifications/Unread/cubit/UnreadNotChatsCubit.dart';

Widget unreadNotifiactions(BuildContext context) {
  return BlocBuilder<UnreadNotChatsCubit, List<int>>(
      builder: (context, state) {
      return CounterBadgeIcon(
        counter: state[0],
        top: 5,
        right: 7,
        child: IconButton(
          icon: Icon(Icons.notifications, color: AppColors.white, size: MediaQuery.of(context).size.width*0.06),
          alignment: Alignment.center,
          padding: EdgeInsets.zero,
          onPressed: () => navigateToNotificationsScreen(context),
        ),
      );
    }
  );
}